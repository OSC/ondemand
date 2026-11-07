require 'test_helper'

module SmartAttributes
  class BcNumNodesTest < ActiveSupport::TestCase
    test "initialize default" do
      attribute = SmartAttributes::AttributeFactory.build_bc_num_nodes()
      assert_equal({min: 1, step: 1}, attribute.opts)
      assert_equal('bc_num_nodes', attribute.id)
      assert_equal('1', attribute.value)
      assert_equal('number_field', attribute.widget)
      assert_equal('Number of nodes', attribute.label)
    end

    test "initialize with options" do
      attribute = SmartAttributes::AttributeFactory.build_bc_num_nodes({value: 2, label: '# of Nodes'})
      assert_equal({min: 1, step: 1, value: 2, label: '# of Nodes'}, attribute.opts)
      assert_equal('bc_num_nodes', attribute.id)
      assert_equal('2', attribute.value)
      assert_equal('number_field', attribute.widget)
      assert_equal('# of Nodes', attribute.label)
    end

    test "submit with different formats" do
      attribute = SmartAttributes::AttributeFactory.build_bc_num_nodes({value: 3})
      assert_equal({script: {native: ['-N', 3]}}, attribute.submit(fmt: 'slurm'))
      assert_equal({script: {native: ['-l', 'select=3']}}, attribute.submit(fmt: 'pbspro'))
      assert_equal({script: {native: ['-n', 3]}}, attribute.submit(fmt: 'lsf'))
      assert_equal({script: {native: ['-L', 'node=3']}}, attribute.submit(fmt: 'fujitsu_tcs'))
      assert_equal({script: {native: {resources: {nodes: 3}}}}, attribute.submit(fmt: 'torque'))
      assert_equal({}, attribute.submit())
    end
  end
end