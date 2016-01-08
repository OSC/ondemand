require 'erb'
require 'fileutils'

module NginxStage
  class Generate
    def self.add_hook(name, &block)
      self.hooks[name] = block
    end

    def self.hooks
      @hooks ||= from_superclass(:hooks, {})
    end

    def self.from_superclass(method, default = nil)
      if self == NginxStage::Generate || !superclass.respond_to?(method, true)
        default
      else
        superclass.send(method).dup
      end
    end

    attr_reader :options

    attr_reader :user
    attr_reader :skip_nginx

    def initialize(opts)
      @options    = opts.dup
      @user       = opts.fetch(:user, nil)
      @skip_nginx = opts.fetch(:skip_nginx, false)
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
      destination
    end

    add_hook :require_user do
      raise MissingOption, "missing option: --user=USER" unless user
    end

    add_hook :validate_user do
      check_user_exists(user)
      check_user_is_special(user)
    end

    private
      def check_user_exists(user)
        Etc.getpwnam(user)
      rescue ArgumentError
        raise InvalidUser, "user doesn't exist: #{user}"
      end

      def check_user_is_special(user)
        passwd = Etc.getpwnam(user)
        raise InvalidUser, "user is special: #{user} (#{passwd.uid} < #{NginxStage.min_uid})" if passwd.uid < NginxStage.min_uid
      end
  end
end
