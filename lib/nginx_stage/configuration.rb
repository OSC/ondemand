module NginxStage
  module Configuration
    attr_accessor :template_root
    attr_accessor :pun_config_root
    attr_accessor :app_config_root
    attr_accessor :pun_tmp_root
    attr_accessor :pun_log_root
    attr_accessor :pun_pid_root
    attr_accessor :pun_sck_root
    attr_accessor :mime_types_path
    attr_accessor :dev_app_relative_root
    attr_accessor :shr_app_relative_root
    attr_accessor :passenger_root
    attr_accessor :passenger_ruby
    attr_accessor :passenger_nodejs
    attr_accessor :sub_uri
    attr_accessor :nginx_signals
    attr_accessor :nginx_bin
    attr_accessor :socket_group
    attr_accessor :min_uid

    def configure
      yield self
    end

    def self.extended(base)
      base.set_default_configuration
    end

    def set_default_configuration
      self.template_root = File.join(root, 'templates')
      self.pun_config_root = File.join('', 'var', 'lib', 'nginx', 'config')
      self.app_config_root = File.join('', 'var', 'lib', 'nginx', 'config')
      self.pun_tmp_root = File.join('', 'var', 'lib', 'nginx', 'tmp')
      self.pun_log_root = File.join('', 'var', 'log', 'nginx')
      self.pun_pid_root = File.join('', 'var', 'run', 'nginx')
      self.pun_sck_root = File.join('', 'var', 'run', 'nginx')
      self.dev_app_relative_root = File.join('ood_dev')
      self.shr_app_relative_root = File.join('ood_shared')
      self.mime_types_path = '/opt/rh/nginx16/root/etc/nginx/mime.types'
      self.passenger_root = '/opt/rh/rh-passenger40/root/usr/share/passenger/phusion_passenger/locations.ini'
      self.passenger_ruby = '/opt/rh/rh-ruby22/root/usr/bin/ruby'
      self.passenger_nodejs = '/opt/rh/nodejs010/root/usr/bin/node'
      self.sub_uri = '/pun'
      self.nginx_signals = %i(stop quit reopen reload)
      self.nginx_bin = '/opt/rh/nginx16/root/usr/sbin/nginx'
      self.socket_group = 'apache'
      self.min_uid = 1000
    end
  end
end
