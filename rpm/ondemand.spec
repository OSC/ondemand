Name:      ondemand
Version:   1.2.0
Release:   1%{dist}
Summary:   Web server that provides users access to HPC resources

Group:     System Environment/Daemons
License:   MIT
URL:       https://osc.github.io/Open-OnDemand
Source0:   ondemand-1.2.0.tar.gz

%if 0%{?rhel} >= 7
%bcond_without systemd
%else
%bcond_with systemd
%endif

BuildRequires:   sqlite-devel, curl
BuildRequires:   rh-ruby22, rh-ruby22-rubygem-rake, rh-ruby22-rubygem-bundler, rh-ruby22-ruby-devel, nodejs010, git19
Requires:        sudo, lsof, sqlite-devel, cronie, wget, curl
Requires:        httpd24, httpd24-mod_ssl, httpd24-mod_ldap, nginx16, rh-passenger40, rh-ruby22, rh-ruby22-rubygem-rake, rh-ruby22-rubygem-bundler, rh-ruby22-ruby-devel, nodejs010, git19

%if %{with systemd}
BuildRequires: systemd
%{?systemd_requires}
%endif

%description
Open OnDemand is an open source release of OSC's OnDemand platform to provide
HPC access via a web browser, supporting web based file management, shell
access, job submission and interactive work on compute nodes.


%prep
%setup -q -n data


%build
SCL_SOURCE=$(command -v scl_source)
if [ "$SCL_SOURCE" ]; then
  source "$SCL_SOURCE" enable rh-ruby22 nodejs010 git19 &> /dev/null || :
fi
rake


%install
SCL_SOURCE=$(command -v scl_source)
if [ "$SCL_SOURCE" ]; then
  source "$SCL_SOURCE" enable rh-ruby22 &> /dev/null || :
fi
rake install PREFIX=%{buildroot}/opt/ood
mkdir -p %{buildroot}%{_localstatedir}/www/ood/public
mkdir -p %{buildroot}%{_localstatedir}/www/ood/discover
mkdir -p %{buildroot}%{_localstatedir}/www/ood/register
mkdir -p %{buildroot}%{_localstatedir}/www/ood/apps/sys
mkdir -p %{buildroot}%{_localstatedir}/www/ood/apps/usr
ln -s -f /opt/ood/apps/dashboard %{buildroot}%{_localstatedir}/www/ood/apps/sys/dashboard
ln -s -f /opt/ood/apps/shell %{buildroot}%{_localstatedir}/www/ood/apps/sys/shell
ln -s -f /opt/ood/apps/files %{buildroot}%{_localstatedir}/www/ood/apps/sys/files
ln -s -f /opt/ood/apps/file-editor %{buildroot}%{_localstatedir}/www/ood/apps/sys/file-editor
ln -s -f /opt/ood/apps/activejobs %{buildroot}%{_localstatedir}/www/ood/apps/sys/activejobs
ln -s -f /opt/ood/apps/myjobs %{buildroot}%{_localstatedir}/www/ood/apps/sys/myjobs
ln -s -f /opt/ood/apps/myjobs %{buildroot}%{_localstatedir}/www/ood/apps/sys/bc_desktop
mkdir -p %{buildroot}%{_sharedstatedir}/nginx/config/puns
mkdir -p %{buildroot}%{_sharedstatedir}/nginx/config/apps/sys
mkdir -p %{buildroot}%{_sharedstatedir}/nginx/config/apps/usr
mkdir -p %{buildroot}%{_sharedstatedir}/nginx/config/apps/dev

install -D -m 644 build/ood-portal-generator/share/ood_portal_example.yml \
    %{buildroot}%{_sysconfdir}/ood/config/ood_portal.yml
mkdir -p %{buildroot}/opt/rh/httpd24/root/etc/httpd/conf.d
%{buildroot}/opt/ood/ood-portal-generator/bin/generate \
    -c %{buildroot}%{_sysconfdir}/ood/config/ood_portal.yml \
    -o %{buildroot}/opt/rh/httpd24/root/etc/httpd/conf.d/ood-portal.conf

install -D -m 644 build/nginx_stage/share/nginx_stage_example.yml \
    %{buildroot}%{_sysconfdir}/ood/config/nginx_stage.yml
touch %{buildroot}%{_sharedstatedir}/nginx/config/apps/sys/dashboard.conf
touch %{buildroot}%{_sharedstatedir}/nginx/config/apps/sys/shell.conf
touch %{buildroot}%{_sharedstatedir}/nginx/config/apps/sys/files.conf
touch %{buildroot}%{_sharedstatedir}/nginx/config/apps/sys/file-editor.conf
touch %{buildroot}%{_sharedstatedir}/nginx/config/apps/sys/activejobs.conf
touch %{buildroot}%{_sharedstatedir}/nginx/config/apps/sys/myjobs.conf
touch %{buildroot}%{_sharedstatedir}/nginx/config/apps/sys/bc_desktop.conf
(
export NGINX_STAGE_CONFIG_FILE=$(mktemp)
cat > $NGINX_STAGE_CONFIG_FILE << EOF
app_config_path:
  sys: '%{buildroot}%{_sharedstatedir}/nginx/config/apps/sys/%%{name}.conf'
EOF
ruby -I%{buildroot}/opt/ood/nginx_stage/lib -rnginx_stage \
    -e "NginxStage::Application.start" -- app_reset --sub-uri=/pun
rm -f $NGINX_STAGE_CONFIG_FILE
)

