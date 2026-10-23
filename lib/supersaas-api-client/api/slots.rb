# frozen_string_literal: true

module Supersaas
  # REF: https://www.supersaas.com/info/dev/appointment_api
  # Only available for capacity type schedules.
  class Slots < BaseApi
    def list(schedule_id, start_time = nil, finish = nil, limit = nil, offset = nil)
      path = '/slots'
      params = {
        schedule_id: validate_id(schedule_id),
        start: start_time ? validate_datetime(start_time) : nil,
        finish: finish ? validate_datetime(finish) : nil
      }
      params.merge!(limit: validate_number(limit)) if limit
      params.merge!(offset: validate_number(offset)) if offset
      res = client.get(path, params)
      res.map { |attributes| Supersaas::Slot.new(attributes) }
    end

    def get(schedule_id, slot_id)
      params = { schedule_id: validate_id(schedule_id) }
      path = "/slots/#{validate_id(slot_id)}"
      res = client.get(path, params)
      Supersaas::Slot.new(res)
    end

    def create(schedule_id, attributes)
      path = '/slots'
      query = { schedule_id: validate_id(schedule_id) }
      client.post(path, { slot: slot_params(attributes) }, query)
    end

    def update(schedule_id, slot_id, attributes)
      path = "/slots/#{validate_id(slot_id)}"
      query = { schedule_id: validate_id(schedule_id) }
      client.put(path, { slot: slot_params(attributes) }, query)
    end

    def delete(schedule_id, slot_id)
      path = "/slots/#{validate_id(slot_id)}"
      params = { schedule_id: validate_id(schedule_id) }
      client.delete(path, nil, params)
    end

    private

    # capacity: an Integer, or '-' for unlimited, '0' for no places
    def slot_params(attributes)
      params = {
        start: attributes[:start] && validate_datetime(attributes[:start]),
        finish: attributes[:finish] && validate_datetime(attributes[:finish]),
        title: attributes[:title],
        description: attributes[:description],
        location: attributes[:location],
        capacity: attributes[:capacity],
        price: attributes[:price],
        color: attributes[:color]
      }
      params.compact!
      params
    end
  end
end
