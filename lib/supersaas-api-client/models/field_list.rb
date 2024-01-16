module Supersaas
  class FieldList < BaseModel
    attr_accessor :name, :type, :label, :advanced
    attr_reader :spec

    def spec=(value)
      if value.is_a?(Array)
        @spec = value.map {|attributes| JSON.parse(attributes) }
      else
        @spec = value
      end
    end
  end
end
