require 'test_helper'

module Supersaas
  class PromotionsTest < SupersaasTest
    def setup
      @client = client_instance
      @promotion_code = "abc123"
    end

    def test_promotion
      refute_nil @client.promotions.promotion(@promotion_code)
      assert_last_request_path "/api/promotions.json?promotion_code=abc123"
    end

    def test_list
      refute_nil @client.promotions.list
      assert_last_request_path "/api/promotions.json"
    end

    def test_duplicate_promotion_code
      refute_nil @client.promotions.duplicate_promotion_code("new123", @promotion_code)
      assert_last_request_path "/api/promotions.json?id=new123&template_code=abc123"
    end
  end
end