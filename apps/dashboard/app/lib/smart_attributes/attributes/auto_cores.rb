# frozen_string_literal: true

module SmartAttributes
    class AttributeFactory
      # Build this attribute object. No options are used as this Attribute
      # is meant to be dynamically generated
      # @param opts [Hash] attribute's options
      # @return [Attributes::AutoGroups] the attribute object
      def self.build_auto_cores(opts = {})
        maximum = 1
        Configuration.job_clusters.each do |cluster|
          max_procs = cluster.job_adapter.nodes.max { |a, b| a.procs <=> b.procs }.procs
          maximum = maximum > max_procs ? maximum : max_procs
        end
        static_opts = {
          max: maximum
        }.merge(opts)
        Attributes::AutoCores.new('auto_cores', static_opts)
      end
    end
  
    module Attributes
      class AutoCores < Attribute
        def opts
          @opts.reverse_merge(min: 1, step: 1)
        end

        def widget
          'number_field'
        end

        def value
          (opts[:value] || '1').to_s
        end
  
        def label(*)
          (opts[:label] || 'Cores').to_s
        end
  
        # Submission hash describing how to submit this attribute
        # @return [Hash] submission hash
        def submit()
          cores = value.blank? ? 1 : value.to_i
          { script: { cores: cores } }
        end
      end
    end
  end
  