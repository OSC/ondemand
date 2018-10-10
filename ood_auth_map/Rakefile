# Build options
PREFIX ||= ENV['PREFIX'] || '/opt/ood/ood_auth_map'

#
# Tasks
#

task :default => :install

desc <<-DESC
Install ood_auth_map into env var PREFIX
Default: PREFIX=/opt/ood/ood_auth_map
DESC
task :install => [:required_files]

# Dynamically generate tasks for copying required files
FileList['bin/ood_auth_map.mapfile', 'bin/ood_auth_map.regex', 'lib/**/*.rb'].each do |source|
  target = "#{PREFIX}/#{source}"
  file target => [source] do
    mkdir_p File.dirname(target) unless File.directory?(File.dirname(target))
    cp source, target
  end
  task :required_files => target
end
