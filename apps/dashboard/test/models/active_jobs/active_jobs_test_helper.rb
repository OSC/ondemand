# Shared dummy classes for ActiveJobs

module ActiveJobs
  module ActiveJobsTestHelper
    Node = Struct.new(:name)
    Status = Struct.new(:state)

    Metadata = Struct.new(:title)

    class FakeJobAdapter
      def supports_job_arrays?
        true
      end
    end

    class FakeCluster
      attr_reader :id, :metadata

      def initialize(id:, title:)
        @id = id
        @metadata = Metadata.new(title)
      end

      def self.set_adapter(setting)
        @adapter = setting
      end

      def job_config
        { adapter: @adapter || 'slurm' }
      end

      def job_adapter
        FakeJobAdapter.new
      end
    end
  end
end