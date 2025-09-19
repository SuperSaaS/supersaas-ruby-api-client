# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require "logger"
require "timeout"

module Supersaas
  class HttpClient
    DEFAULT_TIMEOUTS = {
      open: 5,
      read: 15,
      write: 10
    }.freeze

    NETWORK_ERRORS = [
      Timeout::Error, Errno::ECONNRESET, EOFError,
      Net::OpenTimeout, Net::ReadTimeout, Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError, Net::ProtocolError
    ].freeze

    attr_reader :last_request

    def initialize(configuration, logger: Logger.new($stderr), max_retries: 2, **timeouts)
      @config = configuration
      @logger = logger
      @max_retries = max_retries
      @timeouts = DEFAULT_TIMEOUTS.merge(timeouts)
    end

    def request(method, path, params = {}, query = {})
      validate_method!(method)

      uri = build_uri
      http = create_http_connection(uri)
      request = build_request(method, path, params, query)
      @last_request = request

      log_request(method, path, params) if @config.verbose
      return {} if @config.dry_run

      execute_with_retries(http, request)
    end

    private

    # Validation methods
    def validate_method!(method)
      valid_methods = %i[get post put delete]
      return if valid_methods.include?(method)

      raise Supersaas::Exception, "Invalid HTTP Method: #{method}. Only #{valid_methods.join(", ")} supported."
    end

    # URI and connection setup
    def build_uri
      host = @config.host&.empty? ? nil : @config.host
      host ||= Supersaas::Client.configuration&.host || Configuration::DEFAULT_HOST
      URI.parse(host)
    end

    def create_http_connection(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = @timeouts[:open]
      http.read_timeout = @timeouts[:read]
      http.write_timeout = @timeouts[:write] if http.respond_to?(:write_timeout)
      http
    end

    # Request building
    def build_request(method, path, params, query)
      clean_params = delete_blank_values(params)
      clean_query = delete_blank_values(query)
      full_path = build_path(path, clean_query)

      request = Net::HTTP.const_get(method.capitalize).new(full_path)
      configure_request(request, clean_params, method)
      request
    end

    def build_path(path, query)
      # Remove existing .json extension if present, then add it
      clean_path = path.sub(/\.json$/, '')
      full_path = "/api#{clean_path}.json"
      full_path += "?#{URI.encode_www_form(query)}" if query.any?
      full_path
    end

    def configure_request(request, params, method)
      set_request_headers(request)
      set_request_auth(request)
      set_request_body(request, params, method)
    end

    def set_request_headers(request)
      request["Accept"] = "application/json"
      request["Content-Type"] = "application/json"
      request["User-Agent"] = Client.user_agent
    end

    def set_request_auth(request)
      request.basic_auth(@config.account_name, @config.api_key)
    end

    def set_request_body(request, params, method)
      request.body = params.to_json unless method == :get
    end

    # Request execution and retry logic
    def execute_with_retries(http, request)
      attempts = 0

      begin
        attempts += 1
        response = http.request(request)
        handle_response(response)
      rescue *NETWORK_ERRORS => e
        retry if should_retry?(attempts, e)
        raise Supersaas::Exception, "HTTP Request Error: #{e.message}"
      end
    end

    def should_retry?(attempts, error)
      return false if attempts > @max_retries
      return true if NETWORK_ERRORS.any? { |err| error.is_a?(err) }
      return true if rate_limit_error?(error)

      false
    end

    def rate_limit_error?(error)
      error.is_a?(Supersaas::Exception) && error.message.include?("429")
    end

    # Response handling
    def handle_response(response)
      log_response(response) if @config.verbose

      code = response.code.to_i
      body = json_body(response)

      log_errors(body) if has_errors?(body)
      process_status_code(code, response, body)
    end

    def has_errors?(body)
      body[:errors] || body["errors"]
    end

    def process_status_code(code, response, body)
      case code
      when 200, 201 then handle_success_response(response, body)
      when 400 then raise Supersaas::Exception, "Bad Request (400)"
      when 401 then raise Supersaas::Exception, "Unauthorized (401)"
      when 403 then raise Supersaas::Exception, "Forbidden (403)"
      when 404 then raise Supersaas::Exception, "Not Found (404)"
      when 405 then raise Supersaas::Exception, "Not available for capacity type schedule (405)"
      when 409 then raise Supersaas::Exception, "Conflict (409)"
      when 422 then raise Supersaas::Exception, "Unprocessable Entity (422): #{response.body}"
      when 429 then raise Supersaas::Exception, "Too Many Requests (429)"
      when 501 then raise Supersaas::Exception, "Not yet implemented for service type schedule (501)"
      else raise Supersaas::Exception, "HTTP Request Error: #{code}"
      end
    end

    def handle_success_response(response, body)
      location = response["location"]
      location&.include?("www.supersaas.com") ? location : body
    end

    # Utility methods
    def json_body(response)
      return {} unless response.body&.size&.positive?

      JSON.parse(response.body, symbolize_names: true)
    rescue JSON::ParserError => e
      @logger.debug("Failed to parse JSON response: #{e.message}")
      {}
    end

    def delete_blank_values(hash)
      return hash unless hash

      cleaned = hash.reject { |_k, v| blank_value?(v) }
      cleaned.empty? && !hash.empty? ? {} : cleaned
    end

    def blank_value?(value)
      value.nil? || value == "" || (value.is_a?(Hash) && value.compact.empty?)
    end

    # Logging methods
    def log_errors(body)
      errors = body[:errors] || body["errors"]
      return unless errors.is_a?(Array)

      errors.each do |error|
        code = error[:code] || error["code"]
        title = error[:title] || error["title"]
        @logger.debug("Error code: #{code}, #{title}")
      end
    end

    def log_response(response)
      @logger.info "Response:"
      @logger.info response.inspect
      @logger.info response.body
      @logger.info "=============================="
    end

    def log_request(method, path, params)
      @logger.info "### SuperSaaS Client Request:"
      @logger.info "#{method} #{path}"
      @logger.info params.to_json
      @logger.info "------------------------------"
    end
  end
end