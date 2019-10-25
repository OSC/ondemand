require "pathname"
require "time"

PROJ_DIR     = Pathname.new(__dir__)
APPS_DIR     = PROJ_DIR.join('apps')
INSTALL_ROOT = Pathname.new(ENV["PREFIX"] || "/opt/ood")

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
    if VENDOR_BUNDLE
      args = "--path vendor/bundle"
    else
      args = ""
    end
    sh "BUNDLE_GEMFILE=#{GEMFILE} bundle install #{args}"
    if VENDOR_BUNDLE
      config = <<-EOS
---
BUNDLE_PATH: "../../vendor/bundle"
    EOS
      apps.each do |a|
        bundle_dir = a.path.join('.bundle')
        bundle_dir.mkdir unless bundle_dir.exist?
        config_path = bundle_dir.join('config')
        config_path.write config
      end
    end
  end

  apps.each do |a|
    desc "Build #{a.name} app"
    task a.name.to_sym => [:gems] do
      setup_path = a.path.join("bin", "setup")
      if setup_path.exist? && setup_path.executable?
        sh "BUNDLE_GEMFILE=#{GEMFILE} PASSENGER_APP_ENV=production PASSENGER_BASE_URI=/pun/sys/#{a.name} #{setup_path}"
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
    sh "cp -r mod_ood_proxy #{INSTALL_ROOT}/"
    sh "cp -r nginx_stage #{INSTALL_ROOT}/"
    sh "cp -r ood_auth_map #{INSTALL_ROOT}/"
    sh "cp -r ood-portal-generator #{INSTALL_ROOT}/"
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
