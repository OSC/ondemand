# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

# [1.3.2]

* Update to Rails 4.2.10 to better support Ruby 2.4.
  [#71](https://github.com/OSC/ood-fileeditor/issues/71)
* Update `ood_support` gem to 0.0.3 to better support Ruby 2.4.

# [1.3.1]

* Save user preferences to local storage instead of cookies

# [1.3.0]

* Update to Ace Editor 1.2.6
* Gem update
* Update to Rails 4.2.7.1

# [1.2.5]

* added bin/setup script for easier deployment

# [1.2.4]

* updated README.md
* fixed deprecation warnings when precompiling assets
* patched mime type check to allow broader range of files
* uses the ace modelist extension to automatically select the appropriate syntax highlighting
* updated ood_appkit gem version

# [1.2.3]

* Fixed: ensure we treat all files we open as plain text, and avoid executing any files as a script updated ood_appkit dependency so editor can work without valid cluster config

# [1.2.2]

* Fix bundler issue

# [1.2.1]

* Fix ajax 404 response when selecting default keybinding

# [1.2.0]

* Update to Rails 4.2.7.1
* Documentation improvements
* Bugfixes

[Unreleased]: https://github.com/OSC/ood-fileeditor/compare/v1.3.2...HEAD
[1.3.2]: https://github.com/OSC/ood-fileeditor/compare/v1.3.1...v1.3.2
[1.3.1]: https://github.com/OSC/ood-fileeditor/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/OSC/ood-fileeditor/compare/v1.2.5...v1.3.0
[1.2.5]: https://github.com/OSC/ood-fileeditor/compare/v1.2.4...v1.2.5
[1.2.4]: https://github.com/OSC/ood-fileeditor/compare/v1.2.3...v1.2.4
[1.2.3]: https://github.com/OSC/ood-fileeditor/compare/v1.2.2...v1.2.3
[1.2.2]: https://github.com/OSC/ood-fileeditor/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/OSC/ood-fileeditor/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/OSC/ood-fileeditor/compare/ba6bdcb...v1.2.0
