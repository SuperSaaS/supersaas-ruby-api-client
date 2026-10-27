# frozen_string_literal: true

require 'test_helper'

module Supersaas
  # Invalid input raises Supersaas::Exception before any request is made
  class ValidationTest < SupersaasTest
    def setup
      @client = Supersaas::Client.new
      @client.account_name = 'accnt'
      @client.api_key = 'xxxxxxxxxxxxxxxxxxxxxx'
      @client.dry_run = true
    end

    def test_invalid_id
      error = assert_raises(Supersaas::Exception) { @client.schedules.resources('abc') }
      assert_equal 'Invalid id parameter: abc. Provide a integer value.', error.message
    end

    def test_id_as_numeric_string
      @client.schedules.resources('12345')
      assert_equal '/api/resources.json?schedule_id=12345', @client.last_request.path
    end

    def test_missing_user
      error = assert_raises(Supersaas::Exception) { @client.appointments.agenda(12_345, nil) }
      assert_equal 'Required parameter is missing.', error.message
    end

    def test_invalid_user
      error = assert_raises(Supersaas::Exception) { @client.appointments.changes(12_345, nil, nil, false, 1.5) }
      assert_equal 'Invalid user id parameter: 1.5.', error.message
    end

    def test_invalid_name
      error = assert_raises(Supersaas::Exception) { @client.users.create({ name: 42 }) }
      assert_equal 'Required parameter name is missing.', error.message
    end

    def test_invalid_role
      error = assert_raises(Supersaas::Exception) { @client.users.create({ name: 'Test', role: 1 }) }
      assert_equal 'Invalid option parameter: 1. Must be one of 3, 4, -1.', error.message
    end

    def test_invalid_notfound
      error = assert_raises(Supersaas::Exception) { @client.users.update(12_345, {}, nil, 'create') }
      assert_equal "Required parameter notfound can only be 'error' or 'ignore'.", error.message
    end

    def test_invalid_duplicate
      error = assert_raises(Supersaas::Exception) { @client.users.create({ name: 'Test' }, nil, nil, 'update') }
      assert_equal "Required parameter duplicate can only be 'ignore'.", error.message
    end

    def test_invalid_promotion_code
      error = assert_raises(Supersaas::Exception) { @client.promotions.promotion('not valid!') }
      assert_equal 'Required parameter promotional code not found or contains other than alphanumeric characters.',
                   error.message
    end

    def test_missing_account_name
      @client.account_name = nil
      error = assert_raises(Supersaas::Exception) { @client.schedules.list }
      assert_equal 'Account name not configured. Call `Supersaas::Client.configure`.', error.message
    end

    def test_missing_api_key
      @client.api_key = nil
      error = assert_raises(Supersaas::Exception) { @client.schedules.list }
      assert_equal 'Account api key not configured. Call `Supersaas::Client.configure`.', error.message
    end

    def test_invalid_http_method
      error = assert_raises(Supersaas::Exception) { @client.send(:request, :patch, '/test') }
      assert_equal 'Invalid HTTP Method: patch. Only `:get`, `:post`, `:put`, `:delete` supported.', error.message
    end
  end
end
