# frozen_string_literal: true

module Supersaas
  # REF: https://www.supersaas.com/info/dev/form_api
  class Forms < BaseApi
    def list(template_form_id, from_time = nil, user = nil)
      path = '/forms'
      params = { form_id: validate_id(template_form_id) }
      params.merge!(from: validate_datetime(from_time)) if from_time
      params.merge!(user: validate_user(user)) if user
      res = client.get(path, params)
      res.map { |attributes| Supersaas::Form.new(attributes) }
    end

    def get(form_id)
      path = '/forms'
      params = { id: validate_id(form_id) }
      res = client.get(path, params)
      Supersaas::Form.new(res)
    end

    def forms
      path = '/super_forms'
      res = client.get(path)
      res.map { |attributes| Supersaas::SuperForm.new(attributes) }
    end
  end
end
