# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.18.0] - 2017-10-20
### Added
- Logs the full command line call for any forked processes.
  [#260](https://github.com/OSC/ood-dashboard/issues/260)

### Changed
- (Batch Connect) Check boxes are now placed inside of `form_group`.
  [#266](https://github.com/OSC/ood-dashboard/issues/266)
- Updated `ood_core` library which includes bug fixes and new Batch Connect
  helper functions for scripts.
  [#263](https://github.com/OSC/ood-dashboard/pull/263)
- The developer dashboard is enabled by default if the sandbox directory exists
  for the user. [#264](https://github.com/OSC/ood-dashboard/issues/264)
- Changed app edit button to "Edit Metadata" and moved to right side.
  [#272](https://github.com/OSC/ood-dashboard/issues/272)

### Fixed
- Load a proper login shell for Interactive Apps when using an LSF resource
  manager. [262](https://github.com/OSC/ood-dashboard/issues/262)
- Fixed the misnomer from "New Product" to "New App".
  [#257](https://github.com/OSC/ood-dashboard/issues/257)
- Fixed the default sorting column on Products list page.
  [#273](https://github.com/OSC/ood-dashboard/issues/273)

## [1.17.0] - 2017-09-27
### Added
- optional dashboard help url "Configure Two Factor Authentication" set using
  `OOD_DASHBOARD_2FA_URL` env var
- new Configuration object to centralize domain specific app configuration

### Changed
- The configuration flag for enabling developer mode is no longer
  `NavConfig.show_develop_dropdown`, it is now
  `Configuration.app_development_enabled` and this defaults to the env var
  OOD_APP_DEVELOPMENT being present; the flag can be modified in the initializer

### Fixed
- updated to latest version of Font Awesome: 4.7.0

## [1.16.0] - 2017-09-12
### Added
- (Batch Connect) Added support for ERB rendering of template files.
  [#179](https://github.com/OSC/ood-dashboard/issues/179)
- (Batch Connect) Output informational files to staging directory for debugging
  purposes. [#165](https://github.com/OSC/ood-dashboard/issues/165)
- Added ability to reset the git repository when cloning a sandbox app.
  [#214](https://github.com/OSC/ood-dashboard/issues/214)
- (Batch Connect) Added links to the output and staging directories for the
  apps and their sessions.
  [#218](https://github.com/OSC/ood-dashboard/issues/218)
- Indicates the style of app when viewing the app details in developer view.
  [#219](https://github.com/OSC/ood-dashboard/issues/219)
- Giant launch app buttons on development index and details views [#210](https://github.com/OSC/ood-dashboard/issues/210)

### Changed
- Updated LICENSE date.
- Nav bar is absolutely positioned for responsive issues. The result is that
  scrolling will shift the navbar out of the viewport.
- (Batch Connect) Keep staged directory around if job submission fails for
  debugging purposes.
- (Batch Connect) Don't wipe staging directory when `rsync`ing over template
  directory as it is already a new empty directory.
- Enabling app development and app sharing now use two different env vars,
  OOD_APP_SHARING and OOD_APP_DEVELOPMENT [#212](https://github.com/OSC/ood-dashboard/issues/212)
- (Batch Connect) Attempt to read default app title from manifest.
  [#241](https://github.com/OSC/ood-dashboard/issues/241)
- (Batch Connect) Attempt to read default description from manifest.
  [#245](https://github.com/OSC/ood-dashboard/issues/245)
- Replace app development product page headers with breadcrumbs.
  [#238](https://github.com/OSC/ood-dashboard/issues/238)

### Fixed
- Navbar is more responsive with develop menu consistent with other dropdowns [#213](https://github.com/OSC/ood-dashboard/issues/213)
- Fixed viewport when viewing on mobile devices
- Show full text of navbar options when navbar is collapsed [#168](https://github.com/OSC/ood-dashboard/issues/168)
- (Batch Connect) Rescue from all Standard Exceptions and display error to user
  to keep with "app never crashes" philosophy.
- (Batch Connect) Sanitize user input for a few smart attribute job submission
  parameters.

### Removed
- Removed the ability to build a Rails app from a template as it copies from an
  outdated template. [#215](https://github.com/OSC/ood-dashboard/issues/215)
- (Batch Connect) Removed temporary OSC patch that migrated Batch Connect app
  data to a namespaced data root.
  [#200](https://github.com/OSC/ood-dashboard/issues/200)

## [1.15.3] - 2017-09-08
### Fixed
- update dependencies to fix bug with LSF [#50](https://github.com/OSC/ood_core/pull/50)

## [1.15.2] - 2017-07-24
### Fixed
- Updated and rebuilt noVNC so that it works with Safari browsers now.
  [#177](https://github.com/OSC/ood-dashboard/issues/177)

## [1.15.1] - 2017-07-20
### Fixed
- Fix resize issue observed for "View Only" connections with noVNC and latest
  TurboVNC. [#206](https://github.com/OSC/ood-dashboard/issues/206)
- Browser requirement warnings now show up on every page on the Dashboard.
  [#194](https://github.com/OSC/ood-dashboard/pull/194)

## [1.15.0] - 2017-07-17
### Added
- Added support for the PBS Pro adapter when using the `bc_num_slots` smart
  attribute in iHPC.

### Changed
- Show batch connect "subapps" in navigation instead of just the parent app
- Default batch connect app titles to name of directory or subapp
- Changed wording in the Safari websocket alert message to be more helpful.

### Fixed
- Prevent problems with batch connect app from causing dashboard to crash
- Properly clean up /tmp after running unit tests
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


[Unreleased]: https://github.com/OSC/ood-dashboard/compare/v1.18.0...HEAD
[1.18.0]: https://github.com/OSC/ood-dashboard/compare/v1.17.0...v1.18.0
[1.17.0]: https://github.com/OSC/ood-dashboard/compare/v1.16.0...v1.17.0
[1.16.0]: https://github.com/OSC/ood-dashboard/compare/v1.15.3...v1.16.0
[1.15.3]: https://github.com/OSC/ood-dashboard/compare/v1.15.2...v1.15.3
[1.15.2]: https://github.com/OSC/ood-dashboard/compare/v1.15.1...v1.15.2
[1.15.1]: https://github.com/OSC/ood-dashboard/compare/v1.15.0...v1.15.1
[1.15.0]: https://github.com/OSC/ood-dashboard/compare/v1.14.1...v1.15.0
[1.14.1]: https://github.com/OSC/ood-dashboard/compare/v1.14.0...v1.14.1
[1.14.0]: https://github.com/OSC/ood-dashboard/compare/v1.13.3...v1.14.0
[1.13.3]: https://github.com/OSC/ood-dashboard/compare/v1.13.2...v1.13.3
[1.13.2]: https://github.com/OSC/ood-dashboard/compare/v1.13.1...v1.13.2
[1.13.1]: https://github.com/OSC/ood-dashboard/compare/v1.13.0...v1.13.1
[1.13.0]: https://github.com/OSC/ood-dashboard/compare/v1.12.0...v1.13.0
