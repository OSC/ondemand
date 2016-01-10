require 'erb'
require 'fileutils'

module NginxStage
  class Generator
    def self.add_hook(name, &block)
      self.hooks[name] = block
    end

    def self.hooks
      @hooks ||= from_superclass(:hooks, {})
    end

    def self.from_superclass(method, default = nil)
      if self == NginxStage::Generator || !superclass.respond_to?(method, true)
        default
      else
        superclass.send(method).dup
      end
    end

    def invoke
      output = nil
      self.class.hooks.each {|k,v| output = self.instance_eval(&v)}
      output
    end

    def template(source, destination)
      data = File.read File.join(NginxStage.template_root, source)
      create_file destination, render(data)
    end

    def render(data)
      ERB.new(data).result(binding)
    end

    def create_file(destination, data = "")
      FileUtils.mkdir_p(File.dirname(destination))
      File.open(destination, "wb") do |file|
        file.write data
      end
    end

    def directory(destination, opts = {})
      mode  = opts.fetch(:mode, nil)
      owner = opts.fetch(:owner, nil)
      group = opts.fetch(:group, nil)
      if !File.exist?(destination)
        FileUtils.mkdir_p destination
        FileUtils.chmod mode, destination if mode
        FileUtils.chown owner, group, destination if Process.uid == 0
      end
    end
  end
end
