# Similar to an OodApp in that it represents an application. It differs
# in the view and mutation of that application. OodApps are what customers
# interact with. Products are what app developers interact with.
class Product
  include ActiveModel::Model
  include IconWithUri

  delegate :passenger_rack_app?, :passenger_rails_app?, :passenger_app?, :can_run_bundle_install?, to: :app

  attr_accessor :name
  attr_accessor :found
  attr_accessor :title
  attr_accessor :description
  attr_accessor :icon
  attr_accessor :git_remote

  validates :name, presence: true
  validates :name, format: {
    with: /\A[\w-]+\z/,
    message: "can only contain letters, digits, dash and underscore"
  }

  validate :app_does_not_exist, on: [:create_from_git_remote]
  validates :git_remote, presence: true, on: :create_from_git_remote

  # lint a given app
  validate :manifest_is_valid, on: [:show_app, :list_apps]

  validate :gems_are_valid, on: :show_app, if: :passenger_rack_app?

  validate :is_git_repo, on: :show_app

  def app_does_not_exist
    errors.add(:name, "already exists as an app") if !name.empty? && router.path.exist?
  end

  def manifest_is_valid
    errors.add(:base, "Manifest is missing, add a title and description to fix this") unless app.manifest.exist?
    errors.add(:base, "Manifest is corrupt, please edit the <code>manifest.yml</code> to fix this") if app.manifest.exist? && !app.manifest.valid?
  end

  def gems_are_valid
    if !gemfile.exist?
      errors.add(:base, "App is missing <code>Gemfile</code>")
    elsif !gemfile_lock.exist?
      errors.add(:base, "App is missing <code>Gemfile.lock</code>, please run <strong>Bundle Install</strong>")
    elsif !gems_installed?
      errors.add(:base, "Install missing gems with <strong>Bundle Install</strong>")
    elsif passenger_rails_app?
      errors.add(:base, "Gemfile missing <code>rails_12factor</code> gem") unless gemfile_specs.detect {|s| s.name == "rails_12factor"}
      errors.add(:base, "Gemfile missing <code>dotenv-rails</code> gem") unless gemfile_specs.detect {|s| s.name == "dotenv-rails"}
      errors.add(:base, "Gemfile missing <code>ood_appkit</code> gem") unless gemfile_specs.detect {|s| s.name == "ood_appkit"}
    end
  end

  def gems_installed?
    Dir.chdir(router.path) do
      Bundler.with_unbundled_env do
        ENV['BUNDLE_USER_CONFIG'] = '/dev/null'
        _, s = Open3.capture2e("bundle", "check")
        s.success?
      end
    end
  end

  def is_git_repo
    errors.add(:base, "Not a valid git repo") unless git_repo?
  end

  class NotFound < StandardError; end

  class << self
    def product_types
      {
        dev: DevProduct,
        usr: UsrProduct
      }
    end

    def build(arguments = {})
      type = arguments.delete(:type)
      raise ArgumentError, "Need to specify type of product" unless type
      product_types[type].new arguments
    end

    def all(type)
      product_types[type].all
    end

    def find(type, name)
      product_types[type].find(name)
    end

    def stage(type)
      target = product_types[type].router.base_path
      target = target.readlink if target.symlink?
      target.mkpath
      true
    rescue Errno::EACCES
      false # user does not have permission to create this directory
    end
  end

  def app
    @app ||= begin
      a = OodApp.new(router)
      a.batch_connect_app? ? BatchConnect::App.new(router: router) : a
    end
  end

  def gemfile
    router.path.join("Gemfile")
  end

  def persisted?
    found
  end

  def new_record?
    !persisted?
  end

  def initialize(attributes={})
    super
    @found ||= false
    if persisted?
      @title ||= app.title
      @description ||= app.manifest.description
      @icon ||= app.manifest.icon
      @git_remote ||= get_git_remote
    end
  end

  def create_from_git_remote(reset_git: false)
    if self.valid?(:create_from_git_remote)
      target = router.path
      target.mkpath
      unless clone_git_repo(target)
        target.rmtree if target.exist?
        return false
      end

      # protect shared apps from access by default
      # if permissions are being used
      FileUtils.chmod 0750, target if permissions?

      # Reset the git history and remote (make vanilla git project)
      if reset_git
        target.join(".git").rmtree
        unless init_git_repo(target)
          target.rmtree if target.exist?
          return false
        end
      end

      true
    else
      false
    end
  rescue
    router.path.rmtree if router.path.exist?
    raise
  end

  def update(attributes)
    @title = attributes[:title] if attributes[:title]
    @description = attributes[:description] if attributes[:description]
    @icon = attributes[:icon] if attributes[:icon]
    @git_remote = attributes[:git_remote] if attributes[:git_remote]

    add_icon_uri

    if self.valid?
      write_manifest
      set_git_remote
      true
    else
      false
    end
  end

  def permissions?
    Configuration.app_sharing_facls_enabled?
  end

  def permissions(context)
    Permission.all(context, self)
  end

  def build_permission(context, attributes = {})
    Permission.build(attributes.merge(context: context, product: self))
  end

  def users
    permissions(:user)
  end

  def groups
    permissions(:group)
  end

  def git_repo?
    router.path.join(".git", "HEAD").file?
  end

  def version
    git_describe
  end

  def uncommitted_files
    git_status
  end

  def readme
    @readme ||= ProductReadme.new(self)
  end

  private

    # Writes out a manifest to the router path unless the repository has been newly cloned.
    #
    # @return [true] always returns true
    def write_manifest
      manifest = Manifest.load( app.manifest_path )

      manifest = manifest.merge({ name: title, description: description, icon: icon})

      manifest.save( app.manifest_path ) if (!title.blank? || !description.blank?) || !app.manifest_path.exist?

      true
    end

    def gemfile_lock
      router.path.join("Gemfile.lock")
    end

    def gemfile_specs
      @gemfile_specs ||= Bundler::LockfileParser.new(File.read(gemfile_lock)).specs
    end

    def get_git_remote
      Dir.chdir(router.path) do
        o, s = Open3.capture2({'HOME'=>''}, 'git', 'config', '--get', 'remote.origin.url')
        o.to_s.strip
      end
    end

    def set_git_remote
      Dir.chdir(router.path) do
        o, s = Open3.capture2({'HOME'=>''}, 'git', 'config', '--get', 'remote.origin.url')
        if s.success?
          o, s = Open3.capture2({'HOME'=>''}, 'git', 'remote', 'set-url', 'origin', git_remote)

          unless s.success?
            o, s = Open3.capture2({'HOME'=>''}, 'git', 'remote', 'add', 'origin', git_remote)
          end
        end
      end
    end

    def init_git_repo(target)
      o, s = Open3.capture2e({"HOME" => ""}, "git", "init", chdir: target.to_s)
      unless s.success?
        errors.add(:reset_git, "was unable to initialize git repository:")
        errors.add(:reset_git_error, o)
        Rails.logger.error(o)
        return false
      end
      true
    end

    def clone_git_repo(target)
      o, s = Open3.capture2e({"HOME" => ""}, "git", "clone", git_remote, target.to_s)
      unless s.success?
        errors.add(:git_remote, "was unable to be cloned:")
        errors.add(:git_remote_error, o)
        Rails.logger.error(o)
        return false
      end
      true
    end



    def git_describe
      target = router.path
      Dir.chdir(target) do
        # get reference
        out = `HOME="" git symbolic-ref -q HEAD 2> /dev/null`.strip
        unless out.empty?
          /^(refs\/heads\/)?(?<ref>.+)$/ =~ out
        else
          out = `HOME="" git describe --tags --exact-match 2> /dev/null`.strip
          unless out.empty?
            ref = "tag:#{out}"
          else
            out = `HOME="" git describe --contains --all HEAD 2> /dev/null`.strip
            /^(remotes\/)?(?<ref>.+)$/ =~ out
            ref = `HOME="" git rev-parse --short HEAD 2> /dev/null`.strip unless ref
            ref = "detached:#{ref}"
          end
        end
      ref
      end
    end

    def git_status
      files = Dir.chdir(router.path) do
        `HOME="" git status --porcelain 2> /dev/null`.split("\n")
      end
      results = {}
      results[:unstaged]  = files.select {|v| /^\s\w .+$/ =~ v}
      results[:staged]    = files.select {|v| /^\w\s .+$/ =~ v}
      results[:untracked] = files.select {|v| /^\?\? .+$/ =~ v}
      results
    end

end
