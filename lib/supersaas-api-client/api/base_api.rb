# frozen_string_literal: true

module Supersaas
  class BaseApi
    attr_accessor :client

    INTEGER_REGEX = /\A[0-9]+\Z/.freeze
    DATETIME_REGEX = /\A\d{4}-\d{1,2}-\d{1,2}\s\d{1,2}:\d{1,2}:\d{1,2}\Z/.freeze
    PROMOTION_REGEX = /\A[0-9a-zA-Z]+\Z/.freeze

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
        raise Supersaas::Exception, "Invalid id parameter: #{value}. Provide a integer value."
      end
    end

    def validate_number(value)
      validate_id(value)
    end

    def validate_name(value)
      unless value.nil? || value.is_a?(String) && value.size
        raise Supersaas::Exception, 'Required parameter name is missing.'
      end

      value
    end

    def validate_present(value)
      raise Supersaas::Exception, 'Required parameter is missing.' unless value

      value
    end

    def validate_notfound(value)
      unless value.is_a?(String) && %w[error ignore].include?(value)
        raise Supersaas::Exception, "Required parameter notfound can only be 'error' or 'ignore'."
      end

      value
    end

    def validate_promotion(value)
      unless value.is_a?(String) && value.size && value =~ PROMOTION_REGEX
        raise Supersaas::Exception,
              'Required parameter promotional code not found or contains other than alphanumeric characters.'
      end

      value
    end

    def validate_duplicate(value)
      unless value.is_a?(String) && value == 'raise'
        raise Supersaas::Exception, "Required parameter duplicate can only be 'raise'."
      end

      value
    end

    def validate_datetime(value)
      if value.is_a?(String) && value =~ DATETIME_REGEX
        value
      elsif value.is_a?(Time) || value.is_a?(DateTime)
        value.strftime('%Y-%m-%d %H:%M:%S')
      else
        raise ArgumentError
      end
    rescue ArgumentError
      raise Supersaas::Exception,
            "Invalid datetime parameter: #{value}. Provide a Time object or formatted 'YYYY-DD-MM HH:MM:SS' string."
    end

    def validate_options(value, options)
      unless options.include?(value)
        raise Supersaas::Exception, "Invalid option parameter: #{value}. Must be one of #{options.join(', ')}."
      end

      value
    end
  end
end
