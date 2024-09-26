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
        value:   default_script_value(opts, options, dir)
      }.merge(opts.without(:options, :value).to_h)

      Attributes::AutoScripts.new('auto_scripts', static_opts)
    end

    def self.script_options_from_directory(dir)
      return [] unless dir.directory? && dir.readable?

      Dir.glob("#{dir}/*.{#{AUTO_SCRIPT_EXTENSIONS.join(',')}}").map do |file|
        [File.basename(file), file]
      end.sort_by(&:first)
    end

    def self.default_script_value(initial_opts, script_opts, dir)
      return nil if !initial_opts[:value] || script_opts.empty?

      # Replace directory if the script is present in correct directory, otherwise delete value
      swapped_dir = "#{dir}/#{File.basename(initial_opts[:value])}"
      if script_opts.any?(swapped_dir)
        initial_opts[:value] = swapped_dir
      elsif script_opts&.none? { |opt| opt.include?(initial_opts[:value]) }
        initial_opts.delete(:value)
      end

      (initial_opts[:value] || script_opts.first.last).to_s
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
