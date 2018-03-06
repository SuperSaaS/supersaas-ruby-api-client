require 'test_helper'

module Supersaas
  class ClientTest < SupersaasTest
    def setup
      config = Supersaas::Client::Configuration.new
      @client = Supersaas::Client.new(config)
      @client.dry_run = true
    end

    def test_api
      refute_nil @client.appointments
      refute_nil @client.forms
      refute_nil @client.schedules
      refute_nil @client.users
    end

    def test_request_methods
      @client.account_name = 'Test'
      @client.password = 'testing123'
      [:get,:put,:post,:delete].each do |method|
        refute_nil @client.send(method, '/test')
        assert_equal method.to_s.upcase, @client.last_request.method
        assert_equal '/api/test.json', @client.last_request.path
      end
      assert_equal 'Basic VGVzdDp0ZXN0aW5nMTIz', @client.last_request['Authorization']
      assert_equal 'application/json', @client.last_request['Accept']
      assert_equal 'application/json', @client.last_request['Content-Type']
    end

    def test_instance_configuration
      Supersaas::Client.configure do |config|
        config.account_name = 'account'
        config.password = 'password'
        config.host = 'http://test'
        config.dry_run = true
        config.verbose = true
      end
      assert_equal 'account', Supersaas::Client.configuration.account_name
      assert_equal 'password', Supersaas::Client.configuration.password
      assert_equal 'http://test', Supersaas::Client.configuration.host
      assert_equal true, Supersaas::Client.configuration.dry_run
      assert_equal true, Supersaas::Client.configuration.verbose
    end
  end
end