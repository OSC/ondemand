'use strict';

import { attachPathSelectors }  from './path_selector/path_selector';

jQuery(function() {
  $("#project_template").on('change', (event) => templateChange(event));
  attachPathSelectors();
});

function templateChange(event) {
  const choice = $(`#project_template option[value="${event.target.value}"]`)[0];
  if(choice === undefined) {
    return;
  }

  const name = choice.label;
  const description = choice.dataset.description;
  const icon = choice.dataset.icon;

  $("#project_name").val(name);
  $("#project_description").val(description);
  $("#product_icon_select").val(icon);
  $("#product_icon_select").trigger('change');
}