mkdir -p %{buildroot}%{_sysconfdir}/sudoers.d
cat >> %{buildroot}%{_sysconfdir}/sudoers.d/ood << EOF
Defaults:apache !requiretty, !authenticate
apache ALL=(ALL) NOPASSWD: /opt/ood/nginx_stage/sbin/nginx_stage
EOF
chmod 600 %{buildroot}%{_sysconfdir}/sudoers.d/ood

mkdir -p %{buildroot}%{_sysconfdir}/cron.d
cat >> %{buildroot}%{_sysconfdir}/cron.d/ood << EOF
#!/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
0 */2 * * * root [ -f /opt/ood/bin/update_nginx_stage ] && /opt/ood/bin/update_nginx_stage >/dev/null
EOF

%if %{with systemd}
mkdir -p %{buildroot}%{_sysconfdir}/systemd/system/httpd24-httpd.service.d
cat >> %{buildroot}%{_sysconfdir}/systemd/system/httpd24-httpd.service.d/ood.conf << EOF
[Service]
KillSignal=SIGTERM
KillMode=process
PrivateTmp=false
EOF
%endif


%post
sed -i 's/^HTTPD24_HTTPD_SCLS_ENABLED=.*/HTTPD24_HTTPD_SCLS_ENABLED="httpd24 rh-ruby22"/' \
    /opt/rh/httpd24/service-environment
/opt/ood/bin/update_nginx_stage &>/dev/null || :
/opt/ood/bin/update_ood_portal &>/dev/null || :


%preun
if [ "$1" -eq 0 ]; then
sed -i 's/^HTTPD24_HTTPD_SCLS_ENABLED=.*/HTTPD24_HTTPD_SCLS_ENABLED="httpd24"/' \
    /opt/rh/httpd24/service-environment
/opt/ood/nginx_stage/sbin/nginx_stage nginx_clean --force &>/dev/null || :
fi


%postun
if [ "$1" -eq 0 ]; then
%if %{with systemd}
/bin/systemctl try-restart httpd24-httpd.service httpd24-htcacheclean.service &>/dev/null || :
%else
/sbin/service httpd24-httpd condrestart &>/dev/null
/sbin/service httpd24-htcacheclean condrestart &>/dev/null
exit 0
%endif
fi

%posttrans
%if %{with systemd}
/bin/systemctl try-restart httpd24-httpd.service httpd24-htcacheclean.service &>/dev/null || :
%else
/sbin/service httpd24-httpd condrestart &>/dev/null
/sbin/service httpd24-htcacheclean condrestart &>/dev/null
exit 0
%endif

%files
%defattr(-,root,root)

/opt/ood

%dir %{_localstatedir}/www/ood
%dir %{_localstatedir}/www/ood/public
%dir %{_localstatedir}/www/ood/register
%dir %{_localstatedir}/www/ood/discover
%dir %{_localstatedir}/www/ood/apps
%dir %{_localstatedir}/www/ood/apps/sys
%dir %{_localstatedir}/www/ood/apps/usr
%config(noreplace,missingok) %{_localstatedir}/www/ood/apps/sys/dashboard
%config(noreplace,missingok) %{_localstatedir}/www/ood/apps/sys/shell
%config(noreplace,missingok) %{_localstatedir}/www/ood/apps/sys/files
%config(noreplace,missingok) %{_localstatedir}/www/ood/apps/sys/file-editor
%config(noreplace,missingok) %{_localstatedir}/www/ood/apps/sys/activejobs
%config(noreplace,missingok) %{_localstatedir}/www/ood/apps/sys/myjobs
%config(noreplace,missingok) %{_localstatedir}/www/ood/apps/sys/bc_desktop

%dir %{_sysconfdir}/ood
%dir %{_sysconfdir}/ood/config
%config(noreplace,missingok) %{_sysconfdir}/ood/config/nginx_stage.yml
%config(noreplace,missingok) %{_sysconfdir}/ood/config/ood_portal.yml

%dir %{_sharedstatedir}/nginx/config
%dir %{_sharedstatedir}/nginx/config/puns
%dir %{_sharedstatedir}/nginx/config/apps
%dir %{_sharedstatedir}/nginx/config/apps/sys
%dir %{_sharedstatedir}/nginx/config/apps/usr
%dir %{_sharedstatedir}/nginx/config/apps/dev
%config(noreplace,missingok) %{_sharedstatedir}/nginx/config/apps/sys/dashboard.conf
%config(noreplace,missingok) %{_sharedstatedir}/nginx/config/apps/sys/shell.conf
%config(noreplace,missingok) %{_sharedstatedir}/nginx/config/apps/sys/files.conf
%config(noreplace,missingok) %{_sharedstatedir}/nginx/config/apps/sys/file-editor.conf
%config(noreplace,missingok) %{_sharedstatedir}/nginx/config/apps/sys/activejobs.conf
%config(noreplace,missingok) %{_sharedstatedir}/nginx/config/apps/sys/myjobs.conf
%config(noreplace,missingok) %{_sharedstatedir}/nginx/config/apps/sys/bc_desktop.conf

%config %{_sysconfdir}/sudoers.d/ood
%config(noreplace) %{_sysconfdir}/cron.d/ood
%config(noreplace) /opt/rh/httpd24/root/etc/httpd/conf.d/ood-portal.conf
%if %{with systemd}
%config %{_sysconfdir}/systemd/system/httpd24-httpd.service.d/ood.conf
%endif


%changelog

