require 'erb'

VERSION = '0.1.0'

class String
  # Nice monkey patch that type casts a string to a boolean
  def to_bool
    return true if self =~ (/^(true|t|yes|y|on|1)$/i)
    return false if self.empty? || self =~ (/^(false|f|no|n|off|0)$/i)
    raise ArgumentError.new "invalid value for Boolean: \"#{self}\""
  end
end

if File.file?('config.rake') && !ENV["SKIP_CONFIG"]
  puts "reading variables from 'config.rake'"
  load 'config.rake'
end

# Build options
PREFIX  ||= ENV['PREFIX']  || '/opt/rh/httpd24/root/etc/httpd/conf.d'
SRCDIR  ||= ENV['SRCDIR']  || 'templates'
OBJDIR  ||= ENV['OBJDIR']  || 'build'
OBJFILE ||= ENV['OBJFILE'] || 'ood-portal.conf'

# Server options
OOD_IP             ||= ENV['OOD_IP']             || ''
OOD_PORT           ||= ENV['OOD_PORT']           || '443'
OOD_SERVER_NAME    ||= ENV['OOD_SERVER_NAME']    || ''
OOD_SERVER_ALIASES ||= ENV['OOD_SERVER_ALIASES'] || ''
OOD_LOGS           ||= (ENV['OOD_LOGS']          || 'true').to_bool
OOD_SSL            ||= (ENV['OOD_SSL']           || 'true').to_bool
OOD_SSL_REDIRECT   ||= (ENV['OOD_SSL_REDIRECT']  || 'true').to_bool
OOD_SSL_CERT_FILE  ||= ENV['OOD_SSL_CERT_FILE']  || ''
OOD_SSL_KEY_FILE   ||= ENV['OOD_SSL_KEY_FILE']   || ''
OOD_SSL_CHAIN_FILE ||= ENV['OOD_SSL_CHAIN_FILE'] || ''

# System options
OOD_LUA_ROOT        ||= ENV['OOD_LUA_ROOT']        || '/opt/ood/mod_ood_proxy/lib'
OOD_LUA_LOG_LEVEL   ||= ENV['OOD_LUA_LOG_LEVEL']   || 'info'
OOD_PUN_STAGE_CMD   ||= ENV['OOD_PUN_STAGE_CMD']   || 'sudo /opt/ood/nginx_stage/sbin/nginx_stage'
OOD_PUN_MAX_RETRIES ||= ENV['OOD_PUN_MAX_RETRIES'] || '5'
OOD_USER_MAP_CMD    ||= ENV['OOD_USER_MAP_CMD']    || '/opt/ood/ood_auth_map/bin/ood_auth_map.regex'
OOD_PUN_SOCKET_ROOT ||= ENV['OOD_PUN_SOCKET_ROOT'] || '/var/run/nginx'
OOD_PUBLIC_ROOT     ||= ENV['OOD_PUBLIC_ROOT']     || '/var/www/ood/public'

# OOD Portal URIs
OOD_PUN_URI    ||= ENV['OOD_PUN_URI']      || '/pun'
OOD_NODE_URI   ||= ENV['OOD_NODE_URI']     || ''
OOD_RNODE_URI  ||= ENV['OOD_RNODE_URI']    || ''
OOD_NGINX_URI  ||= ENV['OOD_NGINX_URI']    || '/nginx'
OOD_PUBLIC_URI ||= ENV['OOD_PUBLIC_URI']   || '/public'
OOD_ROOT_URI   ||= ENV['OOD_ROOT_URI']     || '/pun/sys/dashboard'

# OOD Auth Setup
OOD_AUTH_CILOGON ||= (ENV['OOD_AUTH_CILOGON'] || 'false').to_bool
if OOD_AUTH_CILOGON
  OOD_AUTH_OIDC_URI      ||= ENV['OOD_AUTH_OIDC_URI']      || '/oidc'
  OOD_AUTH_DISCOVER_ROOT ||= ENV['OOD_AUTH_DISCOVER_ROOT'] || '/var/www/ood/discover'
  OOD_AUTH_DISCOVER_URI  ||= ENV['OOD_AUTH_DISCOVER_URI']  || '/discover'
  OOD_AUTH_REGISTER_ROOT ||= ENV['OOD_AUTH_REGISTER_ROOT'] || '/var/www/ood/register'
  OOD_AUTH_REGISTER_URI  ||= ENV['OOD_AUTH_REGISTER_URI']  || '/register'

  OOD_AUTH_TYPE    = 'openid-connect'
  OOD_AUTH_EXTEND  = ''
  OOD_MAP_FAIL_URI = OOD_AUTH_REGISTER_URI
else
  OOD_AUTH_OIDC_URI      ||= ENV['OOD_AUTH_OIDC_URI']      || ''
  OOD_AUTH_DISCOVER_ROOT ||= ENV['OOD_AUTH_DISCOVER_ROOT'] || '/var/www/ood/discover'
  OOD_AUTH_DISCOVER_URI  ||= ENV['OOD_AUTH_DISCOVER_URI']  || ''
  OOD_AUTH_REGISTER_ROOT ||= ENV['OOD_AUTH_REGISTER_ROOT'] || '/var/www/ood/register'
  OOD_AUTH_REGISTER_URI  ||= ENV['OOD_AUTH_REGISTER_URI']  || ''

  OOD_AUTH_TYPE    ||= ENV['OOD_AUTH_TYPE']    || 'Basic'
  OOD_AUTH_EXTEND  ||= ENV['OOD_AUTH_EXTEND']  || 'AuthName "private"\nAuthUserFile "/opt/rh/httpd24/root/etc/httpd/.htpasswd"'
  OOD_MAP_FAIL_URI ||= ENV['OOD_MAP_FAIL_URI'] || ''
end

# OOD Analytics
OOD_ANALYTICS_OPT_IN ||= (ENV['OOD_ANALYTICS_OPT_IN'] || 'false').to_bool
if OOD_ANALYTICS_OPT_IN
  OOD_ANALYTICS_TRACKING_URL = 'http://www.google-analytics.com/collect'
  OOD_ANALYTICS_TRACKING_ID  = 'UA-79331310-4'
end

#
# Tasks
#

task :default => "#{OBJDIR}/#{OBJFILE}"

directory OBJDIR

desc "Render the ERB template config file"
file "#{OBJDIR}/#{OBJFILE}" => ["#{SRCDIR}/#{OBJFILE}.erb", OBJDIR] do |task|
  source = task.prerequisites.first
  target = task.name
  puts "rendering #{source} => #{target}"
  data = File.read source
  result = ERB.new(data, nil, '-').result(binding)
  File.open(target, 'w') { |f| f.write(result) }
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
