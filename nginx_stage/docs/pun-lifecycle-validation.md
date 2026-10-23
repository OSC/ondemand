# Live PUN lifecycle validation

Run these checks with the patched nginx_stage and the nginx/Passenger versions
that will be deployed. Use dedicated staging accounts and private test data.
Signals, account removal and interrupted requests in this procedure affect those
test PUNs. Do not run the procedure against production users.

The normal RSpec suite models signals and connection results. It does not
establish Passenger drain timing, process identity or filesystem behavior under
an external writer. A plain nginx experiment must be reported separately from a
Passenger run. Neither is a substitute for the other.

## Record the environment

Record the OnDemand commit, Ruby, nginx and Passenger versions, module build,
operating system, configured `nginx_stage.yml`, and how Passenger was loaded.
Use the configured nginx binary's `-V` output to identify its modules. Do not
record secret values or unrelated users' environment variables.

Resolve the actual PID, socket, config, secret and lock paths from the staging
configuration before starting. Record ownership and permissions. Use a short
runtime root so a test does not accidentally exceed the Unix socket path limit.
Do not modify global production configuration to shorten a test path.

Set the account name only after creating a dedicated account with a valid shell,
home, primary group and UID permitted by the staging configuration:

```bash
pun_test_user=ood_lifecycle_test
getent passwd "$pun_test_user"
```

Resolve its primary group too. Confirm that the installed nginx_stage is the
patched version. Before each scenario, record the PID file contents privately,
master/worker PID tree, process start times, socket entry and listening state.
Use `ps`, `stat`, `ss -xlpn` or an equivalent platform tool, and the PUN's logs.
A process name or UID alone does not establish ownership. Never select processes
with a broad `pkill -f` pattern or signal a PID copied from an unverified file.

Record command start/end times, exit status, standard error and the order in
which the socket and PID entries disappear. Keep background command output in
regular log files. Orphaned workers can inherit a pipe and keep its reader open,
which can make a test appear to hang after the command itself has completed.

## Scenarios and required observations

| Scenario | Procedure | Required observation |
| --- | --- | --- |
| Concurrent startup | With no existing test PUN, issue two `nginx_stage pun --user=...` commands concurrently. Inspect both results and the process tree. | Only one master becomes the active PUN. The second request must not overwrite runtime state belonging to that master. |
| App replacement | Exercise an actual staging app-config regeneration while another startup or replacement request is queued. Use a real installed app rather than an invented app path. | Stop, shutdown waiting and replacement are serialized. The new PID remains present after the old master exits, and the new PUN can subsequently be stopped normally. |
| Immediate stop | Start the test PUN, then run `nginx_stage nginx --user=... --signal=stop`. | Success is reported only after both socket and PID entries disappear. A failed nginx command must not launch a replacement. |
| Passenger graceful drain | Open a real long-lived Passenger request or websocket, run `--signal=quit`, and observe both paths and the master. Repeat with the client closing before and after 30 seconds. | A socket disappearing first does not release startup while the master remains alive. A drain beyond 30 seconds produces a timeout, preserves the PID and releases the lifecycle lock. |
| Startup after timeout | While the preceding master still drains, try both normal `pun` startup and direct `nginx` startup. Then close the client, wait for the old master to finish, and retry startup and stop. | Both entry points reject replacement while the old master lives. After shutdown completes, startup and a later stop succeed; the old master never removes the replacement's PID. |
| Whole-PUN crash | Identify the dedicated master and all workers. Kill only those verified test processes, leaving PID/socket entries. Run targeted cleanup. | The refused stale socket and dead PID are removed. A subsequent normal startup succeeds. |
| Surviving workers | Kill only the verified test master while workers continue serving. Confirm service through the existing socket, then run targeted cleanup, including a separate `--force` attempt. | The live listener and its path remain usable. Cleanup does not unlink it or start a competing PUN. |
| Disabled-user cleanup | For a disposable test account only, disable its directory lookup using the staging account provider. This means failure of account resolution, not merely setting a disabled login shell. Run targeted cleanup. | Lookup is rechecked after locking. A valid recorded master receives SIGTERM; metadata deletion follows completed shutdown. No unrelated account is affected. |
| Interrupted metadata cleanup | Introduce a controlled, reversible deletion error for only the test user's secret or config, using permissions/ACLs appropriate to the test filesystem. Restore access and invoke a fresh cleaner. | A private `.cleanup_pending` record survives the failure and permits completion after the PID is gone. Repeat with a shared PID directory; the shared directory must remain. |
| Runtime-directory failure | Leave one unrelated test file in the per-user PID directory so both rmdir attempts fail. Remove that test file and run a fresh cleaner. | The file is preserved, the directory failure is reported, and the pending record permits a later retry. Directory removal remains serialized with competing startup. |
| Missing/invalid PID | In separate disposable fixtures, exercise malformed PID contents, an absent PID beside a live socket, and dangling symlinks. Do not place arbitrary process IDs in a live control file. | Signals reject invalid files before nginx execution. Live or uncertain sockets and symlinked malformed PID entries are preserved. Startup does not bypass ambiguous state. |
| Selection and dry run | Repeat representative cases with `--user=...` and `--skip-nginx`; snapshot runtime paths and metadata before and after. | Other users' state is unchanged. Dry runs signal nothing, make no probe connection and delete nothing. |

