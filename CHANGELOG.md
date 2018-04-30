# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.6.2] - 2018-04-30
### Fixed
- Updated dependencies that included security fixes.

## [1.6.1] - 2018-01-29
### Changed
- Updated `ood_core`
  ([0.2.0 => 0.2.1](https://github.com/OSC/ood_core/blob/master/CHANGELOG.md))
  which includes a number of bugfixes.
  [#154](https://github.com/OSC/ood-activejobs/issues/154)

### Removed
- Removed `paperclip` gem dependency.
  [#153](https://github.com/OSC/ood-activejobs/issues/153)

## [1.6.0] - 2018-01-10
### Added
- Added global configuration support.
  [#151](https://github.com/OSC/ood-activejobs/issues/151)
- Display list of nodes that a job is running on if available.
  [#141](https://github.com/OSC/ood-activejobs/issues/141)

### Changed
- Updated date in `LICENSE.md`.
- Use `notice` instead of `alert` when successfully deleting job.
  [#110](https://github.com/OSC/ood-activejobs/issues/110)

## [1.5.3] - 2017-11-27
### Changed
- Updated to Rails 4.2.10 to better support Ruby 2.4.
  [#149](https://github.com/OSC/ood-activejobs/issues/149)
- Updated `ood_support` gem to 0.0.3 to better support Ruby 2.4.

## [1.5.2] - 2017-10-20
### Changed
- Updated `ood_core` library which includes bug fixes and new Batch Connect
  helper functions for scripts.
  [#148](https://github.com/OSC/ood-activejobs/pull/148)

## [1.5.1] - 2017-09-08
### Fixed
- update dependencies to fix bug with LSF (see https://github.com/OSC/ood_core/pull/50)

## [1.5.0] - 2017-07-17
### Added
- Show native comment if one is available (Torque)

### Changed
- Update to `ood_appkit v1.0.3` and `ood_core v0.1.0`
- Add a bootstrap alert message instead of a js alert on ajax failure

## [1.4.6] - 2017-07-10
### Added
- Show cluster errors as a dismissable bootstrap alert
- Add extended data support for PBS Professional
- Add extended data support for LSF

### Changed
- Update to `ood_appkit v1.0.2` and `ood_core v0.0.5`
- Update to `pbs v2.1.0`
- Update user-level filtering to employ ood_core optimizations

## [1.4.5] - 2017-06-13
- Add and use the cluster_title where appropriate in views instead of titleized cluster id

## [1.4.4] - 2017-06-05
- Fix bug in `bin/setup` that crashes when `OOD_PORTAL` is set but not
  `OOD_SITE`

## [1.4.3] - 2017-05-18
- Allow user to limit jobs to cluster
- Convert user inputs to dropdown boxes

## [1.4.2] - 2017-05-15
- Update terminal links to connect to the appropriate host
- Update to latest Ood Appkit
- Remove OSC copyright from footer
- Remove deprecation warnings

[Unreleased]: https://github.com/OSC/ood-activejobs/compare/v1.6.2...HEAD
[1.6.2]: https://github.com/OSC/ood-activejobs/compare/v1.6.1...v1.6.2
[1.6.1]: https://github.com/OSC/ood-activejobs/compare/v1.6.0...v1.6.1
[1.6.0]: https://github.com/OSC/ood-activejobs/compare/v1.5.3...v1.6.0
[1.5.3]: https://github.com/OSC/ood-activejobs/compare/v1.5.2...v1.5.3
[1.5.2]: https://github.com/OSC/ood-activejobs/compare/v1.5.1...v1.5.2
[1.5.1]: https://github.com/OSC/ood-activejobs/compare/v1.5.0...v1.5.1
[1.5.0]: https://github.com/OSC/ood-activejobs/compare/v1.4.6...v1.5.0
[1.4.6]: https://github.com/OSC/ood-activejobs/compare/v1.4.5...v1.4.6
[1.4.5]: https://github.com/OSC/ood-activejobs/compare/v1.4.4...v1.4.5
[1.4.4]: https://github.com/OSC/ood-activejobs/compare/v1.4.3...v1.4.4
[1.4.3]: https://github.com/OSC/ood-activejobs/compare/v1.4.2...v1.4.3
[1.4.2]: https://github.com/OSC/ood-activejobs/compare/v1.0.0...v1.4.2
