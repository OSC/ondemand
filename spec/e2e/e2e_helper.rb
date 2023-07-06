# frozen_string_literal: true

require 'watir'

def new_browser
  Watir::Browser.new :chrome, headless: true, options: { args: ['--disable-dev-shm-usage'] }
end

def ctr_base_url
  'http://localhost:8080'
end

def browser_login(browser)
  # sometimes you need to retry to let the container start up, so retry to make the tests
  # a little less flaky
  Watir::Wait.until(timeout: 60, interval: 3) do
    head = `curl --head -w '%{http_code}' -o /dev/null -s http://localhost:8080/`.to_s
    if head == '302'
      browser.goto ctr_base_url
      browser.text_field(id: 'username').present?
    else
      false
    end
  end

  browser.goto ctr_base_url
  browser.text_field(id: 'username').set 'ood@localhost'
  browser.text_field(id: 'password').set 'password'
  browser.button(id: 'submit-login').click
end

def hook_fixture(file)
  "#{File.expand_path('.')}/spec/fixtures/hooks/#{file}"
end

def portal_fixture(file)
  "#{File.expand_path('.')}/spec/fixtures/config/ood_portal/#{file}"
end

def extra_fixtures
  "#{File.expand_path('.')}/spec/fixtures/extras"
end

def proj_root
  File.expand_path(File.join(File.dirname(__FILE__), '../..'))
end

def dist
  case host_inventory['platform']
  when 'redhat'
    major_version = host_inventory['platform_version'].split('.')[0]
    "el#{major_version}"
  when 'amazon'
    "amzn#{host_inventory['platform_version']}"
  when 'ubuntu'
    "ubuntu-#{host_inventory['platform_version']}"
  end
end

def arch
  host_inventory['kernel']['machine']
end

def codename
  case "#{host_inventory['platform']}-#{host_inventory['platform_version']}"
  when 'ubuntu-22.04'
    'jammy'
  when 'ubuntu-20.04'
    'focal'
  end
end

def packager
  if host_inventory['platform'] == 'ubuntu'
    'DEBIAN_FRONTEND=noninteractive apt'
  elsif host_inventory['platform'] == 'redhat' && host_inventory['platform_version'] =~ /^7/
    'yum'
  else
    'dnf'
  end
end

def apache_service
  if host_inventory['platform'] == 'ubuntu'
    'apache2'
  elsif host_inventory['platform'] == 'redhat' && host_inventory['platform_version'] =~ /^7/
    'httpd24-httpd'
  else
    'httpd'
  end
end

def apache_reload
  if host_inventory['platform'] == 'ubuntu'
    '/usr/sbin/apachectl graceful'
  elsif host_inventory['platform'] == 'redhat' && host_inventory['platform_version'] =~ /^7/
    '/opt/rh/httpd24/root/usr/sbin/httpd-scl-wrapper $OPTIONS -k graceful'
  else
    '/usr/sbin/httpd $OPTIONS -k graceful'
  end
end

def apache_user
  case host_inventory['platform']
  when 'ubuntu'
    'www-data'
  else
    'apache'
  end
end

def apache_log_dir
  "/var/log/#{apache_service.split('-').first}"
end

def install_packages(packages)
  on hosts, "#{packager} install -y #{packages.join(' ')}"
end

def copy_files_to_dir(source, dir)
  Dir.glob(source).each do |file|
    name = File.basename(file)
    scp_to(hosts, file, File.join(dir, name))
  end
end

def bootstrap_repos
  repos = []
  case host_inventory['platform']
  when 'redhat'
    repos << 'epel-release'
    case host_inventory['platform_version']
    when /^7/
      repos << 'centos-release-scl yum-plugin-priorities'
    when /^(8|9)/
      on hosts, 'dnf -y module enable ruby:3.1'
      on hosts, 'dnf -y module enable nodejs:18'
    end
  when 'ubuntu'
    on hosts, 'apt-get update'
  end
  install_packages(repos) unless repos.empty?
end

def ondemand_repo
  on hosts, 'mkdir -p /repo'
  if ['redhat', 'amazon'].include?(host_inventory['platform'])
    install_packages(['createrepo'])
    repo_file = <<~EOS
      [ondemand-local]
      name=OnDemand
      enabled=1
      gpgcheck=0
      baseurl=file:///repo
      priority=1
    EOS
    create_remote_file(hosts, '/etc/yum.repos.d/ondemand.repo', repo_file)
    copy_files_to_dir(File.join(proj_root, "dist/#{dist}-#{arch}/*.rpm"), '/repo')
    on hosts, 'createrepo /repo'
  elsif host_inventory['platform'] == 'ubuntu'
    install_packages(['dpkg-dev'])
    copy_files_to_dir(File.join(proj_root, "dist/#{dist}-#{arch}/*.deb"), '/repo')
    on hosts, 'cd /repo ; dpkg-scanpackages .  | gzip -9c > Packages.gz'
    repo_file = <<~EOS
      deb [trusted=yes] file:///repo ./
    EOS
    preference = <<~EOS
      Package: *
      Pin: origin ""
      Pin-Priority: 1001
    EOS
    create_remote_file(hosts, '/etc/apt/sources.list.d/ondemand.list', repo_file)
    create_remote_file(hosts, '/etc/apt/preferences.d/ondemand', preference)
    on hosts, 'apt-get update'
  end
