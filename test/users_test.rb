# frozen_string_literal: true

require 'test_helper'

module Supersaas
  class UsersTest < SupersaasTest
    def setup
      @client = client_instance
      @user_id = 12_345
      @user_fk = '6789fk'
    end

    def test_get
      refute_nil @client.users.get(@user_id)
      assert_last_request_path "/api/users/#{@user_id}.json"
    end

    def test_get_fk
      refute_nil @client.users.get(@user_fk)
      assert_last_request_path "/api/users/#{@user_fk}.json"
    end

    def test_list
      limit = 10
      offset = 0
      refute_nil @client.users.list(true, limit, offset)
      assert_last_request_path "/api/users.json?form=true&limit=#{limit}&offset=#{offset}"
    end

    def test_create
      refute_nil @client.users.create(user_attributes)
      assert_last_request_path '/api/users.json'
    end

    def test_create_fk
      refute_nil @client.users.create(user_attributes, @user_fk, true)
      assert_last_request_path "/api/users/#{@user_fk}.json?webhook=true"
    end

    def test_update
      refute_nil @client.users.update(@user_id, user_attributes, true)
      assert_last_request_path "/api/users/#{@user_id}.json?webhook=true"
    end

    def test_delete
      refute_nil @client.users.delete(@user_id)
      assert_last_request_path "/api/users/#{@user_id}.json"
    end

    def test_field_list
      refute_nil @client.users.field_list
      assert_last_request_path '/api/field_list.json'
    end

    private

    def user_attributes
      {
        name: 'Test',
        email: 'test@example.com',
        password: 'pass123',
        full_name: 'Tester Test',
        address: '123 St, City',
        mobile: '555-5555',
        phone: '555-5555',
        country: 'FR',
        field_1: 'f 1',
        field_2: 'f 2',
        super_field: 'sf',
        credit: 10,
        role: 3
      }
    end
  end
end
