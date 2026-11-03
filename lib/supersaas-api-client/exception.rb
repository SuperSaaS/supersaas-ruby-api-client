# frozen_string_literal: true

module Supersaas
  class Exception < StandardError
    @field = nil
    @code = nil

    attr_accessor :field, :code
    # HTTP status code and the server's parsed errors, e.g. [{"status"=>"404", "title"=>"Not found"}]
    attr_reader :status, :errors

    def initialize(message = nil, status: nil, errors: [])
      super(message)
      @status = status
      @errors = errors
    end
  end
end
