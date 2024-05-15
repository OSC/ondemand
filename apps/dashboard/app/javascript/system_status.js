import { statusIndexUrl } from './config'
import { replaceHTML } from './turbo_shim'

function poll() {
  pollDelay = 30000; // Probably want a configuration in the future, but 30 seconds for now

  url = statusIndexUrl();
  fetch(url, { headers: { Accept: "text/vnd.turbo-stream.html" } })
    .then(response => response.ok ? Promise.resolve(response) : Promise.reject(response.text()))
    .then((r) => r.text())
    .then((html) => replaceHTML("system-status", html))
    .then(setTimeout(poll, pollDelay))
    .catch((err) => {
      console.log('Cannot retrieve system status information due to error:');
      console.log(err);
    });
}

jQuery(poll)