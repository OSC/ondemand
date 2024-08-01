# frozen_string_literal: true

module SmartAttributes
    class AttributeFactory
      # Build this attribute object. No options are used as this Attribute
      # is meant to be dynamically generated from the users' unix groups
      # @param opts [Hash] attribute's options
      # @return [Attributes::AutoGroups] the attribute object
      def self.build_auto_cores(opts = {})
        Attributes::AutoCores.new('auto_cores', opts)
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
        # @param fmt [String, nil] formatting of hash
        # @return [Hash] submission hash
        def submit(*)
          { }
        end
      end
    end
  end
  