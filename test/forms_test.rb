# frozen_string_literal: true

require "test_helper"

module Supersaas
  class FormsTest < SupersaasTest
    def setup
      @client = client_instance
      @super_form_id = 12_345
      @form_id = 67_890
    end

    def test_list
      from = Time.now
      refute_nil @client.forms.list(@super_form_id, from.strftime("%Y-%m-%d %H:%M:%S"))
      assert_last_request_path "/api/forms.json?form_id=#{@super_form_id}&#{URI.encode_www_form(from: from.strftime("%Y-%m-%d %H:%M:%S"))}"
    end

    def test_list_with_user_parameter
      from = Time.now
      user_id = 12345

      refute_nil @client.forms.list(@super_form_id, from.strftime("%Y-%m-%d %H:%M:%S"), user_id)
      assert_last_request_path "/api/forms.json?form_id=#{@super_form_id}&#{URI.encode_www_form(from: from.strftime("%Y-%m-%d %H:%M:%S"), user: user_id)}"
    end

    def test_list_with_limit_and_offset
      from = Time.now
      limit = 25
      offset = 50

      refute_nil @client.forms.list(@super_form_id, from.strftime("%Y-%m-%d %H:%M:%S"), nil, limit, offset)
      assert_last_request_path "/api/forms.json?form_id=#{@super_form_id}&#{URI.encode_www_form(from: from.strftime("%Y-%m-%d %H:%M:%S"), limit: limit, offset: offset)}"
    end

    def test_list_with_all_parameters
      from = Time.now
      user_id = 12345
      limit = 25
      offset = 50

      refute_nil @client.forms.list(@super_form_id, from.strftime("%Y-%m-%d %H:%M:%S"), user_id, limit, offset)
      expected_params = URI.encode_www_form(
        from: from.strftime("%Y-%m-%d %H:%M:%S"),
        user: user_id,
        limit: limit,
        offset: offset
      )
      assert_last_request_path "/api/forms.json?form_id=#{@super_form_id}&#{expected_params}"
    end

    def test_forms
      refute_nil @client.forms.forms
      assert_last_request_path "/api/super_forms.json"
    end

    def test_get
      refute_nil @client.forms.get(@form_id)
      assert_last_request_path "/api/forms.json?id=#{@form_id}"
    end

    def test_list_returns_form_objects
      result = @client.forms.list(@super_form_id)
      assert result.is_a?(Array)
      result.each do |form|
        assert form.is_a?(Supersaas::Form)
      end
    end

    def test_get_returns_form_object
      result = @client.forms.get(@form_id)
      assert result.is_a?(Supersaas::Form)
    end

    def test_forms_returns_super_form_objects
      result = @client.forms.forms
      assert result.is_a?(Array)
      result.each do |form|
        assert form.is_a?(Supersaas::SuperForm)
      end
    end
  end
end
