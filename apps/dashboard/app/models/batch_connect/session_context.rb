# frozen_string_literal: true

module BatchConnect
  # The context of a given batch connect session. It encapsulates all the paramters
  # available from the app and the choices made by the user.
  class SessionContext
    include Enumerable

    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    attr_accessor :app_specific_cache_setting

    # Attributes used for serialization
    # @return [Hash{String => String, nil}] attributes to be serialized
    def attributes
      @attributes.reject(&:fixed?).map { |a| [a.id.to_s, nil] }.to_h
    end

    def attributes=(params = {})
      params&.each do |attr, value|
        public_send("#{attr}=", value) if respond_to?("#{attr}=")
      end
    end

    # @param attributes [Array<Attribute>] list of attribute objects
    def initialize(attributes = [], app_specific_cache_setting = nil)
      @attributes = attributes
      @app_specific_cache_setting = app_specific_cache_setting
    end

    # Find attribute in list using the id of the attribute
    # @param id [Object] id of attribute object
    # @return [SmartAttribute::Attribute, nil] attribute object if found
    def [](id)
      @attributes.detect { |attribute| attribute == id }
    end

    # For a block {|attribute| ...}
    # @yield [SmartAttribute::Attribute] Gives the next attribute object in the
    #   list
    def each(&block)
      @attributes.each(&block)
    end

    # Delegate to attribute object's value getter/setter
    # @param method_name the method name called
    # @param arguments the arguments to the call
    # @param block an optional block for the call
    def method_missing(method_name, *arguments, &block)
      if /^(?<id>[^=]+)(?<assign>=)?$/ =~ method_name.to_s && attribute = self[id]
        assign ? attribute.send('value=', *arguments) : attribute.value
      else
        super
      end
    end

    # Check if attribute object exists for value assignment
    # @param method_name the method name to check
    # @return [Boolean]
    def respond_to_missing?(method_name, include_private = false)
      /^(?<id>[^=]+)=?$/ =~ method_name.to_s && self[id] || super
    end

    def update_with_cache(cache)
      self.attributes = cache.select do |k, _v|
        self[k.to_sym] && self[k.to_sym].cacheable?(app_specific_cache_enabled?)
      end
    end

    def to_h
      Hash[*map { |a| [a.id.to_sym, a.value] }.flatten]
    end

    def to_openstruct(addons: {})
      context_attrs = to_h
      illegal_attrs = OpenStruct.new.methods & context_attrs.keys

      unless illegal_attrs.empty?
        raise ArgumentError,
              "#{illegal_attrs.inspect} are keywords that cannot be used as names for form items"
      end

      OpenStruct.new(context_attrs.merge(addons.symbolize_keys))
    end

    private

    FALSE_VALUES = [false, '', 0, '0', 'f', 'F', 'false', 'FALSE', 'off', 'OFF', 'no', 'NO'].freeze

    # Returns false if value is among the FALSE_VALUES set
    # @param value the value to check
    # @return [Boolean]
    def to_bool(value)
      !FALSE_VALUES.include?(value)
    end

    # @return [Boolean]
    def app_specific_cache_enabled?
      if @app_specific_cache_setting.nil?
        global_cache_enabled?
      else
        to_bool(@app_specific_cache_setting)
      end
    end

    # @return [Boolean]
    def global_cache_enabled?
      Configuration.batch_connect_global_cache_enabled?
    end
  end
end
