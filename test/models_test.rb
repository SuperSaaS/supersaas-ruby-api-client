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
  end
end
