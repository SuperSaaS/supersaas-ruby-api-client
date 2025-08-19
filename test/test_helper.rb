# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("../lib", __dir__)

require "supersaas-api-client"
require "minitest/autorun"

class SupersaasTest < Minitest::Test
  protected

  def assert_last_request_path(path)
    assert_equal path, @client.last_request.path
  end

  def client_instance
    @client ||= create_test_client
  end

  private

  def create_test_client
    config = Supersaas::Configuration.new
    config.account_name = "accnt"
    config.api_key = "xxxxxxxxxxxxxxxxxxxxxx"
    config.dry_run = true

    Supersaas::Client.instance(config)
  end
end