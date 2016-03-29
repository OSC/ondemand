require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
end

task :default => :test

desc <<-DESC
Install nginx_stage into env var PREFIX
Default: PREFIX=/opt/ood/nginx_stage
DESC
task :install do
  prefix = File.expand_path(ENV['PREFIX'] || '/opt/ood/nginx_stage')
  Dir.chdir(__dir__) do
    # copy over git committed files
    sh("git checkout-index --prefix=#{prefix}/ -a -f")

    # copy over an example config file if config doesn't exist
    config = "#{prefix}/config/nginx_stage.yml"
    cp 'config/nginx_stage.yml.example', config unless File.exist?(config)
  end
end
