'use strict';

import { picked, iconId } from './icon_picker';

jQuery(function() {
  $("#project_template").on('change', (event) => templateChange(event));
});

function templateChange(event){
  console.log(event);
  const choice = $(`#project_template option[value="${event.target.value}"]`)[0];
  if(choice === undefined) {
    return;
  }

  const name = choice.label;
  const description = choice.dataset.description;
  const icon = choice.dataset.icon;
  const iconName = icon.replace('fas://', '');

  $("#project_name").val(name);
  $("#project_description").val(description);
  
  picked({ currentTarget: document.querySelector(`#${iconId(iconName)}`) });
}
