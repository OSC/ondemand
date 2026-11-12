# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    extend AccountCache

    # Build this attribute object. Options are dynamically generated from
    # GPU types advertised on queues via TRES.
    #
    # @param opts [Hash] attribute's options
    # @return [Attributes::AutoGpuType] the attribute object
    def self.build_auto_gpu_type(opts = {})
      static_opts = {
        options: gpu_types
      }.merge(opts.without(:options).to_h)

      Attributes::AutoGpuType.new('auto_gpu_type', static_opts)
    end
  end

  module Attributes
    class AutoGpuType < Attribute
      def widget
        'select'
      end

      def label(*)
        (opts[:label] || 'GPU Type').to_s
      end

      # GPU type is scheduler-specific (e.g. Slurm GRES type). Expose the value
      # for use in submit.yml.erb rather than mapping to a Script attribute.
      def submit(*)
        {}
      end
    end
  end
end
