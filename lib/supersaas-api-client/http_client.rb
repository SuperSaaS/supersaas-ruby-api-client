# lib/supersaas-api-client/http_client.rb
module Supersaas
  class HttpClient
    DEFAULT_TIMEOUTS = {
      open: 5,
      read: 15,
      write: 10
    }.freeze

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

    def validate_method!(method)
      valid_methods = %i[get post put delete]
      return if valid_methods.include?(method)

      raise Supersaas::Exception, "Invalid HTTP Method: #{method}. Only #{valid_methods.join(", ")} supported."
    end

    def build_uri
      if @config.host && !@config.host.empty?
        URI.parse(@config.host)
      else
        URI.parse(Supersaas::Client.configuration&.host || Configuration::DEFAULT_HOST)
      end
      # host = @config.host.presence || Configuration::DEFAULT_HOST
      # URI.parse(host)
    end

    def create_http_connection(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = @timeouts[:open]
      http.read_timeout = @timeouts[:read]
      http.write_timeout = @timeouts[:write] if http.respond_to?(:write_timeout)
      http
    end

    def build_request(method, path, params, query)
      clean_params = delete_blank_values(params)
      clean_query = delete_blank_values(query)

      full_path = build_path(path, clean_query)
      request = Net::HTTP.const_get(method.capitalize).new(full_path)

      set_request_headers(request)
      set_request_auth(request)
      set_request_body(request, clean_params, method)

      request
    end

    def build_path(path, query)
      full_path = "/api#{path}.json"
      full_path += "?#{URI.encode_www_form(query)}" if query.any?
      full_path
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

    def execute_with_retries(http, request)
      attempts = 0
      begin
        attempts += 1
        response = http.request(request)
        handle_response(response)
      rescue *network_errors => e
        retry if should_retry?(attempts, e)
        raise Supersaas::Exception, "HTTP Request Error: #{e.message}"
      end
    end

    def network_errors
      [
        Timeout::Error, Errno::ECONNRESET, EOFError,
        Net::OpenTimeout, Net::ReadTimeout, Net::HTTPBadResponse,
        Net::HTTPHeaderSyntaxError, Net::ProtocolError
      ]
    end

    def should_retry?(attempts, _error)
      attempts <= @max_retries
    end

    def handle_response(response)
      log_response(response) if @config.verbose

      code = response.code.to_i
      body = json_body(response)

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
      if response["location"]&.include?("www.supersaas.com")
        response["location"]
      else
        body
      end
    end

    def handle_errors(code, body)
      log_errors(body)
      case code
      when 400
        raise Supersaas::Exception, "HTTP Request Error: Bad Request"
      when 501
        raise Supersaas::Exception, "Not yet implemented for service type schedule"
      when 405
        raise Supersaas::Exception, "Not available for capacity type schedule"
      else
        raise Supersaas::Exception, "HTTP Request Error: #{code}"
      end
    end

    def log_errors(body)
      errors = body[:errors] || body["errors"]
      return unless errors.is_a?(Array)

      errors.each do |error|
        code = error[:code] || error["code"]
        title = error[:title] || error["title"]
        @logger.debug("Error code: #{code}, #{title}")
      end
    end

    def json_body(res)
      return {} unless res.body&.size&.positive?

      JSON.parse(res.body, symbolize_names: true)
    rescue JSON::ParserError => e
      @logger.debug("Failed to parse JSON response: #{e.message}")
      {}
    end

    def delete_blank_values(hash)
      return hash unless hash

      hash.dup.delete_if { |_k, v| v.nil? || v == "" || (v.is_a?(Hash) && v.compact.empty?) }
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
