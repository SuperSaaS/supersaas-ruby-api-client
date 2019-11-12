require 'net/http'
require 'uri'
require 'json'

module Supersaas
  class Client
    class << self
      attr_accessor :configuration

      def configure
        self.configuration ||= Configuration.new
        yield(configuration)
      end

      def instance
        Thread.current['SUPER_SAAS_CLIENT'] ||= new(configuration || Configuration.new)
      end

      def user_agent
        "SSS/#{VERSION} Ruby/#{RUBY_VERSION} API/#{API_VERSION}"
      end
    end

    attr_accessor :account_name, :api_key, :host, :dry_run, :verbose
    attr_reader :last_request

    def initialize(configuration=nil)
      configuration = configuration || Configuration.new
      @account_name = configuration.account_name
      @api_key = configuration.api_key
      @host = configuration.host
      @dry_run = configuration.dry_run
      @verbose = configuration.verbose
    end

    def appointments; @appointments ||= Appointments.new(self); end
    def forms; @forms ||= Forms.new(self); end
    def schedules; @schedules ||= Schedules.new(self); end
    def users; @users ||= Users.new(self); end

    def get(path, query={})
      request(:get, path, {}, query)
    end

    def post(path, params={}, query={})
      request(:post, path, params, query)
    end

    def put(path, params={}, query={})
      request(:put, path, params, query)
    end

    def delete(path, params={}, query={})
      request(:delete, path, params, query)
    end

    private

    def request(http_method, path, params={}, query={})
      raise Supersaas::Exception.new("Account name not configured. Call `Supersaas::Client.configure`.") unless account_name && account_name.size
      raise Supersaas::Exception.new("Account api key not configured. Call `Supersaas::Client.configure`.") unless api_key && api_key.size

      uri = URI.parse(host)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'

      params = delete_blank_values params
      query = delete_blank_values query

      path = "/api#{path}.json"
      path += "?#{URI.encode_www_form(query)}" if query.keys.size > 0

      case http_method
      when :get
        req = Net::HTTP::Get.new(path)
      when :post
        req = Net::HTTP::Post.new(path)
        req.body = params.to_json
      when :put
        req = Net::HTTP::Put.new(path)
        req.body = params.to_json
      when :delete
        req = Net::HTTP::Delete.new(path)
        req.body = params.to_json
      else
        raise Supersaas::Exception.new("Invalid HTTP Method: #{http_method}. Only `:get`, `:post`, `:put`, `:delete` supported.")
      end

      req.basic_auth account_name, api_key

      req['Accept'] = 'application/json'
      req['Content-Type'] = 'application/json'
      req['User-Agent'] = self.class.user_agent

      if verbose
        puts "### SuperSaaS Client Request:"
        puts "#{http_method} #{path}"
        puts params.to_json
        puts "------------------------------"
      end

      @last_request = req
      return {} if dry_run

      begin
        res = http.request(req)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
        Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        raise Supersaas::Exception.new("HTTP Request Error (#{uri}#{path}): #{e.message}")
      end

      if verbose
        puts "Response:"
        puts res.body
        puts "=============================="
      end

      code = res.code.to_i
      case code
      when 200, 201
        json_body(res)
      when 422, 400
        json_body(res)
      when 401
        raise Supersaas::Exception.new("HTTP Request Error: Unauthorised")
      when 404
        raise Supersaas::Exception.new("HTTP Request Error: Not Found")
      else
        {}
      end
    end

    def json_body(res)
      begin
        res.body && res.body.size ? JSON.parse(res.body) : {}
      rescue JSON::ParserError
        {}
      end
    end

    def delete_blank_values(hash)
      return hash unless hash
      hash.delete_if do |k, v|
        v = v.delete_if { |k2, v2| v2.nil? } if (v.is_a?(Hash))
        v.nil? || v == ''
      end
    end

    class Configuration
      DEFAULT_HOST = 'https://www.supersaas.com'

      attr_accessor :account_name, :host, :api_key, :dry_run, :verbose

      def initialize
        @account_name = ENV['SSS_API_ACCOUNT_NAME']
        @api_key = ENV['SSS_API_KEY']
        @host = DEFAULT_HOST
        @dry_run = false
        @verbose = false
      end
    end
  end
end