## Unreleased

Features:

  - remove support for client-side analytics (prefer server-side analytics)

Bugfixes:

  - fix query params not being passed with `/rnode`

## 0.1.0 (2017-01-13)

Features:

  - retrieve backend node server info from Apache instead of determining it
    from within mod

## 0.0.6 (2016-11-10)

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
