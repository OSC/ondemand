import { statusIndexUrl } from './config'
import { pollAndReplace } from './turbo_shim'

jQuery(() => {
  pollDelay = 30000;
  pollAndReplace(statusIndexUrl(), pollDelay, "system-status");
})