end

def build_repo_version
  ENV['OOD_BUILD_REPO'] || '3.1'
end

def install_ondemand
  if ['redhat', 'amazon'].include?(host_inventory['platform'])
    release_rpm = "https://yum.osc.edu/ondemand/latest/ondemand-release-web-#{build_repo_version}-1.#{dist}.noarch.rpm"
    on hosts, "[ -f /etc/yum.repos.d/ondemand-web.repo ] || #{packager} install -y #{release_rpm}"
    on hosts,
       "sed -i 's|ondemand/#{build_repo_version}/web|ondemand/build/#{build_repo_version}/web|g' /etc/yum.repos.d/ondemand-web.repo"
    config_manager = if host_inventory['platform_version'] =~ /^7/
                       'yum-config-manager'
                     else
                       'dnf config-manager'
                     end
    on hosts, "#{config_manager} --save --setopt ondemand-web.exclude='ondemand ondemand-gems* ondemand-selinux'"
    install_packages(['ondemand', 'ondemand-dex', 'ondemand-selinux'])
  elsif host_inventory['platform'] == 'ubuntu'
    install_packages(['wget'])
    on hosts, "wget -O /tmp/ondemand-release.deb https://yum.osc.edu/ondemand/latest/ondemand-release-web_#{build_repo_version}.0-#{codename}_all.deb"
    install_packages(['/tmp/ondemand-release.deb'])
    on hosts,
       "sed -i 's|ondemand/#{build_repo_version}/web|ondemand/build/#{build_repo_version}/web|g' /etc/apt/sources.list.d/ondemand-web.list"
    on hosts, 'apt-get update'
    install_packages(['ondemand', 'ondemand-dex'])
  end
  # Avoid 'update_ood_portal --rpm' so that --insecure can be used
  on hosts, "sed -i 's|--rpm|--rpm --insecure|g' /etc/systemd/system/#{apache_service}.service.d/ood-portal.conf"
  on hosts, 'systemctl daemon-reload'
end

def fix_apache
  # ubuntu has it's own default page
  if host_inventory['platform'] == 'ubuntu'
    default_config = '/etc/apache2/sites-enabled/000-default.conf'
    on hosts, "test -L #{default_config} && unlink #{default_config} || exit 0"
  end
  # Avoid errors when running on non x86_64 hardware via Docker
  on hosts, "echo 'Mutex posixsem' > #{apache_conf_dir}/mutex.conf"
end

def upload_portal_config(file)
  scp_to(hosts, portal_fixture(file), '/etc/ood/config/ood_portal.yml')
end

def apache_conf_dir
  if host_inventory['platform'] == 'ubuntu'
    '/etc/apache2/sites-available'
  elsif host_inventory['platform'] == 'redhat' && host_inventory['platform_version'] =~ /^7/
    '/opt/rh/httpd24/root/etc/httpd/conf.d'
  else
    '/etc/httpd/conf.d'
  end
end

def host_portal_config
  File.join(apache_conf_dir, 'ood-portal.conf')
end

def update_ood_portal
  on hosts, '/opt/ood/ood-portal-generator/sbin/update_ood_portal --insecure'
end

def restart_apache
  on hosts, "systemctl restart #{apache_service}"
end

def restart_dex
  on hosts, 'systemctl restart ondemand-dex'
end

def bootstrap_user
  on hosts, 'getent group ood || groupadd ood'
  on hosts, 'getent passwd ood || useradd --create-home --gid ood ood'
end

def bootstrap_flask
  install_packages(['python3', 'python3-pip'])
  on hosts, 'python3 -m pip install flask'
end

def dl_ctr_logs
  dir = File.join(proj_root, 'tmp/e2e_ctr').tap { |d| `mkdir -p #{d}` }

  hosts.each do |host|
    host_dir = "#{dir}/#{host}".tap { |d| `mkdir -p #{d}` }
    {
      '/var/log/ondemand-nginx/ood' => 'error.log',
      apache_log_dir.to_s           => 'localhost_error.log'
    }.each do |ctr_dir, file|
      `docker cp ondemand-#{host}:#{ctr_dir}/#{file} #{host_dir}/#{file}`
    end
  end
end
