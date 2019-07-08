# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
## [1.4.6] - 2019-06-25
### Fixed
- Fixed caching issue with `ood_shell.js`

## [1.4.5] - 2019-06-20
### Fixed
- Fixed bugs when running Shell in Firefox and MS Edge ([#62](https://github.com/OSC/ood-shell/issues/62), [#59](https://github.com/OSC/ood-shell/issues/59), and [#64](https://github.com/OSC/ood-shell/issues/64))

## [1.4.4] - 2019-06-17
### Changed
- Updated ws to address CVE

## [1.4.3] - 2019-05-09
### Changed
- Changed from pty.js to node-pty as it is still being maintained

## [1.4.2] - 2018-12-19
### Fixed
- Fixed cut and paste not working in Firefox [#48](https://github.com/OSC/ood-shell/issues/48)

## [1.4.1] - 2018-12-03
### Changed
- Updated hterm to 1.80 [#49](https://github.com/OSC/ood-shell/issues/49)

## [1.4.0] - 2018-09-11
### Changed
- Remove special case for "localhost". All shell sessions now use ssh.

## [1.3.1] - 2018-01-10
### Changed
- Remove and rebuild `node-modules` during every setup.
- Updated hterm from 1.73 to 1.77.
- Updated date in `LICENSE.md`.

## [1.3.0] - 2017-12-21
### Added
- Added support to read local environment variable file `.env.local`.
  [#43](https://github.com/OSC/ood-shell/pull/43)

### Changed
- Reads environment variables from global environment file
  `/etc/ood/config/apps/shell/env` in production mode.
  [#42](https://github.com/OSC/ood-shell/issues/42)

### Deprecated
- Deprecating old environment variable file `.env` located underneath the app.
  [#43](https://github.com/OSC/ood-shell/pull/43)

## [1.2.4] - 2017-10-20
### Changed
- Updated hterm from 1.61 to 1.73.
  [#41](https://github.com/OSC/ood-shell/issues/41)

## [1.2.3] - 2017-07-10
### Changed
- Changed the `CHANGELOG.md` formatting.

### Fixed
- Warn user if fail to establish websocket connection.
  [#38](https://github.com/OSC/ood-shell/issues/38)

## 1.2.2 - 2017-05-30
### Fixed
- Fix to handle multibyte UTF-8 URI decoding.
- Warn users if they try to close an active terminal.
- Warn users when their websocket connection is terminated.

[Unreleased]: https://github.com/OSC/ood-shell/compare/v1.4.6...HEAD
[1.4.6]: https://github.com/OSC/ood-shell/compare/v1.4.5...v1.4.6
[1.4.5]: https://github.com/OSC/ood-shell/compare/v1.4.4...v1.4.5
[1.4.4]: https://github.com/OSC/ood-shell/compare/v1.4.3...v1.4.4
[1.4.3]: https://github.com/OSC/ood-shell/compare/v1.4.2...v1.4.3
[1.4.2]: https://github.com/OSC/ood-shell/compare/v1.4.1...v1.4.2
[1.4.1]: https://github.com/OSC/ood-shell/compare/v1.4.0...v1.4.1
[1.4.0]: https://github.com/OSC/ood-shell/compare/v1.3.1...v1.4.0
[1.3.1]: https://github.com/OSC/ood-shell/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/OSC/ood-shell/compare/v1.2.4...v1.3.0
[1.2.4]: https://github.com/OSC/ood-shell/compare/v1.2.3...v1.2.4
[1.2.3]: https://github.com/OSC/ood-shell/compare/v1.2.2...v1.2.3
