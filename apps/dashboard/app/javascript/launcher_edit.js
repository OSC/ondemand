'use strict';

let newFieldTemplate = undefined;

const newFieldData = {
  bc_num_hours: {
    label: "Hours",
    help: "How long the job can run for.",
  },
  auto_queues: {
    label: "Queues",
    help: "Which queue the job will submit too.",
  }, 
  auto_accounts: {
    label: "Account",
    help: "The account the job will be submitted with."
  },
  auto_job_name: {
    label: "Job Name",
    help: "The name the job will have."
  },
  auto_log_location: {
    label: "Log Location",
    help: "The destination of the job's log output."
  },
  bc_num_nodes: {
    label: "Nodes",
    help: "How many nodes the job will run on."
  },
  auto_environment_variable: {
    label: 'Environment Variable',
    help: 'Add an environment variable.'
  },
  auto_cores: {
    label: 'Cores',
    help: 'How many cores the job will run on.'
  }
}

function addNewFieldButton() {
  return $('#add_new_field_button');
}

function enableNewFieldButton() {
  const newFieldButton = addNewFieldButton();
  for(let newField in newFieldData) {
    const field = document.getElementById(`launcher_${newField}`);
    if(field === null) {
      // There is at least one field to be added.
      // Enabled add button.
      newFieldButton.text('Add new option');
      newFieldButton.attr('disabled', false);
      return;
    }
  }

  newFieldButton.text('No more options');
}

function addNewField(_event) {
  const newFieldButton = addNewFieldButton();
  newFieldButton.attr('disabled', true);
  newFieldButton.before(newFieldTemplate.html());

  const justAdded = newFieldButton.prev();
  const deleteButton = justAdded.find('[data-new-field-action="cancel"]');
  const addButton = justAdded.find('[data-new-field-action="add"]');
  const selectMenu = justAdded.find('select');

  deleteButton.on('click', (event) => { removeInProgressField(event) });
  addButton.on('click', (event) => { addInProgressField(event) });
  selectMenu.on('change', (event) => { addHelpTextForOption(event) });

  updateNewFieldOptions(selectMenu.get(0));
  // initialize the help text
  addHelpTextForOption({ target: selectMenu.get(0) });
}

function updateNewFieldOptions(selectMenu) {
  for(let newField in newFieldData) {
    const field = document.getElementById(`launcher_${newField}`);

    // if the field doesn't already exist, it's an option for a new field.
    if(field === null) {
      const option = document.createElement("option");
      option.value = newField;
      option.text = newFieldData[newField].label;

      selectMenu.add(option);
    }
  }
}

function addHelpTextForOption(event) {
  const helpText = newFieldData[event.target.value].help;
  const inProgressField = event.target.closest('[data-in-progress-field]');

  const helpTextDiv = inProgressField.querySelector('[data-new-field-help]');
  helpTextDiv.innerText = helpText;
}

function removeInProgressField(event) {
  event.target.closest('[data-in-progress-field]').remove();
  enableNewFieldButton();
}

function removeField(event) {
  // TODO: shouldn't be able to remove cluster & script form fields.
  event.target.closest('.editable-form-field').remove();
  enableNewFieldButton();
}

function showEditField(event) {
  const entireDiv = event.target.closest('.editable-form-field');
  const editField = entireDiv.querySelector('.edit-group');

  const editButton = entireDiv.querySelector('.btn-primary, .btn-success');

  if (editField.classList.contains('d-none')) {
    editField.classList.remove('d-none');
    editButton.classList.remove('btn-primary');
    editButton.classList.add('btn-success');
    editButton.setAttribute('aria-expanded', 'true');
    editButton.setAttribute('aria-label', editButton.getAttribute('data-save-label'))
    editButton.textContent = editButton.getAttribute('data-save-text');
    
  } else {
    editField.classList.add('d-none');
    editButton.classList.remove('btn-success');
    editButton.classList.add('btn-primary');
    editButton.setAttribute('aria-expanded', 'false');
    editButton.setAttribute('aria-label', editButton.getAttribute('data-edit-label'))
    editButton.textContent = editButton.getAttribute('data-edit-text');
  }
}

function addInProgressField(event) {  
  const inProgressField = event.target.closest('[data-in-progress-field]');
  const selectMenu = inProgressField.querySelector('select');
  const choice = selectMenu.value;
  const template = $(`#${choice}_template`);

  const newFieldButton = addNewFieldButton();
  newFieldButton.before(template.html());

  const justAdded = newFieldButton.prev();
  justAdded.find('[data-field-remove-button]')
           .on('click', (event) => { removeField(event) });

  justAdded.find('[data-field-edit-button]')
           .on('click', (event) => { showEditField(event) });

  justAdded.find('[data-select-toggler]')
           .on('click', (event) => { enableOrDisableSelectOption(event) });

  justAdded.find('[data-fixed-toggler]')
           .on('click', (event) => { toggleFixedField(event) });

  justAdded.find('[data-auto-environment-variable="name"]')
           .on('keyup', (event) => { updateAutoEnvironmentVariable(event) });

  inProgressField.remove();
  enableNewFieldButton();
}

