module SmartAttributes
  class AttributeFactory

    # Build this attribute object. Must specify a valid directory in opts
    #
    # @param opts [Hash] attribute's options
    # @return [Attributes::AutoOutputDirectory] the attribute object
    def self.build_auto_output_directory(opts = {})
      Attributes::AutoOutputDirectory.new('auto_output_directory', opts)
    end
    def self.default_directory_value(default)
      
    end
  end

  module Attributes
    class AutoOutputDirectory < Attribute
      # Value of auto_output_directory attribute
      # Defaults to first script path in the project
      # @return [String] attribute value
      def value
        return nil if !opts[:value] && opts[:options].empty?

        (opts[:value] || opts[:options].first.last).to_s
      end

      def widget
        'select'
      end

      def label(*)
        (opts[:label] || 'Script').to_s
      end

      # Submission hash describing how to submit this attribute
      # @param fmt [String, nil] formatting of hash
      # @return [Hash] submission hash
      def submit(*)
        content = File.read(value)
        { script: { content: content } }
      end

      # Hash of both field options and html options
      # @return [Hash] key value pairs are field and html options
      def all_options(fmt: nil)
        super(fmt: fmt).merge({ directory: directory })
      end

      def directory
        opts[:directory]
      end
    end
  end
end
