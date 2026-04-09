'use strict';

import { attachPathSelectors } from './path_selector/path_selector';
import { prefillTemplatesHandler } from './prefill_templates/prefill_templates';
import { prefillSubmitHandler } from './prefill_templates/prefill_submit';
import { isBCDynamicJSEnabled } from './config';
import { makeChangeHandlers } from './dynamic_forms';
import { setupNotificationToggle } from './batch_connect/bc_notifications';
import { updateResolutions } from './batch_connect/resolution_field';

jQuery(function() {
  if(isBCDynamicJSEnabled()){
    makeChangeHandlers('batch_connect_session_context');
  }

  attachPathSelectors();
  prefillTemplatesHandler();
  prefillSubmitHandler();
  updateRadioCollections();
  updateResolutions();
  
  setupNotificationToggle('notification_toggle');
});

// The following function makes collections of radio buttons and checkboxes accessible following the behavior
//  of bootstrap-form v5.6. This should be removed when bootstrap-form is upgraded to this version.
function updateRadioCollections() {
  $('[data-widget-type="radio"], [data-widget-type="radio_button"]').each(function(_index, wrapper){
    const groupId = $(wrapper).attr('id').replace('_wrapper', '');
    const labelId = `${groupId}_label`;
    // Find the label.form-label inside this widget
    const $formLabel = $(wrapper).find('label.form-label');
    if (!$formLabel.length) return;

    // Copy text from original label
    const innerContent = $formLabel.html();

    // Replace label.form-label with div.form-label, keeping inner content
    // and swapping the `for` attribute for `id`
    const $newDiv = $(document.createElement('div'))
    $newDiv.addClass('form-label').attr('id', labelId).html(innerContent);

    $formLabel.replaceWith($newDiv);

    // Add role="group" and aria-labelledby to the parent .mb-3 div
    $newDiv.closest('.mb-3').attr({
      'role': 'group',
      'aria-labelledby': labelId
    });
  })
}
