# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- Show cluster errors as a dismissable bootstrap alert
- Add extended data support for PBS Professional
- Add extended data support for LSF

### Changed
- Update to `ood_appkit v1.0.2` and `ood_core v0.0.5`
- Update to `pbs v2.1.0`
- Update user-level filtering to employ ood_core optimizations

## [v1.4.5] - 2017-06-13

- Add and use the cluster_title where appropriate in views instead of titleized cluster id

## [v1.4.4] - 2017-06-05

- Fix bug in `bin/setup` that crashes when `OOD_PORTAL` is set but not
  `OOD_SITE`
  
## [v1.4.3] - 2017-05-18

- Allow user to limit jobs to cluster
- Convert user inputs to dropdown boxes

## [v1.4.2] - 2017-05-15

- Update terminal links to connect to the appropriate host
- Update to latest Ood Appkit
- Remove OSC copyright from footer
- Remove deprecation warnings

[Unreleased]: https://github.com/OSC/ood-activejobs/compare/v1.4.5...HEAD
[v1.4.5]: https://github.com/OSC/ood-activejobs/compare/v1.4.4...v1.4.5
[v1.4.4]: https://github.com/OSC/ood-activejobs/compare/v1.4.3...v1.4.4
[v1.4.3]: https://github.com/OSC/ood-activejobs/compare/v1.4.2...v1.4.3
[v1.4.2]: https://github.com/OSC/ood-activejobs/compare/v1.0.0...v1.4.2
