module Supersaas
  # REF: https://www.supersaas.com/info/dev/form_api
  class Forms < BaseApi
    def list(template_form_id, from_time=nil)
      path = "/forms"
      params = {
        form_id: validate_id(template_form_id),
        from: from_time ? validate_datetime(from_time) : nil
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
  end
end