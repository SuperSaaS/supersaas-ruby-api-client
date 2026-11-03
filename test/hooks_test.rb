# frozen_string_literal: true

require 'test_helper'

module Supersaas
  class HooksTest < SupersaasTest
    def setup
      @client = client_instance
    end

    def test_create
      refute_nil @client.hooks.create('https://example.com/hook', 'U', 12_345)
      assert_equal 'POST', @client.last_request.method
      assert_last_request_path '/api/hooks.json'
      assert_equal({ 'target_url' => 'https://example.com/hook', 'event' => 'U', 'parent_id' => 12_345 },
                   JSON.parse(@client.last_request.body))
    end

    def test_create_requires_url
      assert_raises(Supersaas::Exception) { @client.hooks.create(nil, 'U', 12_345) }
    end

    def test_delete
      refute_nil @client.hooks.delete(67, 12_345)
      assert_equal 'DELETE', @client.last_request.method
      assert_last_request_path '/api/hooks.json?id=67&parent_id=12345'
    end
  end
end
