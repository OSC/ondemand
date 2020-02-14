# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
## [1.7.2] - 2019-11-19
### Added
- Job Compser and ActiveJobs now respect same navbar branding configuration as Dashboard @zooley [#101](https://github.com/OSC/ondemand/pull/101)
- running core app unit tests in Travis CI [#303](https://github.com/OSC/ondemand/pull/303)
- support for radio buttons in batch connect apps [#139](https://github.com/OSC/ondemand/pull/139)
- branding to Job Composer and Active Jobs that match Dashboard [#101](https://github.com/OSC/ondemand/pull/101)

### Changed
- rewrote ood-portal-generator in Ruby with automated tests [#108](https://github.com/OSC/ondemand/pull/108)

### Fixed
- SELinux policy issues exposed when installing at external site [#110](https://github.com/OSC/ondemand/issues/110) and [#112](https://github.com/OSC/ondemand/issues/112)
- Shell app now uses en_US.UTF-8 as LANG @jasonbuechler [#308](https://github.com/OSC/ondemand/pull/308)
- ignore comments when comparing Apache configs in ood-portal-generator [#100](https://github.com/OSC/ondemand/issues/100)

## [1.7.1] - 2019-11-04
### Added
- shellcheck static analysis of shell scripts

### Changed
- monorepo: add all core apps to main repo
- start installing app gems to a `GEM_HOME` under /opt/ood that is built into a separate ondemand-gems rpm
- upgrade Dashboard to Rails 5

### Fixed
- fix window.opener vulnerability found by Google's Lighthouse @zooley [#88](https://github.com/OSC/ondemand/pull/88)
- accessibility fixes exposed using Deque's aXe utility @zooley [#89](https://github.com/OSC/ondemand/pull/89)
- optimize some included pngs using ImageOptim app @zooley [#91](https://github.com/OSC/ondemand/pull/91)
- add missing closing tag to missing home directory error page @zooley [#92](https://github.com/OSC/ondemand/pull/92)

## [1.7.0] - 2019-10-14
### Added
- update Dashboard to add account balance warnings & dev mode icon picker
- for new installs, sudoers.d/ood script now includes `env_keep` for all env
  vars starting with `NGING_STAGE_` or `OOD_`
- add support for CentOS/RHEL8

### Changed
- drop support for CentOS/RHEL6
- upgrade to Ruby 2.5, Node 10, and Passenger 6

## [1.6.20] - 2019-10-14
### Fixed
- fix bug to ensure `update_ood_portal` installs new config if existing
  ood-portal.conf matches checksum [#83](https://github.com/OSC/ondemand/pull/83)

## [1.6.19] - 2019-10-09
### Added
- ability to set separate proxy server for rewrite rules in ood-portal-generator config
  https://github.com/OSC/ondemand/blob/4e2614917fac74e861908ca189c42a21e8895518/ood-portal-generator/share/ood_portal_example.yml#L18-L22 fixing [#73](https://github.com/OSC/ondemand/issues/73) - thank you @wdpypere

## [1.6.18] - 2019-10-09
### Fixed
- stop shell app from changing directory to the home directory prior to initiating ssh connection
  which [introduced a crash when the home directory does
  not exist](https://discourse.osc.edu/t/custom-home-directory-broken-after-upgrade-to-1-6-x/518)
  when we upgraded the shell app's pty dependency

## [1.6.17] - 2019-09-26
### Fixed
- ensure ood-portal.conf generated on new install [#65](https://github.com/OSC/ondemand/issues/65)

## [1.6.16] - 2019-09-25
### Fixed
- debian fix for bin/setup in Active Jobs and Dashboard
- use latest ondemand release RPM
- fixed exit codes for `update_ood_portal` script

## [1.6.15] - 2019-09-24
### Fixed
- files app updated for Lustre copy bugfix

## [1.6.14] - 2019-09-19
### Fixed
- files, file editor, job composer apps all get fix in bin/setup for output redirection
- files app gets cachebusting fix for "FancyBox" so images show newest version of file

## [1.6.13] - 2019-09-19
### Fixed
- Depend on system git instead of rh-git29 which is an EOL SCL
- Generate a checksum file when running `update_ood_portal` to avoid overwriting the Apache config `ood-portal.conf` if the file contains manual modifications

## [1.6.12] - 2019-09-11
### Fixed
- Reverted use of Rsync in Files app; use of Rsync caused resource exhaustion on the web nodes when file copies took longer than 1 minute

## [1.6.11] - 2019-08-30
### Fixed
- Fixed bug in the File Explorer when attempting to copy directories on a Lustre FS; a side effect of this fix is that copy-progress messages are no longer sent to the client

## [1.6.10] - 2019-08-27
### Fixed
- Upgraded dependencies for multiple apps

## [1.6.9] - 2019-08-20
### Fixed
- Fixed bug where user's login shell was always set to Bash inside desktop sessions

## [1.6.8] - 2019-08-13
### Fixed
- Fixed issue in Dashboard where older browsers (IE) could not connect to VNC sessions [ood-dashboard](https://github.com/OSC/ood-dashboard/issues/479)

## [1.6.7] - 2019-06-28
## Added
- Added ability to disable RewriteEngine

## [1.6.6] - 2019-06-25
### Fixed
- Cache bust for `ood_shell.js`

## [1.6.5] - 2019-06-20
### Changed
- Added new check to enable developer mode in Dashboard

### Fixed
- Fixed bugs with Firefox and MS Edge in the Shell

## [1.6.4] - 2019-06-16
### Added
- Added VNC quality and compression controls to Dashboard
- Added link to compute node that a VNC job is running on in the Dashboard

### Changed
- Changed 'Open in Terminal' button to offer multiple options when `OOD_SSH_HOSTS` is set in the File Explorer

### Fixed
- Fixed possible crash when running the Job Composer for the first time
- Fix sorting of cluster dropdown ([#168](https://github.com/OSC/ood-activejobs/issues/168))

## [1.6.3] - 2019-05-21
### Fixed
- Fixed translation bug in Dashboard

## [1.6.2] - 2019-05-15
### Fixed
- Fixed another translation issue in Dashboard

## [1.6.1] - 2019-05-15
### Fixed
- Fixed crashing bug in Dashboard

## [1.6.0] - 2019-05-10
### Added
- Added ability to render HTML or Markdown in job template manifests ([#278](https://github.com/OSC/ood-myjobs/issues/278))
- Added I18n hooks to Job Composer for Job Options with an initial OSC/English locale
- Added job array support for PBSPro and LSF
- Added placeholder for job array in job options

### Changed

- Changed Shell to use the maintained `node-pty` instead of `pts.js`
- Slurm adapter now returns `nil` instead of `'(null)'` for `OodCore::Job::Info#account_id`
- Updated Gems to address CVEs
- `nginx_stage` changed to always remove (and report removal of on `stderr`) stale Passenger PID and socket files ([#11](https://github.com/OSC/ondemand/issues/11))

### Fixed
- Disabled warning in Job Composer about Gems not being eager loaded
- Fixed a crash in nginx_stage relating to numeric values in pun_custom_env
- Fixed Active Jobs showing `'null'` when for `OodCore::Job::Info#account_id` was nil
- Fixed Active Jobs showing integer Time Used instead of `HH:MM:SS`
- Fixed bug in `ood_core` live system test
- Fixed bug with Slurm adapter when submit time is not available
- Fixed bug with the live system test that impacted non-LSF systems
- Fixed issue where Slurm comment field might break job info parsing
- Fixed layout bug in Job Composer ([#290](https://github.com/OSC/ood-myjobs/issues/290))
- Fixed possible crash when comparing two clusters if the id of one of the clusters is nil
- Job Composer with Grid Engine will attempt to detect if the user has set the working directory, and if not will set it (matching behavior of other adapters)
- Prevent long job names from breaking the Job Composer layout ([#290](https://github.com/OSC/ood-myjobs/issues/290))
- Fixed bug where using integers as values in `pun_custom_env` caused a `TypeError` ([#26](https://github.com/OSC/ondemand/issues/26))

## [1.5.5] - 2019-02-18
### Added
- Added app title to noVNC launch button to Dashboard
- Added BatchConnect app version to new session form
- Added I18n hooks for Dashboard with an initial OSC/English locale
- Added OOD and Dashboard version to footer
- Added support for fetching quota from a URL
- Allow BatchConnect applications to raise errors that can be shown to users

### Fixed
- Fixed bug in Active Jobs that broke when cluster configs changed
- Fixed bug in File Explorer when `OOD_SHELL` was an empty string
- Handled file not found errors with Announcements and MOTDs
- Updated Gems to address CVEs

## [1.5.4] - 2019-02-07
### Fixed
- Fixed bug in Active Jobs that broke Ganglia graphs

## [1.5.3] - 2019-02-7
### Changed
- Always load the default profile in nginx_stage as we now use the new ondemand SCL
- Include RUBYLIB in the env vars that are declared in the nginx config to be preserved
- Updated Activejobs, Dashboard, and Job Composer to reduce app load time

## [1.5.2] - 2019-01-31
### Added
- RPM friendly execution mode of update_ood_portal script when
  running from rpm [#27](https://github.com/OSC/ondemand/pull/27)

## [1.5.1] - 2019-01-30
### Fixed
- updated infrastructure components to point to new ondemand-nginx paths

## [1.5.0] - 2019-01-30 [YANKED]
### Added
- Dasboard
  - version string to footer
  - add support for localization of home page welcome text and motd title with added setup to be able to add support for more localization options in the future
  - the home page html (both logo and text) can now be customized using a single html formatted string in /etc/ood/config/locales/en.yml with the welcome_html key
- JobComposer
  - submit jobs using job array in job options (for supported adapters)

### Fixed
- ActiveJobs
  - ensure base URI for XHR requests are always correct
- Job Composer
  - handle job arrays submitted through app gracefully for Torque, Slurm, and SGE

### Changed
- ActiveJobs
  - XHR response is now "streamed" and handled using oboe.js to progressively update the view, so when viewing all jobs from all clusters you see jobs from one cluster at a time instead of waiting for them all to be transferred
  - no longer filter out array jobs for Torque, Slurm and SGE since these are now supported
  - no longer pre-sort jobs so user's jobs appear first when loading all jobs
  - use more Rails conventional url for getting all jobs (index.json)

## [1.4.10] - 2019-01-11
### Fixed
- Fixed error in ood_core that caused crashes in MyJobs with a SGE cluster
- Fixed issue with displaying launch button with invalid Batch Connect apps [#435](https://github.com/OSC/ood-dashboard/pull/435)
- Fixed error where users were unable to rename/move files using the FileExplorer [#186](https://github.com/OSC/ood-fileexplorer/issues/186)

### Changed
- Updated ood_core to newest in all core apps

## [1.4.9] - 2018-12-31
### Fixed
- Update Dashboard to improve Quotas

## [1.4.8] - 2018-12-31
### Fixed
- Update Dashboard to fix a divide by zero error when a resource is not limited

## [1.4.7] - 2018-12-26
### Fixed
- Update Dashboard, Active Jobs, and Job Composer to use latest version of `ood_core` for bug fixes to SGE and Torque adapters

## [1.4.6] - 2018-12-21
### Changed
- Reverting a change which may cause Apache configs to be replaced

## [1.4.5] - 2018-12-19
### Added
- Set `OOD_DEV_APPS_ROOT` env var to the parent directory of a user's dev app, so that the Dashboard and other apps will know where dev apps are deployed to, since this is a configuration that will likely differ from site to site
- Default and customizable error page for missing home directory so sites that use pam_mkhomdir.so to create the home directory for new users on login can have a sensible first login flow via OnDemand ([see Discourse discussion](https://discourse.osc.edu/t/launching-ondemand-when-home-directory-does-not-exist/53/7))

### Changed
- Change user tmpdir location to fix upload error due to default permissions on /var/lib/nginx being more restrictive in NGINX 1.14 [#16](https://github.com/OSC/ondemand/pull/16)
- Use same version string for all components, which will be this OnDemand version
- Error reporting for missing home directory occurs after launch of PUN (the error is reported as a change to the PUN config) instead of aborting the launch of the PUN

## [1.4.4] - 2018-12-04
### Added
- `nginx_stage` generates a per user a `secret_key_base.txt` file containing a secure random 128 char string and sets `SECRET_KEY_BASE` env var to this string so that each user's Rails app now more securely can encrypt cookies
- ability to define arbitrary env var name and value pairs in `nginx_stage.yml` config file
- ability to define an arbitrary list of env vars to declare in the PUN config (so they are retained from whatever is set in /etc/ood/profile)
- distinct default profile file at /opt/ood/nginx_stage/etc/profile so this can optionally be sourced by custom /etc/ood/profile

### Changed
- Update `nginx_stage` to work with Passenger 5 and NGINX 1.14
- Since NGINX 1.14 now strips environment, we explicitly pass these env vars to NGINX: `PATH LD_LIBRARY_PATH X_SCLS MANPATH PCP_DIR PERL5LIB PKG_CONFIG_PATH PYTHONPATH XDG_DATA_DIRS SCLS`
- Default path to developer apps are stored at `/var/www/ood/apps/dev/%{owner}/gateway/%{name}`, requiring a symlink to be generated by a developer to enable developer mode

### Fixed
- Fix bug where if you set `ONDEMAND_TITLE` and `ONDEMAND_PORTAL` in nginx_stage.yml config file you can end up with different values set in `OOD_PORTAL` and `OOD_DASHBOARD_TITLE`

## [1.4.3] - 2018-10-19
### Fixed
- Handle spaces in domain groups correctly: https://github.com/OSC/ondemand/commit/09c22c5f0960b39b30167830e23cf3010a91fc44

### Changed
- Switched to monorepo for infrastructure components, archiving old repos for `nginx_stage`, `ood_auth_map`, `mod_ood_proxy`, `ood-portal-generator`
- Updated SCL dependencies to rh-ruby24, rh-git29, rh-nodejs6

## [1.4.2] - 2018-9-14
### Added
- Changelog being added in 1.4.5 but backfilling history to 1.4.2

### Changed
- From 1.3.7 - 1.4.2 updated app versions


[Unreleased]: https://github.com/OSC/ondemand/compare/v1.7.2...HEAD
[1.7.2]: https://github.com/OSC/ondemand/compare/v1.7.1...v1.7.2
[1.7.1]: https://github.com/OSC/ondemand/compare/v1.7.0...v1.7.1
[1.7.0]: https://github.com/OSC/ondemand/compare/v1.6.20...v1.7.0
[1.6.20]: https://github.com/OSC/ondemand/compare/v1.6.19...v1.6.20
[1.6.19]: https://github.com/OSC/ondemand/compare/v1.6.18...v1.6.19
[1.6.18]: https://github.com/OSC/ondemand/compare/v1.6.17...v1.6.18
[1.6.17]: https://github.com/OSC/ondemand/compare/v1.6.16...v1.6.17
[1.6.16]: https://github.com/OSC/ondemand/compare/v1.6.15...v1.6.16
[1.6.15]: https://github.com/OSC/ondemand/compare/v1.6.14...v1.6.15
[1.6.14]: https://github.com/OSC/ondemand/compare/v1.6.13...v1.6.14
[1.6.13]: https://github.com/OSC/ondemand/compare/v1.6.12...v1.6.13
[1.6.12]: https://github.com/OSC/ondemand/compare/v1.6.11...v1.6.12
[1.6.11]: https://github.com/OSC/ondemand/compare/v1.6.10...v1.6.11
[1.6.10]: https://github.com/OSC/ondemand/compare/v1.6.9...v1.6.10
[1.6.9]: https://github.com/OSC/ondemand/compare/v1.6.8...v1.6.9
[1.6.8]: https://github.com/OSC/ondemand/compare/v1.6.7...v1.6.8
[1.6.7]: https://github.com/OSC/ondemand/compare/v1.6.6...v1.6.7
[1.6.6]: https://github.com/OSC/ondemand/compare/v1.6.5...v1.6.6
[1.6.5]: https://github.com/OSC/ondemand/compare/v1.6.4...v1.6.5
[1.6.4]: https://github.com/OSC/ondemand/compare/v1.6.3...v1.6.4
[1.6.3]: https://github.com/OSC/ondemand/compare/v1.6.2...v1.6.3
[1.6.2]: https://github.com/OSC/ondemand/compare/v1.6.1...v1.6.2
[1.6.1]: https://github.com/OSC/ondemand/compare/v1.6.0...v1.6.1
[1.6.0]: https://github.com/OSC/ondemand/compare/v1.5.5...v1.6.0
[1.5.5]: https://github.com/OSC/ondemand/compare/v1.5.4...v1.5.5
[1.5.4]: https://github.com/OSC/ondemand/compare/v1.5.3...v1.5.4
[1.5.3]: https://github.com/OSC/ondemand/compare/v1.5.2...v1.5.3
[1.5.2]: https://github.com/OSC/ondemand/compare/v1.5.1...v1.5.2
[1.5.1]: https://github.com/OSC/ondemand/compare/v1.5.0...v1.5.1
[1.5.0]: https://github.com/OSC/ondemand/compare/v1.4.10...v1.5.0
[1.4.10]: https://github.com/OSC/ondemand/compare/v1.4.9...v1.4.10
[1.4.9]: https://github.com/OSC/ondemand/compare/v1.4.8...v1.4.9
[1.4.8]: https://github.com/OSC/ondemand/compare/v1.4.7...v1.4.8
[1.4.7]: https://github.com/OSC/ondemand/compare/v1.4.6...v1.4.7
[1.4.6]: https://github.com/OSC/ondemand/compare/v1.4.5...v1.4.6
[1.4.5]: https://github.com/OSC/ondemand/compare/v1.4.4...v1.4.5
[1.4.4]: https://github.com/OSC/ondemand/compare/v1.4.3...v1.4.4
[1.4.3]: https://github.com/OSC/ondemand/compare/v1.4.2...v1.4.3
[1.4.2]: https://github.com/OSC/ondemand/compare/v1.3.7...v1.4.2