Typical control commands, after verifying the dedicated test account and paths:

```bash
sudo nginx_stage pun --user="$pun_test_user"
sudo nginx_stage nginx --user="$pun_test_user" --signal=quit
sudo nginx_stage nginx_clean --user="$pun_test_user"
sudo nginx_stage nginx_clean --user="$pun_test_user" --force
sudo nginx_stage nginx_clean --user="$pun_test_user" --skip-nginx
```

These are scenario commands, not a sequence to run blindly: create the specified
process/client state before each command. A quit timeout is an expected result
in the long-drain scenario. It must not be converted to success by deleting a
path or automatically sending another signal. An explicit `stop` is a separate
operator decision after confirming the target and accepting interrupted requests.

## Results and cleanup

For each scenario, record PASS, FAIL or NOT RUN, the actual command exit status,
path removal order, relevant process start times and a short explanation. A
stale socket test is not a pass unless the subsequent startup works. A timeout
recovery test is not a pass unless the replacement can later be stopped using
its own surviving PID file. Record unexpected warnings and differences between
nginx/Passenger versions rather than adjusting assertions to hide them.

Restore staging account-provider settings, permissions and ACLs. Stop only the
verified test processes. Preserve diagnostic evidence needed for failures, and
remove only the dedicated fixture paths after verifying that no master, worker,
client or competing startup still owns them. Retain normal lifecycle lock files.

Attach results to the human review. Keep live integration unchecked until the
nginx/Passenger scenarios have actual results. This document defines the
procedure; it is not evidence that a run occurred.

## Automated real-nginx checks and deployment gate

The unit-test CI job installs nginx and sets `OOD_TEST_NGINX_BIN` to run
`spec/nginx_stage/generator_nginx_integration_spec.rb`. Unlike the controlled-process
native tests, these checks launch a real foreground nginx with private paths.
They verify reload acceptance, invalid reload rejection with continued service,
log reopening after rotation, and stop/quit followed by a manageable replacement.
A rate-limited static request also exercises graceful-drain timeout, startup
rejection and recovery after the client closes. Private executable copies exercise
unlink, rename and dpkg hard-link upgrades. A surviving-worker case verifies
listener preservation and later stale-state recovery. These checks do not load Passenger.

Run the same checks on each supported deployment kernel and architecture, as
the administrator/service identity used for nginx_stage:

```bash
cd nginx_stage
bundle exec ruby test/native/check_pun_signal_support.rb
OOD_REQUIRE_NATIVE_PUN_TESTS=1 OOD_TEST_NGINX_BIN=/absolute/path/to/nginx \
  bundle exec rspec spec/nginx_stage/pun_process_native_spec.rb \
  spec/nginx_stage/generator_nginx_integration_spec.rb
```

Use a native VM or host for EL8 validation. An EL8 container sharing an Ubuntu
kernel does not establish EL8 kernel support. Record kernel release, CPU,
executable version and actual results for each supported target. Unsupported or
denied descriptor signaling must fail this gate; do not bypass the procfs check
or substitute numeric-PID signaling to obtain a passing result.

Passenger drain beyond the shutdown deadline, startup rejection during that
drain, and master death with surviving workers remain required staging scenarios
in the table above. Passing the automated plain-nginx checks does not mark those
scenarios complete.

## Failed session detection

Ordinary cleanup preserves a live PUN when the process-listing command times out,
exits unsuccessfully, or cannot execute. A clean procps status-1 result
containing only its `CMD` header is accepted as an empty selection. Partial output from a failed command is
not evidence of inactivity. The diagnostic identifies the affected user, and
cleanup continues with subsequent users. `--force` bypasses session detection,
including its failures, while retaining process identity and runtime safety checks.

## Busy cleanup locks and dry runs

Hold a dedicated test user's lifecycle lock, then run cleanup with that user and
another eligible candidate. Cleanup must promptly report the busy user, preserve
all of its state, and process the later candidate. Repeat for active, disabled,
and pending-record discovery. An explicit `--force` must not bypass a busy lock.
Dry runs inspect a snapshot without creating or acquiring lifecycle locks.
Startup and replacement retain blocking lock acquisition.

With a confirmed passwd record and a temporarily unavailable primary group,
disabled-user cleanup must preserve all state and any existing retry record.
This safeguard does not distinguish complete directory-service outages from
confirmed deletion; verify the account provider before disabled-user cleanup.

Before release, run the native capability and lifecycle checks with SELinux
enforcing and the deployed `ondemand-selinux` policy. Inspect audit diagnostics
for process metadata reads, descriptor signaling, and Unix socket probing. CI
containers sharing a host kernel do not establish these deployment results.
