# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    extend AccountCache

    # Build this attribute object. No 'options' are used as this Attribute
    # is meant to be dynamically generated from the users' available accounts
    # from a given scheduler.
    #
    # @param opts [Hash] attribute's options
    # @return [Attributes::AutoQueues] the attribute object
    def self.build_auto_queues(opts = {})
      static_opts = {
        options: queues
      }.merge(opts.without(:options).to_h)

      Attributes::AutoQueues.new('auto_queues', static_opts)
    end
  end

  module Attributes
    class AutoQueues < Attribute
      def widget
        'select'
      end

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
      def submit(*)
        { script: { queue_name: value } }
      end
    end
  end
end
