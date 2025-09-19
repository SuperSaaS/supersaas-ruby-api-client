# frozen_string_literal: true

require "test_helper"
require "stringio"
require "logger"

module Supersaas
  class HttpClientTest < SupersaasTest
    def setup
      @client = client_instance
    end

    def teardown
      @client = nil
    end

    # JSON response handling tests
    def test_json_body_symbolizes_keys
      response = create_mock_response('{"key": "value"}')

      result = @client.http_client.send(:json_body, response)

      assert_equal({ key: "value" }, result)
    end

    # Error logging tests
    def test_log_errors_handles_symbolized_keys
      io = StringIO.new
      logger = create_test_logger(io)
      client = create_client_with_logger(logger)
      body = { errors: [{ code: "123", title: "Test Error" }] }

      client.http_client.send(:log_errors, body)

      assert_logged_error(io, "123")
    end

    def test_log_errors_handles_string_keys
      io = StringIO.new
      logger = create_test_logger(io)
      client = create_client_with_logger(logger)
      body = { "errors" => [{ "code" => "456", "title" => "Test Error 2" }] }

      client.http_client.send(:log_errors, body)

      assert_logged_error(io, "456")
    end

    def test_log_errors_handles_mixed_key_types
      io = StringIO.new
      logger = create_test_logger(io)
      client = create_client_with_logger(logger)

      body_with_symbols = { errors: [{ code: "123", title: "Symbol Test" }] }
      body_with_strings = { "errors" => [{ "code" => "456", "title" => "String Test" }] }

      client.http_client.send(:log_errors, body_with_symbols)
      client.http_client.send(:log_errors, body_with_strings)

      output = io.string
      assert_match(/Error code: 123/, output)
      assert_match(/Error code: 456/, output)
    end

    # Data cleaning tests
    def test_delete_blank_values_removes_nil_and_empty_strings
      original = { a: 1, b: nil, c: "", d: "value" }

      result = @client.http_client.send(:delete_blank_values, original)

      assert_equal({ a: 1, d: "value" }, result)
    end

    def test_delete_blank_values_preserves_original_hash
      original = { a: 1, b: nil, c: "" }

      result = @client.http_client.send(:delete_blank_values, original)

      refute_same original, result
      assert_equal({ a: 1, b: nil, c: "" }, original)
    end

    def test_delete_blank_values_handles_empty_hash
      original = {}

      result = @client.http_client.send(:delete_blank_values, original)

      assert_equal({}, result)
      refute_same original, result
    end

    def test_retry_on_network_errors
      http = mock_http_with_timeout_error
      request = create_mock_request

      assert_raises(Supersaas::Exception) do
        @client.http_client.send(:execute_with_retries, http, request)
      end
    end

    def test_should_retry_logic
      client = @client.http_client

      # Should retry on first attempt
      assert client.send(:should_retry?, 1, Timeout::Error.new)

      # Should not retry after max attempts
      refute client.send(:should_retry?, 3, Timeout::Error.new)
    end

    def test_process_status_code_handles_all_error_codes
      client = @client.http_client
      mock_response = create_mock_response("error body")

      [400, 401, 403, 404, 405, 409, 422, 429, 501].each do |code|
        assert_raises(Supersaas::Exception) do
          client.send(:process_status_code, code, mock_response, {})
        end
      end
    end

    def test_handle_success_response_with_location_header
      response = mock_response_with_location
      body = { id: 123 }

      result = @client.http_client.send(:handle_success_response, response, body)

      assert_equal "https://www.supersaas.com/app/123", result
    end

    def test_http_client_initialization_with_custom_timeouts
      config = @client.configuration
      custom_timeouts = { open: 10, read: 30 }

      http_client = HttpClient.new(config, **custom_timeouts)

      assert_equal 10, http_client.instance_variable_get(:@timeouts)[:open]
      assert_equal 30, http_client.instance_variable_get(:@timeouts)[:read]
    end

    def test_json_body_handles_malformed_json
      original_level = @client.http_client.instance_variable_get(:@logger).level
      @client.http_client.instance_variable_get(:@logger).level = Logger::FATAL
      response = create_mock_response('{"invalid": json}')

      result = @client.http_client.send(:json_body, response)

      assert_equal({}, result)
    ensure
      @client.http_client.instance_variable_get(:@logger).level = original_level
    end

    def test_blank_value_detection
      client = @client.http_client

      assert client.send(:blank_value?, nil)
      assert client.send(:blank_value?, "")
      assert client.send(:blank_value?, {})
      refute client.send(:blank_value?, "value")
      refute client.send(:blank_value?, 0)
    end

    private

    def create_mock_response(body)
      Struct.new(:body).new(body)
    end

    def create_test_logger(io)
      logger = Logger.new(io)
      logger.level = Logger::DEBUG

      logger
    end

    def create_client_with_logger(logger)
      config = @client.configuration.dup
      Supersaas::Client.new(config, logger: logger)
    end

    def assert_logged_error(logger, error_code)
      assert_match(/Error code: #{error_code}/, logger.string)
    end

    def mock_http_with_timeout_error
      http = Minitest::Mock.new

      def http.request(_request)
        raise Timeout::Error
      end

      http
    end

    def create_mock_request
      Net::HTTP::Get.new("/test")
    end

    def mock_response_with_location
      response = Struct.new(:code, :body) do
        def [](key)
          key == "location" ? "https://www.supersaas.com/app/123" : nil
        end
      end
      response.new(200, "")
    end
  end
end