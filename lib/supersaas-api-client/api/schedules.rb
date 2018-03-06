module Supersaas
  class Schedules < BaseApi
    def list
      path = "/schedules"
      res = client.get(path)
      res.map { |attributes| Supersaas::Schedule.new(attributes) }
    end

    def resources(schedule_id)
      path = "/resources"
      query = {schedule_id: validate_id(schedule_id)}
      res = client.get(path, query)
      res.map { |attributes| Supersaas::Resource.new(attributes) }
    end
  end
end