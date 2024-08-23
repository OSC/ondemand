# frozen_string_literal: true

require 'net/http'
require 'json'

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
      ENV['PATH'] = PROJ_DIR.join("tests/chromedriver-#{platform}").to_s + ":#{ENV['PATH']}"
      task.pattern = "#{PROJ_DIR.join('spec', 'e2e')}/*_spec.rb"
      task.rspec_opts = ['--format documentation']
    end
  rescue LoadError
  end

  def chrome_version
    `google-chrome --version`.split.last
  end

  def chrome_dl_data(version)
    json_uri = URI('https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json')
    data = Net::HTTP.get(json_uri)
    json = JSON.parse(data)
    maj_version = version.split('.').first

    json['versions'].select do |driver_data|
      driver_major_version = driver_data['version'].split('.').first
      driver_major_version == maj_version
    end.last
  end

  def chrome_dl_url(dl_data)
    drivers = dl_data['downloads']['chromedriver']
    driver = drivers.select { |d| d['platform'] == platform }.first
    driver['url']
  end

  def platform
    @platform ||= begin
      uname = `uname -s`
      case uname.chomp
      when 'Darwin'
        if `uname -m`.chomp == 'arm64'
          'mac-arm64'
        else
          'mac-x64'
        end
      when 'Linux'
        'linux64'
      end
    end
  end

  desc 'Get chromedriver'
  task :chromedriver, [:version] do |_t, args|
    version = args[:version] || chrome_version
    puts "Fetching chromedriver #{version}"

    data = chrome_dl_data(version)
    url = chrome_dl_url(data)

    sh "curl -o tests/chromedriver.zip #{url}"
    chdir PROJ_DIR.join('tests') do
      sh 'unzip -o chromedriver.zip'
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
      abort('"text:unix" failed! These files are DOS encoded.')
    end
  end

  task :all => [:unit, :shellcheck]
end
