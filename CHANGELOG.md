# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.2] - 2017-12-07
### Changed
- Combined the Ruby wrapper script with the `nginx_stage` executable script.
  [#27](https://github.com/OSC/nginx_stage/issues/27)

### Fixed
- Display error if the user's home directory does not exist.
  [#25](https://github.com/OSC/nginx_stage/issues/25)

## [0.3.1] - 2017-11-27
### Changed
- Replaced all occurrences of `Fixnum` with `Integer` to better support Ruby
  2.4+. [#29](https://github.com/OSC/nginx_stage/issues/29)

## [0.3.0] - 2017-10-30
### Added
- Added a confirmation page when attempting to restart PUN due to discovery of
  uninitialized app. [#20](https://github.com/OSC/nginx_stage/issues/20)
- Added configuration option to modify regular expression used to validate user
  name. [#19](https://github.com/OSC/nginx_stage/issues/19)
- Added support to specify custom NGINX environment under `/etc/ood/profile`.
  [#24](https://github.com/OSC/nginx_stage/pull/24)

### Changed
- Default regex for validating username now includes common email symbols.
  [#19](https://github.com/OSC/nginx_stage/issues/19)
- Moved configuration location to `/etc/ood/config/nginx_stage.yml`.
  [#23](https://github.com/OSC/nginx_stage/pull/23)
- Modified the `CHANGELOG.md` formatting.

### Deprecated
- Deprecating the old configuration location located underneath the app's
  installation directory.

### Fixed
- Fixed link to documentation in `README.md`.
- Updated the `LICENSE.txt` with correct information.

## [0.2.1] - 2017-03-02
### Removed
- Removed `%{env}` from config for better readability.

## [0.2.0] - 2017-01-30
### Changed
- Provide better default ruby wrapper that doesn't require modifications.

### Removed
- Removed client-side analytics (now handled server-side).

### Fixed
- Don't crash when config file has invalid option.

## [0.1.0] - 2016-10-27
### Added
- Implement nginx sendfile feature for optimal static file downloads.

### Changed
- Made git 1.9+ a requirement for the dashboard app.

### Fixed
- Fix for app checks under restrictive NFS permissions as `root`.
- Forgot to copy over example ruby wrapper.

## [0.0.13] - 2016-10-11
### Added
- Add query parameter that forces file to be downloaded by browser.

## [0.0.12] - 2016-10-11
### Added
- Added a download uri that serves files directly off of the filesystem.

## [0.0.11] - 2016-09-22
### Fixed
- Fixes/simplifications to default yaml configuration file.
- Display help msg by default if CLI called with no arguments.
- Added back javascript dependency for GA due to caching issues.

## [0.0.10] - 2016-09-14
### Removed
- Removed javascript dependency when setting GA dimensions.

## [0.0.9] - 2016-08-30
### Added
- Added timestamp (hit scope) dimension in Google Analytics.
- Added user id (user scope) dimension in Google Analytics.

## [0.0.8] - 2016-08-09
### Added
- Added session id tracking in Google Analytics

### Changed
- Use wrappers for Passenger binaries (ruby/node/python), allows apps to
  override system-installed binary

### Fixed
- Moved GA to end of `<head>` tag from `<body>`.

## [0.0.7] - 2016-06-17
### Fixed
- Updated Google Analytics account number used in metrics reporting.

## [0.0.6] - 2016-06-03
### Added
- Added Python as a configuration option.
- Added Google analytics (metrics reporting required by project).
- Added `nginx_show` command (lists details of currently running PUN).
- Added `nginx_list` command (lists all users with running PUNs).
- Added `nginx_clean` command (stops all running PUNs w/ no active
  connections).
- Added `app_reset` command (resets all app configs using current template).
- Added `app_list` command (lists all staged app configs).
- Added `app_clean` command (deletes all stale app configs).
- Check if user has disabled shell when starting PUN with `pun` command.

### Changed
- Set Node.js and Python binary paths as optional.
- Uses a full URL now in PUN config for redirection when app doesn't exist.
- Changed default location for dev apps.
- Set Nginx tmp root back to local disk.
- Use local disk paths for staging location of user shared apps.
- Can create `User` object from any string-like object.

### Fixed
- Fixed string concatenation bug.

## [0.0.5] - 2016-04-15
### Changed
- Refactored Configuration module to reduce duplication.
- Move config file parsing from binary to library.
- Separated paths where pun and app configs are stored for easier config
  cleanup.
- Directly spawn Rails apps to keep all apps under parent process.
- Introduced/renamed possible app environments to: `dev`, `usr`, and `sys`.
- Regenerates default config file if doesn't exist or nothing set in it.
- `rake install` doesn't depend on `git` anymore.

### Removed
- Removed unix group whitelists as this should be responsibility of apps and
  file permissions (provides greater flexibility).

### Fixed
- Set Nginx tmp root to user's home directory to allow for larger file uploads.
- Fixed crash when config file was empty.

## [0.0.4] - 2016-04-04
### Added
- Display user name in process information.
- Sys admins can now define configuration options in `config/nginx_stage.yml`.
- Sys admins can now define PUN environment in `bin/ood_ruby` wrapper script.

### Changed
- Set maximum upload file size to 10 GB in nginx config.
- Uses unix group whitelists for consumers and publishers of apps.
- Use "restart" (stop + start) instead of "reload" after generating app config
  (takes advantage of `Open3` for executing nginx binary).

### Fixed
- Uses URL escaped strings for CLI arguments (security fix).
- App requests with periods in the app name now work.
- Fixed code typo in `User` class.
- `rake install` now only installs git version checked out (fixes strange
  behavior with older versions).

## [0.0.3] - 2016-02-04
### Added
- Added `rake install` for simpler installation.
- User can now get individualized help messages corresponding to a command.

### Changed
- Options for a command are now specified in the corresponding generator.

### Fixed
- The `exec` call is made more secure.

## [0.0.2] - 2016-01-20
### Added
- Add app initialization redirect URI option `pun -app-init-uri` if app not
  found by nginx.
- Added `nginx` subcommand for easier control of nginx process.

### Changed
- Sanitize user input from command line.
- Refactoring, cleanup internal configuration code making it more readable.

## 0.0.1 - 2016-01-14
### Added
- Initial release

[Unreleased]: https://github.com/OSC/nginx_stage/compare/v0.3.2...HEAD
[0.3.2]: https://github.com/OSC/nginx_stage/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/OSC/nginx_stage/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/OSC/nginx_stage/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/OSC/nginx_stage/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/OSC/nginx_stage/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/OSC/nginx_stage/compare/v0.0.13...v0.1.0
[0.0.13]: https://github.com/OSC/nginx_stage/compare/v0.0.12...v0.0.13
[0.0.12]: https://github.com/OSC/nginx_stage/compare/v0.0.11...v0.0.12
[0.0.11]: https://github.com/OSC/nginx_stage/compare/v0.0.10...v0.0.11
[0.0.10]: https://github.com/OSC/nginx_stage/compare/v0.0.9...v0.0.10
[0.0.9]: https://github.com/OSC/nginx_stage/compare/v0.0.8...v0.0.9
[0.0.8]: https://github.com/OSC/nginx_stage/compare/v0.0.7...v0.0.8
[0.0.7]: https://github.com/OSC/nginx_stage/compare/v0.0.6...v0.0.7
[0.0.6]: https://github.com/OSC/nginx_stage/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/OSC/nginx_stage/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/OSC/nginx_stage/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/OSC/nginx_stage/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/OSC/nginx_stage/compare/v0.0.1...v0.0.2
