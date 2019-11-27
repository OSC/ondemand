require "pathname"
require "time"

PROJ_DIR          = Pathname.new(__dir__)
APPS_DIR          = PROJ_DIR.join('apps')
GEMFILE           = PROJ_DIR.join('Gemfile')
INSTALL_ROOT      = Pathname.new(ENV["PREFIX"] || "/opt/ood")
VENDOR_BUNDLE     = (ENV['VENDOR_BUNDLE'] == "yes" || ENV['VENDOR_BUNDLE'] == "true")
PASSENGER_APP_ENV = ENV["PASSENGER_APP_ENV"] || "production"

def infrastructure
  [
    'mod_ood_proxy',
    'nginx_stage',
    'ood_auth_map',
    'ood-portal-generator',
  ].map { |d| Component.new(d) }
end

def apps
  Dir["#{APPS_DIR}/*"].map { |d| Component.new(d) }
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

  def gemfile?
    @path.join('Gemfile.lock').exist?
  end
end

desc "Package OnDemand"
task :package do
  `which gtar 1>/dev/null 2>&1`
  if $?.success?
    tar = 'gtar'
  else
    tar = 'tar'
  end
  version = ENV['VERSION']
  if ! version
    latest_commit = `git rev-list --tags --max-count=1`.strip[0..6]
    latest_tag = `git describe --tags #{latest_commit}`.strip[1..-1]
    datetime = Time.now.strftime("%Y%m%d-%H%M")
    version = "#{latest_tag}-#{datetime}-#{latest_commit}"
  end
  sh "git ls-files | #{tar} -c --transform 's,^,ondemand-#{version}/,' -T - | gzip > packaging/v#{version}.tar.gz"
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

desc "Test OnDemand"
task :test => 'test:all'
namespace :test do
  testing = {
    'ood-portal-generator': 'spec',
    'apps/activejobs': 'test',
    'apps/dashboard': 'test',
    'apps/file-editor': 'test',
    'apps/myjobs': 'test'
  }

  desc "Setup tests"
  task :setup do
    testing.each_pair do |app, _task|
      chdir PROJ_DIR.join(app.to_s) do
        sh "bundle install --with development test"
      end
    end
  end

  desc "Run unit tests"
  task :unit => [:setup] do
    testing.each_pair do |app, task|
      chdir PROJ_DIR.join(app.to_s) do
        sh "bundle exec rake #{task}"
      end
    end
  end

  desc "Run shellcheck"
  task :shellcheck do
    sh "shellcheck -x ood-portal-generator/sbin/update_ood_portal"
    sh "shellcheck -x nginx_stage/sbin/nginx_stage"
    sh "shellcheck nginx_stage/sbin/update_nginx_stage"
  end

  task :all => [:unit, :shellcheck]
end

task default: %w[test]
