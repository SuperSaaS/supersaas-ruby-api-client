# frozen_string_literal: true

module Supersaas
  class Appointment < BaseModel
    attr_accessor :field_1, :field_2, :field_2_r, :field_1_r, :country, :address, :mobile, :phone, :email, :price_cents,
                  :finish, :start, :service_name, :res_name, :id, :quantity, :status_message, :deleted,
                  :created_on, :slot_id, :created_by, :price, :status, :full_name, :super_field, :updated_by, :form_id,
                  :updated_on, :user_id, :waitlisted, :resource_id, :schedule_name, :schedule_id, :service_id

    attr_reader :form, :slot

    def form=(value)
      @form = value.is_a?(Hash) ? Supersaas::Form.new(value) : value
    end

    def slot=(value)
      @slot = value.is_a?(Hash) ? Supersaas::Slot.new(value) : value
    end
  end
end
