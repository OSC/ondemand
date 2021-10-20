require "pathname"
require "time"

PROJ_DIR          = Pathname.new(__dir__)
TASK_DIR          = "#{PROJ_DIR}/lib/tasks"
APPS_DIR          = PROJ_DIR.join('apps')
GEMFILE           = PROJ_DIR.join('Gemfile')
DESTDIR           = Pathname.new(ENV['DESTDIR'].to_s)
INSTALL_ROOT      = Pathname.new(ENV["PREFIX"] || "#{DESTDIR}/opt/ood")
VENDOR_BUNDLE     = (ENV['VENDOR_BUNDLE'] == "yes" || ENV['VENDOR_BUNDLE'] == "true")
PASSENGER_APP_ENV = ENV["PASSENGER_APP_ENV"] || "production"

require "#{TASK_DIR}/rake_helper"
require "#{TASK_DIR}/build"
require "#{TASK_DIR}/packaging"
require "#{TASK_DIR}/test"
require "#{TASK_DIR}/lint"
require "#{TASK_DIR}/docker"
require "#{TASK_DIR}/development"
require "#{TASK_DIR}/install"

include RakeHelper

namespace :build do
  desc "Build gems"
  task :gems do
    bundle_args = ["--jobs 4", "--retry 2"]
    if VENDOR_BUNDLE
      bundle_args << "--path vendor/bundle"
    end
    if PASSENGER_APP_ENV == "production"
      bundle_args << "--without doc"
    end
    apps.each do |a|
      next unless a.ruby_app?
      chdir a.path do
        sh "bin/bundle install #{bundle_args.join(' ')}"
      end
    end
    infrastructure.each do |a|
      next unless a.gemfile?
      chdir a.path do
        sh "bundle install #{bundle_args.join(' ')}"
      end
    end
  end

  apps.each do |a|
    if a.ruby_app?
      depends = [:gems]
    else
      depends = []
    end
    task a.name.to_sym => depends do |t|
      setup_path = a.path.join("bin", "setup")
      if setup_path.exist? && setup_path.executable?
        sh "PASSENGER_APP_ENV=#{PASSENGER_APP_ENV} #{setup_path}"
      end
    end
  end

  desc "Build all apps"
  task :all => apps.map { |a| a.name }
end

desc "Build OnDemand"
task :build => 'build:all'

directory INSTALL_ROOT.to_s

namespace :install do

  desc "Install OnDemand infrastructure"
  task :infrastructure => [INSTALL_ROOT] do
    infrastructure.each do |infra|
      sh "cp -r #{infra.name} #{INSTALL_ROOT}/"
    end
  end

  desc "Install OnDemand apps"
  task :apps => [INSTALL_ROOT] do
    sh "cp -r #{APPS_DIR} #{INSTALL_ROOT}/"
  end

  desc "Install OnDemand infrastructure and apps"
  task :all => [:infrastructure, :apps]
end

desc "Install OnDemand"
task :install => 'install:all'

desc "Clean up build"
task :clean do
  sh "git clean -Xdf"
end

desc "Update Ondemand"
task :update do
  ruby_apps.each do |app|
    chdir app.path
    Bundler.with_unbundled_env do
      sh "bundle update"
    end
  end

  yarn_apps.each do |app|
    chdir app.path
    sh "npm install --production --prefix tmp yarn"
    sh "tmp/node_modules/yarn/bin/yarn  upgrade"
  end
end


task default: %w[test]
