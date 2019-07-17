require "pathname"

HERE  = Pathname.new(".")
INSTALL_ROOT = Pathname.new(ENV["PREFIX"] || "/opt/ood")
VENDOR_BUNDLE_DIR = Pathname.new(ENV["VENDOR_BUNDLE_DIR"] || "../../vendor/bundle")

def apps
  %w(activejobs bc_desktop dashboard file-editor files myjobs shell).map {|name| HERE.join("apps", name) }
end

task :default => :build

def build_app(app)
  setup_path = app.join("bin", "setup")
  if setup_path.exist? && setup_path.executable?
    sh "PASSENGER_APP_ENV=production VENDOR_BUNDLE_DIR=#{VENDOR_BUNDLE_DIR} #{setup_path}"
  end
end

namespace :build do
  apps = [:activejobs, :bc_desktop, :dashboard, :"file-editor", :files, :myjobs, :shell]

  apps.each do |app|
    desc "build #{app}"
    task app do
      build_app Pathname.new("apps/#{app}")
    end
  end

  task :all => apps
end

desc "build all apps"
task :build => 'build:all'

directory INSTALL_ROOT.to_s

def proxy_components
  %w(ood-portal-generator mod_ood_proxy ood_auth_map nginx_stage).map {|name| HERE.join(name) }
end

desc "Install OnDemand"
task :install => [:build, INSTALL_ROOT] do
  proxy_components.each do |comp|
    sh "rsync -rptl --delete --copy-unsafe-links #{comp} #{INSTALL_ROOT}"
  end

  sh "rsync -rptl --delete --copy-unsafe-links apps #{INSTALL_ROOT}"
  
  if Pathname.new("vendor").exist?
    sh "rsync -rptl --delete --copy-unsafe-links vendor #{INSTALL_ROOT}"
  end

end
