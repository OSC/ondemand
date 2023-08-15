'use strict';

const selectorID = "modal_input_template_name";
const newNameID = "modal_input_template_new_name";

export function prefillSubmitHandler() {
  const form = $("#new_batch_connect_session_context");

  const chooseTemplateName = $("#chooseTemplateName");
  if (chooseTemplateName.length === 0) {
    return;
  }

  const chooseTemplateNameError = $("#chooseTemplateNameError")
  let url;

  $(`#${selectorID}`).on("change", function () {
    const newName = $(`#${newNameID}`);
    if ($(this).val() === "") {
      newName.show();
    } else {
      newName.hide();
    }
  });

  $("#chooseTemplateNameConfirm").on("click", function () {
    const name = $(`#${selectorID}`).val() || $(`#${newNameID}`).val();
    if (name === "") {
      chooseTemplateNameError.modal('show');
      return;
    }
    chooseTemplateNameError.modal('hide');
    url.searchParams.set('template', name);
    form.attr("action", url.href);
    chooseTemplateName.modal('hide');
  });

  form.one("submit", function (event) {
    const saveTemplate = $("#batch_connect_session_save_template");
    if (!saveTemplate.is(':checked')) {
      return;
    }
    event.preventDefault();

    const path = form.attr("action");
    if (path.startsWith("/")) {
      url = new URL(`${window.location.origin}${path}`);
    } else {
      let cleanPrefix = `${window.location.origin}${window.location.pathname}`;
      if (cleanPrefix.endsWith("/")) {
        cleanPrefix = cleanPrefix.slice(0, -1);
      }
      url = new URL(`${cleanPrefix}/${path}`);
    }
    chooseTemplateName.on("hidden.bs.modal", function () {
      chooseTemplateName.off("hidden.bs.modal");
      form.submit();
    });
    chooseTemplateName.modal('show');
  });
}
