# frozen_string_literal: true

module Supersaas
  class Groups < BaseApi
    # REF: https://www.supersaas.com/info/dev/information_api#groups
    def list
      path = '/groups'
      res = client.get(path)
      res.map { |attributes| Supersaas::Group.new(attributes) }
    end
  end
end
