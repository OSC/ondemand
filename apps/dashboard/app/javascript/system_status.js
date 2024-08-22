import { statusIndexUrl, statusPollDelay } from './config'
import { pollAndReplace } from './turbo_shim'

jQuery(() => {
  pollAndReplace(statusIndexUrl(), statusPollDelay(), "system-status");
});