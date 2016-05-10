# Build options
PREFIX ||= ENV['PREFIX'] || '/opt/ood/ood_auth_map'

#
# Tasks
#

task :default => :install

directory PREFIX

file "#{PREFIX}/bin/ood_auth_map" => ['bin/ood_auth_map', PREFIX] do |t|
  mkdir_p File.dirname(t.name) unless File.directory? File.dirname(t.name)
  cp t.prerequisites.first, t.name
end

desc "Install ood_auth_map into PREFIX"
task :install => "#{PREFIX}/bin/ood_auth_map"
