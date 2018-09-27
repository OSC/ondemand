# Build options
PREFIX ||= ENV['PREFIX'] || '/opt/ood/mod_ood_proxy'

#
# Tasks
#

task :default => :install

directory PREFIX

# Dynamically generate tasks for copying required files
FileList['lib/**/*.lua'].each do |source|
  target = "#{PREFIX}/#{source}"
  file target => [source, PREFIX] do
    mkdir_p File.dirname(target) unless File.directory? File.dirname(target)
    cp source, target
  end
  task :required_files => target
end

desc <<-DESC
Install mod_ood_proxy into PREFIX
Default: PREFIX=/opt/ood/mod_ood_proxy
DESC
task :install => :required_files
