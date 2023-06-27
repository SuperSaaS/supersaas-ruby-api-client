module Supersaas
  class User < BaseModel
    ROLES = [3, 4, -1]

    attr_reader :form

    def form=(value)
      if value.is_a?(Hash)
        @form = Supersaas::Form.new(value)
      else
        @form = value
      end
    end
  end
end