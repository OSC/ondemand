require 'erb'
require 'fileutils'

module NginxStage
  # Base class for objects that add new sub-commands to NginxStage. {Generator}
  # is basically a class with helper methods and the ability to invoke all
  # callback methods in a sequence.
  class Generator
    # Adds a new hook method that is invoked  in the order it is defined
    # @param [Symbol] name unique key defining callback method
    # @yield The body of the generator's callback
    # @return [void]
    def self.add_hook(name, &block)
      self.hooks[name] = block
    end

    # Returns a hash of callback methods in the order they will be invoked
    # @return [Hash] the callback methods
    def self.hooks
      @hooks ||= from_superclass(:hooks, {})
    end

    # Invokes all the callbacks in the order they are defined in the {hooks}
    # hash
    # @return [Object] returns what is returned from last callback
    def invoke
      output = nil
      self.class.hooks.each {|k,v| output = self.instance_eval(&v)}
      output
    end

    # Gets an ERB template at the relative source, executes it and makes a copy
    # at the relative destination
    # @param [String] source the relative path to the source file
    # @param [String] destination the relative path to the destination file
    # @return [void]
    def template(source, destination)
      data = File.read File.join(NginxStage.template_root, source)
      create_file destination, render(data)
    end

    # Create a new file at the destination path with the given data
    # @param [String] destination the relative path to the destination file
    # @param [String] data the given data
    # @return [void]
    def create_file(destination, data = "")
      FileUtils.mkdir_p File.dirname(destination), mode: 0755
      File.open(destination, "wb") { |f| f.write data }
    end

    private
      # Retrieves a value from superclass. If it reaches the baseclass,
      # returns default
      def self.from_superclass(method, default = nil)
        if self == NginxStage::Generator || !superclass.respond_to?(method, true)
          default
        else
          superclass.send(method).dup
        end
      end

      # Use ERB to render templates
      def render(data)
        ERB.new(data).result(binding)
      end
  end
end
