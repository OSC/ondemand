# Temporary CI diagnostics

This is a disposable debugging workflow, not a proposed production fix. It leaves the normal Tests workflow and all subject assertions unchanged.

## Run

Opening or updating a PR that changes this workflow or script directory starts two additional jobs: the full Ruby 3.4 Dashboard browser suite with seed 51445, and EL10 x86_64 package build/E2E tests. Existing workflows still run normally.

Both diagnostic jobs check out instrumentation from this debug PR and independently check out OSC/ondemand at the failed #5989 merge revision, da1b000b0a25e4883fd8d94ae83dc6fccac630e4. That distinction is intentional: the debug PR's master-based source is not substituted for the failed subject.

The workflow also declares workflow_dispatch inputs: subject_ref, suite (both/browser/package), browser_scope (full/files), and package_dist (el10/el8). GitHub requires the workflow to exist on the default branch for manual dispatch. A new unmerged workflow may therefore need the pull_request trigger initially. To change an unmerged debug PR's automatic defaults, edit the fallback ref/scope/distribution in this workflow and push that debug branch.

Use a full commit SHA for exact reproduction. A branch or refs/pull/.../merge tests whatever that ref resolves to at checkout; each job records the actual SHA.

Browser execution uses the original 1400x1400 headless Chrome settings, browser log collection and download profile, with the explicit Chrome/ChromeDriver 155.0.8059.39 pair. Ruby tracks the same 3.4 line as the original job; its exact resolved version is recorded. No no-sandbox flag, sandbox identity fixture, assertion retry or invalid-session rescue is added.

## Artifacts

Artifacts are retained for three days, including on failed runs:

- Per-stage command output, original exit status and before/after host snapshots.
- Periodic RSS/process-name, cgroup memory/OOM-event and PID counters.
- ChromeDriver protocol and stderr logs, Chrome stderr forwarded by the service, and available crash files.
- Per-example start, pre-teardown and finish events, with monotonic timestamps even when a test mocks Time.now. Pre-teardown events preserve the first recorded failure before screenshot/reset errors.
- Rails test.log and available screenshots/HTML. A dead session may prevent both browser captures.
- Docker version, selected daemon fields, container status, events, daemon journal and accessible kernel messages.
- Beaker/container logs if provisioning reached the point that produces them.

Permission failures in privileged diagnostic commands are retained as diagnostic limitations. A cancelled or forcibly terminated job may not finish every collection/upload step; no artifact guarantee is made for hard runner loss.

The collector does not dump environment variables, Docker credentials, full docker inspect output or process argv. The workflow does not request repository or Docker Hub secrets and checkout credentials are not persisted. Logs and crash files can still contain test data, so review artifacts before sharing them.

## Failure semantics

run.sh preserves the tested command's exit status through tee and best-effort collection. A failed collector cannot turn a failed command into success. No timeout is increased in the application/Docker client, no retry is added, and a dead Chrome session remains an error.

The workflow has job time limits of 30 minutes for browser diagnostics and 50 minutes for package diagnostics. Docker version/info/events and privileged journal/kernel reads have their own short time bounds.

## Validate helper behavior

From a Ruby environment with Minitest 5:

```bash
ruby script/ci-debug/test/diagnostics_test.rb
bash -n script/ci-debug/run.sh
bash -n script/ci-debug/collect.sh
shellcheck script/ci-debug/*.sh
actionlint .github/workflows/ci-debug.yml
```

The unit tests run real child commands through the wrapper and actual Minitest example lifecycles. The test fixture replaces only the collector with a tiny deterministic helper, so it does not invoke Docker or sudo while testing wrapper exit-status behavior.

## Investigation targets

- [Ruby 3.4 Chrome session loss](https://github.com/OSC/ondemand/actions/runs/40192225988/job/121165463110): determine the first renderer/browser failure and compare resource state, without treating later invalid-session errors as separate causes.
- [EL10 Docker/Beaker image-build timeout](https://github.com/OSC/ondemand/actions/runs/40192225988/job/121165463086): identify the stalled image-build operation before changing timeouts.
- [EL8 timeout for comparison](https://github.com/OSC/ondemand/actions/runs/40192190043/job/121165355529): select package_dist=el8 when manual dispatch is available or change the PR fallback.

Keep this branch unmerged and discard the instrumentation after identifying the failure. It does not resolve the underlying browser or provisioning failures.
