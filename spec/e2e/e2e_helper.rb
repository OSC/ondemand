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
    "amzn#{host_inventory['platform_version'].split('.')[0]}"
  when 'ubuntu'
    "ubuntu-#{host_inventory['platform_version']}"
  when 'debian'
    "debian-#{host_inventory['platform_version']}"
  end
end

def apt?
  ['ubuntu', 'debian'].include?(host_inventory['platform'])
end

def arch
  host_inventory['kernel']['machine']
end

def codename
  case "#{host_inventory['platform']}-#{host_inventory['platform_version']}"
  when 'ubuntu-24.04'
    'noble'
  when 'ubuntu-22.04'
    'jammy'
  when 'debian-12'
    'bookworm'
  end
end

def packager
  apt? ? 'DEBIAN_FRONTEND=noninteractive apt' : 'dnf'
end

def apache_service
  apt? ? 'apache2' : 'httpd'
end

def apache_reload
  apt? ? '/usr/sbin/apachectl graceful' : '/usr/sbin/httpd $OPTIONS -k graceful'
end

def apache_user
  case host_inventory['platform']
  when 'ubuntu', 'debian'
    'www-data'
  else
    'apache'
  end
end

def apache_log_dir
  "/var/log/#{apache_service.split('-').first}"
end

def ood_gems_path
  case host_inventory['platform']
  when 'redhat'
    return '/opt/ood/ondemand/root/usr/share/gems'
  when 'ubuntu', 'debian'
    return '/opt/ood/gems'
  end
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
    on hosts, 'dnf -y module enable ruby:3.3'
    on hosts, 'dnf -y module enable nodejs:22'
  when 'ubuntu', 'debian'
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
  elsif apt?
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
  ENV['OOD_BUILD_REPO'] || '4.1'
end

def install_ondemand
  if ['redhat', 'amazon'].include?(host_inventory['platform'])
    release_rpm = "https://yum.osc.edu/ondemand/latest/ondemand-release-web-#{build_repo_version}-1.#{dist}.noarch.rpm"
    on hosts, "[ -f /etc/yum.repos.d/ondemand-web.repo ] || #{packager} install -y #{release_rpm}"
    on hosts,
       "sed -i 's|ondemand/#{build_repo_version}/web|ondemand/build/#{build_repo_version}/web|g' /etc/yum.repos.d/ondemand-web.repo"
    on hosts, "dnf config-manager --save --setopt ondemand-web.exclude='ondemand ondemand-gems* ondemand-selinux'"
    install_packages(['ondemand', 'ondemand-dex', 'ondemand-selinux'])
  elsif apt?
    install_packages(['wget'])
    on hosts, "wget -O /tmp/ondemand-release.deb https://yum.osc.edu/ondemand/latest/ondemand-release-web_#{build_repo_version}.0-#{codename}_all.deb"
    install_packages(['/tmp/ondemand-release.deb'])
    on hosts,
       "sed -i 's|ondemand/#{build_repo_version}/web|ondemand/build/#{build_repo_version}/web|g' /etc/apt/sources.list.d/ondemand-web.list"
    on hosts, 'apt-get update'
    install_packages(['ondemand', 'ondemand-dex'])
  end
  if host_inventory['platform'] == 'amazon'
    on hosts, 'alternatives --install /usr/bin/node node /usr/bin/node-22 1'
    on hosts, 'alternatives --install /usr/bin/npm npm /usr/bin/npm-22 1'
  end
  # Avoid 'update_ood_portal --rpm' so that --insecure can be used
  on hosts, "sed -i 's|--rpm|--rpm --insecure|g' /etc/systemd/system/#{apache_service}.service.d/ood-portal.conf"
  on hosts, 'systemctl daemon-reload'
end

def fix_apache
  # ubuntu/debian has it's own default page
  if apt?
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
  apt? ? '/etc/apache2/sites-available' : '/etc/httpd/conf.d'
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
  if host_inventory['platform'] == 'debian' || host_inventory['platform_version'] == '24.04'
    install_packages(['python3', 'python3-flask'])
  else
    install_packages(['python3', 'python3-pip'])
    on hosts, 'python3 -m pip install flask'
  end
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
