require "pathname"

HERE  = Pathname.new(".")
INSTALL_ROOT = Pathname.new(ENV["PREFIX"] || "/opt/ood")
VENDOR_BUNDLE_DIR = Pathname.new(ENV["VENDOR_BUNDLE_DIR"] || "../../vendor/bundle")

def apps
  %w(activejobs bc_desktop dashboard file-editor files myjobs shell).map {|name| HERE.join("apps", name) }
end

task :default => :build

apps.each do |app|
  setup_path = app.join("bin", "setup")
  if setup_path.exist? && setup_path.executable?
    sh "PASSENGER_APP_ENV=production VENDOR_BUNDLE_DIR=#{VENDOR_BUNDLE_DIR} #{setup_path}"
  end
end

desc "Build OnDemand"
task :build => apps

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
