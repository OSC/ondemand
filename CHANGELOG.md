## Unreleased

  - refactored Configuration module to reduce duplication

Features:

  - move config file parsing from binary to library
  - separated paths where pun and app configs are stored for easier config
    cleanup
  - directly spawn Rails apps to keep all apps under parent process
  - removed unix group whitelists as this should be responsibility of apps and
    file permissions (provides greater flexibility)
  - set Nginx tmp root to user's home directory to allow for larger file
    uploads
  - introduced/renamed possible app environments to: `dev`, `usr`, and `sys`

Bugfixes:

  - `rake install` doesn't depend on `git` anymore
  - fixed crash when config file was empty

## 0.0.4 (2016-04-04)

Features:

  - display user name in process information
  - set maximum upload file size to 10 GB in nginx config
  - uses unix group whitelists for consumers and publishers of apps
  - sys admins can now define configuration options in `config/nginx_stage.yml`
  - sys admins can now define PUN environment in `bin/ood_ruby` wrapper script

Bugfixes:

  - uses URL escaped strings for CLI arguments (security fix)
  - app requests with periods in the app name now work
  - fixed code typo in `User` class
  - use "restart" (stop + start) instead of "reload" after generating app
    config (takes advantage of `Open3` for executing nginx binary)
  - `rake install` now only installs git version checked out (fixes strange
    behavior with older versions)

## 0.0.3 (2016-02-04)

  - refactoring & internal cleanup

Features:

  - added `rake install` for simpler installation
  - options for a command are now specified in the corresponding generator
  - user can now get individualized help messages corresponding to a command

Bugfixes:

  - the `exec` call is made more secure

## 0.0.2 (2016-01-20)

Features:

  - add app initialization redirect URI option `pun -app-init-uri` if app not
    found by nginx
  - added `nginx` subcommand for easier control of nginx process

Bugfixes:

  - sanitize user input from command line
  - refactoring, cleanup internal configuration code making it more readable

## 0.0.1 (2016-01-14)

Features:

  - Initial release
