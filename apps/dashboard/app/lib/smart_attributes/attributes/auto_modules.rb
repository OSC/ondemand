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
        @id = "#{id}_#{@hpc_module}" # reset the id to be unique from other auto_module_*
      end

      def widget
        'select'
      end

      def label(*)
        @opts[:label] || @hpc_module.nil? ? 'Auto modules (none given)' : "#{@hpc_module.titleize} version"
      end

      def select_choices
        versions = HpcModule.all_versions(@hpc_module).map do |mod|
          data_opts = Configuration.job_clusters.map do |cluster|
            { "data-option-for-cluster-#{cluster.id}": false } unless mod.on_cluster?(cluster.id)
          end.compact

          [mod.version, mod.to_s].concat(data_opts)
        end

        if show_default?
          versions.prepend(['default', @hpc_module])
        else
          versions
        end
      end

      def show_default?
        default = @opts[:default]
        default.nil? ? true : default != false
      end
    end
  end
end
