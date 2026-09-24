# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    # Build this attribute object. No options are used as this Attribute
    # is meant to be dynamically generated
    # @param opts [Hash] attribute's options
    # @return [Attributes::AutoNumNodes] the attribute object
    def self.build_auto_num_nodes(opts = {})
      Attributes::AutoNumNodes.new('auto_num_nodes', opts)
    end
  end

  module Attributes
    class AutoNumNodes < Attribute
      def initialize(id, opts)
        super(id, opts)
        @opts = @opts.reverse_merge(min: 1, step: 1)
      end

      # Value of attribute
      # @return [String] attribute value
      def value
        (opts[:value] || '1').to_s
      end

      # Type of form widget used for this attribute
      # @return [String] widget type
      def widget
        'number_field'
      end

      # Form label for this attribute
      # @param fmt [String, nil] formatting of form label
      # @return [String] form label
      def label(fmt: nil)
        (opts[:label] || 'Number of nodes').to_s
      end

      # Submission hash describing how to submit this attribute
      # @param fmt [String, nil] formatting of hash
      # @return [Hash] submission hash
      def submit(fmt: nil)
        nodes = value.blank? ? 1 : value.to_i
        native = case fmt
                 when 'torque'
                   { resources: { nodes: nodes } }
                 when 'slurm'
                   ['-N', nodes]
                 when 'pbspro'
                   ['-l', "select=#{nodes}"]
                 when 'lsf'
                   ['-n', nodes]
                 when 'fujitsu_tcs'
                   ['-L', "node=#{nodes}"]
                 end
        native ? { script: { native: native } } : {}
      end
    end
  end
end
