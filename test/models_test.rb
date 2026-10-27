# frozen_string_literal: true

require 'test_helper'

module Supersaas
  class ModelsTest < Minitest::Test
    def test_attributes_are_assigned_and_kept
      attributes = { 'id' => 1, 'name' => 'Test' }
      group = Supersaas::Group.new(attributes)
      assert_equal 1, group.id
      assert_equal 'Test', group.name
      assert_equal attributes, group.attributes
    end

    def test_unknown_attributes_get_an_accessor
      schedule = Supersaas::Schedule.new('id' => 1, 'time_zone' => 'Amsterdam')
      assert_equal 'Amsterdam', schedule.time_zone
    end

    def test_appointment_form_and_slot_are_wrapped_in_models
      appointment = Supersaas::Appointment.new('id' => 1, 'form' => { 'id' => 2, 'content' => 'Answers' },
                                               'slot' => { 'id' => 3, 'title' => 'Yoga' })
      assert_instance_of Supersaas::Form, appointment.form
      assert_equal 'Answers', appointment.form.content
      assert_instance_of Supersaas::Slot, appointment.slot
      assert_equal 'Yoga', appointment.slot.title
    end

    def test_user_form_is_wrapped_in_a_model
      user = Supersaas::User.new('id' => 1, 'form' => { 'id' => 2 })
      assert_instance_of Supersaas::Form, user.form
      assert_equal 2, user.form.id
    end

    def test_slot_bookings_are_wrapped_in_appointments
      slot = Supersaas::Slot.new('id' => 1, 'bookings' => [{ 'id' => 2, 'full_name' => 'Jane' }])
      assert_equal [Supersaas::Appointment], slot.bookings.map(&:class)
      assert_equal 'Jane', slot.bookings.first.full_name
    end

    def test_field_list_spec_is_parsed
      field = Supersaas::FieldList.new('name' => 'country', 'spec' => ['{"a":1}', { 'b' => 2 }, 'plain'])
      assert_equal [{ 'a' => 1 }, { 'b' => 2 }, 'plain'], field.spec
    end

    def test_hash_style_access_still_works_on_nested_models
      appointment = Supersaas::Appointment.new('form' => { 'content' => 'Answers' },
                                               'slot' => { 'bookings' => [{ 'full_name' => 'Jane' }] })
      assert_equal 'Answers', appointment.form['content']
      assert_equal 'Answers', appointment.form[:content]
      assert_equal 'Jane', appointment.slot['bookings'][0]['full_name']
      assert_nil appointment.form['missing']
    end

    def test_hash_style_access_with_symbol_keyed_attributes
      group = Supersaas::Group.new(id: 1, name: 'Test')
      assert_equal 'Test', group[:name]
      assert_equal 'Test', group['name']
      assert_equal({ id: 1, name: 'Test' }, group.to_h)
    end
  end
end
