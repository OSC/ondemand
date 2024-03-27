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
  
          @key = @opts.delete(:key)
          # reset the id to be unique from other auto_environment_variable_*
          @id = @key ? "#{id}_#{normalize_key(@key)}" : id
        end

        def widget
          'text_field'
        end

        def original_label
          return 'Environment Variable' unless @opts[:label]
          @opts[:label].to_s.gsub(": #{@key}", "")
        end

        def label(*)
          "#{original_label}: #{@key}"
        end

        def field_options(fmt: nil)
          @key.blank? ? super.merge({readonly: true}) : super
        end

        def normalize_key(key_name)
          key_name.to_s.gsub('-', '_')
        end

        def submit(*)
          { script: { job_environment: { @key.to_s.upcase: value }}}
        end
      end
    end
  end