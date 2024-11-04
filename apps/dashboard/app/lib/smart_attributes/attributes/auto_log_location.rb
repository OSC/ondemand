# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    # Build this attribute object. Must specify a valid directory in opts
    #
    # @param opts [Hash] attribute's options
    # @return [Attributes::AutoLogLocation] the attribute object
    def self.build_auto_log_location(opts = {})
      Attributes::AutoLogLocation.new('auto_log_location', opts)
    end
  end

  module Attributes
    class AutoLogLocation < Attribute
      # Value of auto_log_location attribute
      # Defaults to first script path in the project
      # @return [String] attribute value
      def value
        opts[:value].presence
      end

      def widget
        'text_field'
      end

      def label(*)
        # (opts[:label] || 'Log Location').to_s
        (opts[:label] || I18n.t('dashboard.smart_attributes.auto_log_location.title')).to_s
      end

      # Submission hash describing how to submit this attribute
      # @param fmt [String, nil] formatting of hash
      # @return [Hash] submission hash
      def submit(*)
        { script: { output_path: value } }
      end
    end
  end
end
