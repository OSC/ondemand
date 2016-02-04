## Unreleased

Features:

  - display user name in process information

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
