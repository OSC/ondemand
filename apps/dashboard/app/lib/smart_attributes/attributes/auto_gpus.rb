# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    # Build this attribute object. No options are used as this Attribute
    # is meant to be dynamically generated.
    # @param opts [Hash] attribute's options
    # @return [Attributes::AutoGpus] the attribute object
    def self.build_auto_gpus(opts = {})
      Attributes::AutoGpus.new('auto_gpus', opts)
    end
  end

  module Attributes
    class AutoGpus < Attribute
      def initialize(id, opts)
        super(id, opts)
        @opts = @opts.reverse_merge(min: 1, step: 1)
      end

      def widget
        'number_field'
      end

      def value
        (opts[:value] || '1').to_s
      end

      def label(*)
        (opts[:label] || 'Number of GPUs').to_s
      end

      # Submission hash describing how to submit this attribute
      # @return [Hash] submission hash
      def submit(*)
        gpus = value.blank? ? 1 : value.to_i
        { script: { gpus_per_node: gpus } }
      end
    end
  end
end
