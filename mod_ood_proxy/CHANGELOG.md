## Frozen. See [CHANGELOG.md](https://github.com/OSC/ondemand/blob/master/CHANGELOG.md) at root of ondemand repo for future changes

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2018-03-26
### Added
- Add logging tag to logger to distinguish from other Lua log lines.

### Changed
- Changed log level for analytics and user mapping to debug to make logs less
  chatty.

### Fixed
- Fixed `req_handler` sometimes missing from logs.
  [#14](https://github.com/OSC/mod_ood_proxy/issues/14)

## [0.4.0] - 2018-02-13
### Added
- Added more verbose logging feature.
  [#12](https://github.com/OSC/mod_ood_proxy/issues/12)

### Changed
- Updated date in `LICENSE.txt`.

## [0.3.1] - 2017-07-25
### Fixed
- Fixed link to documentation in `README.md`.
- Fixed version number in Lua code.

## [0.3.0] - 2017-07-24
### Added
- Add `OOD_USER_ENV` to specify CGI env var used for authenticated username

### Changed
- Replaced unnecessary 307 redirects with 302 redirects.
- Ignore errors when stopping NGINX with a redirect URL.
- Modified `CHANGELOG.md` format.

### Removed
- Removed the `/nginx/start` URL option.

### Fixed
- Fix for GA session blow up due to changing document referrer.
  [#11](https://github.com/OSC/mod_ood_proxy/issues/11)

## [0.2.0] - 2017-01-30
### Removed
- Remove support for client-side analytics (prefer server-side analytics).

### Fixed
- Fix query params not being passed with `/rnode`.

## [0.1.0] - 2017-01-13
### Added
- Parse backend node server info from Apache supplied env vars instead of
  determining it from within mod

## [0.0.6] - 2016-11-10
### Changed
- Strip off query params in doc referer arg sent to analytics server.
- Allow redirects in analytics request.
- Increase network timeout of analytics request to 5 seconds.

## [0.0.5] - 2016-10-27
### Added
- Added server side analytics feature.

### Removed
- Reverted the `sub-uri` option when staging a PUN.

## [0.0.4] - 2016-10-11
### Fixed
- Fixed `nginx_stage pun` call with included `sub_uri` option.

## [0.0.3] - 2016-09-23
### Added
- Added sequence diagram to `README.md`.

### Removed
- Removed user map caching and made mapping more verbose.

## [0.0.2] - 2016-08-04
### Added
- Add cookie to help invalidate cache.

## [0.0.1] - 2016-06-03
### Added
- Initial release!

[Unreleased]: https://github.com/OSC/mod_ood_proxy/compare/v0.5.0...HEAD
[0.5.0]: https://github.com/OSC/mod_ood_proxy/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/OSC/mod_ood_proxy/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/OSC/mod_ood_proxy/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/OSC/mod_ood_proxy/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/OSC/mod_ood_proxy/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/OSC/mod_ood_proxy/compare/v0.0.6...v0.1.0
[0.0.6]: https://github.com/OSC/mod_ood_proxy/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/OSC/mod_ood_proxy/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/OSC/mod_ood_proxy/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/OSC/mod_ood_proxy/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/OSC/mod_ood_proxy/compare/v0.0.1...v0.0.2
