require 'erb'
require 'fileutils'

module NginxStage
  # Base class for objects that add new sub-commands to NginxStage. {Generator}
  # is basically a class with helper methods and the ability to invoke all
  # callback methods in a sequence.
  class Generator
    # Adds a new hook method that is invoked in the order it is defined
    # @param name [Symbol] unique key defining callback method
    # @yield The body of the generator's callback
    # @return [void]
    def self.add_hook(name, &block)
      self.hooks[name] = block
    end

    # Removes a hook method from the callback chain
    # @param name [Symbol] unique key defining callback method
    # @return [void]
    def self.rem_hook(name)
      self.hooks.delete(name)
    end

    # Returns a hash of callback methods in the order they will be invoked
    # @return [Hash] the callback methods
    def self.hooks
      @hooks ||= from_superclass(:hooks, {})
    end

    # Adds a new option expected from CLI and treats it as an attribute
    # @param name [Symbol] unique key defining option
    # @param default [Object] default value used if no option supplied by CLI
    # @yield Optional code block used if no option supplied by CLI (priority over `default`)
    # @return [void]
    def self.add_option(name, default = nil, &block)
      attr_reader name
      self.options[name] = block || Proc.new { default }
    end

    # Removes an option expected from the CLI and removes attribute method
    # @param name [Symbol] unique key defining option
    # @return [void]
    def self.rem_option(name)
      undef name
      self.options.delete(name)
    end

    # Returns a hash of options
    # @return [Hash] the options treated as attributes
    def self.options
      @options ||= from_superclass(:options, {})
    end

    # @param opts [Hash] various options for controlling the behavior of the generator
    def initialize(opts = {})
      self.class.options.each do |k,v|
        instance_variable_set("@#{k}", opts.fetch(k, &v))
      end
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
    # @param source [String] the relative path to the source file
    # @param destination [String] the relative path to the destination file
    # @return [void]
    def template(source, destination)
      data = File.read File.join(NginxStage.template_root, source)
      create_file destination, render(data)
    end

    # Create a new file at the destination path with the given data
    # @param destination [String] the relative path to the destination file
    # @param data [String] the given data
    # @return [void]
    def create_file(destination, data = "")
      empty_directory File.dirname(destination)
      File.open(destination, "wb", 0644) { |f| f.write data }
    end

    # Create an empty directory if it doesn't already exist
    # @param destination [String] the directory path
    # @return [void]
    def empty_directory(destination)
      FileUtils.mkdir_p destination, mode: 0755
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
        ERB.new(data, nil, '-').result(binding)
      end
  end
end
