'use strict';

const id = 'product_cli_modal';
const spinnerId = `${id}_spinner`;
const headerId = `${id}_header`;
const buttonId = `${id}_button`;
const closeButton = `<button id="${buttonId}" class="btn-close float-end" data-bs-dismiss="modal"></button>`;

jQuery(function(){
  $('[data-toggle="cli"]').on('click', (event) => updateModal(event));

  $(`#${headerId}`).replaceWith(`
    <h2>
      <span>no action</pan>
      ${closeButton}
    </h2>
  `);
});

function updateModal(event){
  const button = $(`#${event.target['id']}`);
  if(button === undefined || button.data() == {}) { return; }

  const title = button.data('title');
  const cmd = button.data('cmd');
  const target = button.data('target');
  const header = `\$ <code><strong>${cmd}</strong></code>\n`

  $(`#${headerId}`).replaceWith(`
    <h2>
      <span>${title}</pan>
      ${closeButton}
    </h2>
  `);

  const xhr = new XMLHttpRequest;
  xhr.onreadystatechange = function() {
    if(this.status == 200){
      $(`#${id} .product-cli-body`).html(`${header}${this.responseText}`);
      $(`#${id} .product-cli-body`).scrollTop($(`#${id} .product-cli-body`)[0].scrollHeight);
    }
  };

  xhr.onloadend = function() {
    $(`#${spinnerId}`).replaceWith(`
      <button class="btn-close float-end" data-bs-dismiss="modal">&times;</button>
    `);
    if (this.status != 200) {
      $(`#${id} .product-cli-body`).html(`${header}A fatal error has occurred`);
    };
  };

  xhr.open('PATCH', target);
  xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
  xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
  xhr.send();
  // FIXMME: using window here bc modal is a bootstrap import and there are multiple
  // $ and jQuery's out there.
  window.jQuery(`#${id}`).modal('show');
}
