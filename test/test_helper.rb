$:.push File.expand_path('../../lib', __FILE__)

require "supersaas-api-client"

require "minitest/autorun"

class SupersaasTest < Minitest::Test
  def assert_last_request_path(path)
    assert_equal path, @client.last_request.path
  end

  protected

  def client_instance
    if !@client
      @client = Supersaas::Client.instance
      @client.account_name = 'accnt'
      @client.password = 'pwd'
      @client.dry_run = true
    end
    @client
  end
end