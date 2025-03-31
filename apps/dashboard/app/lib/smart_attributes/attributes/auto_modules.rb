# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    # Build this attribute object with defined options
    # @param opts [Hash] attribute's options
    # @return [Attributes::AutoModules] the attribute object
    def self.build_auto_modules(opts = {})
      Attributes::AutoModules.new('auto_modules', opts)
    end
  end

  module Attributes
    # AutoModules populates a select widget of modules from HpcModule class
    # that is cluster aware. Meaning it will attach data-option-for-cluster-X
    # attributes to the options.
    class AutoModules < Attribute
      def initialize(id, opts = {})
        super

        @hpc_module = @opts[:module]
        @id = "#{id}_#{normalize_module(@hpc_module)}" # reset the id to be unique from other auto_module_*
      end

      def widget
        'select'
      end

      def label(*)
        @opts[:label] || (@hpc_module.nil? ? 'Auto modules (none given)' : "#{@hpc_module.titleize} version")
      end

      def select_choices(*)
        versions = hpc_versions
        versions = versions_with_default(versions) if show_default?
        versions = filtered_versions(versions) if filter_versions?
        versions
      end

      def show_default?
        default = @opts[:default]
        default.nil? ? true : default != false
      end

      def filter
        @filter ||= @opts[:filter]
      end

      def filter_versions?
        filter.present?
      end

      # normalize module names so they can be accessed through methods.
      # see https://github.com/OSC/ondemand/issues/2933
      def normalize_module(module_name)
        module_name.to_s.gsub(/[-\/]/, '_').downcase
      end

      private

      def hpc_versions
        HpcModule.all_versions(@hpc_module).map do |mod|
          data_opts = Configuration.job_clusters.map do |cluster|
            { "data-option-for-cluster-#{cluster.id}": false } unless mod.on_cluster?(cluster.id)
          end.compact

          [mod.version, mod.to_s].concat(data_opts)
        end
      end

      def versions_with_default(versions)
        versions.prepend(['default', @hpc_module])
      end

      def filtered_versions(versions)
        versions.reject do |version|
          begin
            if filter.is_a?(Array)
              filter.any? { |f| version[0].match?(Regexp.new(f)) }
            else
              version[0].match?(Regexp.new(filter))
            end
          rescue RegexpError => e
            Rails.logger.error "Can't filter modules because #{e.message}"
          end
        end
      end
    end
  end
end
