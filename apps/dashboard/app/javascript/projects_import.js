'use strict';

import { attachPathSelectors }  from './path_selector/path_selector';

jQuery(function() {
  attachPathSelectors();
});

document.addEventListener('DOMContentLoaded', function () {
  const inputField = document.getElementById('project_directory');
  const dropdownMenu = document.getElementById('directory_dropdown_menu');

  dropdownMenu.addEventListener('click', function (e) {
    if (e.target && e.target.matches('a.dropdown-item')) {
      inputField.value = e.target.getAttribute('data-value');
    }
  });
});
