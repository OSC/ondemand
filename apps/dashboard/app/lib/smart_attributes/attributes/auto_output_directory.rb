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
      # Value of auto_output_directory attribute
      # Defaults to first script path in the project
      # @return [String] attribute value
      def value
        directory_name(opts[:value] || 'Default Output Directory')
      end

      def widget
        'text_field'
      end

      def label(*)
        (opts[:label] || 'Output Directory').to_s
      end

      # Submission hash describing how to submit this attribute
      # @param fmt [String, nil] formatting of hash
      # @return [Hash] submission hash
      def submit(*)
        { script: { directory_name: value } }
      end

      def directory_name(dir)
        [
          ENV['OOD_PORTAL'], # the OOD portal id
          ENV['RAILS_RELATIVE_URL_ROOT'].to_s.sub(%r{^/[^/]+/}, ''), # the OOD app
          'project-manager',
          dir # the user supplied directory name
        ].reject(&:blank?).join('/')
      end
    end
  end
end
