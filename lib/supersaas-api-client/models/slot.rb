module Supersaas
  class Slot < BaseModel
    attr_accessor :count, :description, :finish, :id, :location, :name, :start, :title
    attr_reader :bookings

    def bookings=(value)
      if value.is_a?(Array)
        @bookings = value.map {|attributes| Supersaas::Appointment.new(attributes) }
      else
        @bookings = value
      end
    end
  end
end