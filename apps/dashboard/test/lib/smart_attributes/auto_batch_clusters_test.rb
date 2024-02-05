# frozen_string_literal: true

require 'test_helper'

class SmartAttributes::AutoBatchClustersTest < ActiveSupport::TestCase

  def fixture_dir
    'test/fixtures/config/clusters.d'
  end

  test 'can correctly set the value when there is a cluster configuration' do
    Configuration.stubs(:job_clusters).returns(OodCore::Clusters.load_file(fixture_dir))
    value = 'dev-cluster'
    attribute = SmartAttributes::AttributeFactory.build('auto_batch_clusters', { value: value })

    assert_instance_of SmartAttributes::Attributes::AutoBatchClusters, attribute
    assert_equal(value, attribute.value)
  end

  test 'default value is the first cluster from all supported clusters from the Configuration' do
    Configuration.stubs(:job_clusters).returns(OodCore::Clusters.load_file(fixture_dir))
    attribute = SmartAttributes::AttributeFactory.build('auto_batch_clusters')

    assert_instance_of SmartAttributes::Attributes::AutoBatchClusters, attribute
    assert_equal('oakley', File.basename(attribute.value))
  end

  test 'can correctly set the label' do
    attribute = SmartAttributes::AttributeFactory.build('auto_batch_clusters', {label: 'My Local Cluster'})

    assert_instance_of SmartAttributes::Attributes::AutoBatchClusters, attribute
    assert_equal('My Local Cluster', File.basename(attribute.label))
  end

  test 'default label is Cluster' do
    attribute = SmartAttributes::AttributeFactory.build('auto_batch_clusters')

    assert_instance_of SmartAttributes::Attributes::AutoBatchClusters, attribute
    assert_equal('Cluster', File.basename(attribute.label))
  end

  test 'select_choices return the sorted list of supported clusters from the Configuration' do
    Configuration.stubs(:job_clusters).returns(OodCore::Clusters.load_file(fixture_dir))
    attribute = SmartAttributes::AttributeFactory.build('auto_batch_clusters')

    assert_instance_of SmartAttributes::Attributes::AutoBatchClusters, attribute
    assert_equal(4, attribute.select_choices.length)
    assert_equal('oakley', attribute.select_choices[0])
    assert_equal('owens', attribute.select_choices[1])
    assert_equal('quick', attribute.select_choices[2])
    assert_equal('ruby', attribute.select_choices[3])
  end

  test 'widget is select' do
    attribute = SmartAttributes::AttributeFactory.build('auto_batch_clusters')

    assert_instance_of SmartAttributes::Attributes::AutoBatchClusters, attribute
    assert_equal('select', File.basename(attribute.widget))
  end
end
