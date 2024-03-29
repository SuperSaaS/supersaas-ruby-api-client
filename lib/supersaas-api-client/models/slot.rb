# frozen_string_literal: true

module Supersaas
  class Slot < BaseModel
    attr_accessor :count, :description, :finish, :id, :location, :name, :start, :title
    attr_reader :bookings

    def bookings=(value)
      @bookings = value.is_a?(Array) ? value.map { |attributes| Supersaas::Appointment.new(attributes) } : value
    end
  end
end
