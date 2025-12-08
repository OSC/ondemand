# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]

## [2.15.2] - 2019-09-18
### Fixed
- bin/setup patch for debian

## [2.15.1] - 2019-08-22
### Fixed
- Upgraded jQuery and Nokogiri

## [2.15.0] - 2019-06-14
### Fixed
- Fixed possible crash when running Job Composer for the first time ([#299](https://github.com/OSC/ood-myjobs/issues/299))

## [2.14.0] - 2019-05-10
### Changed
- Updated [ood_core](https://github.com/OSC/ood_core/blob/v0.9.3/CHANGELOG.md)

### Fixed
- Fixed layout bug relating to ([#290](https://github.com/OSC/ood-myjobs/issues/290))

## [2.13.0] - 2019-04-17
### Added
- Added ability to render HTML or Markdown in job template manifests ([#278](https://github.com/OSC/ood-myjobs/issues/278))
- Added I18n hooks for Job Options with an initial OSC/English translation
- Added placeholder for job array in job options
- Added support for job arrays for LSF and PBSPro ([ood_core](https://github.com/OSC/ood_core/blob/v0.9.0/CHANGELOG.md))

### Fixed
- Updated Gems
- Disabled warning about Gems not being eager loaded
- Prevent long job names from breaking the layout ([#290](https://github.com/OSC/ood-myjobs/issues/290))
- Grid Engine jobs will attempt to start in the current directory like the other adapters ([ood_core](https://github.com/OSC/ood_core/blob/master/CHANGELOG.md))

## [2.12.0] - 2019-02-07
### Changed
- Disable eager loading to speed initial load of the application

## [2.11.0] - 2019-01-29
### Added
- submit jobs using job array in job options (for supported adapters)

### Fixed
- handle job arrays submitted through app gracefully for Torque, Slurm, and SGE
- removed unused .env file

## [2.10.2] - 2019-01-11
### Fixed
- Fixed crash due to bug in ood_core

## [2.10.1] - 2018-12-26
### Fixed
- Update `ood_core` to latest version for Torque and SGE bug fixes

## [2.10.0] - 2018-12-19
### Changed
- Updated to Rails 4.2.11

### Added
- Added an optional whitelist to provide granular control of file system access.
- Adds experimental support for Grid Engine

## [2.9.3] - 2018-12-03
### Changed
- Update gem dependencies

## [2.9.2] - 2018-09-12
### Fixed
- Update to PBS gem fixes crash on job submission

## [2.9.1] - 2018-09-12
### Fixed
- Fixed setup crash due to incompatibilities between older nodejs and newer autoprefixer

## [2.9.0] - 2018-09-12
### Added
- Added logging of system commands
[#264](https://github.com/OSC/ood-myjobs/issues/264)

### Changed
- Update gem dependencies
- Make Script Name field read only on new job form on templates page
[#266](https://github.com/OSC/ood-myjobs/issues/266)

## [2.8.3] - 2018-04-06
### Changed
- Update gem dependencies to patch any possible security vulnerabilities.
  [#261](https://github.com/OSC/ood-myjobs/issues/261)
- Updated `ood_core` dependency to 0.3.0.

### Removed
- Removed the `VERSION` file as this is now added by the installer.

## [2.8.2] - 2018-01-29
### Changed
- Updated `ood_core`
  ([0.2.0 => 0.2.1](https://github.com/OSC/ood_core/blob/master/CHANGELOG.md))
  which includes a number of bugfixes.
  [#259](https://github.com/OSC/ood-myjobs/issues/259)

### Removed
- Removed `paperclip` gem dependency.
  [#258](https://github.com/OSC/ood-myjobs/issues/258)

## [2.8.1] - 2018-01-18
### Fixed
- Fix invalid buttons by disabling them during data refresh process.
  [#226](https://github.com/OSC/ood-myjobs/issues/226)

## [2.8.0] - 2018-01-03
### Added
- `OOD_SHOW_JOB_OPTIONS_ACCOUNT_FIELD` env var can be set to a falsy value
  (i.e. `OOD_SHOW_JOB_OPTIONS_ACCOUNT_FIELD=0`) which allows hiding account
  field from job options.
- Loads `/etc/ood/config/apps/myjobs/env` file as dotenv file when in
  production environment. Can change location of this by setting
  `OOD_APP_CONFIG_ROOT` in `.env.local`. This allows moving app specific
  environment configuration to `/etc/`, easing installing and updating the
  dashboard app.
- `/etc/ood/config/apps/myjobs/initializers` and
  `/etc/ood/config/apps/myjobs/views` now are optional paths to place custom
  initializer and view and view partial overrides.

### Fixed
- Create directory containing sqlite3 database prior to creating sqlite3
  database. [#197](https://github.com/OSC/ood-myjobs/issues/197)

### Changed
- Load dotenv files in two passes: `.env.local` files first, then the rest of
  the dotenv files. This allows overriding `OOD_APP_CONFIG_ROOT` in
  `.env.local` which is useful for testing configuration changes when doing
  development.
- Configuration object is now created in `config/boot.rb` so it can be used in
  setup scripts and rake tasks that don't load the `config/application.rb`.
- Removed `therubyracer` gem requirement in favor of node.js.

## [2.7.0] - 2017-11-27
### Changed
- Updated from Rails 4.1 to Rails 4.2.10.
  [#250](https://github.com/OSC/ood-myjobs/issues/250)

## [2.6.2] - 2017-11-17
### Fixed
- Fix bug when copying job from existing.
  [#245](https://github.com/OSC/ood-myjobs/issues/245)

## [2.6.1] - 2017-10-20
### Changed
- Updated `ood_core` library which includes bug fixes and new Batch Connect
  helper functions for scripts.
  [#241](https://github.com/OSC/ood-myjobs/pull/241)

## [2.6.0] - 2017-09-27
### Fixed
- Joyride help fixed to work with new button dropdwon for creating jobs.
  [#236](https://github.com/OSC/ood-myjobs/issues/236)

### Changed
- Rename app to "Job Composer" because "MyJobs" is a confusing name.
  [#238](https://github.com/OSC/ood-myjobs/issues/238)

## [2.5.2] - 2017-09-08
### Fixed
- Update dependencies to fix bug with LSF.
  [#50](https://github.com/OSC/ood_core/pull/50)

## [2.5.1] - 2017-09-06
### Fixed
- Sanitize user input for account string.
  [#233](https://github.com/OSC/ood-myjobs/issues/233)

## [2.5.0] - 2017-07-12
### Added
- Support for PBS Pro and basic support for LSF 9.1 via update to ood_core gem

## [2.4.2] - 2017-07-10
### Added
- Add warning and prevent submission if host is invalid

### Changed
- Display a cluster's metadata title instead of titleized id
- Fix bug where new template path isn't blank
- Redirect user to new templates page on cancel
- Fix a bug when requesting data for a workflow with an unassigned batch_host

## [2.4.1] - 2017-06-05
- Fix bug in `bin/setup` that crashes when `OOD_PORTAL` is set but not
  `OOD_SITE`

## [2.4.0] - 2017-05-26
- Allow user to enter relative path names as template source
- Allow a user to create a new workflow from a path
- Allow user to resubmit a completed/failed job
- Display the script name associated with a workflow
- Add prompt to null selectpicker option
- Wrap long names that break out of containers
- UI enhancements

## [2.3.4] - 2017-05-15
- Terminal button now links to appropriate host instead of default
- Update to OOD Appkit 1.0.1
- Alert if no valid hosts are available
- Hide row of job creation buttons if no submit hosts
- UI enhancements


[Unreleased]: https://github.com/OSC/ood-myjobs/compare/v2.15.2...HEAD
[2.15.2]: https://github.com/OSC/ood-myjobs/compare/v2.15.1...v2.15.2
[2.15.1]: https://github.com/OSC/ood-myjobs/compare/v2.15.0...v2.15.1
[2.15.0]: https://github.com/OSC/ood-myjobs/compare/v2.14.0...v2.15.0
[2.14.0]: https://github.com/OSC/ood-myjobs/compare/v2.13.0...v2.14.0
[2.13.0]: https://github.com/OSC/ood-myjobs/compare/v2.12.0...v2.13.0
[2.12.0]: https://github.com/OSC/ood-myjobs/compare/v2.11.0...v2.12.0
[2.11.0]: https://github.com/OSC/ood-myjobs/compare/v2.10.2...v2.11.0
[2.10.2]: https://github.com/OSC/ood-myjobs/compare/v2.10.1...v2.10.2
[2.10.1]: https://github.com/OSC/ood-myjobs/compare/v2.10.0...v2.10.1
[2.10.0]: https://github.com/OSC/ood-myjobs/compare/v2.9.3...v2.10.0
[2.9.3]: https://github.com/OSC/ood-myjobs/compare/v2.9.2...v2.9.3
[2.9.2]: https://github.com/OSC/ood-myjobs/compare/v2.9.1...v2.9.2
[2.9.1]: https://github.com/OSC/ood-myjobs/compare/v2.9.0...v2.9.1
[2.9.0]: https://github.com/OSC/ood-myjobs/compare/v2.8.3...v2.9.0
[2.8.3]: https://github.com/OSC/ood-myjobs/compare/v2.8.2...v2.8.3
[2.8.2]: https://github.com/OSC/ood-myjobs/compare/v2.8.1...v2.8.2
[2.8.1]: https://github.com/OSC/ood-myjobs/compare/v2.8.0...v2.8.1
[2.8.0]: https://github.com/OSC/ood-myjobs/compare/v2.7.0...v2.8.0
[2.7.0]: https://github.com/OSC/ood-myjobs/compare/v2.6.2...v2.7.0
[2.6.2]: https://github.com/OSC/ood-myjobs/compare/v2.6.1...v2.6.2
[2.6.1]: https://github.com/OSC/ood-myjobs/compare/v2.6.0...v2.6.1
[2.6.0]: https://github.com/OSC/ood-myjobs/compare/v2.5.2...v2.6.0
[2.5.2]: https://github.com/OSC/ood-myjobs/compare/v2.5.1...v2.5.2
[2.5.1]: https://github.com/OSC/ood-myjobs/compare/v2.5.0...v2.5.1
[2.5.0]: https://github.com/OSC/ood-myjobs/compare/v2.4.2...v2.5.0
[2.4.2]: https://github.com/OSC/ood-myjobs/compare/v2.4.1...v2.4.2
[2.4.1]: https://github.com/OSC/ood-myjobs/compare/v2.4.0...v2.4.1
[2.4.0]: https://github.com/OSC/ood-myjobs/compare/v2.3.4...v2.4.0
[2.3.4]: https://github.com/OSC/ood-myjobs/compare/v1.0.0...v2.3.4
