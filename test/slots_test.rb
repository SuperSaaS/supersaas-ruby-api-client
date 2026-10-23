# frozen_string_literal: true

require 'test_helper'

module Supersaas
  class SlotsTest < SupersaasTest
    def setup
      @client = Supersaas::Client.instance
      @client.account_name = 'accnt'
      @client.api_key = 'xxxxxxxxxxxxxxxxxxxxxx'
      @client.dry_run = true
      @schedule_id = 12_345
      @slot_id = 67_890
    end

    def test_get
      refute_nil @client.slots.get(@schedule_id, @slot_id)
      assert_last_request_path "/api/slots/#{@slot_id}.json?schedule_id=#{@schedule_id}"
    end

    def test_list
      refute_nil @client.slots.list(@schedule_id)
      assert_last_request_path "/api/slots.json?schedule_id=#{@schedule_id}"
    end

    def test_list_with_params
      start_time = '2017-01-31 14:30:00'
      finish = '2017-02-28 14:30:00'
      refute_nil @client.slots.list(@schedule_id, start_time, finish, 10, 5)
      assert_last_request_path "/api/slots.json?schedule_id=#{@schedule_id}&#{URI.encode_www_form(start: start_time)}&#{URI.encode_www_form(finish: finish)}&limit=10&offset=5"
    end

    def test_create
      refute_nil @client.slots.create(@schedule_id, slot_attributes)
      assert_last_request_path "/api/slots.json?schedule_id=#{@schedule_id}"
      assert_equal Net::HTTP::Post, @client.last_request.class
      assert_equal({ 'slot' => slot_attributes.transform_keys(&:to_s) }, JSON.parse(@client.last_request.body))
    end

    def test_update
      refute_nil @client.slots.update(@schedule_id, @slot_id, { title: 'New title', capacity: '-' })
      assert_last_request_path "/api/slots/#{@slot_id}.json?schedule_id=#{@schedule_id}"
      assert_equal Net::HTTP::Put, @client.last_request.class
      assert_equal({ 'slot' => { 'title' => 'New title', 'capacity' => '-' } }, JSON.parse(@client.last_request.body))
    end

    def test_delete
      refute_nil @client.slots.delete(@schedule_id, @slot_id)
      assert_last_request_path "/api/slots/#{@slot_id}.json?schedule_id=#{@schedule_id}"
      assert_equal Net::HTTP::Delete, @client.last_request.class
    end

    def test_invalid_ids
      assert_raises(Supersaas::Exception) { @client.slots.get('abc', @slot_id) }
      assert_raises(Supersaas::Exception) { @client.slots.delete(@schedule_id, nil) }
      assert_raises(Supersaas::Exception) { @client.slots.create(@schedule_id, { start: 'tomorrow' }) }
    end

    private

    def slot_attributes
      {
        start: '2017-01-31 14:30:00',
        finish: '2017-01-31 15:30:00',
        title: 'Yoga',
        description: 'Testing.',
        location: 'Room 1',
        capacity: 10,
        price: '12.50',
        color: 'red'
      }
    end
  end
end
