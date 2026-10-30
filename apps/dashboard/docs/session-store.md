# Batch Connect session records

Records use private temporary files in `.session-store`, flushed and renamed on
the same filesystem. Readers see complete old or new JSON; the schema is unchanged.
Disappearing records are skipped and repeated deletion succeeds. Completion updates
skip absent records. Atomic visibility does not guarantee power-loss durability:
there is no file or directory `fsync`, and process death can leave temporary files.

Advisory locking is **off by default**, so home filesystems need not support `flock`.
Unlocked reads leave corrupt records for inspection, avoiding quarantine of a newer
replacement. Completion can recreate a record deleted between its existence check
and rename. There is no coordinated snapshot or deletion-order guarantee.

To enable coordination, set `bc_session_store_locking: true` in Dashboard config or
`OOD_BC_SESSION_STORE_LOCKING=true` (environment takes precedence). First validate
atomic rename and lock exclusion on the actual filesystem and worker topology;
local `flock` success does not prove cross-host exclusion. Stop affected Dashboards
before changing modes and restart all workers consistently. Older processes and
external writers do not participate. Never unlink or replace `.session-store/lock`.

With locking enabled, reads/quarantine, writes and deletion use that stable exclusive
lock. Completion rechecks existence under it. Scheduler calls stay outside it.
`ENOLCK`, `ENOSYS` and `EOPNOTSUPP` permit read-only access without quarantine:
completion updates are skipped, expired sessions remain listed, and mutations fail.
Known failures stop submission/deletion before scheduler calls; enabled locking
never silently falls back to unlocked writes. Other I/O errors remain visible.

If saving an accepted job fails, submission reports its ID, save error and manual
recovery guidance; it does not cancel the job. Check the scheduler before retrying.
A job accepted without returning its ID cannot be recovered by this store.

Corrupt-record diagnostics remember at most 256 paths per Dashboard process.
Unchanged content/exception errors are logged once per five minutes across store
instances. Changed errors log immediately; successful reads and observed missing
records reset the history. Eviction or restart can cause earlier reporting.

Cleanup is explicit maintenance, never an automatic scan on each write. From the
installed Dashboard, use the affected user's Ruby/Bundler, configuration and data root:

```bash
RAILS_ENV=production bundle exec rails runner \
  'puts BatchConnect::Session.store.cleanup_temporary_files'
```

This previews files older than one hour. With validated, consistent locking, add
`dry_run: false` to delete while holding the writer lock. In unlocked mode, first
stop every writer, prevent new ones starting, and keep them stopped through cleanup;
then pass `dry_run: false, quiescent: true`. Quiescence is an operator assertion,
not a process detector; age alone cannot establish abandonment.

Cleanup rejects unsafe metadata directories and selects only old, owned, single-link
regular files with recognized Ruby temporary names. It preserves locks, symlinks,
directories, hardlinks, fresh files and unrelated names, rechecking identity before
unlinking. Stop external writers too: the recheck cannot prevent arbitrary external
replacement between checking and unlinking. Unexpected names need manual inspection.
