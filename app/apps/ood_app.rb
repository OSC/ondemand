class OodApp
  attr_reader :router
  delegate :owner, :caption, :type, :path, :name, :token, to: :router

  PROTECTED_NAMES = ["shared_apps", "cgi-bin", "tmp"]

  def accessible?
    path.executable? && path.readable?
  end
  alias_method :rx?, :accessible?

  def valid_dir?
    path.directory? &&
    ! self.class::PROTECTED_NAMES.include?(path.basename.to_s) &&
    ! path.basename.to_s.start_with?(".")
  end

  def initialize(router)
    @router = router
  end

  def title
    manifest.name.empty? ? name.titleize : manifest.name
  end

  def url
    if manifest.url.empty?
      router.url
    else
      manifest.url % {
        app_type: type,
        app_owner: owner,
        app_name: name,
        app_token: token
      }
    end
  end

  def has_gemfile?
    path.join("Gemfile").file? && path.join("Gemfile.lock").file?
  end

  def can_run_bundle_install?
    passenger_rack_app? && path.join("Gemfile").file?
  end

  def category
    manifest.category.empty? ? router.category : manifest.category
  end

  def subcategory
    manifest.subcategory
  end

  def role
    manifest.role
  end


  def manifest
    @manifest ||= load_manifest
  end

  def icon_path
    path.join("icon.png")
  end

  class SetupScriptFailed < StandardError; end
  # run the production setup script for setting up the user's
  # dataroot and database for the current app, if the production
  # setup script exists and can be executed
  def run_setup_production
    Bundler.with_clean_env do
      setup = "./bin/setup-production"
      Dir.chdir(path) do
        if File.exist?(setup) && File.executable?(setup)
          output = `bundle exec #{setup} 2>&1`
          unless $?.success?
            msg = "Per user setup failed for script at #{path}/#{setup} "
            msg += "for user #{Etc.getpwuid.name} with output: #{output}"
            raise SetupScriptFailed, msg
          end
        end
      end
    end
  end

  def passenger_rack_app?
    path.join("config.ru").file?
  end

  def passenger_nodejs_app?
    path.join("app.js").file?
  end

  def passenger_python_app?
    path.join("passenger_wsgi.py").file?
  end

  def passenger_meteor_app?
    path.join(".meteor").exist?
  end

  def passenger_app?
    passenger_rack_app? || passenger_nodejs_app? || passenger_python_app? || passenger_meteor_app?
  end

  def passenger_rails_app?
    return @passenger_rails_app if defined? @passenger_rails_app
    @passenger_rails_app = (passenger_rack_app? && has_gem?("rails"))
  end

  def passenger_railsdb_app?
    # FIXME: assumes a rails db ood app will always use sqlite3
    return @passenger_railsdb_app if defined? @passenger_railsdb_app
    @passenger_railsdb_app = (passenger_rails_app? && has_gem?("sqlite3"))
  end



  private

  # Check if Gemfile and Gemfile.lock exists, and if the Gemfile.lock specs
  # include a gem with the specified name
  #
  # @param gemname [String] the name of the gem to check
  # @return [Boolean] true if Gemfile.lock has specified gem name
  def has_gem?(gemname)
    # FIXME: we want to make this public, test it, and add functionality to make it
    # work whether the app has a Gemfile.lock or just a Gemfile. 
    # see ood_app_test.rb
    has_gemfile? && bundler_helper.has_gem?(gemname)
  end

  def bundler_helper
    @bundler_helper ||= BundlerHelper.new(path)
  end

  def load_manifest
    default = path.join("manifest.yml")
    alt = path.dirname.join("#{path.basename}.yml")
    alt.exist? ? Manifest.load(alt) : Manifest.load(default)
  end
end
