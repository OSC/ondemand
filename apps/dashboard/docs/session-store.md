# Batch Connect session-store coordination

The session database uses a stable `.session-store/lock` inode and exclusive
`flock` locks to coordinate readers, atomic record replacement, quarantine and
deletion. All cooperating processes accessing one database must observe the
same lock. Local locks on separate hosts do not coordinate a shared database.
Keep `.session-store` on the record filesystem so replacement uses an atomic
rename. Do not remove or replace the lock inode while workers are using it.

If `flock` reports `ENOLCK`, `ENOSYS` or `EOPNOTSUPP`, existing records remain
readable and a warning is logged. Invalid records are skipped without being
quarantined, because quarantine is a mutation requiring the lock. Completion
cache updates are skipped, and expired records remain listed until locking is
restored. Other I/O and permission errors continue to propagate normally.

This is a read-only degraded mode: session creation, replacement and deletion
require working locking. Repair the filesystem's locking support before using
those operations. Cancellation of an existing scheduler job can still succeed
without updating its completion cache. No mutation silently runs unlocked.

Submission checks locking before calling the scheduler. This preflight cannot
make a scheduler call and a filesystem write transactional. If saving a newly
accepted job's record fails, submission attempts to cancel the accepted job and
reports its ID and the save error. If cancellation also fails, the error includes
both failures and the accepted ID so an operator can cancel the job manually.
Review that ID in the cluster scheduler before retrying submission.

The store protects concurrent record operations and avoids exposing partially
written replacement JSON. It does not promise recovery after process death,
power-loss durability, or compensation when a scheduler accepts a job but raises
before returning its ID. Deployments must validate locking semantics on their
actual shared filesystem and process topology.
