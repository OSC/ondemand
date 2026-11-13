# frozen_string_literal: true

require 'test_helper'
require 'smart_attributes'

class SmartAttributes::AutoGpusTest < ActiveSupport::TestCase
  test 'widget is number_field' do
    attribute = SmartAttributes::AttributeFactory.build('auto_gpus')

    assert_instance_of SmartAttributes::Attributes::AutoGpus, attribute
    assert_equal 'number_field', attribute.widget
  end

  test 'default label is Number of GPUs' do
    attribute = SmartAttributes::AttributeFactory.build('auto_gpus')

    assert_equal 'Number of GPUs', attribute.label
  end

  test 'can correctly set the label' do
    attribute = SmartAttributes::AttributeFactory.build('auto_gpus', { label: 'GPUs per node' })

    assert_equal 'GPUs per node', attribute.label
  end

  test 'defaults to min 1 and value 1' do
    attribute = SmartAttributes::AttributeFactory.build('auto_gpus')

    assert_equal 1, attribute.opts[:min]
    assert_equal 1, attribute.opts[:step]
    assert_equal '1', attribute.value
  end

  test 'submit sets gpus_per_node' do
    attribute = SmartAttributes::AttributeFactory.build('auto_gpus', { value: '3' })

    assert_equal({ script: { gpus_per_node: 3 } }, attribute.submit)
  end

  test 'submit defaults blank values to 1' do
    attribute = SmartAttributes::AttributeFactory.build('auto_gpus', { value: '' })

    assert_equal({ script: { gpus_per_node: 1 } }, attribute.submit)
  end
end
