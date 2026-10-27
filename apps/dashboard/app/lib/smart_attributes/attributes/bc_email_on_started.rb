# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    # Build this attribute object with defined options
    # @param opts [Hash] attribute's options
    # @return [Attributes::BCEmailOnStarted] the attribute object
    def self.build_bc_email_on_started(opts = {})
      Attributes::BcEmailOnStarted.new('bc_email_on_started', opts)
    end
  end

  module Attributes
    class BcEmailOnStarted < Attribute
      # Type of form widget used for this attribute
      # @return [String] widget type
      def widget
        'check_box'
      end

      # Form label for this attribute
      # @param fmt [String, nil] formatting of form label
      # @return [String] form label
      def label(fmt: nil)
        (opts[:label] || 'I would like to receive an email when the session starts').to_s
      end

      # Submission hash describing how to submit this attribute
      # @param fmt [String, nil] formatting of hash
      # @return [Hash] submission hash
      def submit(fmt: nil)
        { script: { email_on_started: !value.to_i.zero? } }
      end
    end
  end
end
