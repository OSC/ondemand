# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.36.0] - 2019-09-19
### Added
- [Support balances and add warnings](https://github.com/OSC/ood-dashboard/pull/483). 
The dashboard now looks for files with users account balance data and can warn them when it's getting close to 0.
- Added [Font Awesome Icon picker](https://github.com/OSC/ood-dashboard/issues/380) to development mode.
### Fixed
- bin/setup patch for debian

## [1.35.2] - 2019-08-22
### Fixed
- Updated jQuery and Nokogiri

## [1.35.1] - 2019-08-13
### Fixed
- Fixed issue where older browsers (IE) could not connect to VNC sessions [ood-dashboard](https://github.com/OSC/ood-dashboard/issues/479)

## [1.35.0] - 2019-06-17
### Added
- Added new check to enable developer mode if a symlink exists between the gateway and the user's ~/ondemand/dev directory, even if the corresponding directory has not yet been created

## [1.34.0] - 2019-06-14
### Added
- Added VNC quality and compression controls
- Added link to compute node that a VNC job is running on

## [1.33.4] - 2019-05-21
### Fixed
- Fixed missing translations

## [1.33.3] - 2019-05-15
### Fixed
- Fixed more missing translations

## [1.33.2] - 2019-05-15
### Fixed
- Fixed translation bug which broke the Dashboard when certain environment variables were set

## [1.33.1] - 2019-05-09
### Changed
- Updated [ood_core](https://github.com/OSC/ood_core/blob/v0.9.3/CHANGELOG.md)

## [1.33.0] - 2019-04-17
### Added
- Added app title to noVNC launch button
- Added BatchConnect app version to new session form
- Added I18n hooks and an initial OSC/English locale
- Added OOD and Dashboard version to footer
- Added support for fetching quota from a URL
- Allow BatchConnect applications to raise errors that can be shown to users

### Fixed
- Handled file not found errors with Announcements and MOTDs
- Updated Gems to address CVEs

## [1.32.0] - 2019-02-07
### Changed
- Disable eager loading to speed initial load of the application

### Fixed
- Replaced missing MoTD formatter

## [1.31.0] - 2019-01-30
### Added
- version string to footer
- add support for localization of home page welcome text and motd title with
  added setup to be able to add support for more localization options in the
  future
- the home page html (both logo and text) can now be customized using a single
  html formatted string in /etc/ood/config/locales/en.yml with the `welcome_html`
  key

## [1.30.3] - 2019-01-11
### Fixed
- ood_core updated with critical bug fix for SGE
- fix displaying "invalid" interactive appp launch button in developer views
  [#434](https://github.com/OSC/ood-dashboard/issues/434)

## [1.30.2] - 2019-01-02
### Fixed
- Fixes for Quotas and improved tests

## [1.30.1] - 2018-12-31
### Fixed
- Fixes a divide by zero error in the Quota model when a resource is not limited

## [1.30.0] - 2018-12-26
### Fixed
- Update `ood_core` to latest version for Torque and SGE bug fixes
- Shortened quota alert

## [1.29.0] - 2018-12-19
### Added
- Added ability to include JavaScript files to the form
- Added experimental Grid Engine support

### Changed
- Changed logout message to inform users that they need to close their browsers to ensure logout
- Changed precision of time reporting of Batch Connect
- Changed development application root to be defined by the environment variable `OOD_DEV_APPS_ROOT`

## [1.28.0] - 2018-11-30
### Added
- Added whitelist mode to manage categories in the navbar.
  [#295](https://github.com/OSC/ood-dashboard/issues/295)

### Changed
- Whitelist mode defaults to false, so now app categories not defined in whitelist
  will appear in navbar. To enable whitelist mode to hide these categories, set
  `NavConfig.categories_whitelist = true` in a custom initializer
- Updated Gem dependency
- Updated Gem dependency (rack)
- Update recommended dependencies (ruby, git, node)

## [1.27.2] - 2018-09-14
### Changed
- Update PBS gem to v2.2.1

## [1.27.1] - 2018-09-12
### Fixed
- Fixed setup crash due to incompatibilities between older nodejs and newer autoprefixer

## [1.27.0] - 2018-09-11
### Added
- Support parsing disk quota information that follows a pre-defined JSON
  schema.
  [#366](https://github.com/OSC/ood-dashboard/issues/366)
- Display disk quota warnings to user if near limit.
  [#366](https://github.com/OSC/ood-dashboard/issues/366)
- Can specify html options for batch connect form fields in form.yml using
  `html_options` key
  [#376](https://github.com/OSC/ood-dashboard/issues/376)
- Can specify other form field helper options for batch connect form fields in
  form.yml by adding more key/value pairs to the attribute section
  [#369](https://github.com/OSC/ood-dashboard/issues/369)

### Changed
- Updated dependencies using `bundle update`
- Improve user messaging around using Git when cloning apps
  [#256](https://github.com/OSC/ood-dashboard/issues/256)
- Changed 'title' to 'name' in the Developer View
- Upgrade Font Awesome to v5
  [#341](https://github.com/OSC/ood-dashboard/issues/341)
- In the Developer View replaced app delete button with instructions on how to do so from the command line


### Fixed
- When rendering form.yml.erb and submit.yml.erb `__FILE__` is now properly set
  to the path to the yaml file being rendered
  [#369](https://github.com/OSC/ood-dashboard/issues/369)
- Fixed a problem where a missing title in the cluster metadata could cause a crash in the fallback handler
  [#395](https://github.com/OSC/ood-dashboard/issues/395)

## [1.26.2] - 2018-05-14
### Fixed
- Updated `ood_core` gem to 0.5.1 to patch VNC template bug.

## [1.26.1] - 2018-04-30
### Fixed
- Updated gem dependencies to stave off security risks.

## [1.26.0] - 2018-04-30
### Added
- Added simple Rake task to test cluster job submission.
  [#358](https://github.com/OSC/ood-dashboard/issues/358)

### Changed
- Updated `ood_core` gem to support `Script#native` arrays for the Torque
  adapter.

### Fixed
- (Batch Connect) Fix crashing when handling invalid session data files.
  [#357](https://github.com/OSC/ood-dashboard/issues/357)

## [1.25.1] - 2018-04-09
### Fixed
- (Batch Connect) Fixed missing `/usr/bin/bash` on CentOS 6.

## [1.25.0] - 2018-04-06
### Added
- (Batch Connect) Can now configure whether global configuration is used for
  system apps.

### Changed
- Allow HTML to be included and rendered in announcement message.
  [#352](https://github.com/OSC/ood-dashboard/issues/352)
- Lazily load the announcements so they aren't parsed unless needed.
  [#353](https://github.com/OSC/ood-dashboard/issues/353)
- Set a default developer documentation link to https://go.osu.edu/ood-app-dev.
  [#255](https://github.com/OSC/ood-dashboard/issues/255)
- Ordered the Shell Apps by cluster title in the dropdown navbar.
  [#116](https://github.com/OSC/ood-dashboard/issues/116)
- (Batch Connect) Shell path is now a configurable option for the job script
  template. [#356](https://github.com/OSC/ood-dashboard/issues/356)

### Fixed
- Show valid announcements even if error raised when parsing an announcement.
  [#354](https://github.com/OSC/ood-dashboard/issues/354)

### Removed
- Removed environment variable specifying `OOD_DEV_SSH_HOST`.
  [#312](https://github.com/OSC/ood-dashboard/issues/312)

## [1.24.0] - 2018-03-27
### Changed
- Open navigation links to external sites in new windows.
  [#349](https://github.com/OSC/ood-dashboard/issues/349)

### Fixed
- Fix sticky footer bug in IE11.
  [#347](https://github.com/OSC/ood-dashboard/issues/347),
  [#351](https://github.com/OSC/ood-dashboard/issues/351)
- Bump version of gem dependencies for security fixes.

## [1.23.0] - 2018-02-26
### Added
- Add Travis CI automated testing.
  [#345](https://github.com/OSC/ood-dashboard/issues/345)

### Changed
- Updated noVNC to version 1.0.0.
  [#297](https://github.com/OSC/ood-dashboard/issues/297)

## [1.22.0] - 2018-02-09
### Added
- (Batch Connect) Added Shared/Sandbox apps to left-hand navigation menu.
  [#317](https://github.com/OSC/ood-dashboard/issues/317),
  [#173](https://github.com/OSC/ood-dashboard/issues/173)
- Added support to launch "sub-apps" from Developer Dashboard.
  [#261](https://github.com/OSC/ood-dashboard/issues/261)

### Changed
- (Batch Connect) Interactive Apps open in same tab from all navigation menus.
  [#318](https://github.com/OSC/ood-dashboard/issues/318)

### Fixed
- (Batch Connect) Hide empty sub-categories in top navbar due to invalid
  Interactive Apps. [#259](https://github.com/OSC/ood-dashboard/issues/259)
- (Batch Connect) Fixed error message displayed when Interactive App directory
  does not exist. [#335](https://github.com/OSC/ood-dashboard/issues/335)

## [1.21.3] - 2018-02-01
### Changed
- Made system call logging more human-friendly.
  [#328](https://github.com/OSC/ood-dashboard/issues/328)

### Fixed
- (Batch Connect) Set check box empty by default or populate it from cache.
  [#315](https://github.com/OSC/ood-dashboard/issues/315)
- (Batch Connect) Update panel when the time left changes.
  [#319](https://github.com/OSC/ood-dashboard/issues/319)

## [1.21.2] - 2018-01-29
### Changed
- Ignore apps if they have a period in directory name.
  [#313](https://github.com/OSC/ood-dashboard/issues/313)
- Updated `ood_core`
  ([0.2.0 => 0.2.1](https://github.com/OSC/ood_core/blob/master/CHANGELOG.md))
  which includes a number of bugfixes.

### Fixed
- Fixed tests with class name collision.
- Fixed tests reading global configuration when they shouldn't.
- Removed missing divider from test.
- Fixed Developer Documentation link appearing when unset.
  [#255](https://github.com/OSC/ood-dashboard/issues/255)

## [1.21.1] - 2018-01-18
### Fixed
- Fixed crash when editing development app and no SSH key exists for user.
  [#314](https://github.com/OSC/ood-dashboard/issues/314)

## [1.21.0] - 2018-01-10
### Added
- Added support for YAML announcements with ERB syntax as well as handling for
  multiple announcements.
  [#306](https://github.com/OSC/ood-dashboard/issues/306)

### Changed
- Updated date in `LICENSE.md`.

## [1.20.0] - 2017-12-21
### Added
- (Batch Connect) Added a root route for iHPC apps that take the user to the
  submission form. [#283](https://github.com/OSC/ood-dashboard/issues/283)
- (Batch Connect) Added title of iHPC app to submission form.
  [#278](https://github.com/OSC/ood-dashboard/issues/278)

### Changed
- (Batch Connect) Change page title for iHPC apps.
  [#289](https://github.com/OSC/ood-dashboard/issues/289)
- Renamed "App Design" in developer interface to "Type".
  [#277](https://github.com/OSC/ood-dashboard/issues/277)
- (Batch Connect) Look for sub-app configuration under the global path
  `/etc/ood/config/<app>/` for system iHPC apps or with the appropriate env var
  set. [#293](https://github.com/OSC/ood-dashboard/issues/293)

### Fixed
- Fix Rack app development by using `bundle` instead of `bin/bundle` as well as
  updating lint checks. [#290](https://github.com/OSC/ood-dashboard/issues/290)

## [1.19.0] - 2017-12-15
### Added
- Loads /etc/ood/config/apps/dashboard/env file as dotenv file when in production
  environment. Can change location of this by setting `OOD_APP_CONFIG_ROOT` in
  .env.local. This allows moving app specific environment configuration to
  /etc/, easing installing and updating the dashboard app.
- /etc/ood/config/apps/dashboard/initializers and
  /etc/ood/config/apps/dashboard/views now are optional paths to place custom
  initializer and view and view partial overrides
- App Index page at /apps/index now displays all apps. The shared apps that
  formerly displayed here are now accessed at /apps/featured. The link to /apps/index
  page only appears in the navbar if the env var `SHOW_ALL_APPS_LINK` is set to
  '1'

### Changed
- Changing nav bar brand colors are now a runtime config, not build time config.
  Changes in dotenv files will be applied on application restart. New runtime config
  for branding only works for background, link colors, and navbar type.
  `OOD_BRAND_BG_COLOR` and `OOD_BRAND_LINK_ACTIVE_BG_COLOR` can be used to
  configure the colors of the navbar. `OOD_NAVBAR_TYPE` still can be used.
  `BOOTSTRAP_NAVBAR_DEFAULT_BG` and `BOOTSTRAP_NAVBAR_INVERSE_BG` will be
  treated as if setting `OOD_BRAND_BG_COLOR`. `BOOTSTRAP_NAVBAR_DEFAULT_LINK_ACTIVE_BG` and
  `BOOTSTRAP_NAVBAR_INVERSE_LINK_ACTIVE_BG` will be treated as if setting
  `OOD_BRAND_LINK_ACTIVE_BG_COLOR`.
- Load dotenv files in two passes: .env.local files first, then the rest of the dotenv files.
  This allows overriding `OOD_APP_CONFIG_ROOT` in .env.local which is useful for
  testing configuration changes when doing development.
- Configuration object is now created in config/boot so it can be used in setup
  scripts and rake tasks that don't load the config/application.

### Removed
- Removed the need for .env.development .env.test  and .env.production files by
  using sensible defaults and avoiding setting RAILS_RELATIVE_URL_ROOT in the
  dotenv files

## [1.18.1] - 2017-11-22
### Changed
- Updated to latest Rails 4.2.10 for better Ruby 2.4 support.
  [#195](https://github.com/OSC/ood-dashboard/issues/195)
- Updated `ood_support` gem to 0.0.3 for better Ruby 2.4 support.

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
  manager. [#262](https://github.com/OSC/ood-dashboard/issues/262)
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


[Unreleased]: https://github.com/OSC/ood-dashboard/compare/v1.36.0...HEAD
[1.36.0]: https://github.com/OSC/ood-dashboard/compare/v1.35.2...v1.36.0
[1.35.2]: https://github.com/OSC/ood-dashboard/compare/v1.35.1...v1.35.2
[1.35.1]: https://github.com/OSC/ood-dashboard/compare/v1.35.0...v1.35.1
[1.35.0]: https://github.com/OSC/ood-dashboard/compare/v1.34.0...v1.35.0
[1.34.0]: https://github.com/OSC/ood-dashboard/compare/v1.33.4...v1.34.0
[1.33.4]: https://github.com/OSC/ood-dashboard/compare/v1.33.3...v1.33.4
[1.33.3]: https://github.com/OSC/ood-dashboard/compare/v1.33.2...v1.33.3
[1.33.2]: https://github.com/OSC/ood-dashboard/compare/v1.33.1...v1.33.2
[1.33.1]: https://github.com/OSC/ood-dashboard/compare/v1.33.0...v1.33.1
[1.33.0]: https://github.com/OSC/ood-dashboard/compare/v1.32.0...v1.33.0
[1.32.0]: https://github.com/OSC/ood-dashboard/compare/v1.31.0...v1.32.0
[1.31.0]: https://github.com/OSC/ood-dashboard/compare/v1.30.3...v1.31.0
[1.30.3]: https://github.com/OSC/ood-dashboard/compare/v1.30.2...v1.30.3
[1.30.2]: https://github.com/OSC/ood-dashboard/compare/v1.30.1...v1.30.2
[1.30.1]: https://github.com/OSC/ood-dashboard/compare/v1.30.0...v1.30.1
[1.30.0]: https://github.com/OSC/ood-dashboard/compare/v1.29.0...v1.30.0
[1.29.0]: https://github.com/OSC/ood-dashboard/compare/v1.28.0...v1.29.0
[1.28.0]: https://github.com/OSC/ood-dashboard/compare/v1.27.1...v1.28.0
[1.27.2]: https://github.com/OSC/ood-dashboard/compare/v1.27.1...v1.27.2
[1.27.1]: https://github.com/OSC/ood-dashboard/compare/v1.27.0...v1.27.1
[1.27.0]: https://github.com/OSC/ood-dashboard/compare/v1.26.2...v1.27.0
[1.26.2]: https://github.com/OSC/ood-dashboard/compare/v1.26.1...v1.26.2
[1.26.1]: https://github.com/OSC/ood-dashboard/compare/v1.26.0...v1.26.1
[1.26.0]: https://github.com/OSC/ood-dashboard/compare/v1.25.1...v1.26.0
[1.25.1]: https://github.com/OSC/ood-dashboard/compare/v1.25.0...v1.25.1
[1.25.0]: https://github.com/OSC/ood-dashboard/compare/v1.24.0...v1.25.0
[1.24.0]: https://github.com/OSC/ood-dashboard/compare/v1.23.0...v1.24.0
[1.23.0]: https://github.com/OSC/ood-dashboard/compare/v1.22.0...v1.23.0
[1.22.0]: https://github.com/OSC/ood-dashboard/compare/v1.21.3...v1.22.0
[1.21.3]: https://github.com/OSC/ood-dashboard/compare/v1.21.2...v1.21.3
[1.21.2]: https://github.com/OSC/ood-dashboard/compare/v1.21.1...v1.21.2
[1.21.1]: https://github.com/OSC/ood-dashboard/compare/v1.21.0...v1.21.1
[1.21.0]: https://github.com/OSC/ood-dashboard/compare/v1.20.0...v1.21.0
[1.20.0]: https://github.com/OSC/ood-dashboard/compare/v1.19.0...v1.20.0
[1.19.0]: https://github.com/OSC/ood-dashboard/compare/v1.18.1...v1.19.0
[1.18.1]: https://github.com/OSC/ood-dashboard/compare/v1.18.0...v1.18.1
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
