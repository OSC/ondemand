# Build options
PREFIX  = ENV['PREFIX']  || '/opt/rh/httpd24/root/etc/httpd/conf.d'
SRCDIR  = ENV['SRCDIR']  || 'templates'
OBJDIR  = ENV['OBJDIR']  || 'build'
OBJFILE = ENV['OBJFILE'] || 'ood-portal.conf'
CNFFILE = ENV['CNFFILE'] || 'config.yml'

#
# Tasks
#

task :default => "#{OBJDIR}/#{OBJFILE}"

directory OBJDIR

desc "Render the Apache config file"
file "#{OBJDIR}/#{OBJFILE}" => ["#{SRCDIR}/#{OBJFILE}.erb", OBJDIR, (CNFFILE if File.file?(CNFFILE))].compact do |task|
  source = task.prerequisites.first
  target = task.name
  sh "bin/generate -c '#{CNFFILE}' -t '#{source}' -o '#{target}'"
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
