require 'test_helper'

module Supersaas
  class SchedulesTest < SupersaasTest
    def setup
      @client = client_instance
    end

    def test_list
      refute_nil @client.schedules.list
      assert_last_request_path "/api/schedules.json"
    end

    def test_resources
      refute_nil @client.schedules.resources(12345)
      assert_last_request_path "/api/resources.json?schedule_id=12345"
    end
  end
end