# frozen_string_literal: true

module Supersaas
  # noinspection RubyTooManyInstanceVariablesInspection
  class Client
    class << self
      attr_accessor :configuration

      def reset_instance!
        Thread.current["SUPER_SAAS_CLIENT"] = nil
      end

      def instance(configuration = nil, **options)
        if configuration
          reset_instance!
        end
        Thread.current["SUPER_SAAS_CLIENT"] ||= new(configuration || Configuration.new, **options)
      end

      def user_agent
        "SSS/#{VERSION} Ruby/#{RUBY_VERSION} API/#{API_VERSION}"
      end
    end
    # The Client class provides a Ruby interface to the SuperSaaS API.

    attr_reader :configuration, :last_request, :rate_limiter, :http_client

    def initialize(configuration = nil, **options)
      @configuration = configuration || Configuration.new
      @configuration.validate!

      validate_options!(options)
      @rate_limiter = RateLimiter.new
      @http_client = HttpClient.new(@configuration, **options)
      reset_service_objects
    end

    def reload!(configuration: nil, **options)
      @configuration = configuration || @configuration
      @configuration.validate!

      validate_options!(options)
      @rate_limiter = RateLimiter.new
      @http_client = HttpClient.new(@configuration, **options)
      reset_service_objects
      self
    end

    def appointments
      @appointments ||= Appointments.new(self)
    end

    def forms
      @forms ||= Forms.new(self)
    end

    def schedules
      @schedules ||= Schedules.new(self)
    end

    def users
      @users ||= Users.new(self)
    end

    def promotions
      @promotions ||= Promotions.new(self)
    end

    def groups
      @groups ||= Groups.new(self)
    end

    def throttle
      rate_limiter.throttle
    end

    def get(path, query = {})
      request(:get, path, {}, query)
    end

    %i[post put delete].each do |method|
      define_method(method) do |path, params = {}, query = {}|
        request(method, path, params, query)
      end
    end


    private

    # Sends an HTTP request using the specified method, path, params, and query.

    def request(method, path, params = {}, query = {})
      rate_limiter.throttle
      resp = http_client.request(method, path, params, query)
      @last_request = http_client.last_request
      resp
    end

    def validate_options!(options)
      valid_keys = %i[timeout open_timeout read_timeout write_timeout retries logger verbose dry_run]
      invalid = options.keys - valid_keys
      raise ArgumentError, "Unknown options: #{invalid.join(", ")}" unless invalid.empty?
    end

    def reset_service_objects
      @appointments = @forms = @schedules = @users = @promotions = @groups = nil
    end
  end
end
