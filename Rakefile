require 'yaml'
require 'erb'

# Build options
PREFIX  ||= ENV['PREFIX']  || '/opt/rh/httpd24/root/etc/httpd/conf.d'
SRCDIR  ||= ENV['SRCDIR']  || 'templates'
OBJDIR  ||= ENV['OBJDIR']  || 'build'
OBJFILE ||= ENV['OBJFILE'] || 'ood-portal.conf'
CNFFILE ||= ENV['CNFFILE'] || 'config.yml'

class OodPortalGenerator
  def initialize(opts = {})
    # Portal configuration
    @listen_addr_port = opts.fetch("listen_addr_port", nil)
    @ssl              = opts.fetch("ssl", nil)
    @ip               = opts.fetch("ip", nil)
    @port             = opts.fetch("port", nil)
    @servername       = opts.fetch("servername", nil)
    @logroot          = opts.fetch("logroot", "logs")
    @lua_root         = opts.fetch("lua_root", "/opt/ood/mod_ood_proxy/lib")
    @lua_log_level    = opts.fetch("lua_log_level", nil)
    @user_map_cmd     = opts.fetch("user_map_cmd", "/opt/ood/ood_auth_map/bin/ood_auth_map.regex")
    @map_file_uri     = opts.fetch("map_file_uri", nil)
    @pun_stage_cmd    = opts.fetch("pun_stage_cmd", "sudo /opt/ood/nginx_stage/sbin/nginx_stage")

    # Portal authentication
    @auth = opts.fetch("auth", [
      %q{AuthType Basic},
      %q{AuthName "Private"},
      %q{AuthUserFile "/opt/rh/httpd24/root/etc/httpd/.htpasswd"},
      %q{RequestHeader unset Authorization},
      %q{Require valid-user}
    ])

    # Portal analytics
    @analytics = opts.fetch("analytics", {
      "url" => "http://www.google-analytics.com/collect",
      "id"  => "UA-79331310-4"
    })

    # Redirect for the root uri
    @root_uri = opts.fetch("root_uri", "/pun/sys/dashboard")

    #
    # Available sub-uri's and their configurations
    #

    # Pubic sub-uri
    @public_uri  = opts.fetch("public_uri", "/public")
    @public_root = opts.fetch("public_root", "/var/www/ood/public")

    # Basic reverse proxy sub-uri
    @host_regex = opts.fetch("host_regex", "[^/]+")
    @node_uri   = opts.fetch("node_uri", nil)
    @rnode_uri  = opts.fetch("rnode_uri", nil)

    # Per-user NGINX sub-uri
    @nginx_uri       = opts.fetch("nginx_uri", "/nginx")
    @pun_uri         = opts.fetch("pun_uri", "/pun")
    @pun_socket_root = opts.fetch("pun_socket_root", "/var/run/nginx")
    @pun_max_retries = opts.fetch("pun_max_retries", 5)

    # OpenID Connect sub-uri
    @oidc_uri           = opts.fetch("oidc_uri", nil)
    @oidc_discover_uri  = opts.fetch("oidc_discover_uri", nil)
    @oidc_discover_root = opts.fetch("oidc_discover_root", nil)

    # Register unmapped user sub-uri
    @register_uri  = opts.fetch("register_uri", nil)
    @register_root = opts.fetch("register_root", nil)
  end

  def render(str)
    ERB.new(str, nil, '-').result(binding)
  end
end

#
# Tasks
#

task :default => "#{OBJDIR}/#{OBJFILE}"

directory OBJDIR

desc "Render the Apache config file"
file "#{OBJDIR}/#{OBJFILE}" => ["#{SRCDIR}/#{OBJFILE}.erb", OBJDIR, (CNFFILE if File.file?(CNFFILE))].compact do |task|
  source = task.prerequisites.first
  target = task.name
  puts "rendering #{source} => #{target}"
  portal_config = File.file?(CNFFILE) ? YAML.load_file(CNFFILE) : {}
  portal = OodPortalGenerator.new(portal_config)
  File.open(target, 'w') { |f| f.write(portal.render(File.read(source))) }
end

directory PREFIX

file "#{PREFIX}/#{OBJFILE}" => ["#{OBJDIR}/#{OBJFILE}", PREFIX] do |task|
  cp task.prerequisites.first, task.name
end

desc <<-DESC
Install rendered config file into PREFIX
Default: PREFIX=/opt/rh/httpd24/root/etc/httpd/conf.d
DESC
task :install => "#{PREFIX}/#{OBJFILE}"

desc "Clean up all temporary rendered configs"
task :clean do |t|
  rm_f "#{OBJDIR}/#{OBJFILE}"
end

desc "Get version of `ood-portal-generator`"
task :version do
  puts "ood-portal-generator v#{VERSION}"
end
