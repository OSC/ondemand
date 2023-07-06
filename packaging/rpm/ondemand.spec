%{!?ncpus: %define ncpus 12}
%global package_name ondemand
%{!?package_release: %define package_release 1}
%{!?git_tag: %define git_tag v%{package_version}}
%define git_tag_minus_v %(echo %{git_tag} | sed -r 's/^v//')
%define major_version %(echo %{git_tag_minus_v} | cut -d. -f1)
%define minor_version %(echo %{git_tag_minus_v} | cut -d. -f2)
%define runtime_version %{major_version}.%{minor_version}.3
%define runtime_release 1
%define runtime_version_full %{runtime_version}-%{runtime_release}%{?dist}
%define selinux_policy_ver %(rpm --qf "%%{version}" -q selinux-policy)
%global selinux_module_version %{package_version}.%{package_release}
%global gem_home %{scl_ondemand_core_gem_home}/%{version}-%{package_release}
%global gems_name ondemand-gems-%{version}-%{package_release}

%define __brp_mangle_shebangs /bin/true
%if 0%{?amzn}
# RPATH is always broken with things like nokogiri
# but only Amazon Linux 2023 seems to care so disable the check
%global __brp_check_rpaths /bin/true
%endif

Name:      %{package_name}
Version:   %{package_version}
Release:   %{package_release}%{?dist}
Summary:   Web server that provides users access to HPC resources

Group:     System Environment/Daemons
License:   MIT
URL:       https://osc.github.io/Open-OnDemand
Source0:   https://github.com/OSC/%{package_name}/releases/download/%{git_tag}/%{package_name}-%{git_tag_minus_v}.tar.gz
Source1:   ondemand-selinux.te
Source2:   ondemand-selinux.fc

# Disable debuginfo as it causes issues with bundled gems that build libraries
%global debug_package %{nil}

# Avoid duplicate build-id files between builds of ondemand-gems
%global _build_id_links none

# These can improve build times but increase ondemand-gems RPM size
# Leaving in case build times become an issue
# %%global __brp_strip /bin/true
# %%global __brp_strip_comment_note /bin/true
# %%global __brp_strip_static_archive /bin/true
# %%global __os_install_post %{nil}

%if 0%{?rhel} == 7
%bcond_without scl_apache
%define apache_confd /opt/rh/httpd24/root/etc/httpd/conf.d
%define apache_service httpd24-httpd
%else
%bcond_with scl_apache
%define apache_confd /etc/httpd/conf.d
%define apache_service httpd
%endif

# Disable automatic dependencies as it causes issues with bundled gems and
# node.js packages used in the apps
AutoReqProv:     no

BuildRequires:   ondemand-runtime = %{runtime_version_full}
BuildRequires:   ondemand-scldevel = %{runtime_version_full}
BuildRequires:   ondemand-build = %{runtime_version_full}
BuildRequires:   ondemand-ruby = %{runtime_version_full}
BuildRequires:   ondemand-nodejs = %{runtime_version_full}
BuildRequires:   rsync
BuildRequires:   git
BuildRequires:   python3
BuildRequires:   libffi-devel
BuildRequires:   libyaml-devel

Requires:        git
Requires:        sudo, lsof, cronie, wget, curl, make, rsync, file, libxml2, libxslt, zlib, lua-posix, diffutils
Requires:        python3
# rclone is not available for Amazon Linux 2023
%if 0%{?rhel}
Requires:        rclone
%endif
Requires:        ondemand-apache = %{runtime_version_full}
Requires:        ondemand-nginx = 1.22.1-1.p6.0.17.ood%{runtime_version}%{?dist}
Requires:        ondemand-passenger = 6.0.17-1.ood%{runtime_version}%{?dist}
Requires:        ondemand-ruby = %{runtime_version_full}
Requires:        ondemand-nodejs = %{runtime_version_full}
Requires:        ondemand-runtime = %{runtime_version_full}
Requires:        %{gems_name}

