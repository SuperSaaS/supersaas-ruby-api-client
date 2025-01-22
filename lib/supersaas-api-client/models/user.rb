# frozen_string_literal: true

module Supersaas
  class User < BaseModel
    ROLES = [3, 4, -1].freeze

    attr_reader :form
    attr_accessor :name, :email, :password, :full_name, :address, :mobile, :phone, :country, :timezone, :field_1,
                  :field_2, :super_field, :credit, :role, :group, :webhook, :id, :fk, :created_on, :updated_on

    def form=(value)
      @form = value.is_a?(Hash) ? Supersaas::Form.new(value) : value
    end
  end
end
