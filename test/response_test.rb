# frozen_string_literal: true

require 'test_helper'

module Supersaas
  # Stubs Net::HTTP to check how the client turns responses into return values and errors
  class ResponseTest < SupersaasTest
    module StubbedRequest
      def request(req, *args, &block)
        response = Thread.current[:supersaas_stubbed_response]
        response ? response.call(req) : super
      end
    end
    Net::HTTP.prepend(StubbedRequest)

    def setup
      @client = Supersaas::Client.new
      @client.account_name = 'accnt'
      @client.api_key = 'xxxxxxxxxxxxxxxxxxxxxx'
      def @client.throttle; end
    end

    def teardown
      Thread.current[:supersaas_stubbed_response] = nil
    end

    def test_json_body_is_parsed
      stub_response(200, '[{"id":1,"name":"Schedule"}]')
      schedules = @client.schedules.list
      assert_equal [1], schedules.map(&:id)
      assert_equal 'Schedule', schedules.first.name
    end

    def test_empty_body_returns_an_empty_hash
      stub_response(200, '')
      assert_equal({}, @client.put('/users/1', {}))
    end

    def test_invalid_json_returns_an_empty_hash
      stub_response(200, 'not json')
      assert_equal({}, @client.get('/test'))
    end

    def test_post_returns_the_location_of_the_created_object
      stub_response(201, '', 'location' => 'https://www.supersaas.com/api/users/1234.json')
      assert_equal 'https://www.supersaas.com/api/users/1234.json', @client.users.create({ name: 'Test' })
    end

    def test_error_messages
      {
        400 => 'HTTP Request Error: Bad Request',
        401 => 'HTTP Request Error: Unauthorised',
        403 => 'Unauthorized',
        404 => 'HTTP Request Error: Not Found',
        422 => 'HTTP Request Error: Unprocessable Content',
        500 => 'HTTP Request Error: 500',
        501 => 'Not yet implemented for service type schedule'
      }.each do |code, message|
        stub_response(code, '{"errors":[{"code":"error","title":"Something went wrong"}]}')
        error = assert_raises(Supersaas::Exception) { @client.get('/test') }
        assert_equal message, error.message, "HTTP #{code}"
      end
    end

    def test_network_errors_raise_supersaas_exception
      Thread.current[:supersaas_stubbed_response] = ->(_req) { raise Net::ReadTimeout }
      error = assert_raises(Supersaas::Exception) { @client.get('/test') }
      assert_match(%r{\AHTTP Request Error \(https://www.supersaas.com/api/test.json\): }, error.message)
    end

    private

    def stub_response(code, body, headers = {})
      response = Net::HTTPResponse::CODE_TO_OBJ[code.to_s].new('1.1', code.to_s, 'Stubbed')
      response.instance_variable_set(:@body, body)
      response.instance_variable_set(:@read, true)
      headers.each { |name, value| response[name] = value }
      Thread.current[:supersaas_stubbed_response] = ->(_req) { response }
    end
  end
end
