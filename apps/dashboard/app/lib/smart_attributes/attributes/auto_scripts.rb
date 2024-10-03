# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    AUTO_SCRIPT_EXTENSIONS = ['sh', 'csh', 'bash', 'slurm', 'sbatch', 'qsub'].freeze

    # Build this attribute object. Must specify a valid directory in opts
    #
    # @param opts [Hash] attribute's options
    # @return [Attributes::AutoScripts] the attribute object
    def self.build_auto_scripts(opts = {})
      dir = Pathname.new(opts[:directory].to_s)
      options = script_options_from_directory(dir)

      static_opts = {
        options: options,
        value:   default_script_value(opts[:value], options)
      }.merge(opts.without(:options, :value).to_h)

      Attributes::AutoScripts.new('auto_scripts', static_opts)
    end

    def self.script_options_from_directory(dir)
      return [] unless dir.directory? && dir.readable?

      Dir.glob("#{dir}/*.{#{AUTO_SCRIPT_EXTENSIONS.join(',')}}").map do |file|
        [File.basename(file), file]
      end.sort_by(&:first)
    end

    def self.default_script_value(default, scripts)
      if !default || scripts.empty?
        nil
      elsif scripts.none? { |s| s[0] == File.basename(default) }
        scripts.first[1].to_s
      else
        scripts.select { |s| s[0] == File.basename(default) }.first[1]
      end
    end
  end

  module Attributes
    class AutoScripts < Attribute
      # Value of auto_scripts attribute
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
