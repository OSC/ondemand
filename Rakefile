require "rake/testtask"

#
# Define tasks for `rake test`
#

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
end

# Set default rake task to `test`
task :default => :test

#
# Define tasks needed for `rake install`
#

PREFIX = ENV['PREFIX'] || '/opt/ood/nginx_stage'

desc <<-DESC
Install nginx_stage into env var PREFIX
Default: PREFIX=/opt/ood/nginx_stage
DESC
task :install => [:required_files, "#{PREFIX}/config/nginx_stage.yml", "#{PREFIX}/bin/ood_ruby"] do
end

# Dynamically generate tasks for copying required files
FileList['sbin/nginx_stage', 'sbin/nginx_stage_dev', 'config/nginx_stage.yml.example', 'lib/**/*.rb'].each do |source|
  target = "#{PREFIX}/#{source}"
  file target => [source] do
    mkdir_p File.dirname(target) unless File.directory? File.dirname(target)
    cp source, target
  end
  task :required_files => target
end

# Generate default config yaml file
file "#{PREFIX}/config/nginx_stage.yml" => 'config/nginx_stage.yml.example' do |task|
  target = task.name
  unless File.exists? target
    mkdir_p File.dirname(target) unless File.directory? File.dirname(target)
    cp task.prerequisites.first, target
    puts <<-EOF.gsub(/^\s{6}/, '')
      \n#
      # Created initial configuration file.
      #
      # You can modify the configuration file here:
      #
      #     #{target}
      #\n
    EOF
  end
end

# Generate default Ruby wrapper script
file "#{PREFIX}/bin/ood_ruby" => 'bin/ood_ruby.example' do |task|
  target = task.name
  unless File.exists? target
    mkdir_p File.dirname(target) unless File.directory? File.dirname(target)
    cp task.prerequisites.first, target
    puts <<-EOF.gsub(/^\s{6}/, '')
      \n#
      # Created initial Ruby wrapper script.
      #
      # You can modify the Ruby wrapper script here:
      #
      #     #{target}
      #\n
    EOF
  end
end
