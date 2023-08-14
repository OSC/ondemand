'use strict';

const bcPrefix = 'batch_connect_session_context';
const prefillTemplatePickerElementName = 'batch_connect_session_prefill_template';
const selectorID = "modal_input_template_name";
const newNameID = "modal_input_template_new_name";

function prefillTemplateHandler() {
  const picker = $(`#${prefillTemplatePickerElementName}`);
  if (picker.length == 0) { return; }
  picker.on('change', function () {
    const templateOption = $(`#${prefillTemplatePickerElementName} option:selected`);
    if (!templateOption.val()) { return; }
    let json;
    try {
      json = JSON.parse(templateOption.val());
    } catch (error) {
      $('#formPrefillErrorBody').text(error.message)
      $('#formPrefillError').modal('show');
      return;
    }
    let errorMsg = '';
    for (const [key, value] of Object.entries(json)) {
      let element = $(`#${bcPrefix}_${key}`);

      if (element.length == 0) {
        // For radio buttons
        if (/^\d+$/.test(value)) {
          element = $(`#${bcPrefix}_${key}_${value}`);
        } else {
          continue;
        }
      }
      if (element.is('select') && value !== '') {
        // Ensure that the option exists
        if (element.find(`option[value="${value}"]`).length == 0) {
          errorMsg += `Invalid value: "${value}" for the field "${key}".<br>`;
          continue;
        }
      }
      switch (element.attr('type')) {
        case "checkbox":
          value === "1" ? element.prop('checked', true) : element.prop('checked', false);
          break;

        case "radio":
          element.filter(`[value="${value}"]`).prop('checked', true);

        default:
          element.val(value);
          break;
      }
      element.trigger('change');
    }
    if (errorMsg) {
      $('#formPrefillErrorBody').html(errorMsg)
      $('#formPrefillError').modal('show');
    }
  });
}

function prefillSubmitHandler() {
  const form = $("#new_batch_connect_session_context");
  const chooseTemplateName = $("#chooseTemplateName");
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

jQuery(function () {
  prefillTemplateHandler();
  prefillSubmitHandler();
});
