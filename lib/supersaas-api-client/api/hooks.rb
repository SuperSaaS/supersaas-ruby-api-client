# frozen_string_literal: true

module Supersaas
  # REF: https://www.supersaas.com/info/dev/webhooks
  class Hooks < BaseApi
    # event: the trigger, e.g. 'U' (user created), 'M' (user changed), 'N' (new appointment), 'C' (changed appointment)
    # parent_id: the schedule id for appointment events, the super form id for form events, else the account id
    # Returns { 'id' => ..., 'parent_id' => ... }
    def create(target_url, event, parent_id)
      path = '/hooks'
      params = {
        target_url: validate_present(target_url),
        event: validate_present(event),
        parent_id: validate_id(parent_id)
      }
      client.post(path, params)
    end

    def delete(hook_id, parent_id)
      path = '/hooks'
      query = { id: validate_id(hook_id), parent_id: validate_id(parent_id) }
      client.delete(path, nil, query)
    end
  end
end
