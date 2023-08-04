module SmartAttributes
  class AttributeFactory

    AUTO_MODULES_REX = /\Aauto_modules_([\w-]+)\z/.freeze

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
