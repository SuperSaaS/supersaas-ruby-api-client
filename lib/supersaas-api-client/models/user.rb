# frozen_string_literal: true

module Supersaas
  class User < BaseModel
    ROLES = [3, 4, -1].freeze

    attr_reader :form

    def form=(value)
      @form = if value.is_a?(Hash)
                Supersaas::Form.new(value)
              else
                value
              end
    end
  end
end
