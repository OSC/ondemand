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

  const entireDiv = event.target.parentElement.parentElement.parentElement;
  entireDiv.remove();
  enableNewFieldButton();
}

function fixedFieldEnabled(checkbox, dataElement) {
  // Disable the element to avoid updates from the user
  dataElement.disabled = true;
  // As it is disabled, need to add a hidden field with the same name to send the fixed field value to the backend.
  const input = $('<input>').attr('type','hidden').attr('name', dataElement.name).attr('value', dataElement.value);
  $(checkbox).after(input);
}

function toggleFixedField(event) {
  event.target.disabled = true;
  const elementId = event.target.dataset.fixedToggler;
  const dataElement = document.getElementById(elementId);
  if (event.target.checked) {
    fixedFieldEnabled(event.target, dataElement)
  } else {
    dataElement.disabled = false;
    // Field enabled, remove the hidden field with the same name needed when disabled.
    $(`input[type=hidden][name="${dataElement.name}"]`).remove();
  }

  event.target.disabled = false;
}

function enableOrDisableSelectOption(event) {
  const toggleAction = event.target.dataset.selectToggler;
  const li = event.target.parentElement;
  event.target.disabled = true;

  const inputId = event.target.dataset.target;
  const choice = $(li).find('[data-select-value]')[0].textContent;

  const select = document.getElementById(event.target.dataset.selectId);
  const selectOptions = Array.from(select.options);
  const optionToToggle = selectOptions.filter(opt => opt.text == choice)[0];
  const selectOptionsEnabled = selectOptions.filter(opt => !opt.disabled);

  if(selectOptionsEnabled.length <= 1 && toggleAction == 'remove') {
    alert("Cannot remove the last option available")
    event.target.disabled = false;
    return
  }

  if(toggleAction == 'add') {
    li.classList.remove('list-group-item-danger', 'text-strike');
    const removeButton = $(li).find('[data-select-toggler="remove"]')[0];
    removeButton.disabled = false;
    removeFromExcludeInput(inputId, choice);
    optionToToggle.disabled = false;
  } else {
    li.classList.add('list-group-item-danger', 'text-strike');
    const addButton = $(li).find('[data-select-toggler="add"]')[0];
    addButton.disabled = false;
    addToExcludeInput(inputId, choice);
    optionToToggle.disabled = true;
    if (optionToToggle.selected) {
      optionToToggle.selected = false;
      // if we can remove, there is always another option
      selectOptionsEnabled.filter(opt => opt.text !== choice)[0].selected = true;
    }
  }
}

function addToExcludeInput(id, item) {
  const input = document.getElementById(id);
  const list = input.value.split(',').filter(word => word != '');
  list.push(item);

  input.value = list.join(',');
}

function removeFromExcludeInput(id, item) {
  const input = document.getElementById(id);
  const currentList = input.value.split(',').filter(word => word != "");
  const newList = currentList.filter(word => word != item);

  input.value = newList.join(',');
}

function initSelectFields(){
  const allButtons = Array.from($('[data-select-toggler]'));

  // find all the disabled 'remove' buttons
  allButtons.filter((button) => {
    return button.disabled && button.dataset.selectToggler == 'remove';

  // now map that disabled button to the option it's disabled.
  }).map((button) => {
    const li = button.parentElement;
    const optionText = $(li).find('[data-select-value]')[0].textContent;
    const select = document.getElementById(button.dataset.selectId);
    const selectOptions = Array.from(select.options);
    const optionToToggle = selectOptions.filter(opt => opt.text == optionText)[0];
    optionToToggle.disabled = true;
    optionToToggle.selected = false;
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
