# frozen_string_literal: true

module Supersaas
  class BaseApi
    attr_accessor :client

    INTEGER_REGEX = /\A[0-9]+\Z/
    DATETIME_REGEX = /\A\d{4}-\d{1,2}-\d{1,2}\s\d{1,2}:\d{1,2}:\d{1,2}\Z/
    PROMOTION_REGEX = /\A[0-9a-zA-Z]+\Z/

    def initialize(client)
      @client = client
    end

    protected

    def validate_id(value)
      case value
      when Integer
        raise Supersaas::Exception, "Invalid id parameter: #{value}. Must be positive." if value < 0
        value
      when String
        raise Supersaas::Exception, "Invalid id parameter: #{value}. Provide a integer value." unless INTEGER_REGEX.match?(value)
        parsed = value.to_i
        raise Supersaas::Exception, "Invalid id parameter: #{value}. Must be positive." if parsed < 0
        parsed
      else
        raise Supersaas::Exception, "Invalid id parameter: #{value}. Provide a integer value."
      end
    end

    def validate_user(value)
      return if value.nil?

      unless value.is_a?(Integer) || value.is_a?(String)
        raise Supersaas::Exception, "Invalid user id parameter: #{value}."
      end

      value
    end

    def validate_number(value)
      validate_id(value)
    end

    def validate_name(value)
      return if value.nil?

      unless value.is_a?(String) && !value.strip.empty?
        raise Supersaas::Exception, "Required parameter name is missing or empty."
      end

      value.strip
    end

    def validate_present(value)
      raise Supersaas::Exception, "Required parameter is missing." unless value

      value
    end

    def validate_notfound(value)
      valid_options = %w[ignore raise]
      unless value.is_a?(String) && valid_options.include?(value)
        raise Supersaas::Exception, "Notfound parameter must be one of: #{valid_options.join(", ")}, got: '#{value}'"
      end
      value
    end

    def validate_promotion(value)
      unless value.is_a?(String) && value.size && value =~ PROMOTION_REGEX
        raise Supersaas::Exception, "Required parameter promotional code not found or contains other than alphanumeric characters."
      end

      value
    end

    def validate_duplicate(value)
      valid_options = %w[ignore raise]
      unless value.is_a?(String) && valid_options.include?(value)
        raise Supersaas::Exception, "Duplicate parameter must be one of: #{valid_options.join(", ")}, got: '#{value}'"
      end

      value
    end

    def validate_datetime(value)
      case value
      when String
        unless DATETIME_REGEX.match?(value)
          raise Supersaas::Exception,
            "Invalid datetime parameter: #{value}. Provide a formatted 'YYYY-MM-DD HH:MM:SS' string."
        end
        value
      when Time, DateTime
        value.strftime("%Y-%m-%d %H:%M:%S")
      else
        raise Supersaas::Exception,
          "Invalid datetime parameter: #{value}. Provide a Time object or formatted 'YYYY-MM-DD HH:MM:SS' string."
      end
    end

    def validate_options(value, valid_options)
      unless valid_options.include?(value)
        raise Supersaas::Exception, "Value must be one of: #{valid_options.join(", ")}, got: '#{value}'"
      end

      value
    end
  end
end
