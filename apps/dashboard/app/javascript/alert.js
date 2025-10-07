
export function OODAlert(message) {
  const div = alertDiv(message, 'danger');
  const main = document.getElementById('main_container');
  main.prepend(div);
  div.scrollIntoView({ behavior: 'smooth' });
}

export function OODAlertSuccess(message) {
  const div = alertDiv(message, 'success');
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
