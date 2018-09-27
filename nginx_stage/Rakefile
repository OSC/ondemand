require "rake/testtask"
require "yaml"

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
task :install => [:required_files] do
end

# Dynamically generate tasks for copying required files
FileList['sbin/*', 'bin/*', 'share/*', 'templates/*.erb', 'lib/**/*.rb'].each do |source|
  target = "#{PREFIX}/#{source}"
  file target => [source] do
    mkdir_p File.dirname(target) unless File.directory? File.dirname(target)
    cp source, target
  end
  task :required_files => target
end
