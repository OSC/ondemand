# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    # Build this attribute object. Must specify a valid directory in opts
    #
    # @param opts [Hash] attribute's options
    # @return [Attributes::AutoScripts] the attribute object
    def self.build_auto_scripts(opts = {})
      dir = Pathname.new(opts[:directory].to_s)
      options = if dir.directory? && dir.readable?
                  Dir.glob("#{dir}/*.{sh,csh,bash,slurm,sbatch,qsub}").map do |file|
                    [File.basename(file), file]
                  end
                else
                  []
                end

      static_opts = {
        options: options
      }.merge(opts.without(:options).to_h)

      Attributes::AutoScripts.new('auto_scripts', static_opts)
    end
  end

  module Attributes
    class AutoScripts < Attribute
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
    end
  end
end
