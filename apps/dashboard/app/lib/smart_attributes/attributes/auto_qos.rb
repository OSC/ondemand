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
    def self.build_auto_qos(opts = {})

      static_opts = {
        options: dynamic_qos
      }.merge(opts.without(:options).to_h)

      Attributes::AutoQos.new('auto_qos', static_opts)
    end
  end

  module Attributes
    class AutoQos < Attribute
      def widget
        'select'
      end

      def label(*)
        (opts[:label] || 'QoS').to_s
      end

      # Submission hash describing how to submit this attribute
      # @param fmt [String, nil] formatting of hash
      # @return [Hash] submission hash
      def submit(*)
        { script: { qos: value } }
      end
    end
  end
end
