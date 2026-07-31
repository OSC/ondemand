require 'test_helper'

class ActivejobsInitializerTest < ActiveSupport::TestCase
  setup do
    stub_clusters
    Object.send(:remove_const, :OODClusters)
    load Rails.root.join('config/initializers/activejobs.rb')
  end

  test "should exclude hidden clusters from OODClusters" do
    OodCore::Clusters.load_file('test/fixtures/config/clusters.d')
      .select { |c| c.metadata.hidden }
      .each { |cluster| assert_nil OODClusters[cluster.id.to_s] }
  end
end
