'use strict';

const selectorID = "modal_input_template_name";
const newNameID = "modal_input_template_new_name";

export function prefillSubmitHandler() {

  const chooseTemplateName = $("#chooseTemplateName");
  if (chooseTemplateName.length === 0) {
    return;
  }

  const chooseTemplateNameError = $("#batch_connect_session_template_name_error_modal");
  const templateName = $("#batch_connect_session_template_name");
  const saveTemplate = $("#batch_connect_session_save_template");
  const saveSubmit = $("#batch_connect_session_save_template_submit");

  $(`#${selectorID}`).on("change", function () {
    const newName = $(`#${newNameID}`);
    if ($(this).val() === "") {
      newName.show();
    } else {
      newName.hide();
    }
  });

  $("#batch_connect_session_template_choose_name_button").on("click", function () {
    const name = $(`#${selectorID}`).val() || $(`#${newNameID}`).val();
    if (name === "") {
      chooseTemplateNameError.modal('show');
      return;
    }

    chooseTemplateNameError.modal('hide');
    templateName.val(name);
    chooseTemplateName.modal('hide');
    saveSubmit.prop("disabled", false);
  });

  saveTemplate.on('change', function () {
    if ($(this).is(':checked')) {
      chooseTemplateName.modal('show');
    } else {
      templateName.val("");
      $(`#${selectorID}`).val("")
      const newName = $(`#${newNameID}`);
      newName.val("");
      newName.show();
      saveSubmit.prop("disabled", true);
    }
  });

  chooseTemplateName.on('hidden.bs.modal', function () {
    if (templateName.val() === "") {
      saveTemplate.prop('checked', false);
      saveTemplate.trigger('change');
    }
  });
}
