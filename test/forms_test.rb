require 'test_helper'

module Supersaas
  class FormsTest < SupersaasTest
    def setup
      @client = client_instance
      @super_form_id = 12345
      @form_id = 67890
    end

    def test_list
      from = Time.now
      refute_nil @client.forms.list(@super_form_id, from)
      assert_last_request_path "/api/forms.json?form_id=#{@super_form_id}&#{URI.encode_www_form(from: from.strftime("%Y-%m-%d %H:%M:%S"))}"
    end

    def test_get
      refute_nil @client.forms.get(@form_id)
      assert_last_request_path "/api/forms.json?id=#{@form_id}"
    end
  end
end