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

      # Max burst allowed without errors
      Client::MAX_REQUESTS.times do
        start_time = Time.now
        client.send(:throttle)
        end_time = Time.now
        elapsed_time = end_time - start_time
        assert_operator elapsed_time, :<, 0.1, "Expected no throttling, but got a delay of #{elapsed_time} seconds"
      end

      # Wait for window to reset
      sleep(Client::WINDOW_SIZE + 0.1) # Added a small buffer

      # Another burst of MAX_REQUESTS should now be allowed
      Client::MAX_REQUESTS.times do
        start_time = Time.now
        client.send(:throttle)
        end_time = Time.now
        elapsed_time = end_time - start_time
        assert_operator elapsed_time, :<, 0.1, "Expected no throttling, but got a delay of #{elapsed_time} seconds"
      end

      # Wait for window to expire and reset
      sleep(Client::WINDOW_SIZE + 0.1)

      # Test longer throttling so that we don't get massive self DDOS
      start_time = Time.now
      20.times do
        client.send(:throttle)
      end
      end_time = Time.now
      elapsed_time = end_time - start_time
      assert_operator elapsed_time, :<, 4.1, "Expected throttling, #{elapsed_time} seconds"
    end

    # 405 means "wrong schedule type" both ways: resources on a capacity schedule, slots on any other type
    def test_405_message_is_generic
      response = Struct.new(:body).new('{"errors":[{"status":"405"}]}')
      error = assert_raises(Supersaas::Exception) { @client.send(:handle_errors, 405, response) }
      assert_equal 'Not available for this schedule type', error.message
    end

    def test_ping
      @client.account_name = 'Test'
      @client.api_key = 'testing123'
      assert_equal true, @client.ping
      assert_equal 'GET', @client.last_request.method
      assert_equal '/api/ping.json', @client.last_request.path
    end

    # The messages are part of the released behaviour; status and errors are extra details
    def test_error_messages_unchanged
      {
        422 => 'HTTP Request Error: Unprocessable Content',
        400 => 'HTTP Request Error: Bad Request',
        401 => 'HTTP Request Error: Unauthorised',
        404 => 'HTTP Request Error: Not Found',
        501 => 'Not yet implemented for service type schedule',
        403 => 'Unauthorized',
        500 => 'HTTP Request Error: 500'
      }.each do |code, message|
        response = Struct.new(:body).new('')
        error = assert_raises(Supersaas::Exception) { @client.send(:handle_errors, code, response) }
        assert_equal message, error.message
        assert_equal code, error.status
        assert_equal [], error.errors
      end
    end

    def test_error_details
      response = Struct.new(:body).new('{"errors":[{"status":"404","title":"Not found"}]}')
      error = assert_raises(Supersaas::Exception) { @client.send(:handle_errors, 404, response) }
      assert_equal 'HTTP Request Error: Not Found', error.message
      assert_equal 404, error.status
      assert_equal [{ 'status' => '404', 'title' => 'Not found' }], error.errors
    end

    def test_error_details_not_json
      response = Struct.new(:body).new('<html>Bad gateway</html>')
      error = assert_raises(Supersaas::Exception) { @client.send(:handle_errors, 502, response) }
      assert_equal 'HTTP Request Error: 502', error.message
      assert_equal [], error.errors
    end

    def test_exception_without_details
      error = Supersaas::Exception.new('message')
      assert_equal 'message', error.message
      assert_nil error.status
      assert_equal [], error.errors
    end
  end
end
