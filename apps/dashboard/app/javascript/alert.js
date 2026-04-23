
export function OODAlertError(message) {
  OODAlert(message, 'danger');
}

export function OODAlertSuccess(message) {
  OODAlert(message, 'success');
}

// The role="alert" has inconsistent behaviour across browser/OS/Screen reader
// combinations when it has content on page load.  Because of this, these elements
// d-none class on page load (they're hidden).
// This simple helper simply updates the content with itself after a small time
// to consistently generate an announcement to the screen reader.
// See https://github.com/OSC/ondemand/issues/2077 for more details.
export function updateAlerts() {
  const alerts = document.querySelectorAll('[data-notice]');
  alerts.forEach((alert) => {
      const tmpHtml = alert.innerHTML;
      alert.innerHTML = null;
      setTimeout(setAlert, 200, alert, tmpHtml);
  });
}

function setAlert(alert, html) {
  alert.innerHTML = html;
  alert.classList.remove('d-none');
}

function OODAlert(message, type) {
  const div = alertDiv(message, type);
  const main = document.getElementById('main_container');
  main.prepend(div);
  div.scrollIntoView({ behavior: 'smooth' });
}

function alertDiv(message, type) {
  const span = document.createElement('span');
  span.innerText = message;

  const div = document.createElement('div');
  div.classList.add('alert', `alert-${type}`, 'alert-dismissible');
  div.setAttribute('role', 'alert');
  div.appendChild(span);
  div.appendChild(closeButton());

  return div;
}

function closeButton() {
  const button = document.createElement('button');
  button.classList.add('btn-close');
  button.dataset.bsDismiss = 'alert';

  const span = document.createElement('span');
  span.classList.add('sr-only');
  span.innerText = 'Close';

  button.appendChild(span);

  return button;
}
