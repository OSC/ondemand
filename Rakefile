require 'erb'

VERSION = 'v0.0.1'

task :default => :build

# Build options
PREFIX    = ENV['PREFIX']    || '/opt/rh/httpd24/root/etc/httpd/conf.d'
TEMPLATES = ENV['TEMPLATES'] || 'templates'
OBJDIR    = ENV['OBJDIR']    || 'build'

# Server options
OOD_IP        = ENV['OOD_IP']        || '*:5000'
OOD_SUBDOMAIN = ENV['OOD_SUBDOMAIN'] || 'apps.ondemand.org'
OOD_AUTH_TYPE = ENV['OOD_AUTH_TYPE'] || 'openid-connect'

# System options
OOD_LUA_ROOT        = ENV['OOD_LUA_ROOT']        || '/nfs/17/jnicklas/Development/mod_ood_proxy/lib'
OOD_PUN_STAGE_CMD   = ENV['OOD_PUN_STAGE_CMD']   || 'sudo /opt/ood/nginx_stage/sbin/nginx_stage_dev --config /nfs/17/jnicklas/Development/nginx_stage/config.yml --'
OOD_USER_MAP_CMD    = ENV['OOD_USER_MAP_CMD']    || '/nfs/17/jnicklas/Development/osc-user-map/bin/osc-user-map'
OOD_PUN_SOCKET_ROOT = ENV['OOD_PUN_SOCKET_ROOT'] || '/var/tmp/nginx_stage0/var/run/nginx'
OOD_PUBLIC_ROOT     = ENV['OOD_PUBLIC_ROOT']     || '/nfs/gpfs/PZS0645/www/public'

# OOD Portal URIs
OOD_PUN_URI    = ENV['OOD_PUN_URI']    || '/pun'
OOD_NODE_URI   = ENV['OOD_NODE_URI']   || '/node'
OOD_RNODE_URI  = ENV['OOD_RNODE_URI']  || '/rnode'
OOD_NGINX_URI  = ENV['OOD_NGINX_URI']  || '/nginx'
OOD_PUBLIC_URI = ENV['OOD_PUBLIC_URI'] || '/public'

SRC_FILES = Rake::FileList.new("#{TEMPLATES}/*.erb")
OBJ_FILES = SRC_FILES.pathmap("%{^#{TEMPLATES}/,#{OBJDIR}/}X")

desc "Get version of `ood-portal-generator`"
task :version do
  puts "ood-portal-generator #{VERSION}"
end

desc "Build the templates in '#{OBJDIR}/'"
task :build => OBJ_FILES

directory "#{OBJDIR}/"

directory "#{PREFIX}/"

rule %r[^#{OBJDIR}/] => [->(f){source_file(f)}, "#{OBJDIR}/"] do |t|
  puts "rendering #{t.source} => #{t.name}"
  data = File.read t.source
  result = ERB.new(data, nil, '-').result(binding)
  File.open(t.name, 'w') { |f| f.write(result) }
end

def source_file(file)
  SRC_FILES.detect do |f|
    f.ext == file.pathmap("%{^#{OBJDIR}/,#{TEMPLATES}/}p")
  end || ""
end

desc "Install rendered files into PREFIX"
task :install => [:build, "#{PREFIX}/"] do
  OBJ_FILES.each { |file| cp file, PREFIX }
end

desc "Clean up rendered files in '#{OBJDIR}/'"
task :clean do |t|
  OBJ_FILES.each { |file| rm_f file }
end
