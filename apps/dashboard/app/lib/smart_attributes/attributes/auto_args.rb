module SmartAttributes
    class AttributeFactory
      extend AccountCache
  
      def self.build_auto_args(opts = {})
        Attributes::AutoArgs.new('auto_args', opts)
      end
    end
  
    module Attributes
      class AutoArgs < Attribute
        def initialize(id, opts = {})
          super
  
          @key = @opts.delete(:key)
          # reset the id to be unique from other auto_args_*
          @id = @key ? "#{id}_#{normalize_key(@key)}" : id
        end

        def widget
          'text_field'
        end

        def original_label
          return 'Args' if !@opts[:label] || opts[:label].match('Args')
          @opts[:label].to_s
        end

        def label(*)
          (opts[:label] || "Args: #{@key}").to_s
        end

        def field_options(fmt: nil)
          @key.blank? ? super.merge({readonly: true}) : super
        end

        def normalize_key(key_name)
          key_name.to_s.gsub('-', '_')
        end

        def submit(*)
          { script: { args: ["--#{@key.to_s}", value.to_s ] }}
        end
      end
    end
  end