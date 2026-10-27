# frozen_string_literal: true

require 'test_helper'

module Supersaas
  class VerboseTest < SupersaasTest
    def setup
      @client = Supersaas::Client.new
      @client.account_name = 'accnt'
      @client.api_key = 'secret-api-key'
      @client.dry_run = true
      @client.verbose = true
      def @client.throttle; end
    end

    def test_verbose_output_filters_the_password
      out, = capture_io { @client.users.create({ name: 'Test', password: 'hunter2' }) }
      assert_includes out, '"password":"[FILTERED]"'
      refute_includes out, 'hunter2'
    end

    def test_the_request_still_sends_the_password
      capture_io { @client.users.update(12_345, { name: 'Test', password: 'hunter2' }) }
      assert_equal 'hunter2', JSON.parse(@client.last_request.body)['user']['password']
    end

    def test_verbose_output_leaves_out_the_credentials
      out, = capture_io { @client.users.create({ name: 'Test' }) }
      refute_includes out, 'secret-api-key'
      refute_includes out, ['accnt:secret-api-key'].pack('m0')
      assert_includes out, '"name":"Test"'
    end
  end
end
