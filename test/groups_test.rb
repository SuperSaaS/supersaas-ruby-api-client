require 'test_helper'

module Supersaas
  class GroupsTest < SupersaasTest
    def setup
      @client = client_instance
    end

    def test_list
      refute_nil @client.groups.list
      assert_last_request_path "/api/groups.json"
    end
  end
end