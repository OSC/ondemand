# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Remove and rebuild `node-modules` during every setup.
- Changed the `CHANGELOG.md` formatting.

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

[Unreleased]: https://github.com/OSC/ood-fileexplorer/compare/v1.4.0...HEAD
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
