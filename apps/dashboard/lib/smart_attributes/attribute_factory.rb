module SmartAttributes
  class AttributeFactory
    extend ActiveSupport::Autoload

    AUTO_MODULES_REX = /^auto_modules_([\w_]+)$/.freeze

    class << self
      # Build an attribute object from an id and its options
      # @param id [#to_s] id of attribute
      # @param opts [Hash] attribute options
      # @return [Attribute] the attribute object
      def build(id, opts = {})
        id = id.to_s
        if id.match?(AUTO_MODULES_REX)
          hpc_mod = id.match(AUTO_MODULES_REX)[1]
          id = 'auto_modules'
          opts = opts.merge({'module' => hpc_mod})
        end

        path_to_attribute = "smart_attributes/attributes/#{id}"
        begin
          require path_to_attribute
        rescue Gem::LoadError
          raise Gem::LoadError, "Specified '#{id}' attribute, but the gem is not loaded."
        rescue LoadError  # ignore if file doesn't exist
          nil
        end

        build_method = "build_#{id}"
        if respond_to?(build_method)
          send(build_method, opts)
        else
          Attribute.new(id, opts)
        end
      end
    end
  end
end
