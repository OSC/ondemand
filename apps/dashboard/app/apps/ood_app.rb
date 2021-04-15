class OodApp
  include Rails.application.routes.url_helpers

  attr_reader :router
  delegate :owner, :caption, :type, :path, :name, :token, to: :router

  def accessible?
    path.executable? && path.readable?
  end
  alias_method :rx?, :accessible?

  def directory?
    path.directory?
  end

  def hidden?
    path.basename.to_s.start_with?(".")
  end

  def backup?
    !hidden? && path.basename.to_s.include?(".")
  end

  def manifest?
    manifest.valid?
  end

  def invalid_batch_connect_app?
    batch_connect_app? && sub_app_list.none?(&:valid?)
  end

  def should_appear_in_nav?
    manifest? && ! (invalid_batch_connect_app? || category.empty?)
  end

  def initialize(router)
    @router = router
  end

  def title
    manifest.name.empty? ? name.titleize : manifest.name
  end

  def url
    if manifest.url.empty?
      if batch_connect_app?
        Rails.application.routes.url_helpers.new_batch_connect_session_context_path(token)
      else
        router.url
      end
    else
      custom_url = manifest.url % {
        app_type: type,
        app_owner: owner,
        app_name: name,
        app_token: token
      }
      self.class.fix_if_internal_url(custom_url, Rails.application.routes.url_helpers.root_path)
    end
  end

  def self.fix_if_internal_url(url, base_url)
    if(Addressable::URI.parse(url).relative? && ! url.include?('.') && ! url.start_with?('/'))
      File.join base_url, url
    else
      url
    end
  end

  # the problem is we need the context :-P
  def links
    if role == "files"
      # assumes Home Directory is primary...
      [
        OodAppLink.new(
          title: "Home Directory",
          description: manifest.description,
          url: OodAppkit::Urls::Files.new(base_url: url).url(path: Dir.home),
          icon_uri: "fas://home",
          caption: caption,
          new_tab: true
        )
      ].concat(
        OodFilesApp.new.favorite_paths.map do |favorite_path|
          OodAppLink.new(
            title: favorite_path.title || favorite_path.path.to_s,
            subtitle: favorite_path.title ? favorite_path.path.to_s : nil,
            description: manifest.description,
            url: OodAppkit::Urls::Files.new(base_url: url).url(path: favorite_path.path.to_s),
            icon_uri: "fas://folder",
            caption: caption,
            new_tab: true
          )
        end
      )
    elsif role == "shell"
      login_clusters = OodCore::Clusters.new(
        OodAppkit.clusters
          .select(&:allow?)
          .reject { |c| c.metadata.hidden }
          .select(&:login_allow?)
      )
      if login_clusters.none?
        [
          OodAppLink.new(
            title: "Shell Access",
            description: manifest.description,
            url: OodAppkit::Urls::Shell.new(base_url: url).url,
            icon_uri: "fas://terminal",
            caption: caption,
            new_tab: true
          )
        ]
      else
        login_clusters.map do |cluster|
          OodAppLink.new(
            title: "#{cluster.metadata.title || cluster.id.to_s.titleize} Shell Access",
            description: manifest.description,
            url: OodAppkit::Urls::Shell.new(base_url: url).url(host: cluster.login.host),
            icon_uri: "fas://terminal",
            caption: caption,
            new_tab: true
          )
        end.sort_by { |lnk| lnk.title }
      end
    elsif role == "batch_connect"
      sub_app_list.select(&:valid?).map(&:link)
    else
      [
        OodAppLink.new(
          title: title,
          description: manifest.description,
          url: (type == :sys && owner == :sys) ? app_path(name, nil, nil) : app_path(name, type, owner),
          icon_uri: icon_uri,
          caption: caption,
          new_tab: true
        )
      ]
    end
  end

  def links_without_validation
    # hack - but at least this hack is in a method next to the method it is
    # coupled with and this prevents control coupling from the outside by doing
    # something atrocious like links(validate: false)
    if batch_connect_app?
      sub_app_list.map(&:link)
    else
      links
    end
  end

  def batch_connect_app?
    role == "batch_connect"
  end

  def batch_connect
    @batch_connect ||= BatchConnect::App.new(router: router)
  end

  def has_gemfile?
    path.join("Gemfile").file? && path.join("Gemfile.lock").file?
  end

  def can_run_bundle_install?
    passenger_rack_app? && path.join("Gemfile").file?
  end

  def category
    if (! router.category.empty?) && manifest.category.empty?
      router.category
    else
      manifest.category
    end
  end

  def subcategory
    manifest.subcategory
  end

  def role
    manifest.role
  end

  def metadata
    manifest.metadata
  end

  def manifest
    @manifest ||= Manifest.load(manifest_path)
  end

  def manifest_path
    path.join("manifest.yml")
  end

  def svg_icon?
    @svg_icon ||= path.join("icon.svg").file?
  end

  def png_icon?
    @png_icon ||= path.join("icon.png").file?
  end

  def image_icon?
    png_icon? || svg_icon?
  end

  def icon_path
    if svg_icon?
      path.join("icon.svg")
    elsif png_icon?
      path.join("icon.png")
    else
      Pathname.new('')
    end
  end

  def icon_uri
    if image_icon?
      app_icon_path(name, type, owner)
    elsif manifest.icon =~ /^fa[bsrl]?:\/\//
      manifest.icon
    else
      "fas://cog"
    end
  end

  class SetupScriptFailed < StandardError; end
  # run the production setup script for setting up the user's
  # dataroot and database for the current app, if the production
  # setup script exists and can be executed
  def run_setup_production
    Bundler.with_clean_env do
      ENV['BUNDLE_USER_CONFIG'] = '/dev/null'
      setup = "./bin/setup-production"
      Dir.chdir(path) do
        if File.exist?(setup) && File.executable?(setup)
          # FIXME: write a test for this

          # Prepend #{path}/bin to the PATH so that bin/ruby wrapper is used if
          # it exists - in other words, /usr/bin/env ruby will resolve to #{path}/bin/ruby
          # instead of whatever ruby version the dashboard is using
          #
          # This makes the execution of the setup-production script use the same ruby versions
          # that Passenger uses when launching the app.
          output, status = Open3.capture2e({'PATH' => path.join('bin').to_s + ':'+ ENV['PATH']}, 'bundle','exec', setup)
          unless status.success?
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

  # @return [String] memoized version string
  def version
    @version ||= (version_from_file || version_from_git || "unknown").strip
  end

  # test whether this object is equal to another.
  # @return [Boolean]
  def ==(other)
    other.respond_to?(:url) ? url == other.url : false
  end

  def sub_app_list
    batch_connect_app? ? batch_connect.sub_app_list : []
  end

  # The subapp list may only be of size 1 and actually contains
  # this app. This returns true if there are indeed sub apps that
  # that differ from this object.
  def has_sub_apps?
    if batch_connect_app?
      sub_app_list.size > 1 || sub_app_list[0] != batch_connect
    else
      false
    end
  end

  private

  # @return [String, nil] version string from git describe, or nil if not git repo
  def version_from_git
    o, e, s = Open3.capture3('git', 'describe', '--always', '--tags', chdir: path.to_s)
    s.success? ? o : nil
  end

  # @return [String, nil] version string from VERSION file, or nil if no file avail
  def version_from_file
    file = path.join("VERSION")
    file.read if file.file?
  end

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
end
