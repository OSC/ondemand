# Build options
PREFIX ||= ENV['PREFIX'] || '/opt/ood/osc-user-map'

#
# Tasks
#

task :default => :install

directory PREFIX

file "#{PREFIX}/bin/osc-user-map" => ['bin/osc-user-map', PREFIX] do |t|
  mkdir_p File.dirname(t.name) unless File.directory? File.dirname(t.name)
  cp t.prerequisites.first, t.name
end

desc "Install osc-user-map into PREFIX"
task :install => "#{PREFIX}/bin/osc-user-map"
