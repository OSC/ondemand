# frozen_string_literal: true

require_relative '../e2e/e2e_helper'

def proj_root
  File.expand_path(File.join(File.dirname(__FILE__), '../..'))
end

def dist
  if host_inventory['platform'] == 'redhat'
    major_version = host_inventory['platform_version'].split('.')[0]
    "el#{major_version}"
  end
end

def packager
  if host_inventory['platform'] == 'redhat'
    if host_inventory['platform_version'] =~ /^7/
      'yum'
    else
      'dnf'
    end
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
  if host_inventory['platform'] == 'redhat'
    repos << 'epel-release'
    if host_inventory['platform_version'] =~ /^7/
      repos << 'centos-release-scl yum-plugin-priorities'
    else
      on hosts, 'dnf -y module enable ruby:2.7'
      on hosts, 'dnf -y module enable nodejs:12'
    end
  end
  install_packages(repos)
end

def ondemand_repo
  if host_inventory['platform'] == 'redhat'
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
    on hosts, 'mkdir -p /repo'
    copy_files_to_dir(File.join(proj_root, "dist/#{dist}/*.rpm"), '/repo')
    on hosts, 'createrepo /repo'
  end
end

def install_ondemand
  if host_inventory['platform'] == 'redhat'
    release_rpm = 'https://yum.osc.edu/ondemand/latest/ondemand-release-web-latest-1-6.noarch.rpm'
    on hosts, "[ -f /etc/yum.repos.d/ondemand-web.repo ] || #{packager} install -y #{release_rpm}"
    config_manager = if host_inventory['platform_version'] =~ /^7/
                       'yum-config-manager'
                     else
                       'dnf config-manager'
                     end
    on hosts, "#{config_manager} --save --setopt ondemand-web.exclude='ondemand ondemand-gems* ondemand-selinux'"
    install_packages(['ondemand', 'ondemand-dex', 'ondemand-selinux'])
  end
end

def upload_portal_config(file)
  scp_to(hosts, portal_fixture(file), '/etc/ood/config/ood_portal.yml')
end

def update_ood_portal
  on hosts, '/opt/ood/ood-portal-generator/sbin/update_ood_portal'
end

def restart_apache
  if host_inventory['platform'] == 'redhat'
    apache_service = if host_inventory['platform_version'] =~ /^7/
                       'httpd24-httpd'
                     else
                       'httpd'
                     end
  end
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
  if host_inventory['platform'] == 'redhat'
    install_packages(['python3'])
    on hosts, 'python3 -m pip install flask'
  end
end
