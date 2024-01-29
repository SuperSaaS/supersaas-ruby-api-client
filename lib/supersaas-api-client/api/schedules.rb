# frozen_string_literal: true

module Supersaas
  class Schedules < BaseApi
    # REF: https://www.supersaas.com/info/dev/information_api
    def list
      path = '/schedules'
      res = client.get(path)
      res.map { |attributes| Supersaas::Schedule.new(attributes) }
    end

    def resources(schedule_id)
      path = '/resources'
      query = { schedule_id: validate_id(schedule_id) }
      res = client.get(path, query)
      res.map { |attributes| Supersaas::Resource.new(attributes) }
    end

    def field_list(schedule_id)
      path = '/field_list'
      query = { schedule_id: validate_id(schedule_id) }
      res = client.get(path, query)
      res.map { |attributes| Supersaas::FieldList.new(attributes) }
    end
  end
end
