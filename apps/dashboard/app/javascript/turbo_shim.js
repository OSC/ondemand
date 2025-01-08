
/*
  While we want Turbo enabled at some point,
  it doesn't really work well yet. So, we'll provide
  this shim until we enable it.
*/

import { setInnerHTML, setFocus } from './utils';
import { alert } from './alert';

/**
 * TODO: Move to batch_connect_sessions
 * Alerts screen readers when the status of an interactive session changes.
 */

const sessionStatusMap = new Map();

function updateLiveRegion(message) {
  const liveRegion = document.getElementById("sr-live-region");
  liveRegion.textContent = message;
}

function checkStatusChanges() {
  const sessionCards = document.querySelectorAll('.card.session-panel');
  
  sessionCards.forEach((card) => {
    const sessionId = card.querySelector('[id^="id_link"]').textContent;
    const newStatus = card.querySelector('.status').textContent;
    if (sessionStatusMap.has(sessionId)) {
      const oldStatus = sessionStatusMap.get(sessionId);
      if (oldStatus !== newStatus) {
        sessionStatusMap.set(sessionId, newStatus);
        const sessionTitle = card.querySelector('.card_title').textContent
        updateLiveRegion(`${sessionTitle} session status changed to ${newStatus}`);
      }
    } else {
      sessionStatusMap.set(sessionId, newStatus);
    }
  });
}

export function replaceHTML(id, html) {
  const ele = document.getElementById(id);

  if(ele == null){
    return;
  }

  var tmp = document.createElement('div');
  tmp.innerHTML = html;
  const newHTML = tmp.querySelector('template').innerHTML;
  tmp.remove();

  const focusedElem = document.activeElement;
  const focusedElemId = focusedElem?.id;

  setInnerHTML(ele, newHTML);

  if (focusedElemId && !focusedElem.isConnected) {
    setFocus(focusedElemId);
  }
}

export function pollAndReplace(url, delay, id, callback) {
  fetch(url, { headers: { Accept: "text/vnd.turbo-stream.html" } })
    .then((response) => {
      if(response.status == 200) {
        return Promise.resolve(response);
      } else if(response.status == 401) {
        return Promise.reject("This page cannot update because you are no longer authenticated. Please refresh the page to log back in.")
      } else {
        return Promise.reject(response.text());
      }
    })
    .then((r) => r.text())
    .then((html) => replaceHTML(id, html))
    .then(() => {
      checkStatusChanges();
      setTimeout(pollAndReplace, delay, url, delay, id, callback);
      if (typeof callback == 'function') {
        callback();
      }
    })
    .catch((err) => {
      if (typeof err == 'string') {
        alert(err);
      } else {
        alert('This page has encountered an unexpected error. Please refresh the page.');
      }
      console.log(err);
    });
}
