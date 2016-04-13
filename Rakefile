require 'erb'

VERSION = 'v0.0.1'

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
OOD_IP        ||= ENV['OOD_IP']        || ''
OOD_SUBDOMAIN ||= ENV['OOD_SUBDOMAIN'] || ''
OOD_AUTH_TYPE ||= ENV['OOD_AUTH_TYPE'] || 'openid-connect'

# System options
OOD_LUA_ROOT        ||= ENV['OOD_LUA_ROOT']        || '/opt/ood/mod_ood_proxy/lib'
OOD_PUN_STAGE_CMD   ||= ENV['OOD_PUN_STAGE_CMD']   || 'sudo /opt/ood/nginx_stage/sbin/nginx_stage'
OOD_USER_MAP_CMD    ||= ENV['OOD_USER_MAP_CMD']    || '/opt/ood/osc-user-map/bin/osc-user-map'
OOD_PUN_SOCKET_ROOT ||= ENV['OOD_PUN_SOCKET_ROOT'] || '/var/run/nginx'
OOD_PUBLIC_ROOT     ||= ENV['OOD_PUBLIC_ROOT']     || '/var/www/docroot/ood/public'

# OOD Portal URIs
OOD_PUN_URI    ||= ENV['OOD_PUN_URI']    || '/pun'
OOD_NODE_URI   ||= ENV['OOD_NODE_URI']   || '/node'
OOD_RNODE_URI  ||= ENV['OOD_RNODE_URI']  || '/rnode'
OOD_NGINX_URI  ||= ENV['OOD_NGINX_URI']  || '/nginx'
OOD_PUBLIC_URI ||= ENV['OOD_PUBLIC_URI'] || '/public'

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

desc "Install rendered config file into PREFIX"
task :install => ["#{OBJDIR}/#{OBJFILE}", PREFIX] do |task|
  cp task.prerequisites.first, "#{PREFIX}/"
end

desc "Clean up all temporary rendered configs"
task :clean do |t|
  rm_f "#{OBJDIR}/#{OBJFILE}"
end

desc "Get version of `ood-portal-generator`"
task :version do
  puts "ood-portal-generator #{VERSION}"
end
