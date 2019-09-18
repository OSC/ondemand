# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
## [1.6.2] - 2019-09-18
### Changed
- Added cache busting to FancyBox so that viewing images always shows the newest version of a file

## [1.6.1] - 2019-09-11
### Fixed
- Reverted use of Rsync; use of Rsync caused resource exhaustion on the web nodes when file copies took longer than 1 minute

## [1.6.0] - 2019-08-30
### Fixed
- Fixed copy bug when used on systems using Lustre FS; a side effect of this fix is that copy-progress messages are no longer sent to the client

## [1.5.5] - 2019-08-26
### Fixed
- Upgrade dependencies

## [1.5.4] - 2019-08-22
### Fixed
- Upgrade jQuery

## [1.5.3] - 2019-06-14
### Changed
- Changed 'Open in Terminal' button to offer multiple options when `OOD_SSH_HOSTS` is set

## [1.5.2] - 2019-02-18
### Fixed
- Fixed bug where setting `OOD_SHELL` variable to empty string did not match documented behavior [Github #191](https://github.com/OSC/ood-fileexplorer/issues/191)

## [1.5.1] - 2019-01-11
### Fixed
- Fixed whitelist bug that broke API calls

## [1.5.0] - 2018-12-19
### Added
- Added an optional whitelist to provide granular control of file system access.

### Changed
- Use yarn to build (use the workspaces feature of yarn)
- Integrated `osc/cloudcmd` repo with the history of our modifications since v5.3.1. Fixes [#175](https://github.com/OSC/ood-fileexplorer/issues/175)
- Updated `bin/setup` script

## [1.4.1] - 2018-01-03
### Changed
- Remove and rebuild `node-modules` during every setup.
- Changed the `CHANGELOG.md` formatting.
- Updated date in `LICENSE.txt`.

## [1.4.0] - 2017-12-21
### Added
- Add global configuration file `/etc/ood/config/apps/files/env/` for
  production mode.
- Add local configuration file `.env.local`.

### Deprecated
- Deprecate previous `.env` file.

### Fixed
- Fix crash when the git folder is not present.

## [1.3.6] - 2017-10-24
### Changed
- Updated to `osc/cloudcmd v5.3.1-osc.29` (open html and pdf files in a new
  tab).
- Updated `cloudcmd` dependencies.

## [1.3.5] - 2017-06-30
### Changed
- Updated to `osc/cloudcmd v5.3.1-osc.28` (fixes a silent delete bug in
  cloudcmd).

## 1.3.4 - 2017-06-19 [YANKED]
### Changed
- Updated to `osc/cloudcmd v5.3.1-osc.27`.

## [1.3.3] - 2017-05-26
### Changed
- Updated to `osc/cloudcmd v5.3.1-osc.26`.

## [1.3.2] - 2017-04-20
### Added
- Added `bin/setup` script for easier deployment.

## [1.3.1] - 2017-03-07
### Fixed
- The `.env` is no longer required for installation as defaults are now set in
  `app.js` for file upload max, and editor and shell URIs.

## [1.3.0] - 2016-11-21
### Added
- Added clearer install documentation.

### Changed
- Renamed the `.env` to `.env.example`.

## [1.2.2] - 2016-11-15
### Changed
- Limit maximum upload size in app.

## [1.2.1] - 2016-11-15
### Fixed
- Add IE download fix for fallback downloader when nginx stage not configured.

## [1.2.0] - 2016-10-27
### Changed
- Removed Passenger overhead for large file downloads by leveraging
  https://github.com/OSC/nginx_stage.

## [1.1.1] - 2016-10-12
### Added
- New downloading scheme for large file download support.

### Fixed
- Fixed IE 11 font caching issue.
- Fixed Chrome warning for deprecated method.

## [1.1.0] - 2016-09-08
### Added
- Added MIT license.
- Added documentation with images in `README.md`.

### Fixed
- Updated `cloudcmd` dependency to address bugfixes in `v5.3.1-osc.15` and
  `v5.3.1-osc.16`.

## 1.0.0 - 2016-06-15
### Added
- Initial Release!

[Unreleased]: https://github.com/OSC/ood-fileexplorer/compare/v1.6.2...HEAD
[1.6.2]: https://github.com/OSC/ood-fileexplorer/compare/v1.6.1...v1.6.2
[1.6.1]: https://github.com/OSC/ood-fileexplorer/compare/v1.6.0...v1.6.1
[1.6.0]: https://github.com/OSC/ood-fileexplorer/compare/v1.5.5...v1.6.0
[1.5.5]: https://github.com/OSC/ood-fileexplorer/compare/v1.5.4...v1.5.5
[1.5.4]: https://github.com/OSC/ood-fileexplorer/compare/v1.5.3...v1.5.4
[1.5.3]: https://github.com/OSC/ood-fileexplorer/compare/v1.5.2...v1.5.3
[1.5.2]: https://github.com/OSC/ood-fileexplorer/compare/v1.5.1...v1.5.2
[1.5.1]: https://github.com/OSC/ood-fileexplorer/compare/v1.5.0...v1.5.1
[1.5.0]: https://github.com/OSC/ood-fileexplorer/compare/v1.4.1...v1.5.0
[1.4.1]: https://github.com/OSC/ood-fileexplorer/compare/v1.4.0...v1.4.1
[1.4.0]: https://github.com/OSC/ood-fileexplorer/compare/v1.3.6...v1.4.0
[1.3.6]: https://github.com/OSC/ood-fileexplorer/compare/v1.3.5...v1.3.6
[1.3.5]: https://github.com/OSC/ood-fileexplorer/compare/v1.3.3...v1.3.5
[1.3.3]: https://github.com/OSC/ood-fileexplorer/compare/v1.3.2...v1.3.3
[1.3.2]: https://github.com/OSC/ood-fileexplorer/compare/v1.3.1...v1.3.2
[1.3.1]: https://github.com/OSC/ood-fileexplorer/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/OSC/ood-fileexplorer/compare/v1.2.2...v1.3.0
[1.2.2]: https://github.com/OSC/ood-fileexplorer/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/OSC/ood-fileexplorer/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/OSC/ood-fileexplorer/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/OSC/ood-fileexplorer/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/OSC/ood-fileexplorer/compare/v1.0.0...v1.1.0
