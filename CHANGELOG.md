# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Added support for the PBS Pro adapter when using the `bc_num_slots` smart
  attribute in iHPC.

### Changed

- Changed wording in the Safari websocket alert message to be more helpful.

### Fixed

- Stopped `spring` from loading on every `bin/rails` and `bin/rake` request.
- Drop back `thor` dependency to remove warning messages.
  [#192](https://github.com/OSC/ood-dashboard/issues/192)

## [1.14.1] - 2017-07-10

### Fixed

- Fixes a bug that broke app creation.
  [#183](https://github.com/OSC/ood-dashboard/issues/183)
- Updated to `bin/rails` and `bin/rake` to remove Bundler warning.
  [#186](https://github.com/OSC/ood-dashboard/issues/186)

## [1.14.0] - 2017-07-10

### Added

- Can now submit iHPC session from command line using rake task.
  [#180](https://github.com/OSC/ood-dashboard/pull/180)
- Added a unsupported browser alert for Safari by default due to Basic Auth and
  websocket issue. [#184](https://github.com/OSC/ood-dashboard/pull/184)

### Changed

- Moved `batch_connect` dataroot to properly namespaced directory.
  [#188](https://github.com/OSC/ood-dashboard/issues/181)
- Updated `CHANGELOG.md` format to match Keep a Changelog.

### Fixed

- Corrected file extension used for session context cache.

## [1.13.3] - 2017-06-23

### Fixed

- Fallback to older noVNC for Safari browsers.
  [#177](https://github.com/OSC/ood-dashboard/issues/177)

## [1.13.2] - 2017-06-23

### Removed

- Removed leftover stubbed files from a bygone era.
- Removed verbiage on requesting reservation while iHPC session is queued.
  [#176](https://github.com/OSC/ood-dashboard/issues/176)

## [1.13.1] - 2017-06-19

### Fixed

- Added back OSC Connect for Windows native VNC support.

## [1.13.0] - 2017-06-14

### Added

- Integrated iHPC support into the dashboard.
  [#155](https://github.com/OSC/ood-dashboard/pull/155)

### Fixed

- Ignore vim temporary files.
  [#161](https://github.com/OSC/ood-dashboard/issues/161)

## 1.12.0 - 2017-06-05

### Added

- Add ability to use RSS/Markdown/Plaintext MOTD.

### Fixed

- Fix bug when OOD portal specified without site.

### Removed

- Remove unused assets.


[Unreleased]: https://github.com/OSC/ood-dashboard/compare/v1.14.1...HEAD
[1.14.1]: https://github.com/OSC/ood-dashboard/compare/v1.14.0...v1.14.1
[1.14.0]: https://github.com/OSC/ood-dashboard/compare/v1.13.3...v1.14.0
[1.13.3]: https://github.com/OSC/ood-dashboard/compare/v1.13.2...v1.13.3
[1.13.2]: https://github.com/OSC/ood-dashboard/compare/v1.13.1...v1.13.2
[1.13.1]: https://github.com/OSC/ood-dashboard/compare/v1.13.0...v1.13.1
[1.13.0]: https://github.com/OSC/ood-dashboard/compare/v1.12.0...v1.13.0
