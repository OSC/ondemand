require "pathname"

BUILD_ROOT   = Pathname.new(ENV["OBJDIR"] || "build")
INSTALL_ROOT = Pathname.new(ENV["PREFIX"] || "/opt/ood")

task :default => :build

# all_components.each do |c|
#   file c.build_root => CONFIG_FILE do
#     rm_rf c.build_root if c.build_root.directory?
#     mkdir_p c.build_root unless c.build_root.directory?
#     cp_r c.file_url, c.build_root
#     setup_path = c.build_root.join("bin", "setup")
#     if setup_path.exist? && setup_path.executable?
#       args = "PASSENGER_APP_ENV=production PASSENGER_BASE_URI=/pun/sys/#{c.name}"
#       args = args + " BUNDLE_DIR="
#       sh "#{args} #{setup_path}"
#     end
#     c.build_root.join("VERSION").write(c.tag) if c.app?
#   end
# end

def apps
  %w(activejobs bc_desktop dashboard file-editor files myjobs shell).map {|name| BUILD_ROOT.join("apps", name) }
end

def build_apps
  app_build_dir = BUILD_ROOT.join("apps")
  vendor_dir = BUILD_ROOT.join("vendor", "bundle").expand_path
  rm_rf app_build_dir if app_build_dir.directory?
  mkdir_p BUILD_ROOT unless BUILD_ROOT.directory?
  mkdir_p vendor_dir unless vendor_dir.directory?

  cp_r "apps", BUILD_ROOT
  apps.each do |app|
    setup_path = app.join("bin", "setup")
    if setup_path.exist? && setup_path.executable?
      args = "PASSENGER_APP_ENV=production PASSENGER_BASE_URI=/pun/sys/#{app.basename}"
      args = args + " BUNDLE_DIR=" + vendor_dir.to_s

      sh "#{args} #{setup_path}"
    end
  end

end

def proxy_components
  %w(ood-portal-generator mod_ood_proxy ood_auth_map nginx_stage).map {|name| BUILD_ROOT.join(name) }
end

def build_proxy_components
  proxy_components.each do |build_root|
    rm_rf build_root if build_root.directory?
    cp_r build_root.basename, build_root
  end
end


desc "Build OnDemand"
task :build => [:clean] do
  build_apps
  build_proxy_components
end

directory INSTALL_ROOT.to_s

desc "Install OnDemand"
task :install => [:build, INSTALL_ROOT] do
  sh "rsync -rptl --delete --copy-unsafe-links #{BUILD_ROOT}/ #{INSTALL_ROOT}"
end

desc "Clean up build"
task :clean do
  rm_rf BUILD_ROOT
end
