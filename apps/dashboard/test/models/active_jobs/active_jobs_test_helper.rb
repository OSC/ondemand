# Shared dummy classes for ActiveJobs

module ActiveJobs
  module ActiveJobsTestHelper
    # Status and NodeInfo are freestanding structures, so we simply alias
    Status = OodCore::Job::Status
    NodeInfo = OodCore::Job::NodeInfo

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

      def ==(other)
        (other) ? id == other.to_sym : false
      end

      def to_sym
        id
      end
    end
  end
end