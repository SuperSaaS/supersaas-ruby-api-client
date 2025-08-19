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
  end
end