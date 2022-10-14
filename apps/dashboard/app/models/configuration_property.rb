# A generic class to map configurations to Ruby runtime objects like Intgers, Strings
# and Booleans.
class ConfigurationProperty

  def self.with_boolean_mapper(name:, default_value: nil, read_from_env: false, env_names: nil)
    ConfigurationProperty.new(name, default_value, read_from_env, env_names, BooleanMapper)
  end

  def self.with_integer_mapper(name:, default_value: nil, read_from_env: false, env_names: nil)
    ConfigurationProperty.new(name, default_value, read_from_env, env_names, IntegerMapper)
  end

  def self.property(name:, default_value: nil, read_from_env: false, env_names: nil)
    ConfigurationProperty.new(name, default_value, read_from_env, env_names, PassThroughMapper)
  end

  attr_reader :name, :default_value, :read_from_environment, :environment_names
  alias_method :read_from_environment?, :read_from_environment

  #
  # Represents a profile based configuration property.
  # These properties are used by the UserConfiguration class to manage all profile based configurations.
  #
  # The default environment name is created based on the property name: ["OOD_#{@name.to_s.upcase}"]
  # The different mappers are used to transform string values from the environment to a type.
  #
  # @param name [symbol] name of the property.To be used by UserConfiguration to lookup a value in the config object.
  # @param default_value [any] default value for the property. To be used by UserConfiguration when no value is defined.
  # @param read_from_env [boolean] if true, UserConfiguration will use the ENV to lookup a value.
  # @param env_names [array] list of environment names to lookup a value for this property in the ENV object. It defaults to ["OOD_#{@name.to_s.upcase}"] if nil provided
  # @param mapper [Mapper Class] Mapper to transform strings from the environment to the property type.
  #
  def initialize(name, default_value, read_from_env, env_names, mapper)
    @name = name.to_sym
    @default_value = default_value
    @read_from_environment = !!read_from_env
    @mapper = mapper

    environment_names = env_names || ["OOD_#{@name.to_s.upcase}"]
    @environment_names = @read_from_environment ? environment_names : []
  end

  def map_string(value)
    @mapper.map_string(value)
  end

  class PassThroughMapper
    def self.map_string(string_value)
      string_value
    end
  end

  class IntegerMapper
    def self.map_string(string_value)
      string_value.nil? ? string_value : Integer(string_value.to_s)
    rescue ArgumentError
      Rails.logger.error("Error parsing Integer property: #{string_value}")
      nil
    end
  end

  class BooleanMapper
    def self.map_string(string_value)
      string_value.nil? ? string_value : BooleanMapper.to_bool(string_value.to_s.upcase)
    end

    private
    FALSE_VALUES = ['', '0', 'F', 'FALSE', 'OFF', 'NO'].freeze
    
    def self.to_bool(value)
      !FALSE_VALUES.include?(value)
    end

  end

end