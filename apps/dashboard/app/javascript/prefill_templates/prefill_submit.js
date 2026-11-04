'use strict';

export function prefillSubmitHandler() {
  const saveTemplate = $("#batch_connect_session_save_template");
  if (saveTemplate.length === 0) {
    return;
  }

  const templateFields = $("#batch_connect_session_save_template_fields");
  const templateName = $("#batch_connect_session_template_name");
  const saveSubmit = $("#batch_connect_session_save_template_submit");

  // Only allow saving once a name has been typed or picked from the list
  templateName.on("input", function () {
    saveSubmit.prop("disabled", $(this).val().trim() === "");
  });

  saveTemplate.on("change", function () {
    const checked = $(this).is(":checked");

    templateFields.prop("hidden", !checked);
    // Launching with "Save settings" checked also saves, so a name is required
    templateName.prop("required", checked);
    if (checked) {
      templateName.trigger("focus");
    }
  });
}
