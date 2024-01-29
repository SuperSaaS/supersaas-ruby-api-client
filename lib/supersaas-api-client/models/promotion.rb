# frozen_string_literal: true

module Supersaas
  class Promotion < BaseModel
    attr_accessor :id, :code, :description, :usage
  end
end
