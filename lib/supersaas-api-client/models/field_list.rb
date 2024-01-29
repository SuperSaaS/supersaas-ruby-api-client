# frozen_string_literal: true

module Supersaas
  class FieldList < BaseModel
    attr_accessor :name, :type, :label, :advanced
    attr_reader :spec

    def spec=(value)
      @spec = value.is_a?(Array) ? value.map { |attributes| JSON.parse(attributes) } : value
    end
  end
end
