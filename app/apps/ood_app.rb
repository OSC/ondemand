class OodApp
  attr_reader :workdir

  PROTECTED_NAMES = ["shared_apps", "cgi-bin", "tmp"]

  # FIXME: still returns nil sometimes yuck
  def self.at(path: path)
    app = self.new(workdir: path)
    app if app.valid_dir? && (app.accessible? || app.manifest.exist?)
  end

  def self.all_at(path: path)
    Dir.glob("#{path}/**").sort.reduce([]) do |apps, appdir|
      app = self.at(path: appdir)
      apps << app unless app.nil?
      apps
    end
  end

  # FIXME: should we be making clear which methods of App
  # require accessible? true i.e. rx access to 
  def accessible?
    workdir.executable? && workdir.readable?
  end
  alias_method :rx?, :accessible?

  def valid_dir?
    (workdir.directory? &&
      ! self.class::PROTECTED_NAMES.include?(workdir.basename.to_s) &&
      workdir.extname != ".git")
  end

  def initialize(workdir: nil)
    # TODO: add gitdir and other properties
    @workdir = Pathname.new(workdir.to_s)
  end

  def name
    @workdir.basename
  end

  # FIXME: this is a little bit crossing concerns between
  # the router and the app...
  # let the app owner be the owner of the directory
  def owner
    Etc.getpwuid(workdir.stat.uid).name
  end

  def title
    name # TODO: name.titleize
  end

  def path
    @workdir
  end

  def has_gemfile?
    workdir.join("Gemfile").file? && workdir.join("Gemfile.lock").file?
  end

  def bundler_helper
    @bundler_helper ||= BundlerHelper.new(workdir)
  end

  def manifest
    @manifest ||= load_manifest
  end

  class SetupScriptFailed < StandardError; end
  # run the production setup script for setting up the user's
  # dataroot and database for the current app, if the production
  # setup script exists and can be executed
  def run_setup_production
    Bundler.with_clean_env do
      setup = "./bin/setup-production"
      Dir.chdir(workdir) do
        if File.exist?(setup) && File.executable?(setup)
          output = `bundle exec #{setup} 2>&1`
          unless $?.success?
            msg = "Per user setup failed for script at #{workdir}/#{setup} "
            msg += "for user #{Etc.getpwuid.name} with output: #{output}"
            raise SetupScriptFailed, msg
          end
        end
      end
    end
  end

  private

  def load_manifest
    default = workdir.join("manifest.yml")
    alt = workdir.dirname.join("#{workdir.basename}.yml")
    alt.exist? ? Manifest.load(alt) : Manifest.load(default)
  end
end
