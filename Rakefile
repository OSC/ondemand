require "pathname"
require "time"

PROJ_DIR          = Pathname.new(__dir__)
TASK_DIR          = "#{PROJ_DIR}/lib/tasks"
APPS_DIR          = PROJ_DIR.join('apps')
GEMFILE           = PROJ_DIR.join('Gemfile')
INSTALL_ROOT      = Pathname.new(ENV["PREFIX"] || "/opt/ood")
VENDOR_BUNDLE     = (ENV['VENDOR_BUNDLE'] == "yes" || ENV['VENDOR_BUNDLE'] == "true")
PASSENGER_APP_ENV = ENV["PASSENGER_APP_ENV"] || "production"

require "#{TASK_DIR}/packaging"
require "#{TASK_DIR}/test"
require "#{TASK_DIR}/docker"
require "#{TASK_DIR}/development"
require "#{TASK_DIR}/ood-proxy"

def infrastructure
  [
    'mod_ood_proxy',
    'nginx_stage',
    'ood_auth_map',
    'ood-portal-generator',
    'ood-proxy-rs',
  ].map { |d| Component.new(d) }
end

def apps
  Dir["#{APPS_DIR}/*"].map { |d| Component.new(d) }
end

def ruby_apps
  apps.select(&:ruby_app?)
end

def yarn_apps
  apps.select(&:package_json?)
end

class Component
  attr_reader :name
  attr_reader :path

  def initialize(app)
    @name = File.basename(app)
    @path = Pathname.new(app)
  end

  def ruby_app?
    @path.join('config.ru').exist?
  end

  def node_app?
    @path.join('app.js').exist?
  end

  def rust_app?
    @path.join('Cargo.toml').exist?
  end

  def package_json?
    @path.join('package.json').exist?
  end

  def gemfile?
    @path.join('Gemfile.lock').exist?
  end
end

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
    sh "bin/bundle update"
  end

  yarn_apps.each do |app|
    chdir app.path
    sh "npm install --production --prefix tmp yarn"
    sh "tmp/node_modules/yarn/bin/yarn  upgrade"
  end
end


task default: %w[test]