BuildRequires: systemd
%{?systemd_requires}

%description
Open OnDemand is an open source release of OSC's OnDemand platform to provide
HPC access via a web browser, supporting web based file management, shell
access, job submission and interactive work on compute nodes.

%package -n %{name}-selinux
Summary: SELinux policy for OnDemand
BuildRequires:      selinux-policy, selinux-policy-devel, checkpolicy, policycoreutils
Requires:           %{name} = %{version}-%{release}
Requires:           selinux-policy >= %{selinux_policy_ver}
Requires(post):     /usr/sbin/semodule, /sbin/restorecon, /usr/sbin/setsebool, /usr/sbin/selinuxenabled, /usr/sbin/semanage
Requires(post):     selinux-policy-targeted
Requires(postun):   /usr/sbin/semodule, /sbin/restorecon

%description -n %{name}-selinux
SELinux policy for OnDemand

%package -n %{gems_name}
Summary: Rubygems for OnDemand
AutoReqProv: no

%description -n %{gems_name}
Rubygem for OnDemand

%package -n ondemand-gems
Summary: Metapackage to include Rubygems for OnDemand
Requires: %{gems_name}

%description -n ondemand-gems
Metapackage to include Rubygems for OnDemand

%prep
%setup -q -n %{package_name}-%{git_tag_minus_v}


%build
%__mkdir selinux
pushd selinux
echo "SELinux policy %{selinux_policy_ver}"
%__cp %{SOURCE1} ./ondemand-selinux.te
%__cp %{SOURCE2} ./ondemand-selinux.fc
%__sed -i 's/@VERSION@/%{selinux_module_version}/' ./ondemand-selinux.te
%__make -f %{_datadir}/selinux/devel/Makefile
popd

scl enable ondemand - << \EOS
set -x
set -e
export GEM_HOME=$(pwd)/gems-build
export GEM_PATH=$(pwd)/gems-build:$GEM_PATH
%ifarch aarch64
%if 0%{?rhel} && 0%{?rhel} < 9
# Nokogiri and possibly other gems will fail to build on older aarch64 and glibc
bundle config set --global force_ruby_platform true
%endif
%endif
%ifarch ppc64le
bundle config set --global force_ruby_platform true
%endif
BUNDLE_WITHOUT='test package' bundle install
rake --trace -mj%{ncpus} build
rm -rf ${GEM_HOME}/cache
rm -rf apps/*/node_modules/.cache
EOS


%install
%__install -p -m 644 -D selinux/%{name}-selinux.pp %{buildroot}%{_datadir}/selinux/packages/%{name}-selinux/%{name}-selinux.pp

scl enable ondemand - << \EOS
set -x
set -e
%__mkdir_p %{buildroot}%{gem_home}
%__mv ./gems-build/* %{buildroot}%{gem_home}/
export GEM_PATH=%{buildroot}%{gem_home}:$GEM_PATH
rake --trace install DESTDIR=%{buildroot}

%__rm %{buildroot}/opt/ood/apps/*/log/production.log
echo "%{git_tag}" > %{buildroot}/opt/ood/VERSION
%__mkdir_p %{buildroot}%{_localstatedir}/www/ood/public
%__mkdir_p %{buildroot}%{_localstatedir}/www/ood/discover
%__mkdir_p %{buildroot}%{_localstatedir}/www/ood/register
%__mkdir_p %{buildroot}%{_localstatedir}/www/ood/apps/sys
%__mkdir_p %{buildroot}%{_localstatedir}/www/ood/apps/usr
# Avoid x86 compiled fixtures on non-x86
%__rm -rf %{buildroot}/opt/ood/apps/dashboard/test
%__mv %{buildroot}/opt/ood/apps/dashboard %{buildroot}%{_localstatedir}/www/ood/apps/sys/dashboard
%__mv %{buildroot}/opt/ood/apps/shell %{buildroot}%{_localstatedir}/www/ood/apps/sys/shell
%__mv %{buildroot}/opt/ood/apps/files %{buildroot}%{_localstatedir}/www/ood/apps/sys/files
%__mv %{buildroot}/opt/ood/apps/file-editor %{buildroot}%{_localstatedir}/www/ood/apps/sys/file-editor
%__mv %{buildroot}/opt/ood/apps/activejobs %{buildroot}%{_localstatedir}/www/ood/apps/sys/activejobs
%__mv %{buildroot}/opt/ood/apps/myjobs %{buildroot}%{_localstatedir}/www/ood/apps/sys/myjobs
%__mv %{buildroot}/opt/ood/apps/bc_desktop %{buildroot}%{_localstatedir}/www/ood/apps/sys/bc_desktop
%__rm -rf %{buildroot}/opt/ood/apps
%__mkdir_p %{buildroot}%{_sharedstatedir}/ondemand-nginx/config/puns
%__mkdir_p %{buildroot}%{_sharedstatedir}/ondemand-nginx/config/apps/sys
%__mkdir_p %{buildroot}%{_sharedstatedir}/ondemand-nginx/config/apps/usr
%__mkdir_p %{buildroot}%{_sharedstatedir}/ondemand-nginx/config/apps/dev
%__mkdir_p %{buildroot}%{_tmppath}/ondemand-nginx
%__mkdir_p %{buildroot}%{_rundir}/ondemand-nginx

