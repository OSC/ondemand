# frozen_string_literal: true

require_relative 'build_utils'
require 'erb'
require 'dotenv'
require 'tempfile'

module InstallUtils
  include BuildUtils

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
