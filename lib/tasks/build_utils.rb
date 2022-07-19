# frozen_string_literal: true

module BuildUtils
  def proj_root
    File.expand_path(File.join(File.dirname(__FILE__), '../..'))
  end

  def image_tag
    tag? ? numeric_tag : "#{numeric_tag}-#{git_hash}"
  end

  def ood_version
    tag? ? git_tag : "#{git_tag}-#{git_hash}"
  end

  def build_timestamp
    @build_timestamp ||= Time.now.strftime("%s")
  end

  def git_hash
    @git_hash ||= `git rev-parse HEAD`.strip[0..6]
  end

  def git_tag
    @git_tag ||= `git describe --tags --abbrev=0`.chomp
  end

  def numeric_tag
    @numeric_tag ||= git_tag.delete_prefix('v')
  end

  def tag?
    @tag ||= `git describe --exact-match --tags HEAD 2>/dev/null`.to_s != ""
  end

  def ood_package_version
    @ood_package_version ||= begin
      if ENV['VERSION']
        ENV['VERSION'].to_s
      elsif ENV['CI_COMMIT_TAG']
        ENV['CI_COMMIT_TAG'].to_s
      else
        tag? ? git_tag : "#{git_tag}.#{build_timestamp}-#{git_hash}"
      end
    end
    @ood_package_version.gsub(/^v/, '')
  end

  def podman_runtime?
    @podman_runtime ||= ENV['CONTAINER_RT'] == "podman"
  end

  def container_runtime
    podman_runtime? ? "podman" : "docker"
  end

  def test_image_name
    "ood-test"
  end

  def dev_image_name
    "ood-dev"
  end

  def image_name
    "ood"
  end

  def user
    @user ||= Etc.getpwnam(Etc.getlogin)
  end

  def os_release
    @os_release ||= begin
      if File.exist?('/etc/os-release')
        Dotenv.parse('/etc/os-release')
      else
        {}
      end
    end
  end

  def scl_apache?
    return true if (el? && os_release['VERSION_ID'] =~ /^7/)
    false
  end

  def el?
    return true if "#{os_release['ID']} #{os_release['ID_LIKE']}" =~ /(rhel|fedora)/
    false
  end

  def debian?
    return true if (os_release['ID'] =~ /(ubuntu|debian)/ or os_release['ID_LIKE'] == 'debian')
    false
  end

  def apache_daemon
    return '/opt/rh/httpd24/root/usr/sbin/httpd-scl-wrapper' if scl_apache?
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
    return 'httpd24-httpd' if scl_apache?
    'httpd'
  end

  def infrastructure_files
    @infrastructure_files ||= [
      {
        src: 'apache-systemd.ood-portal.conf.erb',
        dest: File.join(DESTDIR, "etc/systemd/system/#{apache_service}.service.d/ood-portal.conf"),
        mode: 0444,
      },
      {
        src: 'apache-systemd.ood.conf',
        dest: File.join(DESTDIR, "etc/systemd/system/#{apache_service}.service.d/ood.conf"),
        mode: 0444,
      },
      {
        src: 'crontab',
        dest: File.join(DESTDIR, 'etc/cron.d/ood'),
        mode: 0644,
      },
      {
        src: 'favicon.ico',
        dest: File.join(DESTDIR, 'var/www/ood/public/favicon.ico'),
        mode: 0644,
      },
      {
        src: 'logo.png',
        dest: File.join(DESTDIR, 'var/www/ood/public/logo.png'),
        mode: 0644,
      },
      {
        src: 'logrotate',
        dest: File.join(DESTDIR, 'etc/logrotate.d/ood'),
        mode: 0644,
      },
      {
        src: 'ondemand-nginx-tmpfiles',
        dest: File.join(DESTDIR, 'usr/lib/tmpfiles.d/ondemand-nginx.conf'),
        mode: 0644,
      },
      {
        src: 'sudo.erb',
        dest: File.join(DESTDIR, 'etc/sudoers.d/ood'),
        mode: 0440,
      },
    ]
  end

  def render_package_file(name)
    src = File.join(proj_root, 'packaging/files', name)
    return src unless File.extname(name) == '.erb'

    content = ERB.new(File.read(src), nil, '-').result(binding)
    begin
      t = Tempfile.new(name)
      t.write(content)
      t.path
    ensure
      t.close
    end
  end
end