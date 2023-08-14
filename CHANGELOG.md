# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
only query the fs api if you navigate select a directory (#2951)\
Add delete script functionality for new job composer (#2820) (#2959)\
lint a random file (#2955)\
add gcc to dev container (#2949)\
Container images upgrade to NodeJS 18 and Ruby 3.1 (#2953)\
add test for excluding options and add ids to some elements in the views (#2942)\
Update Changelog (#2946)\
fix mocha deprecation warnings (#2941)\
sort ondemand.d files by name before loading (#2944)\
update dependencies (#2947)\
lint a random file (#2945)

### Added
- Sites can now add javascript files through `custom_javascript_files` config
  in [2791](https://github.com/OSC/ondemand/pull/2791).
- An option for Google analytics javascript has been added to dashboard in 
  in [2795](https://github.com/OSC/ondemand/pull/2795).
- `oidc_crypto_passphrase` can be set in ood_portal in [2807](https://github.com/OSC/ondemand/pull/2807).
- Titles for menus can now be overriden in [2804](https://github.com/OSC/ondemand/pull/2804).
- Sites can now configure `passenger_log_file` in [2835](https://github.com/OSC/ondemand/pull/2835).
- Support for aarch64 builds in [2873](https://github.com/OSC/ondemand/pull/2873).
- The File browser now has a Globus button to link to Globus endpoints in [2858]((https://github.com/OSC/ondemand/pull/2858).

### Fixed
- Develop menu now correctly shows/hides when given a configuration in [2848](https://github.com/OSC/ondemand/pull/2848).
- ood-portal-generator correctly uses `proxy_server` in http rewrites in [2870](https://github.com/OSC/ondemand/pull/2870).
- auto_modules now support module names with hyphens in them in [2938](https://github.com/OSC/ondemand/pull/2938).

### Changed
- Open OnDemand now requires NodeJS 18 and Ruby 3.1 on applicable platforms in [2885](https://github.com/OSC/ondemand/pull/2885).

## [3.0.1] - 04-20-2023

### Fixed

- Only depend on the selinux-policy version, not full version including release in
  [2738](https://github.com/OSC/ondemand/pull/2738).
- Fix [2715](https://github.com/OSC/ondemand/pull/2715) by moving the error partial in 
  [2731](https://github.com/OSC/ondemand/pull/2731).
- Duplicate applications are now filtered in the interactive apps menu
  in [2730](https://github.com/OSC/ondemand/pull/2730).
- Correctly catch errors from account queries in [2742](https://github.com/OSC/ondemand/pull/2742).
- `ood_core` bugfixes in [2740](https://github.com/OSC/ondemand/pull/2740).
  - `activejobs` now correctly shows kubernetes jobs.
  - `auto_accounts` now correctly works with non-standard sacctmgr commands and Slurm
     clusters with the cluster field set.
- The panels for development apps will always show in interactive sessions in
  [2757](https://github.com/OSC/ondemand/pull/2757).
  
### Changed

- Upgrade to rails 6.1.7.3 in [2747](https://github.com/OSC/ondemand/pull/2747).

### Added

- Uppy messages can be localized in [2766](https://github.com/OSC/ondemand/pull/2766).
- [2709](https://github.com/OSC/ondemand/pull/2709) created a VERSIONING_POLICY.md.

## [3.0.0] - 03-27-2023

### Changed

- Added support for YAML anchors and aliases when reading configuration (#2214) (#2224)
- Update hterm to 1.91 in  [#1426](https://github.com/OSC/ondemand/pull/1426).
- Batch connect apps can now use a per cluster dataroot to support sites that have multiple storages
  in [#1409](https://github.com/OSC/ondemand/pull/1409).
- The dashboard now uses strict same site cookies in [#1418](https://github.com/OSC/ondemand/pull/1418).
- Build RPMs in CI/CD pipelines using -s flag to disable source download in [1471](https://github.com/OSC/ondemand/pull/1471).
- Dashboard is rails 6.1 in [1830](https://github.com/OSC/ondemand/pull/1830). Myjobs is rails 6.0 in [2032](https://github.com/OSC/ondemand/pull/2032).
- `context.json` files have moved in location and filename in [1526](https://github.com/OSC/ondemand/pull/1526).
- Switch dev container and EL8 e2e tests to use Rocky Linux 8 [1534](https://github.com/OSC/ondemand/pull/1534).
- The entire Javascript and CSS pipeline was migrated to webpack, closing [1005](https://github.com/OSC/ondemand/pull/1005).
  It was then migrated to esbuild  in [#1957](https://github.com/OSC/ondemand/pull/1957).
- Remove active support dependency for ood-portal-generator in [1572](https://github.com/OSC/ondemand/pull/1572).
- All desktop options now show in bc_desktop [1638](https://github.com/OSC/ondemand/pull/1638).
- Radio buttons are now grouped for labeling in [1611](https://github.com/OSC/ondemand/pull/1611).
- Changed the file editor navbar in [1582](https://github.com/OSC/ondemand/pull/1582).
- CI now uses the `ood_packaging` gem to build artifacts in [1661](https://github.com/OSC/ondemand/pull/1661).
- Yaml files now preview in [1758](https://github.com/OSC/ondemand/pull/1758).
- Manifests can now specify and override an app's caption in [1941](https://github.com/OSC/ondemand/pull/1941).
- The file explorer table has been heavily refactored to be more reusable in [1883](https://github.com/OSC/ondemand/pull/1883).
- The shell app will now diplay specific errors in [#1966](https://github.com/OSC/ondemand/pull/1966).
- The default authentication scheme for the ood portal generator has been changed to an empty array in
  [#1982](https://github.com/OSC/ondemand/pull/1982).  The previous default was OIDC configs.
- Packages now rely on python3 in [#2011](https://github.com/OSC/ondemand/pull/2011).
- Passenger and NGINX dependencies are now 6.0.14 and NGINX repectively in [#2027](https://github.com/OSC/ondemand/pull/2027).
- NavConfig settings have been deprecated and replaced in [2221](https://github.com/OSC/ondemand/pull/2221).
- noNVC is now 1.3.0, up from 1.1.0 in [2295](https://github.com/OSC/ondemand/pull/2295).
- NavConfig should now use allowlist, deprecating whitelist in [2380](https://github.com/OSC/ondemand/pull/2380).
- Shared apps can now correctly set FACLs in [2398](https://github.com/OSC/ondemand/pull/2398).
- Session info is now stored in a local filesystem instead of in cookies in [2434](https://github.com/OSC/ondemand/pull/2434).
- NavConfig is deprecated in favor of an ondeman.d setting `nav_categories` in [2454](https://github.com/OSC/ondemand/pull/2454).
- Passenger security update checks are disabled because users can't update outside of OSC packages in [2660](https://github.com/OSC/ondemand/pull/2660).
- Sites can now server assets out of public/maintanence in [2443](https://github.com/OSC/ondemand/pull/2443).

### Added

- Batch connect apps can now enable automatic javascript to dynamically update:
  - Options in [1380](https://github.com/OSC/ondemand/pull/1380).
  - Min and maxes in [1441](https://github.com/OSC/ondemand/pull/1441).
  - Other fields in [1449](https://github.com/OSC/ondemand/pull/1449).
  - Add functionality for hiding or showing elements in [1529](https://github.com/OSC/ondemand/pull/1529).
- Several automatic batch connect items have been added:
  - `auto_primary_group` added in [1964](https://github.com/OSC/ondemand/pull/1964).
  - `auto_accounts` were added in [2479](https://github.com/OSC/ondemand/pull/2479).
  - `auto_queues` were added in [2511](https://github.com/OSC/ondemand/pull/2511).
  - Modules can be automatically loaded in batch connect forms in (1930)(https://github.com/OSC/ondemand/pull/1930).
  - `auto_qos` was added [2516](https://github.com/OSC/ondemand/pull/2516).
- Test cases for example files for both ood_portal and nginx_stage in [832](https://github.com/OSC/ondemand/pull/832).
- Debian packaging in [1466](https://github.com/OSC/ondemand/pull/1466). With many many subsequent patches.
- Automation will now push ondemand tar.gz to release page on tags in [1564](https://github.com/OSC/ondemand/pull/1564).
- Submit.yml's will now be written to the staged root if they have ERB/YML related errors in [1636](https://github.com/OSC/ondemand/pull/1636).
- Apps recognize if they're preset. Preset apps don't show forms, they just launch in [#1815](https://github.com/OSC/ondemand/pull/1815).
- Citation information for this source is now available in [1887](https://github.com/OSC/ondemand/pull/1887) and releases are made
  in [1888](https://github.com/OSC/ondemand/pull/1887).
- Custom CSS files can be added in [2168](https://github.com/OSC/ondemand/pull/2168).
- Cloud Storage.
  - Support cloud storage file transfers in [2186](https://github.com/OSC/ondemand/pull/2186).
  - RPMs and DEBs now require (or suggest) rlcone in [2234](https://github.com/OSC/ondemand/pull/2234).
- Support for Profiles
  - NavConfig settings have been deprecated and replaced in [2221](https://github.com/OSC/ondemand/pull/2221).
  - The Navbar can be completely defined in [2270](https://github.com/OSC/ondemand/pull/2270).
  - Interactive App Menus can be overridden in [2374](https://github.com/OSC/ondemand/pull/2374).
- Support for opening support tickets in [2292](https://github.com/OSC/ondemand/pull/2292).
  - With support for RT in [2318](https://github.com/OSC/ondemand/pull/2318).
  - Additional support for making support ticket forms in [2348](https://github.com/OSC/ondemand/pull/2348).
  - Support tickets are also part of profiles in [2625](https://github.com/OSC/ondemand/pull/2625).
- Added ENV override for showing/hiding job arrays in [2327](https://github.com/OSC/ondemand/pull/2327).
- Sites can add custom pages in Custom pages feature [2353](https://github.com/OSC/ondemand/pull/2353).
- BC apps can now display choices made in the card in [2366](https://github.com/OSC/ondemand/pull/2366).
- Added the active sessions widget in [2377](https://github.com/OSC/ondemand/pull/2377).
- BatchConnect choices now appear in the cards if display is set to true in [2381](https://github.com/OSC/ondemand/pull/2381).
- BatchConnect apps can now use `auto_group` attributes in Auto groups [2370](https://github.com/OSC/ondemand/pull/2370).
- BatchConnect job directories will now be cleaned on some interval in [2482](https://github.com/OSC/ondemand/pull/2482).
- Added recently used applications widget in [2503](https://github.com/OSC/ondemand/pull/2503).
- Added a configuration to hide app version for batch connects apps in [2462](https://github.com/OSC/ondemand/pull/2462).
- Completed batch connect sessions can relaunch from their card in [2529](https://github.com/OSC/ondemand/pull/2529).
- Sites can add anything to the help menu in [2514](https://github.com/OSC/ondemand/pull/2514).
- The ALLOWED_HOSTS environment variable is populated in the PUN in [2559](https://github.com/OSC/ondemand/pull/2559)
  and [2567](https://github.com/OSC/ondemand/pull/2567).
- Added support for images from /public location in [2577](https://github.com/OSC/ondemand/pull/2577).
- Added configuration to disable the dashboard welcome message in [2585](https://github.com/OSC/ondemand/pull/2585).
- `announcment_paths` are now an ondemand.d property with profile support in [2608](https://github.com/OSC/ondemand/pull/2608).

### Fixed

- Batch connect now safely reads files in db in [1402](https://github.com/OSC/ondemand/pull/1402).
- Add retry attempt counter to 404 loop to fix client side loop in [#1298](https://github.com/OSC/ondemand/pull/1298).
- Removed Index from Public RootOptions in [#1618](https://github.com/OSC/ondemand/pull/1618).
- File uploads have longer upload time limits more in line with TCP TTLs in [#1600](https://github.com/OSC/ondemand/pull/1600).
- passenger_options now works correctly in [#1793](https://github.com/OSC/ondemand/pull/1793).
- File uploads now respect setgid in [1851](https://github.com/OSC/ondemand/pull/1851).
- Fix uploaded correctly set umasks other than 0022 in [1845](https://github.com/OSC/ondemand/pull/1845).
- Home directories can now change in [1854](https://github.com/OSC/ondemand/pull/1854).
- Activejobs now correctly sorts the time column in [2420](https://github.com/OSC/ondemand/pull/2420).
- Some sites can now disable the shell option for BC apps in [2425](https://github.com/OSC/ondemand/pull/2425), fixing [722](https://github.com/OSC/ondemand/issues/722).
- The job composers' setup script now recoginizes a 0 byte file and attempts to fix it in [2461](https://github.com/OSC/ondemand/issues/2461).
- The file browser now filters files with non-utf-8 characters in [2626](https://github.com/OSC/ondemand/issues/2626).
- Safari disables form select options because it cannot hide them in [2640](https://github.com/OSC/ondemand/issues/2640).
- RSS MOTD correctly read feeds from a url in [2681](https://github.com/OSC/ondemand/issues/2681).
- SyntaxErrors in announcements safely rescue in [2647](https://github.com/OSC/ondemand/pull/2647).

### Security

- SVGs, being unsafe to preview, are now downloaded in [1435](https://github.com/OSC/ondemand/pull/1435)
  and [1437](https://github.com/OSC/ondemand/pull/1437)
- Selinux updates in [1496](https://github.com/OSC/ondemand/pull/1496).
- nginx APIs now validate the redirect on stop requests in [#1775](https://github.com/OSC/ondemand/pull/1175).
- Nginx PUNs correclty start with minimal environment in [2157](https://github.com/OSC/ondemand/pull/2157)

## [2.1.0] - 03-09-2023

Similar changelog as [3.0.0]. This version was not released to the general public and indeed was renamed 3.0.0.

## [2.0.32] - 03-27-2023

### Fixed

- Hterm has been updated to v91 in [2632](https://github.com/OSC/ondemand/pull/2632) to add support for
  more utf-8 characters.
- The files app correctly filters filenames with non-utf-8 characters in their name in
  [2626](https://github.com/OSC/ondemand/pull/2626).

## [2.0.31] - 02-07-2023

### Fixed

- The linux Host adapter is now compatabile with apptainer in [2548](https://github.com/OSC/ondemand/pull/2548).

## [2.0.30] - 02-02-2023

### Fixed

- Dynamic batch connect apps correctly clamp to 0 in [2413](https://github.com/OSC/ondemand/pull/2413).

### Added

- Maintanence pages can serve assets in [2436](https://github.com/OSC/ondemand/pull/2436).

## [2.0.29] - 10-31-2022

### Fixed

- Maintanence pages are no longer the default 503 pages in [2202](https://github.com/OSC/ondemand/pull/2202).
- Open terminal buttons do not appear when ssh to compute node is turn off in [2210](https://github.com/OSC/ondemand/pull/2210).
- Fujitsu TCS shows in active jobs in [2208](https://github.com/OSC/ondemand/pull/2208).
- Libraries use SHA1 instead of MD5 to support FIPS systems in [2328](https://github.com/OSC/ondemand/pull/2328).
- Dynamic batch connect now allows for multiple min & max settings in [2337](https://github.com/OSC/ondemand/pull/2337).
- Dynamic batch connect correctly handles keys with / in them in [2340](https://github.com/OSC/ondemand/pull/2340).

### Changed

- Open OnDemand now relies on NodeJS 14 (up from 12 which is EOL) in [2316](https://github.com/OSC/ondemand/pull/2316).
- The job composer now allows for copy environment setting in [2324](https://github.com/OSC/ondemand/pull/2324).
- Upgrade to ood_core 0.22.0 in [2349](https://github.com/OSC/ondemand/pull/2349).
  - This adds the `vnc_container` batch connect template.

## [2.0.28] - 08-01-2022

### Fixed

- `passenger_options` are now safe to use in [2016](https://github.com/OSC/ondemand/pull/2016).
- Interactive jobs now have compatability with turbovnc 3.0+ in [2153](https://github.com/OSC/ondemand/pull/2153).
  Through the `ood_core` update.
- PUNs now start with only the environment variables required in [2156](https://github.com/OSC/ondemand/pull/2156).

### Added

- Support for Ubuntu 20.04 packages was added in [2141](https://github.com/OSC/ondemand/pull/2141).
- Support for Ubuntu 18.04 packages was added in [2160](https://github.com/OSC/ondemand/pull/2160).
- Support for `fujitsu_tcs` scheduler also through the `ood_core` update.
- Dex can now be proxied behind Apache in [2183](https://github.com/OSC/ondemand/pull/2183).

## [2.0.27] - 06-23-2022

### Fixed

- Correctly set `passenger_temp_path` under `tmp_root` in [2096](https://github.com/OSC/ondemand/pull/2096).

## [2.0.26] - 06-02-2022

### Fixed

- The shell app now correctly skips `cluster.d` files it cannot read in [2057](https://github.com/OSC/ondemand/pull/2057).

### Security

- Rack dependency has been updated to 2.2.3.1 in [2063](https://github.com/OSC/ondemand/pull/2063).

## [2.0.25] - 05-20-2022

### Fixed

- 2.0 now depends on a more specific ondemand-passenger ondemand-nginx versions in [2043](https://github.com/OSC/ondemand/pull/2043).

## [2.0.24] - 05-19-2022

### Fixed

- Dynamic form widgets with min and max settings will now correctly initialize in [2014](https://github.com/OSC/ondemand/pull/2014).
- The shell app now correctly skips `cluster.d` files it cannot read in [1988](https://github.com/OSC/ondemand/pull/1988).

### Changed

- Releases will now be added to Zenodo in [2039](https://github.com/OSC/ondemand/pull/2039)

### Security

- Rails has been updated to 5.2.8 up from 5.2.6.x in [2029](https://github.com/OSC/ondemand/pull/2029).
- Passenger has been updated to 6.0.14 in [2026](https://github.com/OSC/ondemand/pull/2026)

## [2.0.23] - 03-02-2022

### Changed

- Bump ondemand-runtime dependency for bigdecimal gem in [1807](https://github.com/OSC/ondemand/pull/1807).

### Fixed

- nginx_stage can now identify when a username has a @domain in it from SSSD. There are issues
  When username have domains in them. [1852](https://github.com/OSC/ondemand/pull/1852) identifies
  this and throws an appropriate error message.
- File uploading now correctly sets the file permissions in [1853](https://github.com/OSC/ondemand/pull/1853).

### Security

- Uppy upgrade to 2.0 in [1804](https://github.com/OSC/ondemand/pull/1804).

## [2.0.22] - 2021-12-21

### Fixed

- Back-ported [1676](https://github.com/OSC/ondemand/pull/1676) to correctly hide options
  with hyphens.

## [2.0.21] - 2021-12-20

### Fixed

- Dynamic javascript now correctly clamps values correcting [1649](https://github.com/OSC/ondemand/issues/1649).
- Dynamic javascript can hide multiple elements correcting [1666](https://github.com/OSC/ondemand/issues/1666).
- Dynamic javascript now correctly handles options with numbers, hyphens and underscores
  back-porting [1656](https://github.com/OSC/ondemand/pull/1656).

## [2.0.20] - 2021-12-01

### Security

- Removed Index from Public RootOptions as to not allow Directory Indexing in [1617](https://github.com/OSC/ondemand/issues/1617).

### Fixed

- Fixed lua warnings `bad argument #2 to 'date'` in [1627](https://github.com/OSC/ondemand/pull/1627).
- Uppy claims failure but upload succeeds. This has been fixed in [1600](https://github.com/OSC/ondemand/pull/1600)
  by extending the timeout.

### Added

- Batch connect apps can now have dynamic behaviour through configuration in [1639](https://github.com/OSC/ondemand/pull/1639).
  This means we now ship a lot of functionality that sites previously had to code themselves in `form.js`.
  This introduces the `OOD_BC_DYNAMIC_JS` that sites must set to enable this feature.

## [2.0.19] - 2021-10-29

### Fixed

- Fixed CSS issue where the noVNC range sliders looked washed out and hard to notice - 
  [1384](https://github.com/OSC/ondemand/issues/1384). 
- Selinux updates mostly for k8s - [1497](https://github.com/OSC/ondemand/pull/1497)

### Added

- Add tmpfiles.d file for ondemand-nginx - [1501](https://github.com/OSC/ondemand/pull/1501)
- Initialize k8s - [1493](https://github.com/OSC/ondemand/pull/1493)

## [2.0.18] - 2021-10-06

### Security

- The svg patch in 2.0.17 needs to account for files with .SVG (all caps) extensions too.

## [2.0.17] - 2021-10-05

### Security

- .svg files in the file browser are now being forced to be downloaded as they could
  contain malicous javascript that would execute in the browser within a site's context.

## [2.0.16] - 2021-08-25

### Fixed

- Fixed an issue with non US keyboards could not use `+` keys in the shell app -
  [1214](https://github.com/OSC/ondemand/issues/1214).
- Fixed Ganglia panels visually and semantically - [1031](https://github.com/OSC/ondemand/issues/1031).
- Fixed error messages in creating invalid files - [1322](https://github.com/OSC/ondemand/issues/1322).
- Fixed removing files when allowlists are in place - [1337](https://github.com/OSC/ondemand/issues/1337).

### Added

- RPM building and e2e testing in several pull requests.
  - [1329](https://github.com/OSC/ondemand/pull/1329)
  - [1340](https://github.com/OSC/ondemand/pull/1340)

### Changed

- Sessions stores can now be overridden in [1321](https://github.com/OSC/ondemand/pull/1321).
- upgraded `ood_core` from v0.17.4 to v0.17.6.

## [2.0.15] - 2021-08-11

### Fixed

- Fix RPM builds to work with top-level Gemfile changes

## [2.0.14] - 2021-08-10

### Fixed

- Files app shell buttons now correctly redirect to the given cluster in [1317](https://github.com/OSC/ondemand/pull/1317).
- Locales now correctly fallback to english in [1314](https://github.com/OSC/ondemand/pull/1314).
- Manifest YAMLs are now read safely in [1325](https://github.com/OSC/ondemand/pull/1325).

### Changed

- Updated `ood_core` to v0.17.4.

### Added

- Development container tooling in [1305](https://github.com/OSC/ondemand/pull/1305).

## [2.0.13] - 2021-07-16

### Fixed

- Fixed in `OOD_NAVBAR_TYPE` bug in [1283](https://github.com/OSC/ondemand/pull/1283).
- `kubectl` commands no longer log to syslog in [1290](https://github.com/OSC/ondemand/pull/1290).
- `rake test` works directly now without having to force `RAILS_ENV` in [1285](https://github.com/OSC/ondemand/pull/1285).

### Changed

- Updated `ood_core` to v0.17.2.

## [2.0.12] - 2021-07-01

### Fixed

- Fixed [1273](https://github.com/OSC/ondemand/issues/1273) where the sessions page crashes when the
  db file contains a nonexistant cluster in [1247](https://github.com/OSC/ondemand/pull/1274).

## [2.0.11] - 2021-06-21

### Fixed

- File preview now correctly shows utf8 characters in [1254](https://github.com/OSC/ondemand/pull/1254).

### Changed

- Sites that enable user sharing now have to configure pinned apps to get them to show
  on the landing page in [1248](https://github.com/OSC/ondemand/pull/1248).

### Added

- Batch connect now respects cluster level settings enable sshing into the compute nodes
  in [1173](https://github.com/OSC/ondemand/pull/1173).
- Cluster shell access menu items are now internationalizeable in [916](https://github.com/OSC/ondemand/pull/916).


## [2.0.10] - 2021-14-06

### Fixed

- Fixed [1207](https://github.com/OSC/ondemand/issues/1207) a bug in the file editor that was saving
  0 byte files when the file being edited has UTF-8 encoded characters.
- Cosmetic fixes to the apps panels in [1213](https://github.com/OSC/ondemand/pull/1213) and
  [1217](https://github.com/OSC/ondemand/pull/1217).

### Added

- Asers can now download multiple files at a time in [1181](https://github.com/OSC/ondemand/pull/1181).
- Administrators can now configure `passenger_pool_idle_time` in [1209](https://github.com/OSC/ondemand/pull/1209).
- Administrators can now configure any passenger configuration in [1211](https://github.com/OSC/ondemand/pull/1211).

### Changed

- Updated ood_core to 0.17.1 in [1223](https://github.com/OSC/ondemand/pull/1223).

## [2.0.9] - 2021-26-05

### Fixed

- Fixed [1164](https://github.com/OSC/ondemand/issues/1164). Uploading directories
  now correctly uploads files and any subdirectories.
- Fixed [1109](https://github.com/OSC/ondemand/issues/1109). Active jobs buttons
  now pull to the left.

### Changed

- update to ood_core 0.17.0 in [1169](https://github.com/OSC/ondemand/pull/1169).

### Added

- `staged_root` is now available in the `submit.yml.erb`'s context completing
  [864](https://github.com/OSC/ondemand/issues/864).

## [2.0.8] - 2021-12-05

### Fixed

- Fixed an issue with hooks prefixing usernames in [1132](https://github.com/OSC/ondemand/pull/1132)

## [2.0.7] - 2021-12-05

### Fixed

- Fixed an issue the in the files app where the wrong file ownder was being shown in
  [1125](https://github.com/OSC/ondemand/pull/1125).

### Added

- Added some helper hook scripts in [995](https://github.com/OSC/ondemand/pull/995).

## [2.0.6] - 2021-11-05

### Fixed

- node and rnode proxies now gaurentees a URL in the request in
  [1105](https://github.com/OSC/ondemand/pull/1105).
- Uploading files now respects the users umask in [1110](https://github.com/OSC/ondemand/pull/1110).

### Changed

- Disable the audio bell in the shell by default in [1089](https://github.com/OSC/ondemand/pull/1089).
- Dashboard widgets are now expected to be in views/widgets in
  [1116](https://github.com/OSC/ondemand/pull/1116).
- pun_pre_hook now uses lua-posix to fork the apache process and set's environment instead
  of feeding nginx_stage stdin in [1091](https://github.com/OSC/ondemand/pull/1091).
- Removed the rails_12factor dependency in [1112](https://github.com/OSC/ondemand/pull/1112).

### Added

- Apps can now define the open in new window behaviour through their manifest in
  [1094](https://github.com/OSC/ondemand/pull/1094).
- Dalli is now added as a dependency to be provided for folks in ondemand-gems in
  [1102](https://github.com/OSC/ondemand/pull/1102).
- The files app can now choose which cluster to open in terminal in
  [1107](https://github.com/OSC/ondemand/pull/1107).
- The files app can now download a directory as a zip in [1108](https://github.com/OSC/ondemand/pull/1108).
- The files app now shows javascript, css and yaml as plain text
  in [1068](https://github.com/OSC/ondemand/pull/1068)

## [2.0.5] - 2021-27-04
### Fixed
- fix file editor bug with opening files with ampersands in their names [#1082](https://github.com/OSC/ondemand/pull/1082)
- files app to open terminal app in new window [#1083](https://github.com/OSC/ondemand/pull/1083)
- fix session card connection tab control that broke when session UUID started with a number [#1084](https://github.com/OSC/ondemand/pull/1084)

### Changed
- Session card element id's now have "id_" prefixing the session id, but attribute data-id is added with unmodified session id

## [2.0.4] - 2021-23-04
### Fixed
- Cosmetic and accessibility defects with XDMoD jobs widget [#1076](https://github.com/OSC/ondemand/pull/1076)

## [2.0.3] - 2021-23-04
### Fixed
- Change `HTTPD24_HTTPD_SCLS_ENABLED` back to default value since we no longer
  need SCL Ruby for user mapping [#1072](https://github.com/OSC/ondemand/pull/1072)
- Fix minor cosmetic defect on files favorites nav [#1074](https://github.com/OSC/ondemand/pull/1074)

## [2.0.2] - 2021-23-04

### Changed
- `ood_core` version bumped from 0.16.0 to 0.16.1. See
  [the ood_core's changelog](https://github.com/OSC/ood_core/blob/master/CHANGELOG.md) for details.
- Set a max PUN per app to 1 in [1069](https://github.com/OSC/ondemand/pull/1069)

## [2.0.1] - 2021-22-04
### Added
- The ability to add pinned apps to the dashboard along with a new menu item titled 'Apps' in 
  [870](https://github.com/OSC/ondemand/pull/870). This change also started added a new general
  purpose configuration file. It added the `pinned_apps` configuration item.
  Other additions to this feature are:
  - Pinned apps menu items are limited in the navbar in [894](https://github.com/OSC/ondemand/pull/894).
    This is configurable by `pinned_apps_menu_length`.
  - Pinned apps can be configured through globs in [898](https://github.com/OSC/ondemand/pull/898).
  - Pinned apps can be configured through app manifest data like category, subcategory or metadata
    in [912](https://github.com/OSC/ondemand/pull/912) and [939](https://github.com/OSC/ondemand/pull/939)
  - This widget has an internationalizable header in [921](https://github.com/OSC/ondemand/pull/921).
  - The string 'Pinned Apps' is internationalizable in [992](https://github.com/OSC/ondemand/pull/992).
  - Pinned apps can be grouped by known fields in [996](https://github.com/OSC/ondemand/pull/996) and by
    metadata in [1026](https://github.com/OSC/ondemand/pull/1026). This adds the `pinned_apps_group_by`
    configuration item.
- Apps can now supply a metadata map in their mainfest files in [903](https://github.com/OSC/ondemand/pull/903).
- Read configurations from an ondemand.d directory in [893](https://github.com/OSC/ondemand/pull/893).
  This directory is configurable through the `OOD_CONFIG_D_DIRECTORY` environment variable.
- The shell app now supports themes in [630](https://github.com/OSC/ondemand/pull/630).
- The dashboard's landing page is now configurable. Users can redefine the layout of defined widgets
  and add entirely new widgets in [1038](https://github.com/OSC/ondemand/pull/1038). This adds the
  `landing_page_layout` configuration item.

### Fixed
- Webpacker now uses it's own yarn in tmp in [862](https://github.com/OSC/ondemand/pull/862).
- Nginx no longer returns the versions in the Server and X-Powered-By headers in [891](https://github.com/OSC/ondemand/pull/891).
- All rails apps now use the secure cookies in [897](https://github.com/OSC/ondemand/pull/897).
- Corrected a broken link in the footer in [899](https://github.com/OSC/ondemand/pull/899)
- Users can now speicfy the dex frontend theme in [929](https://github.com/OSC/ondemand/pull/929).
- Users with specialized conda environments will no longer have issues launching an XFCE desktop
  in [942](https://github.com/OSC/ondemand/pull/942).
- Potential XSS with the Job composer in [949](https://github.com/OSC/ondemand/pull/949).
- Wrong link to docs in ood-portal.conf comments in [1010](https://github.com/OSC/ondemand/pull/1010).
- ood-portal-generator now supports Oracle Linux in [1049](https://github.com/OSC/ondemand/pull/1049).
- Job composer can now store more than 1000 workflows which would previously cause crashes 
  in [1039](https://github.com/OSC/ondemand/pull/1039).

### Changed
- The all apps page is now a table instead of panels holding lists in [884](https://github.com/OSC/ondemand/pull/884).
  - This table also shows metadata fields in [924](https://github.com/OSC/ondemand/pull/924).
- Upgraded the dashboard to bootstrap 4 in [991](https://github.com/OSC/ondemand/pull/991).
- Upgreaded all rials apps to 2.2.5 in [1014](https://github.com/OSC/ondemand/pull/1014).
- The active jobs app is now a part of the dashboard instead of it's own webapp in
  [1034](https://github.com/OSC/ondemand/pull/1034). This breaks some previous behaviour regarding
  this app. See the PR's initial comment for details.
- The files app has been completely replaced in [1040](https://github.com/OSC/ondemand/pull/1040)
  and is now a part of the dashboard. The file-editor was also migrated in into the dashbaord in
  this change. The old files app's source files were removed in [1051](https://github.com/OSC/ondemand/pull/1051).
- The PUN will now redirect old app URLs to new apps in [1056](https://github.com/OSC/ondemand/pull/1056).
- `ood_core` version bumped from 0.15.0 to 0.16.0. See
  [the ood_core's changelog](https://github.com/OSC/ood_core/blob/master/CHANGELOG.md) for details.

## [2.0.0] - 2021-02-03

### Added
- support `markdown_erb` and `txt_erb` MOTD formats [#647](https://github.com/OSC/ondemand/pull/647)
- A pre hook that runs as root before the PUN starts [#535](https://github.com/OSC/ondemand/pull/535)
- end-to-end test in rake tasks that build containers [#695](https://github.com/OSC/ondemand/pull/695)

### Fixed
- escape html in activejobs table [#739](https://github.com/OSC/ondemand/pull/739)
- don't use cached cluster value in session form cache if it is no longer a valid value
  [#748](https://github.com/OSC/ondemand/pull/748) [#761](https://github.com/OSC/ondemand/pull/761)
- ensure LOGNAME set to PUN user [#836](https://github.com/OSC/ondemand/pull/836)

### Changed
- move regex mapping to Lua [#729](https://github.com/OSC/ondemand/pull/729) which removes
  the need to make Apache aware of SCL Ruby and not rely on system Ruby to launch the mapping
  script
- upgrade dependencies nginx to 1.18.0 and passenger to 6.0.7
- upgrade dependencies ruby 2.5.5 => 2.7.1 and bundler 1.17.3 => 2.1.4
- upgrade dependency nodejs 10 => 12
- upgrade dependency sqlite3 to 3.26.0 (will ship custom SCL for newer sqlite3 build)
- add ondemand-dex to the Dockerfile in [#727](httpqs://github.com/OSC/ondemand/pull/727)
- start using GitHub actions instead of Travis CI [#742](https://github.com/OSC/ondemand/pull/742)
  [#743](https://github.com/OSC/ondemand/pull/743) [#747](https://github.com/OSC/ondemand/pull/747)
- move JOSS publication to OSC/ondemand repo

## [1.8.20] - 2020-04-14
### Fixed
- Ensure that LOGNAME is set correctly in the PUN in [837](https://github.com/OSC/ondemand/pull/837).
- Remove unused SELinux dependencies in [853](https://github.com/OSC/ondemand/pull/853).
- Fixed specifiying dex custom frontend themes in [930](https://github.com/OSC/ondemand/pull/930).

### Changed
- Hide Nginx and Passenger versions in the http headers in [892](https://github.com/OSC/ondemand/pull/892).
- Update to Rails 5.2.5 to avoid broken mimemagic dependency in [1028](https://github.com/OSC/ondemand/pull/1028).

## [1.8.19] - 2020-12-14
### Fixed
 - don't use cached cluster value if it's not available [#748](https://github.com/OSC/ondemand/pull/748)
 - fix accessability of buttons in active jobs table [#732](https://github.com/OSC/ondemand/pull/732)

### Changed
- use specific versions of packaging repo in [#735](https://github.com/OSC/ondemand/pull/735)

## [1.8.18] - 2020-11-03
### Fixed
- [Fix name of setting security_csp_frame_ancestors](b7e115cfd35c6c2135c8935fe582fb77342dc7b6) in example ood_portal_example.yml file

## [1.8.17] - 2020-10-30
### Fixed
- build bin from nginx_stage gemspec which can end up placing the
  ruby/node/python wrappers in your PATH which causes issues
  [#719](https://github.com/OSC/ondemand/pull/719)

### Changed
- replace `security_disable_frames` with `security_csp_frame_ancestors` setting
  that lets you set the value of this header and defaults header to servername
  instead of none [#721](https://github.com/OSC/ondemand/pull/721)

## [1.8.16] - 2020-10-23
### Fixed
- accessibility: update html titles of apps to be a little more specific to reduce ambiguity [#698](https://github.com/OSC/ondemand/pull/698)

### Security
- properly escape user input by using Open3 capture methods [#702](https://github.com/OSC/ondemand/pull/702)
- by default, set Content Security Policy frame-ancestors: none for all requests, which can be disabled setting security_disable_frames: false in the ood_portal.yml [#697](https://github.com/OSC/ondemand/pull/697)
- by default, set HSTS if SSL is in use, which can be disabled setting security_strict_transport: false in the ood_portal.yml [#697](https://github.com/OSC/ondemand/pull/697)

## [1.8.15] - 2020-10-08
### Fixed
- replace text "XDMoD" with "Open XDMoD" in Job Composer

## [1.8.14] - 2020-10-06
### Added
- log formatting options for apache and nginx access logs [#677](https://github.com/OSC/ondemand/pull/677)

### Changed
- Changed language to 'Open XDMoD' [#687](https://github.com/OSC/ondemand/pull/687).
- Update to Rails 5.2.4.4 and ood_core 0.14.0 [#690](https://github.com/OSC/ondemand/pull/690).
- ood_core 0.14.0 additions
   - Added: Kubernetes adapter in PR [156](https://github.com/OSC/ood_core/pull/156)
   - Fixed: Handle Slurm timeouts [209](https://github.com/OSC/ood_core/pull/209)
   - Fixed: Linux Host Adapter race condition in deleteing tmp files [212](https://github.com/OSC/ood_core/pull/212)

### Fixed
- Fixed XDMoD queries for staff users [#688](https://github.com/OSC/ondemand/pull/688).

## [1.8.13] - 2020-09-21
### Changed
- make it easier to develop info.html.erb in batch connect apps by gracefully handling crashes and now rendering template from the app root instead of storing a copy of the template in the session [#666](https://github.com/OSC/ondemand/pull/666)

### Added
- can load .rb locale files alongside .yml files [#645](https://github.com/OSC/ondemand/pull/645)
- warn users about job composer links to XDMoD jobs being broken immediately after job starts [#676](https://github.com/OSC/ondemand/pull/676)

### Fixed
- ignore bad cache key values when updating from batch connect form cache [#655](https://github.com/OSC/ondemand/pull/655)
- properly escape characters in Go To dialog in Files app [#660](https://github.com/OSC/ondemand/pull/660)
- force update Files app dependencies using yarn resolutions [#661](https://github.com/OSC/ondemand/pull/661)
- accessibility: hide FA icons from screen readers and use real title in app link list [#667](https://github.com/OSC/ondemand/pull/667)
- xdmod widgets utilize available space when no motd displays [#676](https://github.com/OSC/ondemand/pull/676)

## [1.8.12] - 2020-08-18
### Added
- mod_auth_openidc option for setting OIDCCookieSameSite in ood-portal-generator using
  "oidc_cookie_same_site: On" or "oidc_cookie_same_site: Off" [#651](https://github.com/OSC/ondemand/pull/651)

### Fixed
- default "oidc_cookie_same_site: On" if SSL not enabled so Chrome browser works
  (useful for ood-images) [#651](https://github.com/OSC/ondemand/pull/651)

## [1.8.11] - 2020-08-10
### Added
- grafana config: allow changing the cluster config name when the cluster in OOD differs from the cluster in Grafana [#639](https://github.com/OSC/ondemand/pull/639)
- latest ood_core provides CCQ adapter
- Dex default theme is the ondemand theme so this doesn't have to be configured manually [#635](https://github.com/OSC/ondemand/pull/635)

### Fixed
- job composer staged_dir guard clauses prevent crash [#637](https://github.com/OSC/ondemand/pull/637)
- colors for queued and starting panels changed to differ from completed panels [#636](https://github.com/OSC/ondemand/pull/636)
- clarify Powershell is option for setting up SSH tunnel for Native VNC Windows tab [#638](https://github.com/OSC/ondemand/pull/638)

## [1.8.10] - 2020-08-05
### Fixed
- Fixed a dependency bug in dotwi [#110 on the dotiw repo](https://github.com/radar/distance_of_time_in_words/issues/110).

## [1.8.9] - 2020-08-05
### Changed
- specified clusters in app to support glob expressoins [#617](https://github.com/OSC/ondemand/pull/617)

### Added
- extended view support for SGE [#520](https://github.com/OSC/ondemand/pull/520)
- Native VNC connection tab for OOD can be enabled for sites external to OSC [#625](https://github.com/OSC/ondemand/pull/625)
- Ability to control which batch connect apps or app attrs use cache to preset values [#539](https://github.com/OSC/ondemand/pull/539)
- ood_core 0.12.0 additions
   - qos option to Slurm and Torque [#205](https://github.com/OSC/ood_core/pull/205)
   - native hash returned in qstat for SGE adapter [#198](https://github.com/OSC/ood_core/pull/198)
   - option for specifying `submit_host` to submit jobs via ssh on other host [#204](https://github.com/OSC/ood_core/pull/204)

### Fixed
- support glob style wildcard in host names for OOD_SSHHOST_ALLOWLIST [#601](https://github.com/OSC/ondemand/pull/601)
- ood_core 0.12.0 fixes
   - SGE handle milliseconds instead of seconds when milliseconds used [#206](https://github.com/OSC/ood_core/issues/206)
   - Torque's native "hash" for job submission now handles env vars values with spaces [#202](https://github.com/OSC/ood_core/pull/202)

### Removed
- Safari compatibility alert for BasicAuth [#608](https://github.com/OSC/ondemand/issues/608)

### Security
- use handlebars in files app to prevent XSS
- update files app dependencies ponse, express, jquery
- ensure default Dex generated secret is stored in file with secure permissions

## [1.8.8] - 2020-07-22
### Fixed
- Revert the commit that made XDMoD SSO timeout configurable, which introduced a bug [#607](https://github.com/OSC/ondemand/pull/607)

## [1.8.7] - 2020-07-21
### Fixed
- Add back support for DEFAULT_SSHHOST env var in shell app [#603](https://github.com/OSC/ondemand/pull/603)
- Replace accidental hardcoded OSC XDMoD host [#604](https://github.com/OSC/ondemand/pull/604)

## [1.8.6] - 2020-07-20
### Added
- Configuration for XDMoD auto-login timeout [#597](https://github.com/OSC/ondemand/pull/597)

### Fixed
- Handle edge case in job efficiency widget where no data
  available [#597](https://github.com/OSC/ondemand/pull/597)
- Fix XDMoD auto-login iframe trick to properly hide and position
  iframe so form button clicks in iframe still work
  [#596](https://github.com/OSC/ondemand/pull/596)
- Fix bug where `cluster: ""` in batch connect app resulted in unhandled exception [#593](https://github.com/OSC/ondemand/pull/593)

## [1.8.5] - 2020-07-16
### Fixed
- Broken tests introduced with redirect URIs in Dex [#592](https://github.com/OSC/ondemand/pull/592)

## [1.8.4] - 2020-07-16
### Added
- Support for additional redirect URIs in Dex config [#591](https://github.com/OSC/ondemand/pull/591)

## [1.8.3] - 2020-07-16
### Changed
- Shell App: use OOD_SSHHOST_ALLOWLIST instead of SSHHOST_WHITELIST [#582](https://github.com/OSC/ondemand/pull/582)

### Added
- Dex config generator now supports configuring multiple static clients [#589](https://github.com/OSC/ondemand/pull/589)

## [1.8.2] - 2020-07-13
### Changed
- Retain the BC panel after a job completes [559](https://github.com/OSC/ondemand/pull/559)
- XMDOD panels to use SSO, removing perf & summary widgets and added job efficiency widget
  [578](https://github.com/OSC/ondemand/pull/578) and [580](https://github.com/OSC/ondemand/pull/580)

### Added
- Added jest for shell testing suite [577](https://github.com/OSC/ondemand/pull/577)
- Added Sinatra gems into ondemand-gems for other apps to use [579](https://github.com/OSC/ondemand/pull/579)

### Fixed
- default_sshost is added to the shell's allowlist [564](https://github.com/OSC/ondemand/pull/564)

## [1.8.1] - 2020-07-06
### Fixed
- ondemand-dex binary location in /usr/sbin not /usr/local [#566](https://github.com/OSC/ondemand/pull/566).

## [1.8.0] - 2020-07-06
### Added
- Chinese localization for "Mainland China simplified characters"
  [#477](https://github.com/OSC/ondemand/pull/477), thank you [@374365283](https://github.com/374365283)
  and [@summerwang](https://github.com/summerwang)
- Specify the default login host in the cluster config
  [#508](https://github.com/OSC/ondemand/issues/508)
- Control nginx max upload size by setting byte size in nginx_stage.yml
  using configuration option `nginx_file_upload_max` and the files app will now respect this
  [#502](https://github.com/OSC/ondemand/pull/502)
- Add an info.md.erb (or info.html.erb) to the root of any batch connect app
  to display extra information. the context for the erb is the session and the rendered
  string is passed through a markdown renderer
  [#556](https://github.com/OSC/ondemand/pull/556)
- Configure a single batch connect app to submit to multiple different clusters, either
  in form.yml or submit.yml:
  [#524](https://github.com/OSC/ondemand/pull/553)
  [#536](https://github.com/OSC/ondemand/pull/536)
  [#538](https://github.com/OSC/ondemand/pull/538)
  [#553](https://github.com/OSC/ondemand/pull/553)
- Streamlined Copy and Paste for Chrome
  [#537](https://github.com/OSC/ondemand/pull/537)
- Dockerfile for help with development [#309](https://github.com/OSC/ondemand/pull/309)
- Configurable logo height using OOD_DASHBOARD_LOGO_HEIGHT set to a value like `100px` which
  enables using SVG for logos on the dashboard
- Add TurboLinks dependeny to the dashboard in decrease loading time
  [498](https://github.com/OSC/ondemand/pull/498)

### Changed
- Shell app now requires every host it will connect to to be whitelisted
  defaulting to hosts in colon delimited SSHHOST_WHITELIST env var or every
  host specified in the login section of each cluster config
  [#507](https://github.com/OSC/ondemand/issues/507)
- Switch from BasicAuth to Dex for default authentication
  [#474](https://github.com/OSC/ondemand/pull/474)

## [1.7.14] - 2020-05-27
### Fixed
- Safari bug that broke noVNC [#516](https://github.com/OSC/ondemand/pull/516).

## [1.7.13] - 2020-05-27
### Fixed
- update to latest ood_core, 0.11.4 (up from 0.11.3) for SLURM bug fixes in [#193](https://github.com/OSC/ood_core/pull/193).
- updated rails to 5.2.4.3 (up from 5.2.4.2) for security vulnerabilites in several rails libraries.

### Added
- KDE bc_desktop in [#482](https://github.com/OSC/ondemand/pull/482)

## [1.7.12] - 2020-05-12
### Fixed
- Fix nginx_clean --user --force to properly force kill PUN [#485](https://github.com/OSC/ondemand/issues/485)
- Linux Host Adapter: fix to work when a user's default shell is not bash [#187](https://github.com/OSC/ood_core/issues/187)
- Linux Host Adapter: fix issue with wrong arguments passed to pstree [#188](https://github.com/OSC/ood_core/pull/188)

## [1.7.11] - 2020-04-23
### Fixed
- update to latest `ood_core` patch version to fix calls to
  LinuxHost#info_where_owner, particularly by the Active Jobs app

## [1.7.10] - 2020-04-08
### Fixed
- fix bug with file favorite URLs being incorrectly set in dropdown [#472](https://github.com/OSC/ondemand/pull/472)

## [1.7.9] - 2020-04-03
### Fixed
- remove deprecated Dashboard version string from footer
  [#467](https://github.com/OSC/ondemand/issues/467)
- fix hiding the joy ride script which is meant to be hidden in the DOM on the
  bottom of the page, not visible [#466](https://github.com/OSC/ondemand/issues/466)

## [1.7.8] - 2020-04-03
### Fixed
- fix use of ActiveSupport::Inflector#parameterize in Rails 5.1+ [#71](https://github.com/OSC/osc_machete_rails/pull/71) and [commit cbb8b19](https://github.com/OSC/osc_machete_rails/commit/cbb8b1949ac971b8f34877a64c3d86c9f33a5fb5)
- update Rails patch version for dependency security updates [#463](https://github.com/OSC/ondemand/pull/463)
- update Job Composer schema file to be Rails 5.2 compliant [#463](https://github.com/OSC/ondemand/pull/463)

## [1.7.7] - 2020-03-30
### Fixed
- Use legal job names in job submission rake task [#341](https://github.com/OSC/ondemand/issues/341) and [#355](https://github.com/OSC/ondemand/pull/355)
- Support sanitizing job names of batch connect apps with `OOD_JOB_NAME_ILLEGAL_CHARS` env var [#429](https://github.com/OSC/ondemand/pull/429)
- Add CSRF protection via CSRF token and Origin checking when creating shell app
  websocket connection [#444](https://github.com/OSC/ondemand/commit/1816de76fdf8bcec21d5f9619f5a3a09ff8db01d)
  and [#452](https://github.com/OSC/ondemand/pull/452)
- Fix JoyRide tooltip positioning for the Job Composer [#396](https://github.com/OSC/ondemand/pull/396)

### Changed
- Regenerate `ood_portal.conf` whenever Apache is restarted [#371](https://github.com/OSC/ondemand/pull/371).
  This means you can edit `/etc/ood/config/ood-portal.conf` and restart Apache and your change should take effect.
- Upgrade Rails to version 5.2 (from 4.2)
  * Dashboard [#374](https://github.com/OSC/ondemand/pull/374)
  * Active Jobs [#378](https://github.com/OSC/ondemand/pull/378)
  * Job Composer [#385](https://github.com/OSC/ondemand/pull/385)
  * File Editor [#440](https://github.com/OSC/ondemand/pull/440)
- Upgrade noVNC to 1.1.0 (from 1.0) in [#428](https://github.com/OSC/ondemand/pull/440)
  and [#431](https://github.com/OSC/ondemand/pull/431)

### Added
- Title to Favorite Paths dropdown [#418](https://github.com/OSC/ondemand/pull/418) and
  [#432](https://github.com/OSC/ondemand/pull/432)
- Action column with delete button in active jobs [#423](https://github.com/OSC/ondemand/pull/423)
- Alert for invalid clusters [#427](https://github.com/OSC/ondemand/pull/427)
- Configurable SSH Wrapper for Shell app @baverhey [#406](https://github.com/OSC/ondemand/pull/406)
- Regenerate ood-portal.conf when apache starts or reloads [#371](https://github.com/OSC/ondemand/pull/371)
- Maintenance Mode for OnDemand [#370](https://github.com/OSC/ondemand/pull/370)

## [1.7.6] - 2019-12-20
### Fixed
- Remove Async ClipboardAPI (noVNC copy/paste hack) due to noVNC freezes [#356](https://github.com/OSC/ondemand/pull/356)
- Fix missing favicon [#322](https://github.com/OSC/ondemand/pull/322)
- Remove hidden/dot files from JobComposer's file list [#346](https://github.com/OSC/ondemand/pull/346)

## [1.7.5] - 2019-12-11
### Added
- use Async ClipboardAPI for better copy and paste with Chrome and NoVNC [#335](https://github.com/OSC/ondemand/pull/335)
- restrictions on what can be set as a job script in Job Composer to mitigate
  problem with accidently choosing input file as job script [#310](https://github.com/OSC/ondemand/pull/310)

### Fixed
- fix URL used for file-editor assets [#343](https://github.com/OSC/ondemand/pull/343)

## [1.7.4] - 2019-12-04
### Added
- Addition of LinuxHost adapter to the Dashboard

### Fixed
- Fixed bug where an unreadable cluster config (e.g. due to file permissions) would cause crashes

## [1.7.3] - 2019-12-03
### Added
- `-u/--user` flag to `nginx_stage nginx_clean` subcommand [#315](https://github.com/OSC/ondemand/pull/315)
- enable admin to disable shell link to compute node by setting env var
  `OOD_BC_SSH_TO_COMPUTE_NODE` to falsy value (0, false, off) [#306](https://github.com/OSC/ondemand/issues/306)

### Changed
- rewrite SELinux support by running as `ood_pun_t` context instead of `httpd_t`
  context [#319](https://github.com/OSC/ondemand/pull/319)

### Fixed
- ensure `BUNDLE_USER_CONFIG` is set to `/dev/null` when the dashboard executes
  the per user setup script for an app [#318](https://github.com/OSC/ondemand/pull/318)
- include development and test gems in production build so OnDemand developers
  can develop against existing gem set [#326](https://github.com/OSC/ondemand/pull/326)
- Fix font awesome icon usage for activejobs [#323](https://github.com/OSC/ondemand/issues/323)

## [1.7.2] - 2019-11-19
### Added
- Job Compser and ActiveJobs now respect same navbar branding configuration as Dashboard @zooley [#101](https://github.com/OSC/ondemand/pull/101)
- running core app unit tests in Travis CI [#303](https://github.com/OSC/ondemand/pull/303)
- support for radio buttons in batch connect apps [#139](https://github.com/OSC/ondemand/pull/139)
- branding to Job Composer and Active Jobs that match Dashboard [#101](https://github.com/OSC/ondemand/pull/101)

### Changed
- rewrote ood-portal-generator in Ruby with automated tests [#108](https://github.com/OSC/ondemand/pull/108)

### Fixed
- SELinux policy issues exposed when installing at external site [#110](https://github.com/OSC/ondemand/issues/110) and [#112](https://github.com/OSC/ondemand/issues/112)
- Shell app now uses en_US.UTF-8 as LANG @jasonbuechler [#308](https://github.com/OSC/ondemand/pull/308)
- ignore comments when comparing Apache configs in ood-portal-generator [#100](https://github.com/OSC/ondemand/issues/100)

## [1.7.1] - 2019-11-04
### Added
- shellcheck static analysis of shell scripts

### Changed
- monorepo: add all core apps to main repo
- start installing app gems to a `GEM_HOME` under /opt/ood that is built into a separate ondemand-gems rpm
- upgrade Dashboard to Rails 5

### Fixed
- fix window.opener vulnerability found by Google's Lighthouse @zooley [#88](https://github.com/OSC/ondemand/pull/88)
- accessibility fixes exposed using Deque's aXe utility @zooley [#89](https://github.com/OSC/ondemand/pull/89)
- optimize some included pngs using ImageOptim app @zooley [#91](https://github.com/OSC/ondemand/pull/91)
- add missing closing tag to missing home directory error page @zooley [#92](https://github.com/OSC/ondemand/pull/92)

## [1.7.0] - 2019-10-14
### Added
- update Dashboard to add account balance warnings & dev mode icon picker
- for new installs, sudoers.d/ood script now includes `env_keep` for all env
  vars starting with `NGING_STAGE_` or `OOD_`
- add support for CentOS/RHEL8

### Changed
- drop support for CentOS/RHEL6
- upgrade to Ruby 2.5, Node 10, and Passenger 6

## [1.6.20] - 2019-10-14
### Fixed
- fix bug to ensure `update_ood_portal` installs new config if existing
  ood-portal.conf matches checksum [#83](https://github.com/OSC/ondemand/pull/83)

## [1.6.19] - 2019-10-09
### Added
- ability to set separate proxy server for rewrite rules in ood-portal-generator config
  https://github.com/OSC/ondemand/blob/4e2614917fac74e861908ca189c42a21e8895518/ood-portal-generator/share/ood_portal_example.yml#L18-L22 fixing [#73](https://github.com/OSC/ondemand/issues/73) - thank you @wdpypere

## [1.6.18] - 2019-10-09
### Fixed
- stop shell app from changing directory to the home directory prior to initiating ssh connection
  which [introduced a crash when the home directory does
  not exist](https://discourse.osc.edu/t/custom-home-directory-broken-after-upgrade-to-1-6-x/518)
  when we upgraded the shell app's pty dependency

## [1.6.17] - 2019-09-26
### Fixed
- ensure ood-portal.conf generated on new install [#65](https://github.com/OSC/ondemand/issues/65)

## [1.6.16] - 2019-09-25
### Fixed
- debian fix for bin/setup in Active Jobs and Dashboard
- use latest ondemand release RPM
- fixed exit codes for `update_ood_portal` script

## [1.6.15] - 2019-09-24
### Fixed
- files app updated for Lustre copy bugfix

## [1.6.14] - 2019-09-19
### Fixed
- files, file editor, job composer apps all get fix in bin/setup for output redirection
- files app gets cachebusting fix for "FancyBox" so images show newest version of file

## [1.6.13] - 2019-09-19
### Fixed
- Depend on system git instead of rh-git29 which is an EOL SCL
- Generate a checksum file when running `update_ood_portal` to avoid overwriting the Apache config `ood-portal.conf` if the file contains manual modifications

## [1.6.12] - 2019-09-11
### Fixed
- Reverted use of Rsync in Files app; use of Rsync caused resource exhaustion on the web nodes when file copies took longer than 1 minute

## [1.6.11] - 2019-08-30
### Fixed
- Fixed bug in the File Explorer when attempting to copy directories on a Lustre FS; a side effect of this fix is that copy-progress messages are no longer sent to the client

## [1.6.10] - 2019-08-27
### Fixed
- Upgraded dependencies for multiple apps

## [1.6.9] - 2019-08-20
### Fixed
- Fixed bug where user's login shell was always set to Bash inside desktop sessions

## [1.6.8] - 2019-08-13
### Fixed
- Fixed issue in Dashboard where older browsers (IE) could not connect to VNC sessions [ood-dashboard](https://github.com/OSC/ood-dashboard/issues/479)

## [1.6.7] - 2019-06-28
## Added
- Added ability to disable RewriteEngine

## [1.6.6] - 2019-06-25
### Fixed
- Cache bust for `ood_shell.js`

## [1.6.5] - 2019-06-20
### Changed
- Added new check to enable developer mode in Dashboard

### Fixed
- Fixed bugs with Firefox and MS Edge in the Shell

## [1.6.4] - 2019-06-16
### Added
- Added VNC quality and compression controls to Dashboard
- Added link to compute node that a VNC job is running on in the Dashboard

### Changed
- Changed 'Open in Terminal' button to offer multiple options when `OOD_SSH_HOSTS` is set in the File Explorer

### Fixed
- Fixed possible crash when running the Job Composer for the first time
- Fix sorting of cluster dropdown ([#168](https://github.com/OSC/ood-activejobs/issues/168))

## [1.6.3] - 2019-05-21
### Fixed
- Fixed translation bug in Dashboard

## [1.6.2] - 2019-05-15
### Fixed
- Fixed another translation issue in Dashboard

## [1.6.1] - 2019-05-15
### Fixed
- Fixed crashing bug in Dashboard

## [1.6.0] - 2019-05-10
### Added
- Added ability to render HTML or Markdown in job template manifests ([#278](https://github.com/OSC/ood-myjobs/issues/278))
- Added I18n hooks to Job Composer for Job Options with an initial OSC/English locale
- Added job array support for PBSPro and LSF
- Added placeholder for job array in job options

### Changed

- Changed Shell to use the maintained `node-pty` instead of `pts.js`
- Slurm adapter now returns `nil` instead of `'(null)'` for `OodCore::Job::Info#account_id`
- Updated Gems to address CVEs
- `nginx_stage` changed to always remove (and report removal of on `stderr`) stale Passenger PID and socket files ([#11](https://github.com/OSC/ondemand/issues/11))

### Fixed
- Disabled warning in Job Composer about Gems not being eager loaded
- Fixed a crash in nginx_stage relating to numeric values in pun_custom_env
- Fixed Active Jobs showing `'null'` when for `OodCore::Job::Info#account_id` was nil
- Fixed Active Jobs showing integer Time Used instead of `HH:MM:SS`
- Fixed bug in `ood_core` live system test
- Fixed bug with Slurm adapter when submit time is not available
- Fixed bug with the live system test that impacted non-LSF systems
- Fixed issue where Slurm comment field might break job info parsing
- Fixed layout bug in Job Composer ([#290](https://github.com/OSC/ood-myjobs/issues/290))
- Fixed possible crash when comparing two clusters if the id of one of the clusters is nil
- Job Composer with Grid Engine will attempt to detect if the user has set the working directory, and if not will set it (matching behavior of other adapters)
- Prevent long job names from breaking the Job Composer layout ([#290](https://github.com/OSC/ood-myjobs/issues/290))
- Fixed bug where using integers as values in `pun_custom_env` caused a `TypeError` ([#26](https://github.com/OSC/ondemand/issues/26))

## [1.5.5] - 2019-02-18
### Added
- Added app title to noVNC launch button to Dashboard
- Added BatchConnect app version to new session form
- Added I18n hooks for Dashboard with an initial OSC/English locale
- Added OOD and Dashboard version to footer
- Added support for fetching quota from a URL
- Allow BatchConnect applications to raise errors that can be shown to users

### Fixed
- Fixed bug in Active Jobs that broke when cluster configs changed
- Fixed bug in File Explorer when `OOD_SHELL` was an empty string
- Handled file not found errors with Announcements and MOTDs
- Updated Gems to address CVEs

## [1.5.4] - 2019-02-07
### Fixed
- Fixed bug in Active Jobs that broke Ganglia graphs

## [1.5.3] - 2019-02-7
### Changed
- Always load the default profile in nginx_stage as we now use the new ondemand SCL
- Include RUBYLIB in the env vars that are declared in the nginx config to be preserved
- Updated Activejobs, Dashboard, and Job Composer to reduce app load time

## [1.5.2] - 2019-01-31
### Added
- RPM friendly execution mode of update_ood_portal script when
  running from rpm [#27](https://github.com/OSC/ondemand/pull/27)

## [1.5.1] - 2019-01-30
### Fixed
- updated infrastructure components to point to new ondemand-nginx paths

## [1.5.0] - 2019-01-30 [YANKED]
### Added
- Dasboard
  - version string to footer
  - add support for localization of home page welcome text and motd title with added setup to be able to add support for more localization options in the future
  - the home page html (both logo and text) can now be customized using a single html formatted string in /etc/ood/config/locales/en.yml with the welcome_html key
- JobComposer
  - submit jobs using job array in job options (for supported adapters)

### Fixed
- ActiveJobs
  - ensure base URI for XHR requests are always correct
- Job Composer
  - handle job arrays submitted through app gracefully for Torque, Slurm, and SGE

### Changed
- ActiveJobs
  - XHR response is now "streamed" and handled using oboe.js to progressively update the view, so when viewing all jobs from all clusters you see jobs from one cluster at a time instead of waiting for them all to be transferred
  - no longer filter out array jobs for Torque, Slurm and SGE since these are now supported
  - no longer pre-sort jobs so user's jobs appear first when loading all jobs
  - use more Rails conventional url for getting all jobs (index.json)

## [1.4.10] - 2019-01-11
### Fixed
- Fixed error in ood_core that caused crashes in MyJobs with a SGE cluster
- Fixed issue with displaying launch button with invalid Batch Connect apps [#435](https://github.com/OSC/ood-dashboard/pull/435)
- Fixed error where users were unable to rename/move files using the FileExplorer [#186](https://github.com/OSC/ood-fileexplorer/issues/186)

### Changed
- Updated ood_core to newest in all core apps

## [1.4.9] - 2018-12-31
### Fixed
- Update Dashboard to improve Quotas

## [1.4.8] - 2018-12-31
### Fixed
- Update Dashboard to fix a divide by zero error when a resource is not limited

## [1.4.7] - 2018-12-26
### Fixed
- Update Dashboard, Active Jobs, and Job Composer to use latest version of `ood_core` for bug fixes to SGE and Torque adapters

## [1.4.6] - 2018-12-21
### Changed
- Reverting a change which may cause Apache configs to be replaced

## [1.4.5] - 2018-12-19
### Added
- Set `OOD_DEV_APPS_ROOT` env var to the parent directory of a user's dev app, so that the Dashboard and other apps will know where dev apps are deployed to, since this is a configuration that will likely differ from site to site
- Default and customizable error page for missing home directory so sites that use pam_mkhomdir.so to create the home directory for new users on login can have a sensible first login flow via OnDemand ([see Discourse discussion](https://discourse.osc.edu/t/launching-ondemand-when-home-directory-does-not-exist/53/7))

### Changed
- Change user tmpdir location to fix upload error due to default permissions on /var/lib/nginx being more restrictive in NGINX 1.14 [#16](https://github.com/OSC/ondemand/pull/16)
- Use same version string for all components, which will be this OnDemand version
- Error reporting for missing home directory occurs after launch of PUN (the error is reported as a change to the PUN config) instead of aborting the launch of the PUN

## [1.4.4] - 2018-12-04
### Added
- `nginx_stage` generates a per user a `secret_key_base.txt` file containing a secure random 128 char string and sets `SECRET_KEY_BASE` env var to this string so that each user's Rails app now more securely can encrypt cookies
- ability to define arbitrary env var name and value pairs in `nginx_stage.yml` config file
- ability to define an arbitrary list of env vars to declare in the PUN config (so they are retained from whatever is set in /etc/ood/profile)
- distinct default profile file at /opt/ood/nginx_stage/etc/profile so this can optionally be sourced by custom /etc/ood/profile

### Changed
- Update `nginx_stage` to work with Passenger 5 and NGINX 1.14
- Since NGINX 1.14 now strips environment, we explicitly pass these env vars to NGINX: `PATH LD_LIBRARY_PATH X_SCLS MANPATH PCP_DIR PERL5LIB PKG_CONFIG_PATH PYTHONPATH XDG_DATA_DIRS SCLS`
- Default path to developer apps are stored at `/var/www/ood/apps/dev/%{owner}/gateway/%{name}`, requiring a symlink to be generated by a developer to enable developer mode

### Fixed
- Fix bug where if you set `ONDEMAND_TITLE` and `ONDEMAND_PORTAL` in nginx_stage.yml config file you can end up with different values set in `OOD_PORTAL` and `OOD_DASHBOARD_TITLE`

## [1.4.3] - 2018-10-19
### Fixed
- Handle spaces in domain groups correctly: https://github.com/OSC/ondemand/commit/09c22c5f0960b39b30167830e23cf3010a91fc44

### Changed
- Switched to monorepo for infrastructure components, archiving old repos for `nginx_stage`, `ood_auth_map`, `mod_ood_proxy`, `ood-portal-generator`
- Updated SCL dependencies to rh-ruby24, rh-git29, rh-nodejs6

## [1.4.2] - 2018-9-14
### Added
- Changelog being added in 1.4.5 but backfilling history to 1.4.2

### Changed
- From 1.3.7 - 1.4.2 updated app versions

[Unreleased]: https://github.com/OSC/ondemand/compare/v3.0.1...HEAD
[3.0.1]: https://github.com/OSC/ondemand/compare/v3.0.0...v3.0.1
[3.0.0]: https://github.com/OSC/ondemand/compare/v2.0.32...v3.0.0
[2.1.0]: https://github.com/OSC/ondemand/compare/v2.0.31...v2.1.0
[2.0.32]: https://github.com/OSC/ondemand/compare/v2.0.31...v2.0.32
[2.0.31]: https://github.com/OSC/ondemand/compare/v2.0.30...v2.0.31
[2.0.30]: https://github.com/OSC/ondemand/compare/v2.0.29...v2.0.30
[2.0.29]: https://github.com/OSC/ondemand/compare/v2.0.28...v2.0.29
[2.0.28]: https://github.com/OSC/ondemand/compare/v2.0.27...v2.0.28
[2.0.27]: https://github.com/OSC/ondemand/compare/v2.0.26...v2.0.27
[2.0.26]: https://github.com/OSC/ondemand/compare/v2.0.25...v2.0.26
[2.0.25]: https://github.com/OSC/ondemand/compare/v2.0.24...v2.0.25
[2.0.24]: https://github.com/OSC/ondemand/compare/v2.0.23...v2.0.24
[2.0.23]: https://github.com/OSC/ondemand/compare/v2.0.22...v2.0.23
[2.0.22]: https://github.com/OSC/ondemand/compare/v2.0.21...v2.0.22
[2.0.21]: https://github.com/OSC/ondemand/compare/v2.0.20...v2.0.21
[2.0.20]: https://github.com/OSC/ondemand/compare/v2.0.19...v2.0.20
[2.0.19]: https://github.com/OSC/ondemand/compare/v2.0.18...v2.0.19
[2.0.18]: https://github.com/OSC/ondemand/compare/v2.0.17...v2.0.18
[2.0.17]: https://github.com/OSC/ondemand/compare/v2.0.16...v2.0.17
[2.0.16]: https://github.com/OSC/ondemand/compare/v2.0.15...v2.0.16
[2.0.15]: https://github.com/OSC/ondemand/compare/v2.0.14...v2.0.15
[2.0.14]: https://github.com/OSC/ondemand/compare/v2.0.13...v2.0.14
[2.0.13]: https://github.com/OSC/ondemand/compare/v2.0.12...v2.0.13
[2.0.12]: https://github.com/OSC/ondemand/compare/v2.0.11...v2.0.12
[2.0.11]: https://github.com/OSC/ondemand/compare/v2.0.10...v2.0.11
[2.0.10]: https://github.com/OSC/ondemand/compare/v2.0.9...v2.0.10
[2.0.9]: https://github.com/OSC/ondemand/compare/v2.0.8...v2.0.9
[2.0.8]: https://github.com/OSC/ondemand/compare/v2.0.7...v2.0.8
[2.0.7]: https://github.com/OSC/ondemand/compare/v2.0.6...v2.0.7
[2.0.6]: https://github.com/OSC/ondemand/compare/v2.0.5...v2.0.6
[2.0.5]: https://github.com/OSC/ondemand/compare/v2.0.4...v2.0.5
[2.0.4]: https://github.com/OSC/ondemand/compare/v2.0.3...v2.0.4
[2.0.3]: https://github.com/OSC/ondemand/compare/v2.0.2...v2.0.3
[2.0.2]: https://github.com/OSC/ondemand/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/OSC/ondemand/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/OSC/ondemand/compare/v1.8.19...v2.0.0
[1.8.20]: https://github.com/OSC/ondemand/compare/v1.8.19...v1.8.20
[1.8.19]: https://github.com/OSC/ondemand/compare/v1.8.18...v1.8.19
[1.8.18]: https://github.com/OSC/ondemand/compare/v1.8.17...v1.8.18
[1.8.17]: https://github.com/OSC/ondemand/compare/v1.8.16...v1.8.17
[1.8.16]: https://github.com/OSC/ondemand/compare/v1.8.15...v1.8.16
[1.8.15]: https://github.com/OSC/ondemand/compare/v1.8.14...v1.8.15
[1.8.14]: https://github.com/OSC/ondemand/compare/v1.8.13...v1.8.14
[1.8.13]: https://github.com/OSC/ondemand/compare/v1.8.12...v1.8.13
[1.8.12]: https://github.com/OSC/ondemand/compare/v1.8.11...v1.8.12
[1.8.11]: https://github.com/OSC/ondemand/compare/v1.8.10...v1.8.11
[1.8.10]: https://github.com/OSC/ondemand/compare/v1.8.9...v1.8.10
[1.8.9]: https://github.com/OSC/ondemand/compare/v1.8.8...v1.8.9
[1.8.8]: https://github.com/OSC/ondemand/compare/v1.8.7...v1.8.8
[1.8.7]: https://github.com/OSC/ondemand/compare/v1.8.6...v1.8.7
[1.8.6]: https://github.com/OSC/ondemand/compare/v1.8.5...v1.8.6
[1.8.5]: https://github.com/OSC/ondemand/compare/v1.8.4...v1.8.5
[1.8.4]: https://github.com/OSC/ondemand/compare/v1.8.3...v1.8.4
[1.8.3]: https://github.com/OSC/ondemand/compare/v1.8.2...v1.8.3
[1.8.2]: https://github.com/OSC/ondemand/compare/v1.8.1...v1.8.2
[1.8.1]: https://github.com/OSC/ondemand/compare/v1.8.0...v1.8.1
[1.8.0]: https://github.com/OSC/ondemand/compare/v1.7.14...v1.8.0
[1.7.14]: https://github.com/OSC/ondemand/compare/v1.7.13...v1.7.14
[1.7.13]: https://github.com/OSC/ondemand/compare/v1.7.12...v1.7.13
[1.7.12]: https://github.com/OSC/ondemand/compare/v1.7.11...v1.7.12
[1.7.11]: https://github.com/OSC/ondemand/compare/v1.7.10...v1.7.11
[1.7.10]: https://github.com/OSC/ondemand/compare/v1.7.9...v1.7.10
[1.7.9]: https://github.com/OSC/ondemand/compare/v1.7.8...v1.7.9
[1.7.8]: https://github.com/OSC/ondemand/compare/v1.7.7...v1.7.8
[1.7.7]: https://github.com/OSC/ondemand/compare/v1.7.6...v1.7.7
[1.7.6]: https://github.com/OSC/ondemand/compare/v1.7.5...v1.7.6
[1.7.5]: https://github.com/OSC/ondemand/compare/v1.7.4...v1.7.5
[1.7.4]: https://github.com/OSC/ondemand/compare/v1.7.3...v1.7.4
[1.7.3]: https://github.com/OSC/ondemand/compare/v1.7.2...v1.7.3
[1.7.2]: https://github.com/OSC/ondemand/compare/v1.7.1...v1.7.2
[1.7.1]: https://github.com/OSC/ondemand/compare/v1.7.0...v1.7.1
[1.7.0]: https://github.com/OSC/ondemand/compare/v1.6.20...v1.7.0
[1.6.20]: https://github.com/OSC/ondemand/compare/v1.6.19...v1.6.20
[1.6.19]: https://github.com/OSC/ondemand/compare/v1.6.18...v1.6.19
[1.6.18]: https://github.com/OSC/ondemand/compare/v1.6.17...v1.6.18
[1.6.17]: https://github.com/OSC/ondemand/compare/v1.6.16...v1.6.17
[1.6.16]: https://github.com/OSC/ondemand/compare/v1.6.15...v1.6.16
[1.6.15]: https://github.com/OSC/ondemand/compare/v1.6.14...v1.6.15
[1.6.14]: https://github.com/OSC/ondemand/compare/v1.6.13...v1.6.14
[1.6.13]: https://github.com/OSC/ondemand/compare/v1.6.12...v1.6.13
[1.6.12]: https://github.com/OSC/ondemand/compare/v1.6.11...v1.6.12
[1.6.11]: https://github.com/OSC/ondemand/compare/v1.6.10...v1.6.11
[1.6.10]: https://github.com/OSC/ondemand/compare/v1.6.9...v1.6.10
[1.6.9]: https://github.com/OSC/ondemand/compare/v1.6.8...v1.6.9
[1.6.8]: https://github.com/OSC/ondemand/compare/v1.6.7...v1.6.8
[1.6.7]: https://github.com/OSC/ondemand/compare/v1.6.6...v1.6.7
[1.6.6]: https://github.com/OSC/ondemand/compare/v1.6.5...v1.6.6
[1.6.5]: https://github.com/OSC/ondemand/compare/v1.6.4...v1.6.5
[1.6.4]: https://github.com/OSC/ondemand/compare/v1.6.3...v1.6.4
[1.6.3]: https://github.com/OSC/ondemand/compare/v1.6.2...v1.6.3
[1.6.2]: https://github.com/OSC/ondemand/compare/v1.6.1...v1.6.2
[1.6.1]: https://github.com/OSC/ondemand/compare/v1.6.0...v1.6.1
[1.6.0]: https://github.com/OSC/ondemand/compare/v1.5.5...v1.6.0
[1.5.5]: https://github.com/OSC/ondemand/compare/v1.5.4...v1.5.5
[1.5.4]: https://github.com/OSC/ondemand/compare/v1.5.3...v1.5.4
[1.5.3]: https://github.com/OSC/ondemand/compare/v1.5.2...v1.5.3
[1.5.2]: https://github.com/OSC/ondemand/compare/v1.5.1...v1.5.2
[1.5.1]: https://github.com/OSC/ondemand/compare/v1.5.0...v1.5.1
[1.5.0]: https://github.com/OSC/ondemand/compare/v1.4.10...v1.5.0
[1.4.10]: https://github.com/OSC/ondemand/compare/v1.4.9...v1.4.10
[1.4.9]: https://github.com/OSC/ondemand/compare/v1.4.8...v1.4.9
[1.4.8]: https://github.com/OSC/ondemand/compare/v1.4.7...v1.4.8
[1.4.7]: https://github.com/OSC/ondemand/compare/v1.4.6...v1.4.7
[1.4.6]: https://github.com/OSC/ondemand/compare/v1.4.5...v1.4.6
[1.4.5]: https://github.com/OSC/ondemand/compare/v1.4.4...v1.4.5
[1.4.4]: https://github.com/OSC/ondemand/compare/v1.4.3...v1.4.4
[1.4.3]: https://github.com/OSC/ondemand/compare/v1.4.2...v1.4.3
[1.4.2]: https://github.com/OSC/ondemand/compare/v1.3.7...v1.4.2
