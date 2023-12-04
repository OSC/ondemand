# frozen_string_literal: true

desc 'Test OnDemand'
task :test => 'test:all'

namespace :test do
  require_relative 'rake_helper'
  include RakeHelper

  testing = {
    'ood-portal-generator': 'spec',
    'nginx_stage':          'spec',
    'apps/dashboard':       'test',
    'apps/myjobs':          'test'
  }

  desc 'Setup tests'
  task :setup do
    testing.each_pair do |app, _task|
      chdir PROJ_DIR.join(app.to_s) do
        sh 'bin/yarn install' if yarn_app?(Dir.pwd)

        Bundler.with_unbundled_env do
          sh 'bundle install'
        end
      end
    end

    chdir PROJ_DIR.join('apps/shell') do
      # bin/setup doesn't install dev packages
      sh 'bin/setup'
      sh 'tmp/node_modules/yarn/bin/yarn install'
    end
  end

  desc 'Run unit tests'
  task :unit => [:setup] do
    testing.each_pair do |app, task|
      chdir PROJ_DIR.join(app.to_s) do
        Bundler.with_unbundled_env do
          sh "bundle exec rake #{task}"
        end
      end
    end

    chdir PROJ_DIR.join('apps/shell') do
      sh 'tmp/node_modules/yarn/bin/yarn test'
    end
  end

  desc 'Run shellcheck'
  task :shellcheck do
    sh 'shellcheck -x ood-portal-generator/sbin/update_ood_portal'
    sh 'shellcheck -x nginx_stage/sbin/nginx_stage'
    sh 'shellcheck nginx_stage/sbin/update_nginx_stage'
    sh 'shellcheck hooks/k8s-bootstrap/*.sh'
  end

  begin
    require 'rspec/core/rake_task'
    RSpec::Core::RakeTask.new(:e2e) do |task|
      ENV['BEAKER_setdir'] = PROJ_DIR.join('spec', 'e2e', 'nodesets').to_s
      ENV['PATH'] = PROJ_DIR.join('tests').to_s + ":#{ENV['PATH']}"
      task.pattern = "#{PROJ_DIR.join('spec', 'e2e')}/*_spec.rb"
      task.rspec_opts = ['--format documentation']
    end
  rescue LoadError
  end

  desc 'Get chromedriver'
  task :chromedriver, [:version] do |_t, args|
    version = args[:version] || '87.0.4280.88'
    uname = `uname -s`
    case uname.chomp
    when 'Darwin'
      file = if `uname -m`.chomp == 'arm64'
               'chromedriver_mac_arm64.zip'
             else
               'chromedriver_mac64.zip'
             end
    when 'Linux'
      file = 'chromedriver_linux64.zip'
    end
    url = "https://chromedriver.storage.googleapis.com/#{version}/#{file}"
    sh "curl -o tests/#{file} #{url}"
    chdir PROJ_DIR.join('tests') do
      sh "unzip -o #{file}"
    end
  end

  task :unix do
    dos_files = Dir.glob('*/**/*.{rb,js,scss,html,erb}').reject do |file|
      file.include?('vendor/') || file.include?('node_modules/')
    end.map do |file|
      dos_encoded = `file #{file} | grep -q CRLF; echo $?`.chomp.to_i
      dos_encoded.positive? ? nil : file
    end.compact

    if dos_files.empty?
      puts 'There are no DOS encoded files in this project.'
    else
      dos_files.each { |f| warn f }
      abort('"text:unix" failed! These files are dos encoded.')
    end
  end

  task :all => [:unit, :shellcheck]
end
