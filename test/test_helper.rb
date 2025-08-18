# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("../lib", __dir__)

require "supersaas-api-client"

require "minitest/autorun"

class SupersaasTest < Minitest::Test
  def assert_last_request_path(path)
    assert_equal path, @client.last_request.path
  end

  protected

  def client_instance
    unless defined? @client
      @config = Supersaas::Configuration.new

      @config.account_name = "accnt"
      @config.api_key = "xxxxxxxxxxxxxxxxxxxxxx"
      @config.dry_run = true
      @client = Supersaas::Client.instance(@config)
    end
    @client
  end
end
