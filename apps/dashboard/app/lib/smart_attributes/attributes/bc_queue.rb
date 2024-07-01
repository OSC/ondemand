# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    # Build this attribute object with defined options
    # @param opts [Hash] attribute's options
    # @return [Attributes::BCQueue] the attribute object
    def self.build_bc_queue(opts = {})
      Attributes::BcQueue.new('bc_queue', opts)
    end
  end

  module Attributes
    class BcQueue < Attribute
      # Type of form widget used for this attribute
      # @return [String] widget type
      def widget
        'text_field'
      end

      # Form label for this attribute
      # @param fmt [String, nil] formatting of form label
      # @return [String] form label
      def label(fmt: nil)
        str = opts[:label] || case fmt
                              when 'slurm'
                                'Partition'
                              else
                                'Queue'
                              end
        str.to_s
      end

      # Submission hash describing how to submit this attribute
      # @param fmt [String, nil] formatting of hash
      # @return [Hash] submission hash
      def submit(fmt: nil)
        { script: { queue_name: value.blank? ? nil : value.strip } }
      end
    end
  end
end