%__install -D -m 644 ood-portal-generator/share/ood_portal_example.yml \
    %{buildroot}%{_sysconfdir}/ood/config/ood_portal.yml
%__mkdir_p %{buildroot}%{apache_confd}
PREFIX=%{buildroot} %{buildroot}/opt/ood/ood-portal-generator/sbin/update_ood_portal
%__sed -i 's|%{buildroot}||g' %{buildroot}%{_sysconfdir}/ood/config/ood_portal.sha256sum
%__mkdir_p %{buildroot}%{_localstatedir}/www/ood/public/maintenance
%__install -D -m 644 ood-portal-generator/share/maintenance.html \
    %{buildroot}%{_localstatedir}/www/ood/public/maintenance/index.html
%__install -D -m 644 ood-portal-generator/share/need_auth.html \
    %{buildroot}%{_localstatedir}/www/ood/public/need_auth.html

%__install -D -m 644 nginx_stage/share/nginx_stage_example.yml \
    %{buildroot}%{_sysconfdir}/ood/config/nginx_stage.yml
touch %{buildroot}%{_sharedstatedir}/ondemand-nginx/config/apps/sys/dashboard.conf
touch %{buildroot}%{_sharedstatedir}/ondemand-nginx/config/apps/sys/shell.conf
touch %{buildroot}%{_sharedstatedir}/ondemand-nginx/config/apps/sys/myjobs.conf

%__cp -R hooks %{buildroot}/opt/ood/hooks
%__install -D -m 644 hooks/hook.env.example %{buildroot}%{_sysconfdir}/ood/config/hook.env
EOS

%post
%if %{with scl_apache}
if [ "$1" -eq 2 ]; then
%__sed -i 's/^HTTPD24_HTTPD_SCLS_ENABLED=.*/HTTPD24_HTTPD_SCLS_ENABLED="httpd24"/' \
    /opt/rh/httpd24/service-environment
fi
%endif

/bin/systemctl daemon-reload &>/dev/null || :

# These NGINX app configs need to exist before rebuilding them
touch %{_sharedstatedir}/ondemand-nginx/config/apps/sys/dashboard.conf
touch %{_sharedstatedir}/ondemand-nginx/config/apps/sys/shell.conf
touch %{_sharedstatedir}/ondemand-nginx/config/apps/sys/myjobs.conf

