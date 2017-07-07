## Unreleased

### Added

  - Added a unsupported browser alert for Safari by default due to Basic Auth
    and websocket issue.

### Fixed

  - Moved `batch_connect` dataroot to properly namespaced directory. [#188](https://github.com/OSC/ood-dashboard/issues/181)
  - Corrected file extension used for session context cache.

## 1.13.3 (2017-06-23)

### Fixed

  - Fallback to older noVNC for Safari browsers. [#177](https://github.com/OSC/ood-dashboard/issues/177)

## 1.13.2 (2017-06-23)

### Removed

  - Removed leftover stubbed files from a bygone era.
  - Removed verbiage on requesting reservation while iHPC session is queued. [#176](https://github.com/OSC/ood-dashboard/issues/176)

## 1.13.1 (2017-06-19)

### Fixed

  - Added back OSC Connect for Windows native VNC support.

## 1.13.0 (2017-06-14)

### Added

  - Integrated iHPC support into the dashboard. [#155](https://github.com/OSC/ood-dashboard/pull/155)

### Fixed

  - Ignore vim temporary files. [#161](https://github.com/OSC/ood-dashboard/issues/161)

## 1.12.0 (2017-06-05)

### Added

  - Add ability to use RSS/Markdown/Plaintext MOTD

### Fixed

  - Fix bug when OOD portal specified without site

### Removed

  - Remove unused assets
