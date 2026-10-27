# frozen_string_literal: true

module Supersaas
  # REF: https://www.supersaas.com/info/dev/information_api#groups
  class Groups < BaseApi
    def list
      path = '/groups'
      res = client.get(path)
      res.map { |attributes| Supersaas::Group.new(attributes) }
    end
  end
end
