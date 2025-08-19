# test/client_test.rb
# frozen_string_literal: true

require "test_helper"

module Supersaas
  class ClientTest < SupersaasTest
    def setup
      @client = client_instance
    end

    def teardown
      @client = nil
    end

    def test_api
      refute_nil @client.appointments
      refute_nil @client.forms
      refute_nil @client.schedules
      refute_nil @client.users
    end

    def test_service_object_memoization
      appointments = @client.appointments
      assert_equal appointments, @client.appointments
    end

    def test_reload_configuration
      new_config = Configuration.new
      new_config.account_name = "NewAccount"
      new_config.api_key = "NewKey"

      @client.reload!(configuration: new_config)
      assert_equal "NewAccount", @client.configuration.account_name
      assert_equal "NewKey", @client.configuration.api_key
    end

    def test_request_methods
      @client.configuration.account_name = "Test"
      @client.configuration.api_key = "testing123"
      %i[get put post delete].each do |method|
        refute_nil @client.send(method, "/test")
        assert_equal method.to_s.upcase, @client.last_request.method
        assert_equal "/api/test.json", @client.last_request.path
      end
      assert_equal "Basic VGVzdDp0ZXN0aW5nMTIz", @client.last_request["Authorization"]
      assert_equal "application/json", @client.last_request["Accept"]
      assert_equal "application/json", @client.last_request["Content-Type"]
    end
  end
end