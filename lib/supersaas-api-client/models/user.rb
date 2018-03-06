module Supersaas
  class User < BaseModel
    ROLES = [3, 4, -1]

    attr_accessor :address, :country, :created_on, :credit, :email, :field_1, :field_2, :fk, :full_name, :id, :mobile, :name, :phone, :role, :super_field
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