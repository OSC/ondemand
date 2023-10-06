'use strict';

const selectorID = "modal_input_template_name";
const newNameID = "modal_input_template_new_name";

export function prefillSubmitHandler() {
  const form = $("#new_batch_connect_session_context");

  const chooseTemplateName = $("#chooseTemplateName");
  if (chooseTemplateName.length === 0) {
    return;
  }

  const chooseTemplateNameError = $("#chooseTemplateNameError");
  const templateName = $("#batch_connect_session_template_name");
  const saveTemplate = $("#batch_connect_session_save_template");

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
    templateName.val(name);
    chooseTemplateName.modal('hide');
  });

  saveTemplate.change(function () {
    if ($(this).is(':checked')) {
      chooseTemplateName.modal('show');
    } else {
      templateName.val("");
      $(`#${selectorID}`).val("")
      const newName = $(`#${newNameID}`);
      newName.val("");
      newName.show();
    }
  });

  chooseTemplateName.on('hidden.bs.modal', function () {
    if (templateName.val() === "") {
      saveTemplate.prop('checked', false);
      saveTemplate.change();
    }
  });
}
