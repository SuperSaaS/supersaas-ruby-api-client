module Supersaas
  # REF: https://www.supersaas.com/info/dev/form_api
  class Forms < BaseApi
    def forms(template_form_id, from_time=nil, user=nil)
      path = "/forms"
      params = {
        form_id: validate_id(template_form_id),
        from: from_time ? validate_datetime(from_time) : nil,
        user: user ? validate_user(user) : nil
      }
      res = client.get(path, params)
      res.map { |attributes| Supersaas::Form.new(attributes) }
    end

    def get(form_id)
      path = "/forms"
      params = {id: validate_id(form_id)}
      res = client.get(path, params)
      Supersaas::Form.new(res)
    end

    def list
      path = "/super_forms"
      res = client.get(path)
      res.map { |attributes| Supersaas::SuperForm.new(attributes) }
    end
  end
end