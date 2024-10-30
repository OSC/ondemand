# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    # Build this attribute object. Must specify a valid directory in opts
    #
    # @param opts [Hash] attribute's options
    # @return [Attributes::AutoOutputDirectory] the attribute object
    def self.build_auto_output_directory(opts = {})
      Attributes::AutoOutputDirectory.new('auto_output_directory', opts)
    end
  end

  module Attributes
    class AutoOutputDirectory < Attribute
      OUTPUT_LOG_SUFFIX = "/%j-output.log"
      

      # Value of auto_output_directory attribute
      # Defaults to first script path in the project
      # @return [String] attribute value
      def value
        opts[:value].presence
      end

      def widget
        'text_field'
      end

      def label(*)
        (opts[:label] || 'Output Directory').to_s
      end

      def output_path_value
        return "#{value}#{OUTPUT_LOG_SUFFIX}" if value
      end

      # Submission hash describing how to submit this attribute
      # @param fmt [String, nil] formatting of hash
      # @return [Hash] submission hash
      def submit(*)
        { script: { output_path: output_path_value }}
      end
    end
  end
end
