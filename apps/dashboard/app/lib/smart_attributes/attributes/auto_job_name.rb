# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    # Build this attribute object. Must specify a valid directory in opts
    #
    # @param opts [Hash] attribute's options
    # @return [Attributes::AutoJobName] the attribute object
    def self.build_auto_job_name(opts = {})
      Attributes::AutoJobName.new('auto_job_name', opts)
    end
  end

  module Attributes
    class AutoJobName < Attribute
      # Value of auto_job_name attribute
      # Defaults to ondemand/[dev,sys]/projects
      # @return [String] attribute value
      def value
        job_name(opts[:value] || 'Project Manager Job')
      end

      def widget
        'text_field'
      end

      def label(*)
        (opts[:label] || 'Job Name').to_s
      end

      # Submission hash describing how to submit this attribute
      # @param fmt [String, nil] formatting of hash
      # @return [Hash] submission hash
      def submit(*)
        { script: { job_name: value } }
      end

      # TODO: need to sanitize the job name for some schedulers
      def job_name(name)
        formatted_prefix = [
          ENV['OOD_PORTAL'], # the OOD portal id
          ENV['RAILS_RELATIVE_URL_ROOT'].to_s.sub(%r{^/[^/]+/}, ''), # the OOD app
          'project-manager'
        ].reject(&:blank?).join('/')
        name.include?(formatted_prefix) ? name : "#{formatted_prefix}/#{name}"
      end
    end
  end
end
