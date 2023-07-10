# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory

    # Build this attribute object. Must specify a valid directory in opts
    #
    # @param opts [Hash] attribute's options
    # @return [Attributes::AutoBatchClusters] the attribute object
    def self.build_auto_batch_clusters(opts = {})
      options = batch_clusters

      static_opts = {
        options: options
      }.merge(opts.without(:options).to_h)

      Attributes::AutoBatchClusters.new('auto_batch_clusters', static_opts)
    end

    def self.batch_clusters
      Rails.cache.fetch('script_batch_clusters', expires_in: 4.hours) do
        Configuration.job_clusters.reject do |c|
          reject_cluster?(c)
        end.map(&:id).map(&:to_s).sort
      end
    end

    def self.reject_cluster?(cluster)
      cluster.kubernetes? || cluster.linux_host? || cluster.systemd?
    end
  end

  module Attributes
    class AutoBatchClusters < Attribute

      # Value of auto_batch_clusters attribute
      # Defaults to first cluster in the options
      # @return [String] attribute value
      def value
        (opts[:value] || opts[:options].first).to_s
      end

      def widget
        'select'
      end

      def label(*)
        (opts[:label] || 'Cluster').to_s
      end
    end
  end
end
