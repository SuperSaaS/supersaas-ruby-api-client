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
      !account_name.to_s.empty? && !api_key.to_s.empty? && !host.to_s.empty?
    end

    def validate!
      raise Supersaas::Exception, "Account name is required" if account_name.to_s.empty?
      raise Supersaas::Exception, "API key is required" if api_key.to_s.empty?
      raise Supersaas::Exception, "Host is required" if host.to_s.empty?
      raise Supersaas::Exception, "Dry run must be boolean" unless [true, false].include?(dry_run)
      raise Supersaas::Exception, "Verbose must be boolean" unless [true, false].include?(verbose)
    end
  end
end
