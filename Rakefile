require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
end

task :default => :test

desc %q{Install nginx_stage (Defaults: prefix=/opt/ood/nginx_stage tag=HEAD)}
task :install do
  tag = ENV['tag']
  prefix = File.expand_path(ENV['prefix'] || '/opt/ood/nginx_stage')
  Dir.chdir(__dir__) do
    sh("git read-tree #{tag}") if tag
    begin
      sh("git checkout-index --prefix=#{prefix}/ -a -f")
    ensure
      sh("git read-tree HEAD") if tag
    end
  end
end
