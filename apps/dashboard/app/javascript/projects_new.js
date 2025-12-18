'use strict';

import { attachPathSelectors }  from './path_selector/path_selector';
import { userHome } from './config';

// cache this just so we don't have to keep parsing the DOM to retrieve it.
const home = userHome();

jQuery(function() {
  $("#project_template").on('change', (event) => templateChange(event));
  $("#project_directory").on('input', (event) => toggleSharedSettings(event.target.value));
  attachPathSelectors();

  toggleSharedSettings(document.getElementById('project_directory').value);
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

function toggleSharedSettings(value) {
  const owner = document.getElementById('project_group_owner');
  const setgid = document.getElementById('project_setgid');
  const isDisabled = value.startsWith(home) || value === "";

  owner.disabled = isDisabled;
  setgid.disabled = isDisabled;
}