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
This deadline starts after signaling succeeds; it does not bound lock acquisition
or the nginx command itself. It is currently fixed, not a configuration option.

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

Disabled-user cleanup candidates come from **PID files and explicit
`<pun-config>.cleanup_pending` records**. Old configs, secrets and empty runtime
directories alone are not candidates. Historical metadata purging is not a
feature of this cleanup policy. Configured discovery paths support literal glob
characters and identical repeated `%{user}` fields, including numeric suffixes.

A private pending record is created beside the stable lifecycle lock before
shutdown can remove the PID. It remains until shutdown, secret/config deletion
and runtime-directory cleanup finish, allowing a later invocation to retry
partial failures even when the PID is gone. Shared PID parent directories and
lifecycle lock files are retained. Do not remove a pending record to suppress an
error; resolve the reported failure and rerun cleanup.

`--skip-nginx` reports candidates without signaling, probing sockets or deleting
files. With `--user`, only that selected user's state is modified. Candidate
account lookup still occurs during enumeration.

## Operator recovery

1. Check user **and primary-group lookup** health first. Cleanup currently treats
   `User.new` raising `ArgumentError` as a disabled account, even when LDAP/SSSD
   or group lookup is failing. Stop scheduled cleanup while investigating a
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
and nginx rereads PID files when signaling. `reload`/`reopen` keep their existing
locking behavior.

See [live lifecycle validation](docs/pun-lifecycle-validation.md) for the nginx/
Passenger checks required before claiming integration coverage. Outage-aware
account classification, configurable shutdown waits and stronger process identity
are separate hardening work; the current implementation does not claim those
guarantees.

## Contributing

1. Fork it ( https://github.com/OSC/ondemand/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
