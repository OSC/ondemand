require 'rubocop/rake_task'
require 'fileutils'

desc "Test OnDemand"
task :test => 'test:all'

def yarn_app?(path)
  Pathname.new(path).join('yarn.lock').exist?
end

namespace :test do
  require_relative 'build_utils'
  include BuildUtils

  testing = {
    'ood-portal-generator': 'spec',
    'nginx_stage': 'spec',
    'apps/dashboard': 'test',
    'apps/myjobs': 'test'
  }

  desc "Setup tests"
  task :setup do
    testing.each_pair do |app, _task|
      chdir PROJ_DIR.join(app.to_s) do

        if yarn_app?(Dir.pwd)
          sh 'bin/yarn install'
        end

        Bundler.with_unbundled_env do
          sh "bundle install"
        end
      end
    end
  end

  desc "Run unit tests"
  task :unit => [:setup] do
    testing.each_pair do |app, task|
      chdir PROJ_DIR.join(app.to_s) do
        Bundler.with_unbundled_env do
          sh "bundle exec rake #{task}"
        end
      end
    end
  end

  namespace :lint do
    begin
      RuboCop::RakeTask.new(:rubocop, [:path]) do |t, args|
        t.options = ["--config=#{File.join(proj_root, ".rubocop.yml")}"]
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
      source = File.join(proj_root, '.rubocop.yml')
      testing.each_pair do |app, _task|
        FileUtils.cp(source, PROJ_DIR.join(app.to_s, '.rubocop.yml'), verbose: true)
      end
    end
  end

  desc "Run shellcheck"
  task :shellcheck do
    sh "shellcheck -x ood-portal-generator/sbin/update_ood_portal"
    sh "shellcheck -x nginx_stage/sbin/nginx_stage"
    sh "shellcheck nginx_stage/sbin/update_nginx_stage"
    sh "shellcheck hooks/k8s-bootstrap/*.sh"
  end

  begin
    require "rspec/core/rake_task"
    RSpec::Core::RakeTask.new(:e2e) do |task|
      ENV['BEAKER_setdir'] = PROJ_DIR.join('spec', 'e2e', 'nodesets').to_s
      ENV['PATH'] = PROJ_DIR.join('tests').to_s + ":#{ENV['PATH']}"
      task.pattern = "#{PROJ_DIR.join('spec', 'e2e')}/*_spec.rb"
      task.rspec_opts = ['--format documentation']
    end
  rescue LoadError
  end

  desc "Get chromedriver"
  task :chromedriver, [:version] do |t, args|
    version = args[:version] || '87.0.4280.88'
    uname = `uname -s`
    case uname.chomp
    when 'Darwin'
      file = 'chromedriver_mac64.zip'
    when 'Linux'
      file = 'chromedriver_linux64.zip'
    end
    url = "https://chromedriver.storage.googleapis.com/#{version}/#{file}"
    sh "curl -o tests/#{file} #{url}"
    chdir PROJ_DIR.join("tests") do
      sh "unzip -o #{file}"
    end
  end

  task :all => [:unit, :shellcheck]
end
