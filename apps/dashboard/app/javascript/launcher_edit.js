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
  const deleteButton = justAdded.find('.btn-danger');
  const addButton = justAdded.find('.btn-success');
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
  const topLevelDiv = event.target.parentElement.parentElement;

  const helpTextDiv = topLevelDiv.firstElementChild;
  helpTextDiv.innerText = helpText;
}

function removeInProgressField(event) {
  const entireDiv = event.target.parentElement.parentElement.parentElement;
  entireDiv.remove();
  enableNewFieldButton()
}

function removeField(event) {
  // TODO: shouldn't be able to remove cluster & script form fields.
  const entireDiv = event.target.parentElement;
  entireDiv.remove();
  enableNewFieldButton();
}

function showEditField(event) {
  const entireDiv = event.target.parentElement;
  const editField = entireDiv.querySelector('.edit-group');
  editField.classList.remove('d-none');

  const saveButton = entireDiv.querySelector('.btn-success');
  const editButton = entireDiv.querySelector('.btn-primary');

  saveButton.classList.remove('d-none');
  editButton.disabled = true;

  saveButton.onclick = (event) => { saveEdit(event) };
}

function saveEdit(event) {
  const entireDiv = event.target.parentElement;
  const editField = entireDiv.querySelector('.edit-group');
  editField.classList.add('d-none');

  const saveButton = entireDiv.querySelector('.btn-success');
  const editButton = entireDiv.querySelector('.btn-primary');

  saveButton.classList.add('d-none');
  editButton.disabled = false;
}

function addInProgressField(event) {  
  const selectMenu = event.target.parentElement.parentElement.firstElementChild;
  const choice = selectMenu.value;
  const template = $(`#${choice}_template`);

  const newFieldButton = addNewFieldButton();
  newFieldButton.before(template.html());

  const justAdded = newFieldButton.prev();
  justAdded.find('.btn-danger')
           .on('click', (event) => { removeField(event) });

  justAdded.find('.btn-primary')
           .on('click', (event) => { showEditField(event) });

  justAdded.find('[data-select-toggler]')
           .on('click', (event) => { enableOrDisableSelectOption(event) });

  justAdded.find('[data-fixed-toggler]')
           .on('click', (event) => { toggleFixedField(event) });

  justAdded.find('[data-auto-environment-variable="name"]')
           .on('keyup', (event) => { updateAutoEnvironmentVariable(event) });

  const entireDiv = event.target.parentElement.parentElement.parentElement;
  entireDiv.remove();
  enableNewFieldButton();
}

function updateAutoEnvironmentVariable(event) {
  const aev_name = event.target.value;
  const labelString = event.target.dataset.labelString;
  const idString = `launcher_auto_environment_variable_${aev_name}`;
  const nameString = `launcher[auto_environment_variable_${aev_name}]`;
  var input_field = event.target.parentElement.children[2].children[1];

  input_field.removeAttribute('readonly');
  input_field.id = idString;
  input_field.name = nameString;

  if (labelString.match(/Environment(&#32;|\s)Variable/)) {
    const label_field = event.target.parentElement.children[2].children[0];
    label_field.innerHTML = `Environment Variable: ${aev_name}`;
  }

  // Update the checkbox so that environment variables can be fixed when created
  let fixedBoxGroup = event.target.parentElement.children[3].children[0].children[0];

  let checkbox = fixedBoxGroup.children[0];
  checkbox.id = `${idString}_fixed`;
  checkbox.name = `launcher[auto_environment_variable_${aev_name}_fixed]`;
  checkbox.setAttribute('data-fixed-toggler', idString);

  // Update hidden field if attribute is already fixed, otherwise just update label
  let labelIndex = 2;
  if(fixedBoxGroup.children.length == 3) {
    let hiddenField = fixedBoxGroup.children[1];
    hiddenField.name = nameString;
  } else {
    labelIndex = 1;
  }

  let fixedLabel = fixedBoxGroup.children[labelIndex];
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
    const selectOptionsConfig = $(dataElement).parents('.editable-form-field').find('li.list-group-item').get();

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
    $(`input[type=hidden][name="${dataElement.name}"]`).remove();

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
  const li = event.target.parentElement;
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
  const selectOptionsConfig = $(selectElement).parents('.editable-form-field').find('li.list-group-item').get();
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
    .find('.btn-danger')
    .on('click', (event) => { removeField(event) });

  $('.new_launcher')
    .find('.editable-form-field')
    .find('.btn-primary')
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
