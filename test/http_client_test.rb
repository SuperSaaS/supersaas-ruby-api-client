# test/http_client_test.rb
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

    def test_json_body_symbolized_keys
      response = Struct.new(:body).new('{"key": "value"}')
      result = @client.http_client.send(:json_body, response)
      assert_equal({ key: "value" }, result)
    end

    def test_log_errors_handles_both_key_types
      io = StringIO.new
      logger = Logger.new(io)
      logger.level = Logger::DEBUG

      client = Supersaas::Client.new(@config, logger: logger)

      body_with_symbols = { errors: [{ code: "123", title: "Test" }] }
      body_with_strings = { "errors" => [{ "code" => "456", "title" => "Test2" }] }

      client.http_client.send(:log_errors, body_with_symbols)
      client.http_client.send(:log_errors, body_with_strings)

      output = io.string
      assert_match(/Error code: 123/, output)
      assert_match(/Error code: 456/, output)
    end

    def test_delete_blank_values_immutable
      original = { a: 1, b: nil, c: "" }
      result = @client.http_client.send(:delete_blank_values, original)

      refute_same original, result
      assert_equal({ a: 1, b: nil, c: "" }, original)
      assert_equal({ a: 1 }, result)
    end
  end
end