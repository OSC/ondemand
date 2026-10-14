require 'test_helper'

class SmartAttributes::AutoNumNodesTest < ActiveSupport::TestCase
  test 'build creates AutoNumNodes attribute that subclasses BcNumNodes' do
    attribute = SmartAttributes::AttributeFactory.build('auto_num_nodes')

    assert_instance_of SmartAttributes::Attributes::AutoNumNodes, attribute
    assert_kind_of SmartAttributes::Attributes::BcNumNodes, attribute
    assert_equal 'auto_num_nodes', attribute.id
    assert_equal 'number_field', attribute.widget
    assert_equal '1', attribute.value
    assert_equal 'Number of nodes', attribute.label
    assert_equal 1, attribute.opts[:min]
    assert_equal 1, attribute.opts[:step]
  end

  test 'inherits submit behavior from BcNumNodes' do
    attribute = SmartAttributes::AttributeFactory.build('auto_num_nodes', { value: '3' })

    assert_equal({ script: { native: ['-N', 3] } }, attribute.submit(fmt: 'slurm'))
    assert_equal({ script: { native: { resources: { nodes: 3 } } } }, attribute.submit(fmt: 'torque'))
    assert_equal({ script: { native: ['-l', 'select=3'] } }, attribute.submit(fmt: 'pbspro'))
    assert_equal({}, attribute.submit(fmt: 'unknown'))
  end
end
