# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
## [1.5.6] - 2020-03-30
- update Shell app to [v1.5.0](https://github.com/OSC/ood-shell/compare/v1.4.8...v1.5.0) which has
  backported fix for adding CSRF protection via CSRF token and Origin checking when creating shell app
  websocket connection [#444](https://github.com/OSC/ondemand/commit/1816de76fdf8bcec21d5f9619f5a3a09ff8db01d)
- Other Shell app fixes released in OnDemand 1.6 [v1.4.2 to v1.4.8 diff](https://github.com/OSC/ood-shell/compare/v1.4.2...v1.4.8)

## [1.5.5] - 2019-02-18
### Fixed
- Fixed bug in Active Jobs that broke when cluster configs changed
- Fixed bug in File Explorer when `OOD_SHELL` was an empty string

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


[Unreleased]: https://github.com/OSC/ondemand/compare/v1.5.6...HEAD
[1.5.6]: https://github.com/OSC/ondemand/compare/v1.5.5...v1.5.6
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
