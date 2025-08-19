# frozen_string_literal: true

require "test_helper"

module Supersaas
  class RateLimiterTest < SupersaasTest
    def setup
      @client = client_instance
    end

    # Basic rate limiting behavior tests
    def test_allows_max_requests_without_delay
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      RateLimiter::MAX_REQUESTS.times { @client.throttle }

      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
      assert_operator elapsed, :<, 0.05, "Should complete quickly within rate limit"
    end

    def test_throttles_when_exceeding_rate_limit
      RateLimiter::MAX_REQUESTS.times { @client.throttle }

      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      @client.throttle
      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time

      assert_operator elapsed, :>=, 0.9, "Should throttle for nearly full window"
      assert_operator elapsed, :<=, 1.1, "Should not over-throttle significantly"
    end

    # Request tracking tests
    def test_request_times_tracking
      initial_count = request_times_count

      @client.throttle
      assert_equal initial_count + 1, request_times_count

      @client.throttle
      assert_equal initial_count + 2, request_times_count
    end

    def test_cleanup_removes_only_expired_requests
      # Add some requests
      3.times { @client.throttle }
      assert_equal 3, request_times_count

      # Manually add an old timestamp to test cleanup
      old_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - (RateLimiter::WINDOW_SIZE + 1)
      request_times = @client.rate_limiter.instance_variable_get(:@request_times)
      request_times.unshift(old_time)

      # Trigger cleanup with new request
      @client.throttle

      # Should have removed the old timestamp but kept recent ones
      assert_equal 4, request_times_count, "Should keep recent requests and add new one"
    end

    # Thread safety tests
    def test_thread_safety_maintains_consistency
      request_count = 6
      threads = Array.new(3) do
        Thread.new { 2.times { @client.throttle } }
      end

      threads.each(&:join)

      final_count = request_times_count
      assert_operator final_count, :<=, request_count, "Should not exceed expected request count"
      assert_operator final_count, :>, 0, "Should have recorded some requests"

      # Verify timestamps are valid and ordered
      times = @client.rate_limiter.instance_variable_get(:@request_times)
      times.each_cons(2) do |earlier, later|
        assert_operator earlier, :<=, later, "Timestamps should be ordered"
        assert_kind_of Numeric, earlier
        assert_kind_of Numeric, later
      end
    end

    # Sliding window algorithm tests
    def test_sliding_window_calculation
      # Fill the limit
      RateLimiter::MAX_REQUESTS.times { @client.throttle }

      # Get the oldest request time for calculation
      oldest_time = @client.rate_limiter.instance_variable_get(:@request_times).first
      current_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      # Calculate expected wait time
      expected_wait = oldest_time + RateLimiter::WINDOW_SIZE - current_time

      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      @client.throttle
      actual_wait = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time

      assert_in_delta expected_wait, actual_wait, 0.1, "Should wait for calculated sliding window time"
    end

    def test_multiple_rapid_requests_spread_over_time
      total_requests = RateLimiter::MAX_REQUESTS * 2
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      total_requests.times { @client.throttle }

      total_elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
      minimum_expected = RateLimiter::WINDOW_SIZE # At least one full window

      assert_operator total_elapsed, :>=, minimum_expected - 0.1
      assert_operator request_times_count, :<=, RateLimiter::MAX_REQUESTS, "Should maintain window size"
    end

    # Configuration tests
    def test_rate_limiter_constants
      assert_equal 1, RateLimiter::WINDOW_SIZE
      assert_equal 4, RateLimiter::MAX_REQUESTS
      assert_instance_of Integer, RateLimiter::WINDOW_SIZE
      assert_instance_of Integer, RateLimiter::MAX_REQUESTS
    end

    private

    def request_times_count
      @client.rate_limiter.instance_variable_get(:@request_times)&.size || 0
    end
  end
end