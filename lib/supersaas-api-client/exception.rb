module Supersaas
  class Exception < StandardError
    @field = nil
    @code = nil

    attr_accessor :field, :code
  end
end