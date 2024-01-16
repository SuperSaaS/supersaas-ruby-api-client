module Supersaas
  class Groups < BaseApi
    def list
      path = "/groups"
      res = client.get(path)
      res.map { |attributes| Supersaas::Group.new(attributes) }
    end
  end
end