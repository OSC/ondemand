## Unreleased

Bugfixes:

  - strip off query params in doc referer arg sent to analytics server
  - allow redirects in analytics request
  - increase network timeout of analytics request to 5 seconds

## 0.0.5 (2016-10-27)

Features:

  - added server side analytics feature

Bugfixes:

  - reverted the `sub-uri` option when staging a PUN

## 0.0.4 (2016-10-11)

Bugfixes:

  - fixed `nginx_stage pun` call with included `sub_uri` option

## 0.0.3 (2016-09-23)

Features:

  - added sequence diagram to `README.md`
  - removed user map caching and made mapping more verbose

## 0.0.2 (2016-08-04)

Features:

  - uses cookie to help invalidate cache

## 0.0.1 (2016-06-03)

Features:

  - Initial release
