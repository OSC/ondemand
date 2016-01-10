module NginxStage
  module Configuration
    attr_accessor :proxy_user
    attr_accessor :template_root
    attr_accessor :pun_config_root
    attr_accessor :app_config_root
    attr_accessor :pun_tmp_root
    attr_accessor :pun_log_root
    attr_accessor :pun_run_root
    attr_accessor :mime_types_path
    attr_accessor :passenger_root
    attr_accessor :passenger_ruby
    attr_accessor :passenger_nodejs
    attr_accessor :nginx_signals
    attr_accessor :nginx_bin
    attr_accessor :app_root
    attr_accessor :app_namespace
    attr_accessor :app_request_regex
    attr_accessor :min_uid

    def configure
      yield self
    end

    def self.extended(base)
      base.set_default_configuration
    end

    def set_default_configuration
      self.proxy_user = 'apache'
      self.template_root = File.join(root, 'templates')
      self.pun_config_root = File.join('', 'var', 'lib', 'nginx', 'config')
      self.app_config_root = File.join('', 'var', 'lib', 'nginx', 'config')
      self.pun_tmp_root = File.join('', 'var', 'lib', 'nginx', 'tmp')
      self.pun_log_root = File.join('', 'var', 'log', 'nginx')
      self.pun_run_root = File.join('', 'var', 'run', 'nginx')
      self.mime_types_path = '/opt/rh/nginx16/root/etc/nginx/mime.types'
      self.passenger_root = '/opt/rh/rh-passenger40/root/usr/share/passenger/phusion_passenger/locations.ini'
      self.passenger_ruby = '/opt/rh/rh-ruby22/root/usr/bin/ruby'
      self.passenger_nodejs = '/opt/rh/nodejs010/root/usr/bin/node'
      self.nginx_signals = %i(stop quit reopen reload)
      self.nginx_bin = '/opt/rh/nginx16/root/usr/sbin/nginx'
      self.app_root = {
        dev: File.join('~%{owner}', 'ood_dev'),
        shared: File.join('~%{owner}', 'ood_shared')
      }
      self.app_namespace = {
        dev: '%{app}',
        shared: '%{owner}/%{app}'
      }
      self.app_request_regex = {
        dev: %r[^/(?<app>[\w-]+)],
        shared: %r[^/(?<owner>[\w-]+)/(?<app>[\w-]+)]
      }
      self.min_uid = 1000
    end
  end
end
