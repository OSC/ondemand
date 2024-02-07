module SmartAttributes
  class AttributeFactory
    extend AccountCache

    def self.build_auto_environment_variable(opts = {})
      Attributes::AutoEnvironmentVariable.new('auto_environment_variable', opts)
    end
  end

  module Attributes
    class AutoEnvironmentVariable < Attribute
      def initialize(id, opts = {})
        super

        @key = @opts[:key]
        @id = "#{id}_#{normalize_module(@key)}" # reset the id to be unique from other auto_environment_variable_*
      end

      def widget
        'key_value_pair'
      end
      
      def label(*)
        (opts[:label] || 'Environment Variable').to_s
      end

      def normalize_module(module_name)
        module_name.to_s.gsub('-', '_')
      end
    end
  end
end