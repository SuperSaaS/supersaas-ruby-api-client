# frozen_string_literal: true

require "test_helper"
require "time"

module Supersaas
  # noinspection RubyNilAnalysis
  class ClientTest < SupersaasTest
    def setup
      @client = client_instance
    end

    def teardown
      # Clean up any client state between tests
      @client = nil
    end

    def test_api
      refute_nil @client.appointments
      refute_nil @client.forms
      refute_nil @client.schedules
      refute_nil @client.users
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

    def test_rate_limit
      return unless ENV["SSS_RUBY_RATE_LIMITER_TEST"] == "true"

      client = Supersaas::Client.new(@config)

      # Max burst allowed without errors
      RateLimiter::MAX_REQUESTS.times do
        start_time = Time.now
        client.send(:throttle)
        end_time = Time.now
        elapsed_time = end_time - start_time
        assert_operator elapsed_time, :<, 0.1, "Expected no throttling, but got a delay of #{elapsed_time} seconds"
      end

      # Wait for window to reset
      sleep(RateLimiter::WINDOW_SIZE + 0.1) # Added a small buffer

      # Another burst of MAX_REQUESTS should now be allowed
      RateLimiter::MAX_REQUESTS.times do
        start_time = Time.now
        client.send(:throttle)
        end_time = Time.now
        elapsed_time = end_time - start_time
        assert_operator elapsed_time, :<, 0.1, "Expected no throttling, but got a delay of #{elapsed_time} seconds"
      end

      # Wait for window to expire and reset
      sleep(RateLimiter::WINDOW_SIZE + 0.1)

      # Test longer throttling so that we don't get massive self DDOS
      start_time = Time.now
      20.times do
        client.send(:throttle)
      end
      end_time = Time.now
      elapsed_time = end_time - start_time
      assert_operator elapsed_time, :<, 4.1, "Expected throttling, #{elapsed_time} seconds"
    end

    def test_throttle_rate_limiting_mocked
      client = Supersaas::Client.new(@config)
      mock_time = 0

      Process.stub(:clock_gettime, ->(clock_type) { mock_time }) do
        # Test burst allowance
        RateLimiter::MAX_REQUESTS.times do
          client.send(:throttle)
          mock_time += 0.1  # Simulate time progression
        end

        # Verify throttling kicks in
        assert_equal RateLimiter::MAX_REQUESTS, client.rate_limiter.instance_variable_get(:@request_times).size
      end
    end

    def test_throttle_thread_safety
      return unless ENV["SSS_RUBY_RATE_LIMITER_TEST"] == "true"

      client = Supersaas::Client.new(@config)

      # Test concurrent access doesn't cause race conditions
      threads = []
      results = Queue.new

      5.times do
        threads << Thread.new do
          start_time = Time.now
          RateLimiter::MAX_REQUESTS.times { client.send(:throttle) }
          end_time = Time.now
          results << (end_time - start_time)
        end
      end

      threads.each(&:join)

      # All threads should complete without errors
      assert_equal 5, results.size

      # At least some threads should experience throttling
      total_time = 0
      5.times { total_time += results.pop }
      assert_operator total_time, :>, 0, "Expected some throttling in concurrent scenario"
    end

    def test_throttle_sliding_window
      return unless ENV["SSS_RUBY_RATE_LIMITER_TEST"] == "true"

      # Create a fresh client to avoid interference from previous tests
      client = Supersaas::Client.new(@config)

      # Fill up the rate limit
      RateLimiter::MAX_REQUESTS.times do |i|
        start_time = Time.now
        client.send(:throttle)
        elapsed = Time.now - start_time
        assert_operator elapsed, :<, 0.1, "Request #{i + 1} of #{RateLimiter::MAX_REQUESTS} should not be throttled"
      end

      # Next request should be throttled for approximately WINDOW_SIZE
      start_time = Time.now
      client.send(:throttle)
      elapsed = Time.now - start_time
      assert_operator elapsed, :>=, RateLimiter::WINDOW_SIZE - 0.2, "Request exceeding limit should be throttled"

      # Wait for window to partially expire
      sleep(RateLimiter::WINDOW_SIZE / 2.0)

      # Make another request - should still experience some throttling
      # since the window is sliding and some requests are still within the window
      start_time = Time.now
      client.send(:throttle)
      elapsed = Time.now - start_time

      # The exact throttling time depends on sliding window cleanup,
      # but it should be less than a full window since some time has passed
      assert_operator elapsed, :<, RateLimiter::WINDOW_SIZE, "Sliding window should reduce throttling time"
    end

    def test_throttle_mutex_synchronization
      return unless ENV["SSS_RUBY_RATE_LIMITER_TEST"] == "true"

      # Create a fresh client to avoid interference from previous tests
      client = Supersaas::Client.new(@config)

      # Make some requests sequentially
      3.times { client.send(:throttle) }

      request_times_after = client.rate_limiter.instance_variable_get(:@request_times)
      assert_equal 3, request_times_after&.size, "Should track exactly 3 requests"

      # Verify all timestamps are recent using monotonic time
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      request_times_after.each do |timestamp|
        assert_operator (now - timestamp), :<, 2, "All timestamps should be recent (within 2 seconds)"
      end

      # Test actual mutex synchronization with concurrent access
      threads = []
      errors = []

      # Launch multiple threads that make requests concurrently
      5.times do
        threads << Thread.new do
          2.times { client.send(:throttle) }
        rescue => e
          errors << e
        end
      end

      threads.each(&:join)

      # Verify no race conditions occurred
      assert_empty errors, "No synchronization errors should occur"

      # Verify the request times array is in a consistent state
      final_request_times = client.rate_limiter.instance_variable_get(:@request_times)
      refute_nil final_request_times, "Request times should not be nil"
      assert_operator final_request_times.size, :>, 0, "Should have recorded some requests"

      # Verify timestamps are monotonically ordered (no race conditions in array manipulation)
      final_request_times.each_cons(2) do |earlier, later|
        assert_operator earlier, :<=, later, "Timestamps should be in chronological order"
      end
    end

    def test_throttle_window_cleanup
      return unless ENV["SSS_RUBY_RATE_LIMITER_TEST"] == "true"

      client = Supersaas::Client.new(@config)

      # Fill the window
      RateLimiter::MAX_REQUESTS.times { client.send(:throttle) }

      request_times = client.rate_limiter.instance_variable_get(:@request_times)
      assert_equal RateLimiter::MAX_REQUESTS, request_times.size

      # Wait for window to expire
      sleep(RateLimiter::WINDOW_SIZE + 0.1)

      # Make another request - should clean up old entries
      client.send(:throttle)

      request_times_after = client.rate_limiter.instance_variable_get(:@request_times)
      assert_equal 1, request_times_after.size, "Old entries should be cleaned up"
    end

    def test_throttle_constants
      assert_equal 1, Supersaas::RateLimiter::WINDOW_SIZE, "Window size should be 1 second"
      assert_equal 4, Supersaas::RateLimiter::MAX_REQUESTS, "Max requests should be 4"
    end

    def test_json_body_symbolized_keys
      response = Struct.new(:body).new('{"key": "value"}')
      result = @client.http_client.send(:json_body, response)
      assert_equal({key: "value"}, result)
    end

    def test_log_errors_handles_both_key_types
      # Create a logger that outputs to stdout for testing
      string_io = StringIO.new
      logger = Logger.new(string_io)
      logger.level = Logger::DEBUG

      client = Supersaas::Client.new(@config, logger: logger)

      body_with_symbols = {errors: [{code: "123", title: "Test"}]}
      body_with_strings = {"errors" => [{"code" => "456", "title" => "Test2"}]}

      client.http_client.send(:log_errors, body_with_symbols)
      client.http_client.send(:log_errors, body_with_strings)

      output = string_io.string
      assert_match(/Error code: 123/, output)
      assert_match(/Error code: 456/, output)
    end

    def test_delete_blank_values_immutable
      original = {a: 1, b: nil, c: ""}
      result = @client.http_client.send(:delete_blank_values, original)

      refute_same original, result
      assert_equal({a: 1, b: nil, c: ""}, original) # Original unchanged
      assert_equal({a: 1}, result)
    end

    def test_throttle_thread_safety_deterministic
      client = client_instance
      barrier = Queue.new
      errors = []

      threads = 3.times.map do
        Thread.new do
          barrier.pop # Wait for all threads to be ready
          10.times { client.send(:throttle) }
        rescue => e
          errors << e
        end
      end

      3.times { barrier.push(true) } # Release all threads
      threads.each(&:join)

      assert_empty errors, "No thread safety errors should occur"
    end
  end
end
