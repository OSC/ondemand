require 'test_helper'

class SmartAttributes::AutoNumNodesTest < ActiveSupport::TestCase
  test 'build creates AutoNumNodes attribute' do
    attribute = SmartAttributes::AttributeFactory.build('auto_num_nodes')

    assert_instance_of SmartAttributes::Attributes::AutoNumNodes, attribute
    assert_equal 'number_field', attribute.widget
    assert_equal '1', attribute.value
    assert_equal 'Number of nodes', attribute.label
    assert_equal 1, attribute.opts[:min]
    assert_equal 1, attribute.opts[:step]
  end

  test 'can set value and label' do
    attribute = SmartAttributes::AttributeFactory.build('auto_num_nodes', { value: '4', label: 'Nodes' })

    assert_equal '4', attribute.value
    assert_equal 'Nodes', attribute.label
  end

  test 'submit returns native options for supported formats' do
    attribute = SmartAttributes::AttributeFactory.build('auto_num_nodes', { value: '3' })

    assert_equal({ script: { native: ['-N', 3] } }, attribute.submit(fmt: 'slurm'))
    assert_equal({ script: { native: { resources: { nodes: 3 } } } }, attribute.submit(fmt: 'torque'))
    assert_equal({ script: { native: ['-l', 'select=3'] } }, attribute.submit(fmt: 'pbspro'))
    assert_equal({ script: { native: ['-n', 3] } }, attribute.submit(fmt: 'lsf'))
    assert_equal({ script: { native: ['-L', 'node=3'] } }, attribute.submit(fmt: 'fujitsu_tcs'))
    assert_equal({}, attribute.submit(fmt: 'unknown'))
  end

  test 'submit defaults blank value to 1' do
    attribute = SmartAttributes::AttributeFactory.build('auto_num_nodes', { value: '' })

    assert_equal({ script: { native: ['-N', 1] } }, attribute.submit(fmt: 'slurm'))
  end
end
