'use strict';

export function prefillSubmitHandler() {
  const saveTemplate = $("#batch_connect_session_save_template");
  if (saveTemplate.length === 0) {
    return;
  }

  const templateFields = $("#batch_connect_session_save_template_fields");
  const templateName = $("#batch_connect_session_template_name");
  const saveSubmit = $("#batch_connect_session_save_template_submit");
  const nameError = $("#batch_connect_session_template_name_error").text();

  function validateName() {
    const blank = templateName.val().trim() === "";
    // Only allow saving once a name has been typed or picked from the list
    saveSubmit.prop("disabled", blank);
    // Show the translated message instead of the browser's default one
    templateName[0].setCustomValidity(blank && saveTemplate.is(":checked") ? nameError : "");
  }

  templateName.on("input", validateName);

  saveTemplate.on("change", function () {
    const checked = $(this).is(":checked");

    templateFields.prop("hidden", !checked);
    // Launching with "Save settings" checked also saves, so a name is required
    templateName.prop("required", checked);
    validateName();
    if (checked) {
      templateName.trigger("focus");
    }
  });

  validateName();
}
