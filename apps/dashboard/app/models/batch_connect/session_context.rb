module BatchConnect
  class SessionContext
    include Enumerable

    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    # Attributes used for serialization
    # @return [Hash{String => String, nil}] attributes to be serialized
    def attributes
      @attributes.reject(&:fixed?).map { |a| [a.id.to_s, nil] }.to_h
    end

    def attributes=(params = {})
      params.each do |attr, value|
        self.public_send("#{attr}=", value) if self.respond_to?("#{attr}=")
      end if params
    end

    # @param attributes [Array<Attribute>] list of attribute objects
    def initialize(attributes = [])
      @attributes = attributes
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

    # Get the binding for this object
    # @return [Binding] binding of this object
    def get_binding
      binding
    end

    # Delegate to attribute object's value getter/setter
    # @param method_name the method name called
    # @param arguments the arguments to the call
    # @param block an optional block for the call
    def method_missing(method_name, *arguments, &block)
      if /^(?<id>[^=]+)(?<assign>=)?$/ =~ method_name.to_s && attribute = self[id]
        assign ? attribute.send("value=", *arguments) : attribute.value
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
    

    # Determines if any of the attributes are cacheable on a per attribute level
    # If more attributes need to be cached in the future, consider iterating through Self
    #instead of cehcking each attribute manually 
    # return [Boolean]
    def attribute_has_cache_enabled?
     if !( self[:num_cores].opts[:cacheable]) && !(self[:bc_num_hours].opts[:cacheable])
       false
     else 
       true 
     end
    end
   
    # value of atttribute only changes if set through the Attribute.value setter,
    # updating the hash directly will result in the attribute mainting its old value.
    def test()
      self[:bc_num_hours].value = 4
      self[:bc_num_hours].opts  
     # self.map  {|element| element}
    end

    # Logic for updating cacheable attributes 
    # As of now only bc_num_hours & num_cores are cacheble 
    # return nil, updates Self[:Attribute].value
    def load_from_cache(cache)
     if self[:num_cores].opts[:cacheable] && self[:bc_num_hours].opts[:cacheable]

       self[:num_cores].opts[:value] =  cache.fetch("num_cores", {})
       self[:bc_num_hours].value =  cache.fetch("bc_num_hours", {})
     
     elsif self[:num_cores].opts[:cacheable]

       self[:num_cores].opts[:value] =  cache.fetch("num_cores", {})
     
     elsif self[:bc_num_hours].opts[:cacheable]
      
       self[:bc_num_hours].value = cache.fetch("bc_num_hours", {}) 
     
     end
    end

    #Logic or determining if attributes should be pulled from cache
    # cache can be set either per attribute, per app, or system wide 
    def update_from(cache)
      if attribute_has_cache_enabled?
       load_from_cache(cache)       
      end
        
    end

  end
end
