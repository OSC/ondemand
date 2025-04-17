
export function OODAlert(message) {
  const div = alertDiv(message);
  const main = document.getElementById('main_container');
  main.prepend(div);
  div.scrollIntoView({ behavior: 'smooth' });
}

function alertDiv(message) {
  const span = document.createElement('span');
  span.innerText = message;

  const div = document.createElement('div');
  div.classList.add('alert', 'alert-danger', 'alert-dismissible');
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