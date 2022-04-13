"use strict";
(() => {
  // app/javascript/packs/products_show.js
  var id = "product_cli_modal";
  var spinnerId = `${id}_spinner`;
  var headerId = `${id}_header`;
  var buttonId = `${id}_button`;
  var closeButton = `<button id="${buttonId}" class="close float-right" data-dismiss="modal">&times;</button>`;
  jQuery(function() {
    $('[data-toggle="cli"]').on("click", (event) => updateModal(event));
    $(`#${headerId}`).replaceWith(`
    <h2>
      <span>no action</pan>
      ${closeButton}
    </h2>
  `);
  });
  function updateModal(event) {
    const button = $(`#${event.target["id"]}`);
    if (button === void 0 || button.data() === {}) {
      return;
    }
    const title = button.data("title");
    const cmd = button.data("cmd");
    const target = button.data("target");
    const header = `$ <code><strong>${cmd}</strong></code>
`;
    $(`#${headerId}`).replaceWith(`
    <h2>
      <span>${title}</pan>
      ${closeButton}
    </h2>
  `);
    const xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (this.status == 200) {
        $(`#${id} .product-cli-body`).html(`${header}${this.responseText}`);
        $(`#${id} .product-cli-body`).scrollTop($(`#${id} .product-cli-body`)[0].scrollHeight);
      }
    };
    xhr.onloadend = function() {
      $(`#${spinnerId}`).replaceWith(`
      <button class="close float-right" data-dismiss="modal">&times;</button>
    `);
      if (this.status != 200) {
        $(`#${id} .product-cli-body`).html(`${header}A fatal error has occurred`);
      }
      ;
    };
    xhr.open("PATCH", target);
    xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr("content"));
    xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
    xhr.send();
    window.jQuery(`#${id}`).modal("show");
  }
})();
//# sourceMappingURL=products_show.js.map
