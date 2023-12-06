module SmartAttributes
  class AttributeFactory
    extend AccountCache

    def self.build_auto_environment_variable(opts = {})
      Attributes::AutoEnvironmentVariable.new('auto_environment_variable', opts)
    end
  end

  module Attributes
    class AutoEnvironmentVariable < Attribute
      def widget
        'key_value_pair'
      end
      
      def label(*)
        (opts[:label] || 'Environment Variable').to_s
      end
    end
  end
end