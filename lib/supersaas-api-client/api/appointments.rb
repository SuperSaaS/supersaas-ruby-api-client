# frozen_string_literal: true

module Supersaas
  # REF: https://www.supersaas.com/info/dev/appointment_api
  class Appointments < BaseApi
    def agenda(schedule_id, user, from_time = nil, slot = false)
      path = "/agenda/#{validate_id(schedule_id)}"
      params = {
        user: validate_present(user),
        from: from_time && validate_datetime(from_time)
      }
      params.merge!(slot: true) if slot
      res = client.get(path, params)
      map_slots_or_bookings(res)
    end

    # LEGACY METHOD WILL BE REMOVED USE AGENDA
    def agenda_slots(schedule_id, user_id, from_time = nil)
      path = "/agenda/#{validate_id(schedule_id)}"
      params = {
        user: validate_present(user_id),
        from: from_time && validate_datetime(from_time),
        slot: true
      }
      res = client.get(path, params)
      map_slots_or_bookings(res, true)
    end

    def available(schedule_id, from_time, length_minutes = nil, resource = nil, full = nil, limit = nil)
      path = "/free/#{validate_id(schedule_id)}"
      params = {
        length: length_minutes && validate_number(length_minutes),
        from: validate_datetime(from_time),
        resource: resource,
        full: full ? true : nil
      }
      params.merge!(maxresults: validate_number(limit)) if limit
      res = client.get(path, params)
      map_slots_or_bookings(res)
    end

    def list(schedule_id, form = nil, start_time = nil, limit = nil, finish = nil, offset = nil)
      path = '/bookings'
      params = {
        schedule_id: validate_id(schedule_id),
        form: form ? true : nil,
        start: start_time ? validate_datetime(start_time) : nil,
        finish: finish ? validate_datetime(finish) : nil
      }
      params.merge!(limit: validate_number(limit)) if limit
      params.merge!(offset: validate_number(offset)) if offset
      res = client.get(path, params)
      map_slots_or_bookings(res)
    end

    def get(schedule_id, appointment_id)
      params = { schedule_id: validate_id(schedule_id) }
      path = "/bookings/#{validate_id(appointment_id)}"
      res = client.get(path, params)
      Supersaas::Appointment.new(res)
    end

    def create(schedule_id, user_id, attributes, form = nil, webhook = nil)
      path = '/bookings'
      params = {
        schedule_id: schedule_id,
        webhook: webhook,
        user_id: validate_id(user_id),
        form: form ? true : nil,
        booking: {
          start: attributes[:start],
          finish: attributes[:finish],
          email: attributes[:email],
          res_name: attributes[:name],
          full_name: attributes[:full_name],
          address: attributes[:address],
          mobile: attributes[:mobile],
          phone: attributes[:phone],
          country: attributes[:country],
          field_1: attributes[:field_1],
          field_2: attributes[:field_2],
          field_1_r: attributes[:field_1_r],
          field_2_r: attributes[:field_2_r],
          super_field: attributes[:super_field],
          resource_id: attributes[:resource_id],
          slot_id: attributes[:slot_id]
        }
      }
      params[:booking].compact!
      client.post(path, params)
    end

    def update(schedule_id, appointment_id, attributes, form = nil, webhook = nil)
      path = "/bookings/#{validate_id(appointment_id)}"
      params = {
        schedule_id: schedule_id,
        booking: {
          start: attributes[:start],
          finish: attributes[:finish],
          email: attributes[:email],
          res_name: attributes[:name],
          full_name: attributes[:full_name],
          address: attributes[:address],
          mobile: attributes[:mobile],
          phone: attributes[:phone],
          country: attributes[:country],
          field_1: attributes[:field_1],
          field_2: attributes[:field_2],
          field_1_r: attributes[:field_1_r],
          field_2_r: attributes[:field_2_r],
          super_field: attributes[:super_field],
          resource_id: attributes[:resource_id],
          slot_id: attributes[:slot_id]
        }
      }

      params.merge!(form: form) if form
      params.merge!(webhook: webhook) if webhook
      params[:booking].compact!
      client.put(path, params)
    end

    def delete(schedule_id, appointment_id, webhook = nil)
      path = "/bookings/#{validate_id(appointment_id)}"
      params = { schedule_id: validate_id(schedule_id) }
      params.merge!(webhook: webhook) if webhook
      client.delete(path, nil, params)
    end

    def changes(schedule_id, from_time = nil, to = nil, slot = false, user = nil, limit = nil, offset = nil)
      path = "/changes/#{validate_id(schedule_id)}"
      params = build_param({}, from_time, to, slot, user, limit, offset)
      res = client.get(path, params)
      map_slots_or_bookings(res)
    end

    def range(schedule_id, today = false, from_time = nil, to = nil, slot = false, user = nil, resource_id = nil,
              service_id = nil, limit = nil, offset = nil)
      path = "/range/#{validate_id(schedule_id)}"
      params = {}
      params = build_param(params, from_time, to, slot, user, limit, offset, resource_id, service_id)
      params.merge!(today: true) if today
      res = client.get(path, params)
      map_slots_or_bookings(res)
    end

    private

    def map_slots_or_bookings(obj, slot = false)
      if obj.is_a?(Array) && slot
        obj.map { |attributes| Supersaas::Slot.new(attributes) }
      elsif obj.is_a?(Array)
        obj.map { |attributes| Supersaas::Appointment.new(attributes) }
      elsif obj['slots']
        obj['slots'].map { |attributes| Supersaas::Slot.new(attributes) }
      elsif obj['bookings']
        obj['bookings'].map { |attributes| Supersaas::Appointment.new(attributes) }
      else
        []
      end
    end

    def build_param(params, from_time, to, slot, user, limit, offset, resource_id = nil, service_id = nil)
      params.merge!(from: validate_datetime(from_time)) if from_time
      params.merge!(to: validate_datetime(to)) if to
      params.merge!(slot: true) if slot
      params.merge!(user: validate_user(user)) if user
      params.merge!(limit: validate_number(limit)) if limit
      params.merge!(offset: validate_number(offset)) if offset
      params.merge!(resource_id: validate_id(resource_id)) if resource_id
      params.merge!(service_id: validate_id(service_id)) if service_id
      params
    end
  end
end
