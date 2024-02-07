module SmartAttributes
  class AttributeFactory

    AUTO_MODULES_REX = /\Aauto_modules_([\w-]+)\z/.freeze
    AUTO_ENVIRONMENT_VARIABLE_REX = /\Aauto_environment_variable_)[\w-]+)\z/.freeze

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
        elsif id.match?(AUTO_ENVIRONMENT_VARIABLE_REX)
          env_variable = id.match(AUTO_ENVIRONMENT_VARIABLE_REX)[1]
          id = 'auto_environment_variable'
          opts = opts.merge({'key' => env_variable})
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