%post selinux
SELINUX_TEMP=$(mktemp -t ondemand-selinux-enable.XXXXX)
echo "boolean -m --on httpd_setrlimit" >> $SELINUX_TEMP
echo "boolean -m --on httpd_mod_auth_pam" >> $SELINUX_TEMP
echo "boolean -m --on httpd_run_stickshift" >> $SELINUX_TEMP
echo "boolean -m --on httpd_can_network_connect" >> $SELINUX_TEMP
echo "boolean -m --on daemons_use_tty" >> $SELINUX_TEMP
echo "boolean -m --on use_nfs_home_dirs" >> $SELINUX_TEMP
semanage -S targeted -i $SELINUX_TEMP
semodule -i %{_datadir}/selinux/packages/%{name}-selinux/%{name}-selinux.pp
restorecon -R /opt/ood/nginx_stage
restorecon -R /opt/ood/ondemand/root/usr/sbin/nginx
restorecon -R /opt/ood/ondemand/root/usr/lib64/passenger/support-binaries/PassengerAgent
restorecon -R %{_rundir}/ondemand-nginx
restorecon -R %{_sharedstatedir}/ondemand-nginx
restorecon -R %{_localstatedir}/tmp/ondemand-nginx
restorecon -R %{_localstatedir}/log/ondemand-nginx
restorecon -R %{_localstatedir}/www/ood

%preun
if [ "$1" -eq 0 ]; then
/opt/ood/nginx_stage/sbin/nginx_stage nginx_clean --force &>/dev/null || :
fi

%preun selinux
semodule -r %{name}-selinux 2>/dev/null || :

%postun
if [ "$1" -eq 0 ]; then
/bin/systemctl daemon-reload &>/dev/null || :
/bin/systemctl try-restart %{apache_service}.service &>/dev/null || :
fi

%postun selinux
if [ "$1" -ge "1" ] ; then # Upgrade
semodule -i %{_datadir}/selinux/packages/%{name}-selinux/%{name}-selinux.pp 2>/dev/null || :
fi

%posttrans
# Rebuild NGINX app configs and restart PUNs w/ no active connections
/opt/ood/nginx_stage/sbin/update_nginx_stage &>/dev/null || :
# Migrate from OnDemand 1.3 or 1.4
if [ -d %{_sharedstatedir}/nginx/config ] ; then
    rm -rf %{_sharedstatedir}/nginx/config
fi

# Restart apps in case PUN wasn't restarted
touch %{_localstatedir}/www/ood/apps/sys/dashboard/tmp/restart.txt
touch %{_localstatedir}/www/ood/apps/sys/shell/tmp/restart.txt
touch %{_localstatedir}/www/ood/apps/sys/myjobs/tmp/restart.txt

/bin/systemctl try-restart %{apache_service}.service &>/dev/null || :

%files
%defattr(-,root,root)

