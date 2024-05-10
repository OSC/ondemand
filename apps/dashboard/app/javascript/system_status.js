import { bcPollDelay, statusIndexUrl } from './config'
import { replaceHTML } from './turbo_shim'

function poll() {
  url = statusIndexUrl();
  fetch(url, { headers: { Accept: "text/vnd.turbo-stream.html" } })
    .then(response => response.ok ? Promise.resolve(response) : Promise.reject(response.text()))
    .then((r) => r.text())
    .then((html) => replaceHTML("system-status", html))
    .then(setTimeout(poll, bcPollDelay()))
    .catch((err) => {
      console.log('Cannot retrieve batch connect sessions due to error:');
      console.log(err);
    });
}

jQuery(poll)