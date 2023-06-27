module Supersaas
  class BaseApi
    attr_accessor :client

    INTEGER_REGEX = /\A[0-9]+\Z/
    DATETIME_REGEX = /\A\d{4}-\d{1,2}-\d{1,2}\s\d{1,2}:\d{1,2}:\d{1,2}\Z/

    def initialize(client)
      @client = client
    end

    protected

    def validate_id(value)
      if value.is_a?(Integer)
        value
      elsif value.is_a?(String) && value =~ INTEGER_REGEX
        value.to_i
      else
        raise Supersaas::Exception.new("Invalid id parameter: #{value}. Provide a integer value.")
      end
    end
    def validate_number(value); validate_id(value); end

    def validate_present(value, name = nil)
      if value.is_a?(String) ? value.size : value
        value
      else
        raise Supersaas::Exception.new("Required parameter '#{name}' is missing.")
      end
    end

    def validate_datetime(value)
      begin
        if value.is_a?(String) && value =~ DATETIME_REGEX
          value
        elsif value.is_a?(Time) || value.is_a?(DateTime)
          value.strftime("%Y-%m-%d %H:%M:%S")
        else
          raise ArgumentError
        end
      rescue ArgumentError
        raise Supersaas::Exception.new("Invalid datetime parameter: #{value}. Provide a Time object or formatted 'YYYY-DD-MM HH:MM:SS' string.")
      end
    end

    def validate_options(value, options)
      if options.include?(value)
        value
      else
        raise Supersaas::Exception.new("Invalid option parameter: #{value}. Must be one of #{options.join(', ')}.")
      end
    end
  end
end