module Supersaas
  class Appointment < BaseModel
    attr_accessor :address, :country, :created_by, :created_on, :deleted, :description, :email, :field_1, :field_2, :field_1_r, :field_2_r, :finish, :form_id, :full_name, :id, :mobile, :name, :phone, :price, :res_name, :resource_id, :schedule_id, :schedule_name, :service_id, :service_name, :slot_id, :start, :status, :super_field, :updated_by, :updated_on, :user_id, :waitlisted
    attr_reader :form, :slot

    def form=(value)
      if value.is_a?(Hash)
        @form = Supersaas::Form.new(value)
      else
        @form = value
      end
    end

    def slot=(value)
      if value.is_a?(Hash)
        @slot = Supersaas::Slot.new(value)
      else
        @slot = value
      end
    end
  end
end