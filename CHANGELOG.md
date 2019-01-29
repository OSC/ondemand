# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
## [1.7.0] - 2019-01-29
### Changed
- xhr response is now "streamed" and handled using oboe.js to progressively
  update the view, so when viewing all jobs from all clusters you see jobs from
  one cluster at a time instead of waiting for them all to be transferred
- no longer filter out array jobs for Torque, Slurm and SGE since these are now
  supported
- no longer pre-sort jobs so user's jobs appear first when loading all jobs
- use more Rails conventional url for getting all jobs (index.json)

### Fixed
- removed stray .env file
- ensure base uri for xhr requests are always correct

## [1.6.9] - 2019-01-11
### Changed
- Updating ood_core gem

## [1.6.8] - 2018-12-26
### Fixed
- Update `ood_core` to latest version for Torque and SGE bug fixes

## [1.6.7] - 2018-12-19
### Fixed
- Update Rails to 4.2.11 to address security issues with dependencies

### Added
- Adds experimental Grid Engine support

## [1.6.6] - 2018-11-30
### Changed
- Update recommended development dependencies for ruby, node, git
- Update Gem dependency (rack)

## [1.6.5] - 2018-09-14
### Changed
- Update PBS gem to v2.2.1
- Update Gem dependencies

## [1.6.4] - 2018-09-12
### Fixed
- Fixed setup crash due to incompatibilities between older nodejs and newer autoprefixer

## [1.6.3] - 2018-09-11
### Changed
- Update gem dependencies

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

[Unreleased]: https://github.com/OSC/ood-activejobs/compare/v1.7.0...HEAD
[1.7.0]: https://github.com/OSC/ood-activejobs/compare/v1.6.9...v1.7.0
[1.6.9]: https://github.com/OSC/ood-activejobs/compare/v1.6.8...v1.6.9
[1.6.8]: https://github.com/OSC/ood-activejobs/compare/v1.6.7...v1.6.8
[1.6.7]: https://github.com/OSC/ood-activejobs/compare/v1.6.6...v1.6.7
[1.6.6]: https://github.com/OSC/ood-activejobs/compare/v1.6.5...v1.6.6
[1.6.5]: https://github.com/OSC/ood-activejobs/compare/v1.6.4...v1.6.5
[1.6.4]: https://github.com/OSC/ood-activejobs/compare/v1.6.3...v1.6.4
[1.6.3]: https://github.com/OSC/ood-activejobs/compare/v1.6.2...v1.6.3
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
