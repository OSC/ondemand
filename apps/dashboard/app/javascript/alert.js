
export function OODAlertError(message) {
  OODAlert(message, 'danger');
}

export function OODAlertSuccess(message) {
  OODAlert(message, 'success');
}

// Many pages are loaded with role="alert" div/content, but these are not
// read by all browser/OS/Screen reader combinations. This is a simple hack to simply
// replace the content with itself after some delay for force all combinations
// to correctly read alerts.
// see https://github.com/OSC/ondemand/issues/2077 for more details.
export function updateAlerts() {
  const alerts = document.querySelectorAll('[data-notice]');
  alerts.forEach((alert) => {
    setTimeout(() => {
      const tmpHtml = alert.innerHTML;
      alert.innerHTML = null;
      alert.innerHTML = tmpHtml;
    }, 200);
  });
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
