# frozen_string_literal: true

module Supersaas
  class Promotions < BaseApi
    # REF: https://www.supersaas.com/info/dev/promotion_api
    def list(limit = nil, offset = nil)
      path = '/promotions'
      params = {}
      params.merge!(limit: validate_number(limit)) if limit
      params.merge!(offset: validate_number(offset)) if offset
      res = client.get(path, params)
      res.map { |attributes| Supersaas::Promotion.new(attributes) }
    end

    def promotion(promotion_code)
      path = '/promotions'
      query = { promotion_code: validate_promotion(promotion_code) }
      res = client.get(path, query)
      res.map { |attributes| Supersaas::Promotion.new(attributes) }
    end

    def duplicate_promotion_code(promotion_code, template_code)
      path = '/promotions'
      query = { id: validate_promotion(promotion_code), template_code: validate_promotion(template_code) }
      client.post(path, query)
    end
  end
end
