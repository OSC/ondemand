module SmartAttributes
  class AttributeFactory
    extend ActiveSupport::Autoload

    class << self
      # Build an attribute object from an id and its options
      # @param id [#to_s] id of attribute
      # @param opts [Hash] attribute options
      # @return [Attribute] the attribute object
      def build(id, opts = {})
        id = id.to_s

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
