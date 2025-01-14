# frozen_string_literal: true

require 'test_helper'
require 'time'

module Supersaas
  class ClientTest < SupersaasTest
    def setup
      config = Supersaas::Client::Configuration.new
      @client = Supersaas::Client.new(config)
      @client.dry_run = true
    end

    def test_api
      refute_nil @client.appointments
      refute_nil @client.forms
      refute_nil @client.schedules
      refute_nil @client.users
    end

    def test_request_methods
      @client.account_name = 'Test'
      @client.api_key = 'testing123'
      %i[get put post delete].each do |method|
        refute_nil @client.send(method, '/test')
        assert_equal method.to_s.upcase, @client.last_request.method
        assert_equal '/api/test.json', @client.last_request.path
      end
      assert_equal 'Basic VGVzdDp0ZXN0aW5nMTIz', @client.last_request['Authorization']
      assert_equal 'application/json', @client.last_request['Accept']
      assert_equal 'application/json', @client.last_request['Content-Type']
    end

    def test_instance_configuration
      Supersaas::Client.configure do |config|
        config.account_name = 'account'
        config.api_key = 'api_key'
        config.host = 'http://test'
        config.dry_run = true
        config.verbose = true
      end
      assert_equal 'account', Supersaas::Client.configuration.account_name
      assert_equal 'api_key', Supersaas::Client.configuration.api_key
      assert_equal 'http://test', Supersaas::Client.configuration.host
      assert_equal true, Supersaas::Client.configuration.dry_run
      assert_equal true, Supersaas::Client.configuration.verbose
    end

    def test_rate_limit
      return unless ENV['SSS_RUBY_RATE_LIMITER_TEST'] == 'true'

      client = Supersaas::Client.new
      client.account_name = 'test'
      client.api_key = 'test'
      client.dry_run = true

      start_time = Time.now

      # Make multiple requests
      5.times do
        client.get('/test')
      end

      end_time = Time.now
      elapsed_time = end_time - start_time

      assert_operator elapsed_time, :>=, 4.0, "Rate limiting should cause 5 requests to take at least 4 seconds, took #{elapsed_time}"
    end
  end
end
