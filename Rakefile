require 'erb'

VERSION = '0.0.1'

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
OOD_IP           ||= ENV['OOD_IP']            || ''
OOD_PORT         ||= ENV['OOD_PORT']          || '443'
OOD_SSL          ||= (ENV['OOD_SSL']          || 'true').to_bool
OOD_SSL_REDIRECT ||= (ENV['OOD_SSL_REDIRECT'] || 'true').to_bool
OOD_SERVER_NAME  ||= ENV['OOD_SERVER_NAME']   || 'www.example.com'
OOD_AUTH_TYPE    ||= ENV['OOD_AUTH_TYPE']     || 'openid-connect'

# System options
OOD_LUA_ROOT        ||= ENV['OOD_LUA_ROOT']        || '/opt/ood/mod_ood_proxy/lib'
OOD_PUN_STAGE_CMD   ||= ENV['OOD_PUN_STAGE_CMD']   || 'sudo /opt/ood/nginx_stage/sbin/nginx_stage'
OOD_PUN_MAX_RETRIES ||= ENV['OOD_PUN_MAX_RETRIES'] || '5'
OOD_USER_MAP_CMD    ||= ENV['OOD_USER_MAP_CMD']    || '/opt/ood/ood_auth_map/bin/ood_auth_map'
OOD_PUN_SOCKET_ROOT ||= ENV['OOD_PUN_SOCKET_ROOT'] || '/var/run/nginx'
OOD_PUBLIC_ROOT     ||= ENV['OOD_PUBLIC_ROOT']     || '/var/www/ood/public'

# OOD Portal URIs
OOD_PUN_URI      ||= ENV['OOD_PUN_URI']      || '/pun'
OOD_NODE_URI     ||= ENV['OOD_NODE_URI']     || '/node'
OOD_RNODE_URI    ||= ENV['OOD_RNODE_URI']    || '/rnode'
OOD_NGINX_URI    ||= ENV['OOD_NGINX_URI']    || '/nginx'
OOD_PUBLIC_URI   ||= ENV['OOD_PUBLIC_URI']   || '/public'
OOD_MAP_FAIL_URI ||= ENV['OOD_MAP_FAIL_URI'] || '/register'

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

desc "Install rendered config file into PREFIX"
task :install => "#{PREFIX}/#{OBJFILE}"

desc "Clean up all temporary rendered configs"
task :clean do |t|
  rm_f "#{OBJDIR}/#{OBJFILE}"
end

desc "Get version of `ood-portal-generator`"
task :version do
  puts "ood-portal-generator v#{VERSION}"
end
