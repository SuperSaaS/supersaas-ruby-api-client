# frozen_string_literal: true

module Supersaas
  class RateLimiter
    WINDOW_SIZE = 1 # seconds
    MAX_REQUESTS = 4

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

      sleep_time = WINDOW_SIZE - (now - @request_times.first)
      sleep(sleep_time) if sleep_time > 0
      cleanup_old_requests(current_time)
    end

    def record_request(now)
      @request_times << now
    end
  end
end
