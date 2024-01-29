# frozen_string_literal: true

module Supersaas
  class Form < BaseModel
    attr_accessor :content, :created_on, :deleted, :id, :reservation_process_id, :super_form_id, :uniq, :updated_name,
                  :updated_on, :user_id
  end
end