/opt/ood/VERSION
/opt/ood/mod_ood_proxy
/opt/ood/nginx_stage
/opt/ood/ood-portal-generator
/opt/ood/ood_auth_map
/opt/ood/hooks
%{_localstatedir}/www/ood/apps/sys/dashboard
%{_localstatedir}/www/ood/apps/sys/shell
%{_localstatedir}/www/ood/apps/sys/files
%{_localstatedir}/www/ood/apps/sys/file-editor
%{_localstatedir}/www/ood/apps/sys/activejobs
%{_localstatedir}/www/ood/apps/sys/myjobs
%{_localstatedir}/www/ood/apps/sys/bc_desktop
%exclude %{_localstatedir}/www/ood/apps/sys/*/tmp/*

%dir %{_localstatedir}/www/ood
%dir %{_localstatedir}/www/ood/public
%dir %{_localstatedir}/www/ood/public/maintenance
%dir %{_localstatedir}/www/ood/register
%dir %{_localstatedir}/www/ood/discover
%dir %{_localstatedir}/www/ood/apps
%dir %{_localstatedir}/www/ood/apps/sys
%dir %{_localstatedir}/www/ood/apps/usr
%config(noreplace,missingok) %{_localstatedir}/www/ood/public/maintenance/index.html
%{_localstatedir}/www/ood/public/need_auth.html
%ghost %{_sysconfdir}/ood/maintenance.enable
%config(noreplace,missingok) %{_localstatedir}/www/ood/public/logo.png
%config(noreplace,missingok) %{_localstatedir}/www/ood/public/favicon.ico

%dir %{_sysconfdir}/ood
%dir %{_sysconfdir}/ood/config
%config(noreplace,missingok) %{_sysconfdir}/ood/config/nginx_stage.yml
%config(noreplace,missingok) %{_sysconfdir}/ood/config/ood_portal.yml
%config(noreplace,missingok) %{_sysconfdir}/ood/config/hook.env
%config(noreplace) %{_sysconfdir}/ood/config/ood_portal.sha256sum

%dir %{_sharedstatedir}/ondemand-nginx/config
%dir %{_sharedstatedir}/ondemand-nginx/config/puns
%dir %{_sharedstatedir}/ondemand-nginx/config/apps
%dir %{_sharedstatedir}/ondemand-nginx/config/apps/sys
%dir %{_sharedstatedir}/ondemand-nginx/config/apps/usr
%dir %{_sharedstatedir}/ondemand-nginx/config/apps/dev
%ghost %{_sharedstatedir}/ondemand-nginx/config/apps/sys/dashboard.conf
%ghost %{_sharedstatedir}/ondemand-nginx/config/apps/sys/shell.conf
%ghost %{_sharedstatedir}/ondemand-nginx/config/apps/sys/myjobs.conf
%dir %{_tmppath}/ondemand-nginx
%dir %{_rundir}/ondemand-nginx

%config(noreplace) %{_sysconfdir}/sudoers.d/ood
%config(noreplace) %{_sysconfdir}/cron.d/ood
%config(noreplace) %{_sysconfdir}/logrotate.d/ood
%config(noreplace) %attr(0640, root, apache) %{apache_confd}/ood-portal.conf
%config(noreplace) %{_sysconfdir}/systemd/system/%{apache_service}.service.d/ood.conf
%config(noreplace,missingok) %{_sysconfdir}/systemd/system/%{apache_service}.service.d/ood-portal.conf
%{_tmpfilesdir}/ondemand-nginx.conf

%files -n %{gems_name}
%{gem_home}/*

%files -n ondemand-gems

%files -n %{name}-selinux
%{_datadir}/selinux/packages/%{name}-selinux/%{name}-selinux.pp

%changelog
* Fri Feb 08 2019 Morgan Rodgers <mrodgers@osc.edu> 1.5.4-2
- Second build for 1.5.4 (mrodgers@osc.edu)

* Fri Feb 08 2019 Morgan Rodgers <mrodgers@osc.edu> 1.5.4-1
- Bump release to 1.5.4 (mrodgers@osc.edu)

* Thu Feb 07 2019 Morgan Rodgers <mrodgers@osc.edu> 1.5.3-1
- Bump release to 1.5.3 (mrodgers@osc.edu)

* Tue Feb 05 2019 Trey Dockendorf <tdockendorf@osc.edu> 1.5.2-6
- Re-added rh-ruby24 back into apache startup (tdockendorf@osc.edu)

* Sun Feb 03 2019 Trey Dockendorf <tdockendorf@osc.edu> 1.5.2-5
- Fix Update to not copy config.rpmsave to config.rpmsave (tdockendorf@osc.edu)

* Sun Feb 03 2019 Trey Dockendorf <tdockendorf@osc.edu> 1.5.2-4
- Copy from config.rpmsave because earlier step removed app configs from
  original path (tdockendorf@osc.edu)

* Sat Feb 02 2019 Trey Dockendorf <tdockendorf@osc.edu> 1.5.2-3
- No longer set HTTPD24_HTTPD_SCLS_ENABLED, causes problems on RHEL 6 and not
  needed (tdockendorf@osc.edu)

* Fri Feb 01 2019 Trey Dockendorf <tdockendorf@osc.edu> 1.5.2-2
- Handle 1.3 to 1.5 upgrades and better upgrade handling Add /var/tmp/ondemand-
  nginx (tdockendorf@osc.edu)

* Fri Feb 01 2019 Trey Dockendorf <tdockendorf@osc.edu> 1.5.2-1
- Bump ondemand to 1.5.2 Improve 1.4 to 1.5 upgrade and don't suppress ood-
  portal-generator output during package installs (tdockendorf@osc.edu)

* Wed Jan 30 2019 Trey Dockendorf <tdockendorf@osc.edu> 1.5.1-1
- Update to 1.5.1 (tdockendorf@osc.edu)
- Prep for 1.5.0 build (tdockendorf@osc.edu)
- Remove ondemand-scl patch (tdockendorf@osc.edu)
- Have ondemand depend on ondemand meta packages and not direct SCLs
  (tdockendorf@osc.edu)
- Need pun_config_path too (tdockendorf@osc.edu)
- Only kill off old PUNs if upgrade and old PUN config directory still exists,
  hopefully once someone cleans up old config directory the upgrade steps will
  stop (tdockendorf@osc.edu)
- Add logic to kill of PUNs before upgrading so stray processes are not left
  behind (tdockendorf@osc.edu)
- Apply ondemand-scl patch (tdockendorf@osc.edu)
- Use /var/lib/ondemand-nginx and add logic to migrate /var/lib/nginx to
  /var/lib/ondemand-nginx (tdockendorf@osc.edu)
- Update ondemand package to support ondemand SCL (tdockendorf@osc.edu)

* Wed Jan 30 2019 Morgan Rodgers <mrodgers@osc.edu> 1.5.0-1
- Update OnDemand to version 1.5.0 (mrodgers@osc.edu)

* Fri Jan 11 2019 Morgan Rodgers <mrodgers@osc.edu> 1.4.10-1
- Update ood to v1.4.10 (mrodgers@osc.edu)

* Wed Jan 02 2019 Morgan Rodgers <mrodgers@osc.edu> 1.4.9-1
- Update OnDemand to v 1.4.9 (mrodgers@osc.edu)

* Mon Dec 31 2018 Morgan Rodgers <mrodgers@osc.edu> 1.4.8-1
- Update OnDemand to 1.4.8 (mrodgers@osc.edu)

* Thu Dec 27 2018 Trey Dockendorf <tdockendorf@osc.edu> 1.4.7-1
- Update OnDemand to 1.4.7 (tdockendorf@osc.edu)

* Fri Dec 21 2018 Morgan Rodgers <mrodgers@osc.edu> 1.4.6-3
- Revert ood_portal_generator version string (mrodgers@osc.edu)

* Thu Dec 20 2018 Trey Dockendorf <tdockendorf@osc.edu> 1.4.5-3
- Change cloudcmd symlink to directory during RPM build to avoid warnings
  during yum update (tdockendorf@osc.edu)

* Thu Dec 20 2018 Trey Dockendorf <tdockendorf@osc.edu> 1.4.5-2
- Fix so that cloudcmd node module directory is able to be replaced with a
  symlink (tdockendorf@osc.edu)
- Actually use package_version for version (tdockendorf@osc.edu)

* Wed Dec 19 2018 Morgan Rodgers <mrodgers@osc.edu> 1.4.5-1
- OnDemand 1.4.5 release (mrodgers@osc.edu)

* Tue Dec 04 2018 Trey Dockendorf <tdockendorf@osc.edu> 1.4.4-4
- Fix release (tdockendorf@osc.edu)

* Tue Dec 04 2018 Trey Dockendorf <tdockendorf@osc.edu> 1.4.4-3
- Fix dependency on nginx to use correct epoch number

* Tue Dec 04 2018 Morgan Rodgers <mrodgers@osc.edu> 1.4.4-2
- Ondemand 1.4.4 (mrodgers@osc.edu)

* Fri Oct 19 2018 Morgan Rodgers <mrodgers@osc.edu> 1.4.3-2
- Ondemand dependency update and switch to monorepo (mrodgers@osc.edu)

* Fri Sep 14 2018 Morgan Rodgers <mrodgers@osc.edu> 1.4.2-2
- Bump OOD version to v1.4.2 (mrodgers@osc.edu)

* Thu Sep 13 2018 Morgan Rodgers <mrodgers@osc.edu> 1.4.1-2
- Bump OOD version to 1.4.1 (mrodgers@osc.edu)
- Bump ondemand version to v1.4.0 (mrodgers@osc.edu)

* Wed Jul 18 2018 Trey Dockendorf <tdockendorf@osc.edu> 1.3.7-2
- Remove production.log (tdockendorf@osc.edu)

* Tue May 15 2018 Jeremy Nicklas <jnicklas@osc.edu> 1.3.7-1
- Bump ondemand to 1.3.7 (jnicklas@osc.edu)

* Mon Apr 30 2018 Jeremy Nicklas <jnicklas@osc.edu> 1.3.6-1
- Bump ondemand to 1.3.6 (jnicklas@osc.edu)

* Fri Apr 20 2018 Jeremy Nicklas <jnicklas@osc.edu> 1.3.5-2
- add version file for ondemand (jnicklas@osc.edu)

* Mon Apr 09 2018 Jeremy Nicklas <jnicklas@osc.edu> 1.3.5-1
- Bump ondemand to 1.3.5 (jnicklas@osc.edu)

* Fri Apr 06 2018 Jeremy Nicklas <jnicklas@osc.edu> 1.3.4-1
- Bump ondemand to 1.3.4 (jnicklas@osc.edu)

* Tue Mar 27 2018 Jeremy Nicklas <jnicklas@osc.edu> 1.3.3-1
- Bump ondemand to 1.3.3 (jnicklas@osc.edu)

* Mon Mar 26 2018 Jeremy Nicklas <jnicklas@osc.edu> 1.3.2-1
- Bump ondemand to 1.3.2 (jnicklas@osc.edu)
- set web server configs as ghost (jnicklas@osc.edu)
- Use macros where possible (tdockendorf@osc.edu)

* Wed Feb 28 2018 Trey Dockendorf <tdockendorf@osc.edu> 1.3.1-5
- Set modes to be more restrictive. Matches OSC puppet environment but still
  functions the same (tdockendorf@osc.edu)

* Wed Feb 28 2018 Trey Dockendorf <tdockendorf@osc.edu> 1.3.1-4
- Try to speed up builds by doing rake in parallel (tdockendorf@osc.edu)
- Set sudo config to noreplace (tdockendorf@osc.edu)

* Wed Feb 28 2018 Trey Dockendorf <tdockendorf@osc.edu> 1.3.1-3
- Move %%posttrans into %%post (#23) Run daemon-reload for systemd in %%post
  and %%postun (#22) Make systemd unit file override %%config(noreplace)
  (tdockendorf@osc.edu)

* Tue Feb 27 2018 Jeremy Nicklas <jnicklas@osc.edu> 1.3.1-2
- set apache config as ghost (jnicklas@osc.edu)

* Tue Feb 27 2018 Trey Dockendorf <tdockendorf@osc.edu> 1.3.1-1
- Bump ondemand to 1.3.1 (jnicklas@osc.edu)

* Wed Feb 14 2018 Trey Dockendorf <tdockendorf@osc.edu> 1.3.0-1
- update ondemand to v1.3.0 (jeremywnicklas@gmail.com)


