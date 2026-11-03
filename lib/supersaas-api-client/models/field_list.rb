# frozen_string_literal: true

module Supersaas
  class FieldList < BaseModel
    attr_accessor :name, :type, :label, :advanced, :required
    attr_reader :spec

    def spec=(value)
      @spec = value.is_a?(Array) ? value.map { |item| parse_spec_item(item) } : value
    end

    private

    # Items arrive as JSON strings; anything else (or invalid JSON) is kept as is
    def parse_spec_item(item)
      item.is_a?(String) ? JSON.parse(item) : item
    rescue JSON::ParserError
      item
    end
  end
end
