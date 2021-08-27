require 'rubocop/rake_task'
require 'fileutils'

desc "Lint OnDemand"
task :lint => 'lint:all'

namespace :lint do
  require_relative 'rake_helper'
  include RakeHelper

  begin
    RuboCop::RakeTask.new(:rubocop, [:path]) do |t, args|
      t.options = ["--config=#{PROJ_DIR.join(".rubocop.yml")}"]
      default_patterns = [
        "apps/**/*.rb",
        "lib/**/*.rb",
        "nginx_stage/**/*.rb",
        "ood-portal-generator/**/*.rb",
        "spec/**/*.rb",
      ]
      t.patterns = args[:path].nil? ? default_patterns : [args[:path]]
    end
  rescue LoadError
  end

  desc "Setup .rubocop.yml files"
  task :setup do
    source = PROJ_DIR.join('.rubocop.yml')
    (ruby_apps + infrastructure).each do |app|
      FileUtils.cp(source, app.path.join('.rubocop.yml'), verbose: true)
    end
  end

  task :all => [:rubocop]
end
