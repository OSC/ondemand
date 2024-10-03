# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    # Build this attribute object with defined options
    # @param opts [Hash] attribute's options
    # @return [Attributes::BCNumSlots] the attribute object
    def self.build_bc_num_slots(opts = {})
      Attributes::BcNumSlots.new('bc_num_slots', opts)
    end
  end

  module Attributes
    class BcNumSlots < Attribute
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
        str = opts[:label] || case fmt
                              when 'lsf'
                                'Number of processors'
                              when 'pbspro'
                                'Number of CPUs on single node'
                              else
                                'Number of nodes'
                              end
        str.to_s
      end

      # Whether this attribute is required
      # @return [Boolean] is required
      def required
        true
      end

      # Submission hash describing how to submit this attribute
      # @param fmt [String, nil] formatting of hash
      # @return [Hash] submission hash
      def submit(fmt: nil)
        slots = value.blank? ? 1 : value.to_i
        native = case fmt
                 when 'torque'
                   { resources: { nodes: slots } }
                 when 'slurm'
                   ['-N', slots]
                 when 'pbspro'
                   ['-l', "select=1:ncpus=#{slots}"]
                 when 'lsf'
                   ['-n', slots]
                 when 'fujitsu_tcs'
                   ['-L', "node=#{slots}"]
                 end
        native ? { script: { native: native } } : {}
      end
    end
  end
end
