# frozen_string_literal: true

require 'test_helper'
require 'smart_attributes'

class SmartAttributes::AutoGpuTypeTest < ActiveSupport::TestCase
  def setup
    Rails.cache.clear
    SmartAttributes::AttributeFactory.stubs(:gpu_types).returns(
      [
        ['v100', 'v100', { 'data-option-for-auto-queues-batch' => false }],
        ['p100', 'p100', { 'data-option-for-auto-queues-gpu' => false }]
      ]
    )
  end

  test 'widget is select' do
    attribute = SmartAttributes::AttributeFactory.build('auto_gpu_type')

    assert_instance_of SmartAttributes::Attributes::AutoGpuType, attribute
    assert_equal 'select', attribute.widget
  end

  test 'default label is GPU Type' do
    attribute = SmartAttributes::AttributeFactory.build('auto_gpu_type')

    assert_equal 'GPU Type', attribute.label
  end

  test 'can correctly set the label' do
    attribute = SmartAttributes::AttributeFactory.build('auto_gpu_type', { label: 'Accelerator' })

    assert_equal 'Accelerator', attribute.label
  end

  test 'select_choices come from gpu_types' do
    attribute = SmartAttributes::AttributeFactory.build('auto_gpu_type')

    assert_equal 2, attribute.select_choices.length
    assert_equal 'v100', attribute.select_choices[0].first
    assert_equal 'p100', attribute.select_choices[1].first
    assert_equal false, attribute.select_choices[0].last['data-option-for-auto-queues-batch']
  end

  test 'submit is empty so value can be used in submit.yml.erb' do
    attribute = SmartAttributes::AttributeFactory.build('auto_gpu_type', { value: 'v100' })

    assert_equal({}, attribute.submit)
  end
end
