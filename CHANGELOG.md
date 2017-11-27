# unreleased

# version 1.3.2

* Update to Rails 4.2.10 to better support Ruby 2.4.
  [#71](https://github.com/OSC/ood-fileeditor/issues/71)
* Update `ood_support` gem to 0.0.3 to better support Ruby 2.4.

# version 1.3.1

* Save user preferences to local storage instead of cookies

# version 1.3.0

* Update to Ace Editor 1.2.6
* Gem update
* Update to Rails 4.2.7.1

# version 1.2.5

* added bin/setup script for easier deployment

# version 1.2.4

* updated README.md
* fixed deprecation warnings when precompiling assets
* patched mime type check to allow broader range of files
* uses the ace modelist extension to automatically select the appropriate syntax highlighting
* updated ood_appkit gem version

# version 1.2.3

* Fixed: ensure we treat all files we open as plain text, and avoid executing any files as a script updated ood_appkit dependency so editor can work without valid cluster config

# v1.2.2

* Fix bundler issue

# v1.2.1

* Fix ajax 404 response when selecting default keybinding

# v1.2.0

* Update to Rails 4.2.7.1
* Documentation improvements
* Bugfixes
