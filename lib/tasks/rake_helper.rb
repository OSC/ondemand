# frozen_string_literal: true

require 'pathname'
require 'erb'
require 'dotenv'
require 'tempfile'

module RakeHelper
  def proj_root
    File.expand_path(File.join(File.dirname(__FILE__), '../..'))
  end

  def infrastructure
    [
      'mod_ood_proxy',
      'nginx_stage',
      'ood_auth_map',
      'ood-portal-generator'
    ].map { |d| Component.new(d) }
  end

  def apps
    Dir["#{APPS_DIR}/*"].map { |d| Component.new(d) }
  end

  def ruby_apps
    apps.select(&:ruby_app?)
  end

  def yarn_apps
    apps.select(&:package_json?)
  end

  def yarn_app?(path)
    Pathname.new(path).join('yarn.lock').exist?
  end

  class Component
    attr_reader :name, :path

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

    def package_json?
      @path.join('package.json').exist?
    end

    def gemfile?
      @path.join('Gemfile.lock').exist?
    end
  end

  def infrastructure_files
    @infrastructure_files ||= [
      {
        src:  'apache-systemd.ood-portal.conf.erb',
        dest: File.join(DESTDIR, "etc/systemd/system/#{apache_service}.service.d/ood-portal.conf"),
        mode: 0o444
      },
      {
        src:  'apache-systemd.ood.conf',
        dest: File.join(DESTDIR, "etc/systemd/system/#{apache_service}.service.d/ood.conf"),
        mode: 0o444
      },
      {
        src:  'crontab',
        dest: File.join(DESTDIR, 'etc/cron.d/ood'),
        mode: 0o644
      },
      {
        src:  'favicon.ico',
        dest: File.join(DESTDIR, 'var/www/ood/public/favicon.ico'),
        mode: 0o644
      },
      {
        src:  'logo.png',
        dest: File.join(DESTDIR, 'var/www/ood/public/logo.png'),
        mode: 0o644
      },
      {
        src:  'logrotate',
        dest: File.join(DESTDIR, 'etc/logrotate.d/ood'),
        mode: 0o644
      },
      {
        src:  'ondemand-nginx-tmpfiles',
        dest: File.join(DESTDIR, 'usr/lib/tmpfiles.d/ondemand-nginx.conf'),
        mode: 0o644
      },
      {
        src:  'sudo.erb',
        dest: File.join(DESTDIR, 'etc/sudoers.d/ood'),
        mode: 0o440
      }
    ]
  end

  def render_package_file(name)
    src = File.join(proj_root, 'packaging/files', name)
    return src unless File.extname(name) == '.erb'

    content = ERB.new(File.read(src), trim_mode: '-').result(binding)
    begin
      t = Tempfile.new(name)
      t.write(content)
      t.path
    ensure
      t.close
    end
  end

  def ood_image_tag
    tag? ? numeric_tag : "#{numeric_tag}-#{git_hash}"
  end

  def ood_version
    tag? ? git_tag : "#{git_tag}-#{git_hash}"
  end

  def ood_package_version
    @ood_package_version ||= if ENV['VERSION']
                               ENV['VERSION'].to_s
                             elsif ENV['CI_COMMIT_TAG']
                               ENV['CI_COMMIT_TAG'].to_s
                             else
                               tag? ? git_tag : "#{git_tag}.#{build_timestamp}-#{git_hash}"
                             end

    @ood_package_version.gsub(/^v/, '')
  end

  def build_timestamp
    @build_timestamp ||= Time.now.strftime('%s')
  end

  def git_hash
    @git_hash ||= `git rev-parse HEAD`.strip[0..6]
  end

  def git_tag
    @git_tag ||= `git describe --tags --abbrev=0`.chomp
  end

  def nightly_version
    version_major, version_minor, version_patch = git_tag.gsub(/^v/, '').split('.', 3)
    date = Time.now.strftime('%Y%m%d')
    id = ENV['CI_PIPELINE_ID'] || Time.now.strftime('%H%M%S')
    "#{version_major}.#{version_minor}.#{date}-#{id}.#{git_hash}.nightly"
  end

  def today
    Time.now.strftime('%Y%m%d')
  end

  def numeric_tag
    @numeric_tag ||= git_tag.delete_prefix('v')
  end

  def tag?
    @tag ||= `git describe --exact-match --tags HEAD 2>/dev/null`.to_s != ''
  end

  def podman_runtime?
    @podman_runtime ||= ENV['CONTAINER_RT'] == 'podman'
  end

  def container_runtime
    podman_runtime? ? 'podman' : 'docker'
  end

  def dev_image_name
    'ood-dev'
  end

  def image_name
    'ood'
  end

  def user
    @user ||= Etc.getpwuid
  end

  def image_names
    @image_names ||=
      {
        ood: 'ood',
        dev: 'ood-dev',
        demo: 'ood-demo',
      }.freeze
  end

  def image_exists?(image_name)
    `#{container_runtime} inspect --type image --format exists #{image_name} || true`.chomp.eql?('exists')
  end

  def buildah_build_cmd(docker_file, image_name, image_tag: ood_image_tag, extra_args: [])
    args = ['bud', '--build-arg', "VERSION=#{ood_version}"]
    args.concat(['--layers'])
    args.concat ['-t', "#{image_name}:#{image_tag}", '-f', docker_file]
    args.concat extra_args

    "buildah #{args.join(' ')}"
  end

  def docker_build_cmd(docker_file, image_name, image_tag: ood_image_tag, extra_args: [])
    args = ['build', '--build-arg', "VERSION=#{ood_version}"]
    args.concat ['-t', "#{image_name}:#{image_tag}", '-f', docker_file, '.']
    args.concat extra_args

    "docker #{args.join(' ')}"
  end

  def build_cmd(file, image_name, image_tag: ood_image_tag, extra_args: [])
    if podman_runtime?
      buildah_build_cmd(file, image_name, image_tag: image_tag, extra_args: extra_args)
    else
      docker_build_cmd(file, image_name, image_tag: image_tag, extra_args: extra_args)
    end
  end

  def tag_latest_container_cmd(image_name, image_tag: ood_image_tag)
    "#{container_runtime} tag #{image_name}:#{image_tag} #{image_name}:latest"
  end

  def package_file(filename)
    File.join(proj_root, 'packaging/files', filename)
  end

  def ood_bin_dir
    "#{INSTALL_ROOT}/bin"
  end

  def rt_specific_flags
    if podman_runtime?
      ['--security-opt', 'label=disable'] # SELinux doesn't like it if you're mounting from $HOME
    else
      []
    end
  end

  def container_userns_flag
    return ['--userns', 'keep-id'] if container_runtime == 'podman'

    []
  end

  def os_release
    @os_release ||= if File.exist?('/etc/os-release')
                      Dotenv.parse('/etc/os-release')
                    else
                      {}
                    end
  end

  def el?
    return true if "#{os_release['ID']} #{os_release['ID_LIKE']}" =~ /(rhel|fedora)/

    false
  end

  def debian?
    return true if os_release['ID'] =~ (/(ubuntu|debian)/) || (os_release['ID_LIKE'] == 'debian')

    false
  end

  def apache_daemon
    "/usr/sbin/#{apache_service}"
  end

  def apache_reload
    return '/usr/sbin/apachectl graceful' if debian?

    "#{apache_daemon} $OPTIONS -k graceful"
  end

  def apache_user
    return 'www-data' if debian?

    'apache'
  end

  def apache_service
    return 'apache2' if debian?

    'httpd'
  end
end
