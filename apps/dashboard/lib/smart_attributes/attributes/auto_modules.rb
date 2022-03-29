# frozen_string_literal: true
module SmartAttributes
  class AttributeFactory
    # Build this attribute object with defined options
    # @param opts [Hash] attribute's options
    # @return [Attributes::AutoModules] the attribute object
    def self.build_auto_modules(opts = {})
      Attributes::AutoModules.new("auto_modules", opts)
    end
  end

  module Attributes


    # AutoModules populates a select widget of modules from HpcModule class
    # that is cluster aware. Meaning it will attach data-option-for-cluster-X
    # attributes to the options.
    class AutoModules < Attribute

      def initialize(id, opts = {})
        @id   = id.to_s
        @opts = opts.to_h.symbolize_keys

        @hpc_module = @opts[:module]
      end

      def widget
        'select'
      end

      # Form label for this attribute
      # @param fmt [String, nil] formatting of form label
      # @return [String] form label
      def label(fmt: nil)
        (opts[:label] || "Module Version").to_s
      end

      def select_choices
        HpcModule.all_versions(@hpc_module).map do |mod|
          data_opts = Configuration.job_clusters.map do |cluster|
            unless HpcModule.on_cluster?(mod, cluster.id)
              { "data-option-for-cluster-#{cluster.id}": false }
            end
          end.compact

          [ mod.version, mod.version ].concat(data_opts)
        end
      end
    end
  end
end
