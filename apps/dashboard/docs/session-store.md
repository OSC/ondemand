# Batch Connect session-store persistence

Session records are always written to a private temporary file, flushed, and
renamed over the destination on the same filesystem. Readers see a complete
old or new record rather than partially written replacement JSON. Temporary
files live in the private `.session-store` directory and are not enumerated as
session records. The JSON schema is unchanged; no migration is needed.

## Default: atomic replacement without advisory locking

`bc_session_store_locking` defaults to `false`. Creating, updating and deleting
records does not call `flock`, so deploying this change does not introduce an
advisory-locking requirement on users' home filesystems. Completion updates
skip a record that is already absent when checked; repeated deletion succeeds.

Without coordination, checking existence and renaming are separate operations:
a completion update can recreate a record deleted between those operations.
There is no cross-process snapshot or deletion-ordering guarantee in this mode.
Invalid records are logged and skipped, but left in place for manual inspection.
They are not renamed to `.bak`, because an unlocked quarantine could move a
newer valid replacement. Existing `.bak` files are still ignored.

Repeated errors for the same path, record contents and exception are suppressed
for five minutes within each Dashboard process, across store instances. Changed
failures are reported immediately; a successful read or an observed missing
record clears the path's history. The diagnostic cache holds at most 256 paths,
so eviction or process restart can cause earlier reporting. Other processes
maintain their own histories. This limits log repetition without moving records
or retaining their JSON contents in the diagnostic cache.

## Optional coordinated mode

After validating the filesystem and worker topology, enable coordination in
the Dashboard configuration:

```yaml
bc_session_store_locking: true
```

Alternatively set `OOD_BC_SESSION_STORE_LOCKING=true`. The environment setting
takes precedence over the configuration file. All workers accessing a database
must use the same setting. Stop the affected Dashboard processes before changing
the setting, then restart them with the consistent configuration; mixed modes
do not coordinate safely.

Coordinated mode uses a stable `.session-store/lock` inode and exclusive `flock`
locks for reading/quarantine, replacement and deletion. Completion updates
recheck record existence under the lock, preventing recreation after a
cooperating deletion. Scheduler calls remain outside the lock. Reads can
quarantine invalid records, so their critical section also needs exclusive
access. Do not remove or replace the lock inode while workers are using it.

All cooperating processes accessing a database must observe the same lock.
Local-only locks on separate hosts do not coordinate a shared database. Test
both lock exclusion and atomic rename on the actual shared filesystem and
process topology before enabling this option. A successful local `flock` call
alone does not establish cross-host exclusion. Direct external edits and older
OnDemand processes do not participate in this coordination.

If enabled locking reports `ENOLCK`, `ENOSYS` or `EOPNOTSUPP`, existing records
remain readable with a warning; invalid records are skipped without quarantine.
Completion cache updates are skipped, and expired records remain listed.
Creation and deletion fail before scheduler side effects when preflight detects
the lock failure. There is no automatic switch to unlocked writes. Restore
locking or stop and consistently reconfigure all workers to disable it.
Other I/O and permission errors continue to propagate normally.

## Failure recovery and durability

Submission prepares the temporary directory and, when enabled, checks locking
before contacting the scheduler. A scheduler call and a filesystem write are
not one transaction. If saving an accepted job's record fails, submission
returns an error containing the accepted job ID and save failure. The job is
not automatically cancelled, preserving the previous scheduler policy. Review
that ID in the scheduler before retrying; cancel it manually if appropriate.
If the scheduler accepts a job but raises before returning its ID, this store
cannot identify or recover that job.

Atomic visibility is not a power-loss durability guarantee. No file or directory
`fsync` is added here. Process death can also leave private temporary files.
Power-loss durability remains separate work.

## Temporary-file housekeeping

Cleanup is an explicit maintenance operation, with a preview by default and a
one-hour minimum age by default. Run it as the affected user from the installed
Dashboard directory, using the deployment's Ruby/Bundler and the same environment,
configuration and data root as that user's Dashboard:

```bash
RAILS_ENV=production bundle exec rails runner \
  'puts BatchConnect::Session.store.cleanup_temporary_files'
```

The output lists candidate paths. With coordinated mode enabled consistently
across all workers and validated filesystem locking, perform deletion with:

```bash
RAILS_ENV=production bundle exec rails runner \
  'puts BatchConnect::Session.store.cleanup_temporary_files(dry_run: false)'
```

Cleanup holds the same exclusive lock as writers until its scan and deletions
finish. An aged temporary file belonging to a suspended cooperating writer
cannot be removed while that writer holds the lock. There is no automatic scan
on every session write; schedule this maintenance only after validating its
cost and coordination on the deployment filesystem.

In the default unlocked mode, deletion refuses to proceed unless the operator
explicitly supplies `quiescent: true`. First stop all Dashboard processes and
other writers for the affected database, prevent requests from starting new
ones, and keep them stopped through cleanup. Then run:

```bash
RAILS_ENV=production bundle exec rails runner \
  'puts BatchConnect::Session.store.cleanup_temporary_files(dry_run: false, quiescent: true)'
```

The quiescent flag is an operator assertion, not a process detector. File age
alone does not establish abandonment. In both modes cleanup selects only old,
owned, single-link regular files with recognized Ruby `session-` temporary
names. It preserves the `lock` inode, symlinks, directories, hardlinks and
unrecognized entries. It rejects unsafe metadata directories and rechecks each
candidate's identity before unlinking. External writers that ignore the lock
must also be stopped; the identity recheck does not make unlink atomic against
arbitrary external replacement. The operation can leave older or unexpected
temporary naming formats for manual inspection.
