## Unreleased

## 0.3.0 (2017-03-01)

Features:

  - use a YAML file for overriding default configuration
  - use a common ERB template with the Puppet project
  - add logout sub-uri and redirect uri

Bugfixes:

  - fix CILogon default map command to use mapfile instead of regex
  - filter sensitive info for Basic Auth default option
  - fix missing closing bracket

## 0.2.0 (2017-01-30)

Features:

  - namespace cookies using the `Path` attribute
  - add documentation for Shibboleth (including filtering session cookie)
  - can specify host regex used for proxying

Bugfixes:

  - use better regex for modifying `Location` header
  - strip out or replace `Domain` attribute when setting a cookie
  - fixed hardcoded `/rnode` uri that should have been a variable
  - filter out `mod_auth_openidc` session/claims information

## 0.1.0 (2017-01-13)

Features:

  - modify redirect headers from backend web servers running on nodes

Bugfixes:

  - disabled node/rnode support by default due to security concerns

## 0.0.7 (2016-11-10)

Features:

  - adds analytics reporting feature
  - don't recommend CILogon anymore and allow all of its options to be set
    individually

Bugfixes:

  - fixed default location for `.htpasswd`

## 0.0.6 (2016-10-11)

Bugfixes:

  - fix for modifying `Location` header on a redirect from PUN

## 0.0.5 (2016-10-05)

Features:

  - simplified default authentication to basic auth

Bugfixes:

  - `ood_auth_map` path changed

## 0.0.4 (2016-09-26)

Features:

  - added server aliases option for redirection
  - added extended authentication options

## 0.0.3 (2016-09-23)

Bugfixes:

  - forgot to write out new variables to Apache config

## 0.0.2 (2016-09-23)

Features:

  - added more SSL options
  - added log options

Bugfixes:

  - removed extraneous whitespace

## 0.0.1 (2016-06-03)

Features:

  - Initial release
