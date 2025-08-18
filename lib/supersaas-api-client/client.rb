# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require "logger"
require "timeout"

module Supersaas
  class Client
    class << self
      attr_accessor :configuration

      def reset_instance!
        Thread.current["SUPER_SAAS_CLIENT"] = nil
      end

      def instance(configuration = nil)
        Thread.current["SUPER_SAAS_CLIENT"] ||= new(configuration || Configuration.new)
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

      @rate_limiter = RateLimiter.new
      @http_client = HttpClient.new(@configuration, **options)
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

    %i[get post put delete].each do |method|
      define_method(method) do |path, params = {}, query = {}|
        params, query = {}, params if method == :get && query.empty? && !params.empty?
        request(method, path, params, query)
      end
    end

    private

    # Sends an HTTP request using the specified method, path, params, and query.

    def request(method, path, params = {}, query = {})
      rate_limiter.throttle
      req = http_client.request(method, path, params, query)
      @last_request = http_client.last_request
      req
    end
  end
end
