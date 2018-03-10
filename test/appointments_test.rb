require 'test_helper'

module Supersaas
  class AppointmentsTest < SupersaasTest
    def setup
      @client = Supersaas::Client.instance
      @client.account_name = 'accnt'
      @client.password = 'pwd'
      @client.dry_run = true
      @schedule_id = 12345
      @appointment_id = 67890
      @user_id = 9876
    end

    def test_get
      refute_nil @client.appointments.get(@schedule_id, @appointment_id)
      assert_last_request_path "/api/bookings/#{@appointment_id}.json?schedule_id=#{@schedule_id}"
    end

    def test_list
      start_time = Time.now
      limit = 10
      form = true
      refute_nil @client.appointments.list(@schedule_id, form, start_time, limit)
      assert_last_request_path "/api/bookings.json?schedule_id=#{@schedule_id}&form=true&#{URI.encode_www_form(start: start_time.strftime("%Y-%m-%d %H:%M:%S"))}&limit=#{limit}"
    end

    def test_create
      refute_nil @client.appointments.create(@schedule_id, @user_id, appointment_attributes, true, true)
      assert_last_request_path "/api/bookings.json"
    end

    def test_update
      refute_nil @client.appointments.update(@schedule_id, @appointment_id, appointment_attributes)
      assert_last_request_path "/api/bookings/#{@appointment_id}.json"
    end

    def test_agenda
      refute_nil @client.appointments.agenda(@schedule_id, @user_id).inspect
      assert_last_request_path "/api/agenda/#{@schedule_id}.json?user=#{@user_id}"
    end

    def test_agenda_slots
      refute_nil @client.appointments.agenda_slots(@schedule_id, @user_id).inspect
      assert_last_request_path "/api/agenda/#{@schedule_id}.json?user=#{@user_id}&slot=true"
    end

    def test_available
      from_time = Time.now
      refute_nil @client.appointments.available(@schedule_id, from_time)
      assert_last_request_path "/api/free/#{@schedule_id}.json?#{URI.encode_www_form(from: from_time.strftime("%Y-%m-%d %H:%M:%S"))}"
    end

    def test_available_full
      length_minutes = 15
      resource = 'MyResource'
      limit = 10
      refute_nil @client.appointments.available(@schedule_id, "2017-01-31 14:30:00", length_minutes, resource, true, limit)
      assert_last_request_path "/api/free/#{@schedule_id}.json?length=#{length_minutes}&#{URI.encode_www_form(from: "2017-01-31 14:30:00")}&resource=#{resource}&full=true&maxresults=#{limit}"
    end

    def test_changes
      from = "2017-01-31 14:30:00"
      refute_nil @client.appointments.changes(@schedule_id, from)
      assert_last_request_path "/api/changes/#{@schedule_id}.json?#{URI.encode_www_form(from: from)}"
    end

    def test_changes_slots
      from = Time.now
      refute_nil @client.appointments.changes_slots(@schedule_id, from)
      assert_last_request_path "/api/changes/#{@schedule_id}.json?#{URI.encode_www_form(from: from.strftime("%Y-%m-%d %H:%M:%S"))}&slot=true"
    end

    def test_delete
      refute_nil @client.appointments.delete(@appointment_id)
      assert_last_request_path "/api/bookings/#{@appointment_id}.json"
    end

    private

    def appointment_attributes
      {
        description: 'Testing.',
        name: 'Test',
        email: 'test@example.com',
        full_name: 'Tester Test',
        address: '123 St, City',
        mobile: '555-5555',
        phone: '555-5555',
        country: 'FR',
        field_1: 'f 1',
        field_2: 'f 2',
        field_1_r: 'f 1 r',
        field_2_r: 'f 2 r',
        super_field: 'sf'
      }
    end
  end
end