'use strict';

const bcPrefix = 'batch_connect_session_context';
const templateSelectId = 'batch_connect_session_prefill_template';

export function prefillTemplatesHandler() {
  const picker = $(`#${templateSelectId}`);
  if (picker.length == 0) { return; }

  picker.on('change', function () {
    const templateOption = $(`#${templateSelectId} option:selected`);
    if (!templateOption.val()) { return; }

    let json;
    try {
      json = JSON.parse(templateOption.val());
    } catch (error) {
      $('#batch_connect_session_template_form_error_modal').text(error.message)
      $('#batch_connect_session_template_form_error_modal_body').modal('show');
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
      $('#batch_connect_session_template_form_error_modal_body').html(errorMsg)
      $('#batch_connect_session_template_form_error_modal').modal('show');
    }
  });
}
