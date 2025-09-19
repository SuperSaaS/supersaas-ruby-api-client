# frozen_string_literal: true

module Supersaas
  class RateLimiter
    WINDOW_SIZE = 1.freeze # seconds
    MAX_REQUESTS = 4.freeze
    TIMING_TOLERANCE = 0.001.freeze # For floating point comparisons

    def initialize
      @mutex = Mutex.new
      @request_times = []
    end

    def throttle
      @mutex.synchronize do
        now = current_time
        cleanup_old_requests(now)
        wait_if_rate_limited(now)
        record_request(now)
      end
    end

    private

    def current_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def cleanup_old_requests(now)
      @request_times.shift while @request_times.any? && now - @request_times.first >= WINDOW_SIZE
    end

    def wait_if_rate_limited(now)
      return unless @request_times.size >= MAX_REQUESTS

      # Recalculate after potential cleanup
      oldest_request = @request_times.first
      sleep_time = WINDOW_SIZE - (now - oldest_request)

      if sleep_time > 0
        sleep(sleep_time)
        # Update now after sleep and cleanup again
        updated_now = current_time
        cleanup_old_requests(updated_now)
      end
    end

    def record_request(now)
      @request_times << now
    end
  end
end
