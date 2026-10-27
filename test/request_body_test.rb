# frozen_string_literal: true

require 'test_helper'

module Supersaas
  # Checks the JSON bodies the client sends, not only the request paths
  class RequestBodyTest < SupersaasTest
    def setup
      @client = client_instance
    end

    def test_user_create_sends_only_given_attributes
      @client.users.create({ name: 'Test', email: 'test@example.com', credit: '10', role: 3, unknown: 'x' })
      assert_equal({ 'user' => { 'name' => 'Test', 'email' => 'test@example.com', 'credit' => 10, 'role' => 3 } },
                   last_body)
    end

    def test_user_update_sends_the_same_attributes_as_create
      @client.users.update(12_345, { full_name: 'New Name', group: 7 })
      assert_equal({ 'user' => { 'full_name' => 'New Name', 'group' => 7 } }, last_body)
    end

    def test_user_create_with_duplicate_and_webhook
      @client.users.create({ name: 'Test' }, nil, true, 'raise')
      assert_equal '/api/users.json?webhook=true&duplicate=raise', @client.last_request.path
    end

    def test_user_update_with_notfound
      @client.users.update(12_345, { name: 'Test' }, nil, 'ignore')
      assert_equal '/api/users/12345.json?notfound=ignore', @client.last_request.path
    end

    def test_appointment_create_maps_name_to_res_name
      @client.appointments.create(12_345, 9876, { name: 'Room 1', full_name: 'Tester', slot_id: 5 }, true, true)
      assert_equal({ 'schedule_id' => 12_345, 'webhook' => true, 'user_id' => 9876, 'form' => true,
                     'booking' => { 'res_name' => 'Room 1', 'full_name' => 'Tester', 'slot_id' => 5 } },
                   last_body)
    end

    def test_get_requests_have_an_empty_json_body
      @client.schedules.list
      assert_nil @client.last_request.body
    end

    def test_user_agent
      @client.schedules.list
      assert_equal "SSS/#{VERSION} Ruby/#{RUBY_VERSION} API/#{API_VERSION}", @client.last_request['User-Agent']
    end

    private

    def last_body
      JSON.parse(@client.last_request.body)
    end
  end
end
