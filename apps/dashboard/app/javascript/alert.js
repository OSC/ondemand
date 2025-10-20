
export function OODAlertError(message) {
  OODAlert(message, 'danger');
}

export function OODAlertSuccess(message) {
  OODAlert(message, 'success');
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
