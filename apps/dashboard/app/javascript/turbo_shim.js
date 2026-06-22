
/*
  While we want Turbo enabled at some point,
  it doesn't really work well yet. So, we'll provide
  this shim until we enable it.
*/

import { setInnerHTML } from './utils';
import { OODAlertError } from './alert';

export function replaceHTML(id, html) {
  const ele = document.getElementById(id);

  if(ele == null) return;

  var tmp = document.createElement('div');
  tmp.innerHTML = html;
  const newHTML = tmp.querySelector('template').innerHTML;
  tmp.remove();

  setInnerHTML(ele, newHTML);
}

export function pollAndReplace(url, delay, id, callback, continuePolling = () => true) {
  var focusedId = null;
  var focusedSelector = null;
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
    .then((html) => {
      const focusedElement = document.activeElement
      if (jQuery.contains(document.getElementById(id), focusedElement)) {
        // system status ensures that focusable elements have ids
        focusedId = focusedElement.id;

        // batch connect sessions use user-provided views, so use a weaker but more general approach

        const parentId = $(focusedElement).closest('.session-panel').attr('id');
        const ele = focusedElement.tagName.toLowerCase();
        const classArray = Array.from(focusedElement.classList);
        const text = $(focusedElement).text();
        let classes = "";
        if (classArray.length > 0) { // adds the leading . if classes are present
          classes = `.${classArray.join('.')}`;
        }
        focusedSelector = `#${parentId} ${ele}${classes}:contains("${text}")`;
      }
      replaceHTML(id, html);
      const newFocus = document.getElementById(focusedId);
      if (newFocus) {
        newFocus.focus();
      }	else {
        $(focusedSelector).focus();
      }
    })
    .then(() => {
      if (continuePolling()) {
        setTimeout(pollAndReplace, delay, url, delay, id, callback, continuePolling);
      }

      if (typeof callback == 'function') {
        callback();
      }
    })
    .catch((err) => {
      if (typeof err == 'string') {
        OODAlertError(err);
      } else {
        OODAlertError('This page has encountered an unexpected error. Please refresh the page.');
      }
      console.log(err);
    });
}
