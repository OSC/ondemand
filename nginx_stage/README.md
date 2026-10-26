# nginx_stage

![GitHub Release](https://img.shields.io/github/release/osc/nginx_stage.svg)
![GitHub License](https://img.shields.io/github/license/osc/nginx_stage.svg)

Stages and launches the per-user NGINX (PUN) processes for individual users. It
is also responsible for staging, listing, and cleaning up web application NGINX
configuration files, as well as listing and stopping running PUNs.

For more information please visit the
[Documentation](https://osc.github.io/ood-documentation/latest/reference/commands/nginx-stage/usage.html).

## Shutdown and replacement

PUN startup, app-config replacement, explicit `stop`/`quit`, and cleanup use a
stable per-user `<pun-config>.lock`. After successful shutdown signaling,
nginx_stage waits for **both the socket and PID paths to disappear**. This
includes disabled-user SIGTERM cleanup. Dangling symlinks count as occupied.

The wait polls every 0.1 second against a **30-second monotonic deadline**.
This deadline starts after signaling succeeds. It does not bound blocking
startup/replacement lock acquisition or the nginx command itself. It is currently fixed, not a configuration option.

A timeout returns an error without forcing termination or starting a replacement.
A graceful `quit` may have removed its socket while its master is still draining
websockets or Passenger requests. Startup stays blocked while that recorded
master is alive. Retry after it finishes. An administrator who has verified the
PUN and accepts interrupting its requests can explicitly request `stop`:

```bash
sudo nginx_stage nginx --user=exampleuser --signal=stop
```

This also validates the PID and waits for shutdown. Do not delete PID/socket
paths to bypass the startup guard. Missing or malformed PID state can require
operator investigation. Signals reject raw PID files over 22 bytes before
execution; PID syntax and liveness alone do not establish process identity.

Startup and cleanup also check process identity. A verified PUN master blocks
startup while draining even if its socket is gone. A PID reused by an unrelated
executable, another configured PUN master, a verified nginx worker or a kernel
thread does not block startup when the socket is absent; cleanup can remove
that stale PID file without signaling the unrelated process. Uncertain identity
is preserved with a diagnostic, including with `--force`.

All signals (`stop`, `quit`, `reload`, `reopen`, and disabled-user termination)
verify the running executable by inode or protected upgrade provenance, the
exact per-user nginx master command/configuration, and its effective UID. Signaling uses
the same open `/proc/PID` directory descriptor used to read identity. It does
not use numeric-PID `kill` or invoke `nginx -s`, so PID reuse or a later PID-file
change cannot redirect the signal. nginx process titles are not a security
boundary against a malicious privileged process; configured roots remain trusted.

Safe signaling requires Linux `pidfd_send_signal` support (upstream Linux 5.1
or a compatible backport), readable procfs in the caller's PID namespace, and
x86_64, aarch64 or ppc64le. There is no unchecked fallback on unsupported systems.
Before deploying this signaling path on a native EL8 host or VM, run the
capability probe as the same administrator/service identity that runs nginx_stage:

```bash
cd nginx_stage
bundle exec ruby test/native/check_pun_signal_support.rb
```

The probe uses signal zero on its own process directory descriptor. It checks
that the actual kernel and syscall policy accept the API; it does not terminate
any process or establish permission to signal every PUN. A nonzero exit blocks
compatibility acceptance. A container on a newer host is not an EL8 kernel test.
Also exercise stop/quit, reload/reopen, cleanup and executable replacement with
an isolated PUN on each supported native kernel before release. EL8 backport
availability must be established on that kernel; its version string alone does
not prove support. Unsupported or denied signaling preserves PUN state and
requires a supported kernel/policy, without falling back to a numeric PID.

The Ubuntu CI unit-test matrix sets `OOD_REQUIRE_NATIVE_PUN_TESTS=1`, making
unavailable native process or Unix-socket coverage fail instead of skip. Native
process specs use the production capability probe, and CI also runs the script
above. Other local runs may skip native examples when capabilities are unavailable.

Executable replacement remains identifiable when the running inode is unlinked
at the exact configured canonical executable path, or is retained at its exact
`.old` or `.dpkg-tmp` backup path. Retired and replacement files must have the
same owner and exclude group/other writes. The process must still have the exact
expected master command/configuration and effective UID. A deleted marker or a
matching basename alone never authorizes a signal. During dpkg hard-link
backup replacement, the exact regular `.dpkg-tmp` file must match the retired
executable by device/inode and meet the ownership and permission checks. Unexpected binary locations,
changed symlink targets or unexpected nginx launch commands remain uncertain.
A process name or UID alone is not accepted as identity.
`nginx --skip-nginx --signal=...` describes the requested
signal without printing a runnable unchecked `nginx -s` command.
Successful `reload`/`reopen` reports signal delivery; inspect the master log to
confirm that nginx accepted a reload. No separate nginx signal process parses
the configuration before delivery.

A dead recorded PID with an occupied socket path also blocks startup. Run
`nginx_stage nginx_clean --user=exampleuser` before retrying. Cleanup can remove
a confirmed stale socket; startup itself does not probe or delete socket state.

## Cleanup and retries

`nginx_clean` normally stops PUNs with no active connections. `--force` ignores
the connection count but retains PID validation and socket safety checks. A live
master whose socket has already disappeared is preserved. Cleanup decisions,
signaling, metadata deletion and per-user runtime-directory removal remain under
the lifecycle lock.

When the recorded master is dead, an actual socket that refuses a nonblocking
connection can be removed after its type, device and inode are rechecked. A
listening socket may belong to surviving orphaned workers and is preserved.
Symlinks, ordinary files, full backlogs, permission errors and other inconclusive
probe results are preserved. A malformed active-user PID file can be removed
only beside an absent or confirmed stale socket; symlinked malformed PIDs are
preserved.

Disabled-user cleanup candidates come from **PID/socket paths and explicit
`<pun-config>.cleanup_pending` records**. Old configs, secrets and empty runtime
directories alone are not candidates. Historical metadata purging is not a
feature of this cleanup policy. Configured discovery paths support literal glob
characters and identical repeated `%{user}` fields, including numeric suffixes.
Literal directory text matching the internal username placeholder is supported;
discovery chooses a placeholder absent from each configured path's literal text.
Cleanup also discovers socket-only accounts. For a resolvable account with no
PID file, it removes only a confirmed stale socket under the lifecycle lock and
preserves configuration and secrets. A listening or uncertain socket is retained
with a diagnostic. The ordinary PID-based user listing remains unchanged.

A private pending record is created beside the stable lifecycle lock before
shutdown can remove the PID. It remains until shutdown, secret/config deletion
and runtime-directory cleanup finish, allowing a later invocation to retry
partial failures even when the PID is gone. Shared PID parent directories and
lifecycle lock files are retained. If the account becomes resolvable again,
cleanup cancels its safe pending record under the lifecycle lock and preserves
the remaining PUN state. This also applies to accounts restored before the
cleaner starts. Dry runs retain the record. Do not remove a pending record to
suppress an error; resolve the reported failure and rerun cleanup.

Cleanup attempts each lifecycle lock without blocking. A busy user is preserved
with a diagnostic, and cleanup continues with subsequent users. Startup and app
replacement continue to use blocking locks. This avoids queuing scheduled
cleanup and package-maintenance cleanup behind a stuck lifecycle operation.

Session detection checks command status and stderr. A clean procps status-1
result containing only its `CMD` header represents no selected processes;
other unsuccessful results preserve the PUN. `--force` bypasses session detection.

`--skip-nginx` reports a snapshot without signaling, probing sockets, deleting
files, or creating/acquiring lifecycle locks. With `--user`, only that selected
user's state is modified. Candidate account lookup still occurs during enumeration.

## Operator recovery

### Configuration path or executable changes

Stop existing PUNs before changing `pun_config_path`, `nginx_bin`, or the
symlink target used by `nginx_bin`. Verification compares the running master's
launch configuration path and executable with the current settings. Changing
configuration contents at the same path does not itself change that identity.
Supported package replacement at the same executable path is handled separately
by the upgrade checks described above.

Preserve the original `nginx_stage.yml` and its executable/runtime paths before
a migration. If the settings have already changed, a targeted invocation with
that saved configuration can recover a master that still meets all identity
checks:

```bash
sudo env NGINX_STAGE_CONFIG_FILE=/root/nginx_stage.before-migration.yml \
  nginx_stage nginx --user=exampleuser --signal=stop
```

Use an administrator-owned, protected configuration file with the original
`nginx_bin`, `pun_config_path`, `pun_pid_path`, and `pun_socket_path` settings.
Confirm that the service profile does not replace `NGINX_STAGE_CONFIG_FILE`.
The command still verifies the executable, complete master title and effective
UID, then waits for shutdown. It does not authorize a process merely because
the old configuration was supplied. If the old executable path is unavailable,
the executable provenance is unsupported, or process metadata is unreadable,
investigate the reported identity failure before taking further action.

Coordinate migration across every cooperating startup, restart and cleanup
caller before using the saved settings. Changing `pun_config_path` also changes
the lifecycle lock path, so commands using the old and new settings must not run
concurrently against the same PUN. Stop automatic cleanup and prevent new
requests from starting PUNs during that maintenance window. After the old PUNs
have stopped, enable the new settings and resume normal operation. Keep stable
lock files; do not delete PID/socket files to bypass verification.

### Other uncertain runtime state

1. Check user **and primary-group lookup** health first. Cleanup currently treats
   an unresolved account as disabled. It preserves state when a passwd record
   still exists but full user/group lookup fails. A complete LDAP/SSSD outage
   can still be mistaken for deletion. Stop scheduled cleanup while investigating a
   directory-service outage; a dry run does not make the classification reliable.
2. Record the warning and configured PID, socket, config, lock and pending-record
   paths. Inspect ownership, permissions and symlinks without following unknown
   targets. Do not include secret contents in diagnostics.
3. Establish whether the original master or orphaned workers still serve the
   socket. A PID's existence, process name or UID alone is not sufficient proof
   of identity. Correlate the configured PUN, process tree, command line, start
   times, open files and listener information. If the verified master is draining, wait or explicitly request
   `stop` if interruption is acceptable. Preserve any live orphaned listener.
4. Rerun targeted cleanup after resolving the cause:

   ```bash
   sudo nginx_stage nginx_clean --user=exampleuser
   ```

   Normal safe stale-state recovery and pending retries then apply. For remaining
   ambiguous state, an administrator must first establish that no master, worker
   or competing startup owns the affected paths before repairing those specific
   entries. There is no general safe command to blindly delete inconsistent state.

The lock excludes cooperating nginx_stage operations, not external writers.
Configured lock, retry-record and runtime roots must exclude untrusted writers.
The socket identity recheck does not make unlink atomic against external changes,
and identity checks do not exclude an external privileged process changing its
own executable. `reload`/`reopen` keep their existing locking behavior.

See [live lifecycle validation](docs/pun-lifecycle-validation.md) for the nginx/
Passenger checks required before claiming integration coverage. Outage-aware
account classification and configurable shutdown waits remain separate work.

## Contributing

1. Fork it ( https://github.com/OSC/ondemand/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
