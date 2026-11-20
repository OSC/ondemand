# frozen_string_literal: true

require 'test_helper'
require 'smart_attributes'

module SmartAttributes
  class AutoWallclockLimitTest < ActiveSupport::TestCase
    test 'initialize default' do
      attribute = SmartAttributes::AttributeFactory.build('auto_wallclock_limit')
      assert_equal({ min: 1, step: 1 }, attribute.opts)
      assert_equal('auto_wallclock_limit', attribute.id)
      assert_equal('1', attribute.value)
      assert_equal('number_field', attribute.widget)
      assert_equal('Walltime Limit', attribute.label)
      assert attribute.required
    end

    test 'initialize with options' do
      attribute = SmartAttributes::AttributeFactory.build('auto_wallclock_limit', { value: 4, label: 'Max Hours' })
      assert_equal({ min: 1, step: 1, value: 4, label: 'Max Hours' }, attribute.opts)
      assert_equal('4', attribute.value)
      assert_equal('Max Hours', attribute.label)
    end

    test 'submit emits wall_time in seconds' do
      attribute = SmartAttributes::AttributeFactory.build('auto_wallclock_limit', { value: 2 })
      assert_equal({ script: { wall_time: 7200 } }, attribute.submit)
    end
  end
end
