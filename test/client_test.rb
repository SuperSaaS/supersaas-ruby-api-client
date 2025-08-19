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

    # API service object tests
    def test_api_service_objects_exist
      refute_nil @client.appointments
      refute_nil @client.forms
      refute_nil @client.schedules
      refute_nil @client.users
      refute_nil @client.groups
      refute_nil @client.promotions
    end

    def test_service_object_memoization
      appointments = @client.appointments
      assert_equal appointments, @client.appointments

      forms = @client.forms
      assert_equal forms, @client.forms

      schedules = @client.schedules
      assert_equal schedules, @client.schedules
    end

    # Configuration tests
    def test_reload_configuration
      original_account = @client.configuration.account_name
      original_api_key = @client.configuration.api_key

      new_config = Configuration.new
      new_config.account_name = "NewAccount"
      new_config.api_key = "NewKey"

      @client.reload!(configuration: new_config)

      assert_equal "NewAccount", @client.configuration.account_name
      assert_equal "NewKey", @client.configuration.api_key
      refute_equal original_account, @client.configuration.account_name
      refute_equal original_api_key, @client.configuration.api_key
    end

    # HTTP method tests
    def test_http_methods_and_headers
      @client.configuration.account_name = "Test"
      @client.configuration.api_key = "testing123"

      %i[get put post delete].each do |method|
        result = @client.send(method, "/test")

        refute_nil result
        assert_equal method.to_s.upcase, @client.last_request.method
        assert_equal "/api/test.json", @client.last_request.path
      end

      verify_request_headers
    end

    def test_request_path_formatting
      @client.get("/test")
      assert_equal "/api/test.json", @client.last_request.path

     @client.get("/test.json")
      assert_equal "/api/test.json", @client.last_request.path
    end

    private

    def verify_request_headers
      assert_equal "Basic VGVzdDp0ZXN0aW5nMTIz", @client.last_request["Authorization"]
      assert_equal "application/json", @client.last_request["Accept"]
      assert_equal "application/json", @client.last_request["Content-Type"]
    end
  end
end