function updateAutoEnvironmentVariable(event) {
  const aev_name = event.target.value;
  const labelString = event.target.dataset.labelString;
  const idString = `launcher_auto_environment_variable_${aev_name}`;
  const nameString = `launcher[auto_environment_variable_${aev_name}]`;
  const editableTextField = event.target.closest('.editable-form-field');

  const formItemPreview = editableTextField.querySelector('[data-form-item-preview]');
  const input_field = formItemPreview.querySelector('input');
  input_field.removeAttribute('readonly');
  input_field.id = idString;
  input_field.name = nameString;

  if (labelString.match(/Environment(&#32;|\s)Variable/)) {
    const label_field = formItemPreview.querySelector('label');
    label_field.innerHTML = `Environment Variable: ${aev_name}`;
  }

  // Update the checkbox so that environment variables can be fixed when created
  const fixedField = editableTextField.querySelector('[data-edit-fixed-field]');

  const checkbox = fixedField.querySelector('input[type="checkbox"]');
  checkbox.id = `${idString}_fixed`;
  checkbox.name = `launcher[auto_environment_variable_${aev_name}_fixed]`;
  checkbox.setAttribute('data-fixed-toggler', idString);

  // Update hidden field if attribute is already fixed
  const hiddenField = fixedField.querySelector('input[type="hidden"]');
  if (hiddenField) {
    hiddenField.name = nameString;
  }

  const fixedLabel = fixedField.querySelector('label');
  fixedLabel.setAttribute('for', `${idString}_fixed`);
}

function fixExcludeBasedOnSelect(selectElement) {
  const excludeElementId = selectElement.dataset.excludeId;
  const selectOptions = Array.from(selectElement.options);
  const itemsToExclude = selectOptions.filter(opt => !opt.selected).map(opt => opt.text);
  const excludeElement = document.getElementById(excludeElementId);
  excludeElement.value = itemsToExclude.join(',');
}

function fixedFieldEnabled(checkbox, dataElement) {
  // Disable the element to avoid updates from the user
  dataElement.disabled = true;
  // As it is disabled, need to add a hidden field with the same name to send the fixed field value to the backend.
  const input = $('<input>').attr('type','hidden').attr('name', dataElement.name).attr('value', dataElement.value);
  $(checkbox).after(input);

  if (dataElement.nodeName == 'SELECT') {
    const selectOptions = Array.from(dataElement.options);
    const selectedOption = selectOptions.filter(opt => opt.selected)[0];
    const selectOptionsConfig = $(dataElement).closest('.editable-form-field').find('[data-select-option]').get();

    selectOptionsConfig.forEach(configItemLi => {
      const textContent = $(configItemLi).find('[data-select-value]')[0].textContent;
      if (selectedOption.text == textContent) {
        enableRemoveOption(configItemLi, true);
      } else {
        enableAddOption(configItemLi, true);
      }
    });
  }
}

function toggleFixedField(event) {
  event.target.disabled = true;
  const targetId = event.target.dataset.fixedToggler;
  const dataElement = document.getElementById(targetId);
  if (event.target.checked) {
    fixedFieldEnabled(event.target, dataElement)
  } else {
    dataElement.disabled = false;
    // Field enabled, remove the hidden field with the same name needed when disabled.
    $(event.target).closest('.editable-form-field').find(`input[type=hidden][name="${dataElement.name}"]`).remove();

    if (dataElement.nodeName == 'SELECT') {
      fixExcludeBasedOnSelect(dataElement);
      initSelect(dataElement);
    }
  }

  event.target.disabled = false;
}

function enableAddOption(optionLi, addButtonDisabled = false) {
  optionLi.classList.add('list-group-item-danger', 'text-strike');
  const addButton = $(optionLi).find('[data-select-toggler="add"]')[0];
  addButton.disabled = addButtonDisabled;
  const removeButton = $(optionLi).find('[data-select-toggler="remove"]')[0];
  removeButton.disabled = true;
}

function enableRemoveOption(optionLi, removeButtonDisabled = false) {
  optionLi.classList.remove('list-group-item-secondary', 'list-group-item-danger', 'text-strike');
  const addButton = $(optionLi).find('[data-select-toggler="add"]')[0];
  addButton.disabled = true;
  const removeButton = $(optionLi).find('[data-select-toggler="remove"]')[0];
  removeButton.disabled = removeButtonDisabled;
}

function enableOrDisableSelectOption(event) {
  const toggleAction = event.target.dataset.selectToggler;
  const li = event.target.closest('[data-select-option]');
  event.target.disabled = true;

  const choice = $(li).find('[data-select-value]')[0].textContent;

  const select = document.getElementById(event.target.dataset.selectId);
  const excludeId = select.dataset.excludeId;
  const selectOptions = Array.from(select.options);
  const optionToToggle = selectOptions.filter(opt => opt.text == choice)[0];
  const selectOptionsEnabled = selectOptions.filter(opt => !opt.disabled);

  if(toggleAction == 'add') {
    enableRemoveOption(li);
    removeFromExcludeInput(excludeId, choice);
    optionToToggle.disabled = false;
  } else {
    enableAddOption(li);
    addToExcludeInput(excludeId, choice);
    optionToToggle.disabled = true;
    if (optionToToggle.selected) {
      optionToToggle.selected = false;
      // if we can remove, there is always another option
      selectOptionsEnabled.filter(opt => opt.text !== choice)[0].selected = true;
    }
  }
  enableOrDisableLastOption(li.parentElement);
}

function enableOrDisableLastOption(optionsOl) {
  const optionLis = Array.from(optionsOl.children);

  const optionsEnabled = Array.from(optionLis.filter((child) => {
    return !child.classList.contains('text-strike');
  }));

  if(optionsEnabled.length > 1) {
    // Make sure there are no options that have both the add and remove button disabled
    const bothButtonsDisabled = optionsEnabled.filter((option) => {
      return option.querySelectorAll('button:disabled').length == 2;
    });
    for(const option of bothButtonsDisabled) {
      enableRemoveOption(option);
    }
  } else {
    // Disable the remove button on the last option
    enableRemoveOption(optionsEnabled[0], true);
  }
}

function getExcludeList(excludeElementId) {
  const excludeInput = document.getElementById(excludeElementId);
  const excludeList = excludeInput.value.split(',').filter(word => word != "");
  return { excludeInput, excludeList };
}

function addToExcludeInput(id, item) {
  const { excludeInput, excludeList } = getExcludeList(id);
  excludeList.push(item);

  excludeInput.value = excludeList.join(',');
}

function removeFromExcludeInput(id, item) {
  const { excludeInput, excludeList } = getExcludeList(id);
  const newList = excludeList.filter(word => word != item);

  excludeInput.value = newList.join(',');
}

function initSelectFields(){
  const selectFields = Array.from($('select[data-exclude]'));

  selectFields.forEach(select => {
    initSelect(select);
  });
}

function initSelect(selectElement) {
  const excludeId = selectElement.dataset.excludeId;
  const selectOptions = Array.from(selectElement.options);
  const selectOptionsConfig = $(selectElement).closest('.editable-form-field').find('[data-select-option]').get();
  const { excludeList } = getExcludeList(excludeId);

  selectOptions.forEach(option => {
    option.disabled = false;
    if (excludeList.includes(option.text)) {
      option.disabled = true;
      option.selected = false;
    }
  });

  selectOptionsConfig.forEach(configItem => {
    enableRemoveOption(configItem);
    const textContent = $(configItem).find('[data-select-value]')[0].textContent;
    if (excludeList.includes(textContent)) {
      enableAddOption(configItem);
    }
  });

  enableOrDisableLastOption(selectOptionsConfig[0].parentElement);
}


function initFixedFields(){
  const fixedCheckboxes = Array.from($('[data-fixed-toggler]'));

  // find all the enabled 'fixed' checkboxes
  fixedCheckboxes.filter((fixedFieldCheckbox) => {
    return fixedFieldCheckbox.checked;
    // now fix the value of the related field
  }).map((fixedFieldCheckbox) => {
    const dataElement = document.getElementById(fixedFieldCheckbox.dataset.fixedToggler);
    fixedFieldEnabled(fixedFieldCheckbox, dataElement)
  });
}

jQuery(() => {
  newFieldTemplate = $('#new_field_template');
  $('#add_new_field_button').on('click', (event) => { addNewField(event) });
  $('.new_launcher')
    .find('.editable-form-field')
    .find('[data-field-remove-button]')
    .on('click', (event) => { removeField(event) });

  $('.new_launcher')
    .find('.editable-form-field')
    .find('[data-field-edit-button]')
    .on('click', (event) => { showEditField(event) });

  $('[data-select-toggler]')
    .on('click', (event) => { enableOrDisableSelectOption(event) });

  $('[data-fixed-toggler]')
      .on('click', (event) => { toggleFixedField(event) });

  $('[data-auto-environment-variable="name"]')
      .on('keyup', (event) => { updateAutoEnvironmentVariable(event) });

  initSelectFields();
  initFixedFields();
});
