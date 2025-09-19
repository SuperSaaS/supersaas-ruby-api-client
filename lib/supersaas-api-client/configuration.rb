# frozen_string_literal: true

module Supersaas
  class Configuration
    DEFAULT_HOST = "https://www.supersaas.com"

    attr_accessor :account_name, :host, :api_key, :dry_run, :verbose

    def initialize
      @account_name = ENV.fetch("SSS_API_ACCOUNT_NAME", nil)
      @api_key = ENV.fetch("SSS_API_KEY", nil)
      @host = DEFAULT_HOST
      @dry_run = false
      @verbose = false
    end

    def valid?
      required_fields_present? && boolean_fields_valid?
    end

    def validate!
      raise Supersaas::Exception, "Account name is required" if account_name.to_s.empty?
      raise Supersaas::Exception, "API key is required" if api_key.to_s.empty?
      raise Supersaas::Exception, "Host is required" if host.to_s.empty?
      validate_host_format!
      validate_boolean_fields!
    end

    private

    def required_fields_present?
      !account_name.to_s.empty? && !api_key.to_s.empty? && !host.to_s.empty?
    end

    def boolean_fields_valid?
      [dry_run, verbose].all? { |field| [true, false].include?(field) }
    end

    def validate_host_format!
      return if host =~ /\Ahttps?:\/\/.+/
      raise Supersaas::Exception, "Host must be a valid URL"
    end

    def validate_boolean_fields!
      raise Supersaas::Exception, "Dry run must be boolean" unless boolean_fields_valid?
    end
  end
end
