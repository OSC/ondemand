## Frozen. See [CHANGELOG.md](https://github.com/OSC/ondemand/blob/master/CHANGELOG.md) at root of ondemand repo for future changes

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.7.1] - 2018-02-26
### Changed
- Return non-zero exit status if there is no change in the generated Apache
  configuration file.
  [#14](https://github.com/OSC/ood-portal-generator/issues/14)

## [0.7.0] - 2018-02-14
### Added
- Added the verbose Lua log handler `logger` for metrics gathering.

### Changed
- Set default log level to `info` to enable verbose logging.

## [0.6.0] - 2018-02-09
### Added
- Added helpful utility for performing the necessary operations when updating
  the Apache config.

## [0.5.0] - 2018-01-31
### Added
- Added a commented warning about editing the Apache config directly in the ERB
  template. [#11](https://github.com/OSC/ood-portal-generator/issues/11)
- Added the executable `bin/generate` for easier generation of Apache configs.

### Changed
- Updated information in `LICENSE.txt`.
- Changed location of default YAML configuration file to the well-defined
  global location `/etc/ood/config/ood-portal.yml`.
  [#11](https://github.com/OSC/ood-portal-generator/issues/11)
- Refactored code out of `Rakefile` into a separate library for code reuse.

## [0.4.0] - 2017-07-25
### Added
- Added configuration option for `OOD_USER_ENV` used in `mod_ood_proxy`.

### Changed
- Changed the formatting of the `CHANGELOG.md`.

### Fixed
- Fixed link to documentation in `README.md`.

## [0.3.1] - 2017-03-06
### Fixed
- Fix double escaping query params on redirect.

## [0.3.0] - 2017-03-01
### Added
- Use a YAML file for overriding default configuration.
- Use a common ERB template with the Puppet project.
- Add logout sub-uri and redirect uri.

### Fixed
- Fix CILogon default map command to use mapfile instead of regex.
- Fix missing closing bracket.

### Security
- Filter sensitive info for Basic Auth default option.

## [0.2.0] - 2017-01-30
### Added
- Add documentation for Shibboleth (including filtering session cookie).
- Supports specifying host regex used for proxying

### Fixed
- Use better regex for modifying `Location` header.
- Strip out or replace `Domain` attribute when setting a cookie.
- Fixed hardcoded `/rnode` uri that should have been a variable.

### Security
- Namespace cookies using the `Path` attribute.
- Filter out `mod_auth_openidc` session/claims information.

## [0.1.0] - 2017-01-13

### Security
- Disabled node/rnode support by default due to security concerns.
- Modify redirect headers from backend web servers running on nodes.

## [0.0.7] - 2016-11-10
### Added
- Adds analytics reporting feature.

### Changed
- Don't recommend CILogon anymore and allow all of its options to be set
  individually.

### Fixed
- Fixed default location for `.htpasswd`.

## [0.0.6] - 2016-10-11
### Fixed
- Fix for modifying `Location` header on a redirect from PUN.

## [0.0.5] - 2016-10-05
### Changed
- Simplified the default authentication to use Basic Auth.
- The `ood_auth_map` path has changed.

## [0.0.4] - 2016-09-26
### Added
- Added server aliases option for redirection.
- Added extended authentication options.

## [0.0.3] - 2016-09-23
### Fixed
- Forgot to write out new variables to Apache config.

## [0.0.2] - 2016-09-23
### Added
- Added more SSL options.
- Added log options.

### Removed
- Removed extraneous whitespace.

## 0.0.1 - 2016-06-03
### Added
- Initial release!

[Unreleased]: https://github.com/OSC/ood-portal-generator/compare/v0.7.1...HEAD
[0.7.1]: https://github.com/OSC/ood-portal-generator/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/OSC/ood-portal-generator/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/OSC/ood-portal-generator/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/OSC/ood-portal-generator/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/OSC/ood-portal-generator/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/OSC/ood-portal-generator/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/OSC/ood-portal-generator/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/OSC/ood-portal-generator/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/OSC/ood-portal-generator/compare/v0.0.7...v0.1.0
[0.0.7]: https://github.com/OSC/ood-portal-generator/compare/v0.0.6...v0.0.7
[0.0.6]: https://github.com/OSC/ood-portal-generator/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/OSC/ood-portal-generator/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/OSC/ood-portal-generator/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/OSC/ood-portal-generator/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/OSC/ood-portal-generator/compare/v0.0.1...v0.0.2
