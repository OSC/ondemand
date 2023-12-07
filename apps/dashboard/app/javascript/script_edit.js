'use strict';

let newFieldTemplate = undefined;

const newFieldData = {
  "bc_num_hours": {
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
  bc_num_slots: {
    label: "Nodes",
    help: "How many nodes the job will run on."
  },
  auto_environment_variable: {
    label: "Environment Variable",
    help: "Add an environment variable."
  }
}

function addNewFieldButton() {
  return $('#add_new_field_button');
}

function enableNewFieldButton() {
  const newFieldButton = addNewFieldButton();
  for(let newField in newFieldData) {
    const field = document.getElementById(`script_${newField}`);
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
    const field = document.getElementById(`script_${newField}`);

    // if the field doesn't already exist, it's an option for a new field.
    // TODO: maybe JS equiv of ALLOW_MULTIPLE_FIELDS.include?(newField)
    if(field === null || newField == "auto_environment_variable") {
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
  updateMultiple(event);
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

  justAdded.find('[data-multiple-input]')
           .on('change', (event) => { updateMultiple(event) });

  const entireDiv = event.target.parentElement.parentElement.parentElement;
  entireDiv.remove();
  enableNewFieldButton();
}

function updateMultiple(event) {
  $('#auto_environment_variable_multiple').value = "";
  let list = {};

  for (let index in $('[data-multiple-input="group"]')) {
    if (index < 2) {
      let group = $('[data-multiple-input="group"')[index];
      let name = group.children[0].value;
      let value = group.children[1].value;

      if (name != "") {
        list[name] = value;
      }
    }
  }

  $('#auto_environment_variable_multiple')[0].value = JSON.stringify(list);
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

  if(selectOptionsEnabled.length <= 1 && toggleAction == 'remove') {
    alert("Cannot remove the last option available")
    event.target.disabled = false;
    return
  }

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
  $('.new_script')
    .find('.editable-form-field')
    .find('.btn-danger')
    .on('click', (event) => { removeField(event) });

  $('.new_script')
    .find('.editable-form-field')
    .find('.btn-primary')
    .on('click', (event) => { showEditField(event) });

  $('[data-select-toggler]')
    .on('click', (event) => { enableOrDisableSelectOption(event) });

  $('[data-fixed-toggler]')
      .on('click', (event) => { toggleFixedField(event) });

  initSelectFields();
  initFixedFields();
});
