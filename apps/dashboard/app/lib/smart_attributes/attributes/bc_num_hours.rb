# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    # Build this attribute object with defined options
    # @param opts [Hash] attribute's options
    # @return [Attributes::BCNumHours] the attribute object
    def self.build_bc_num_hours(opts = {})
      Attributes::BcNumHours.new('bc_num_hours', opts)
    end
  end

  module Attributes
    class BcNumHours < Attribute
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
        (opts[:label] || 'Number of hours').to_s
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
        { script: { wall_time: (value.blank? ? 1 : value.to_i) * 3600 } }
      end
    end
  end
end
