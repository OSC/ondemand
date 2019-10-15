require "json"
require "pathname"

PROJ_DIR     = Pathname.new(__dir__)
CONFIG_FILE  = PROJ_DIR.join(ENV["CNFFILE"] || "config.json")
BUILD_ROOT   = Pathname.new(ENV["OBJDIR"] || "build")
INSTALL_ROOT = Pathname.new(ENV["PREFIX"] || "/opt/ood")

def all_components
  JSON.parse(CONFIG_FILE.read).map { |c| Component.new(c) }
end

class Component
  attr_reader :name
  attr_reader :url
  attr_reader :tag

  def initialize(opts = {})
    @name = opts.fetch("name") { raise ArgumentError, "No name specified. Missing argument: name" }.to_s
    @url  = opts.fetch("url")  { raise ArgumentError, "No url specified. Missing argument: url" }.to_s
    @tag  = opts.fetch("tag")  { raise ArgumentError, "No tag specified. Missing argument: tag" }.to_s
    @app  = opts.fetch("app", nil)
  end

  def app?
    !!@app
  end

  def build_root
    app? ? BUILD_ROOT.join("apps", name) : BUILD_ROOT.join(name)
  end

  def download_url
    "#{url}/archive/#{tag}.tar.gz"
  end
end

task :default => :build

all_components.each do |c|
  file c.build_root => CONFIG_FILE do
    rm_rf c.build_root if c.build_root.directory?
    mkdir_p c.build_root unless c.build_root.directory?
    sh "curl -skL #{c.download_url} | tar xzf - -C #{c.build_root} --strip-components=1"
    setup_path = c.build_root.join("bin", "setup")
    if setup_path.exist? && setup_path.executable?
      sh "PASSENGER_APP_ENV=production PASSENGER_BASE_URI=/pun/sys/#{c.name} #{setup_path}"
    end
    c.build_root.join("VERSION").write(c.tag) if c.app?
  end
end

def proxy_components
  %w(ood-portal-generator mod_ood_proxy ood_auth_map nginx_stage).map {|name| BUILD_ROOT.join(name) }
end

proxy_components.each do |build_root|
  file build_root => 'nginx_stage/lib/nginx_stage/version.rb' do
    rm_rf build_root if build_root.directory?
    sh "rsync -rptl --delete --copy-unsafe-links #{PROJ_DIR.join(build_root.basename)} #{build_root}"
  end
end


desc "Build OnDemand"
task :build => all_components.map(&:build_root) + proxy_components

directory INSTALL_ROOT.to_s

desc "Install OnDemand"
task :install => [:build, INSTALL_ROOT] do
  sh "rsync -rptl --delete --copy-unsafe-links #{BUILD_ROOT}/ #{INSTALL_ROOT}"
end

desc "Clean up build"
task :clean do
  rm_rf BUILD_ROOT
end
