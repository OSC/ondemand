# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2018-03-26
### Added
- Added support for the Xfce desktop.

### Changed
- Moved "Account" field higher up in the form.
- Updated date in `LICENSE.txt`.

### Fixed
- Disabled all the unnecessary services that are auto-started when Mate loads.
- Fixed local configuration directory not always being ignored.
- Set Mate and Xfce terminals to launch login shell to get proper `TERM` set.
- Restore module environment in login shells.

### Removed
- Remove local OSC configuration as this has moved to
  [osc-ood-config](https://github.com/OSC/osc-ood-config).

## [0.1.2] - 2017-10-12
### Changed
- Modified app to take advantage of ERB templates in updated Dashboard.
  [#3](https://github.com/OSC/bc_desktop/issues/3)

## [0.1.1] - 2017-07-12
### Changed
- Changed the `CHANGELOG.md` formatting.
- Fixed form attributes `node_type` to `null` and `desktop` to `"mate"` for
  default installs.

## [0.1.0] - 2017-06-14
### Changed
- Refactored for the new Batch Connect app.

### Fixed
- Disable disk check utility on startup.
  [#2](https://github.com/OSC/bc_desktop/issues/2)

## [0.0.3] - 2017-01-18
### Fixed
- Set desktop working dir to user's home dir.

## [0.0.2] - 2017-01-04
### Added
- Added Mate desktop support.
- Added variable `$DESKTOP` that specifies desktop script run.

## 0.0.1 (2016-12-14)
### Added
- Initial release!

[Unreleased]: https://github.com/OSC/bc_desktop/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/OSC/bc_desktop/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/OSC/bc_desktop/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/OSC/bc_desktop/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/OSC/bc_desktop/compare/v0.0.3...v0.1.0
[0.0.3]: https://github.com/OSC/bc_desktop/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/OSC/bc_desktop/compare/v0.0.1...v0.0.2
