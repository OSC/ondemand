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

function lastOption() {
  return $('.new_script').find('.editable-form-field').last();
}

function addNewField(_event) {
  const last = lastOption();
  last.after(newFieldTemplate.html());

  const justAdded = last.next();
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
  for(var newField in newFieldData) {
    field = document.getElementById(`script_${newField}`);

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
}

function removeField(event) {
  // TODO: shouldn't be able to remove cluster & script form fields.
  const entireDiv = event.target.parentElement;
  entireDiv.remove();
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

  const last = lastOption();
  last.after(template.html());

  const justAdded = last.next();
  justAdded.find('.btn-danger')
           .on('click', (event) => { removeField(event) });

  justAdded.find('.btn-primary')
           .on('click', (event) => { showEditField(event) });

  const entireDiv = event.target.parentElement.parentElement.parentElement;
  entireDiv.remove();
}

function enableOrDisableSelectOption(event) {
  const toggleAction = event.target.dataset.selectToggler;
  const li = event.target.parentElement;
  event.target.disabled = true;

  const inputId = event.target.dataset.target;
  const choice = $(li).find('[data-select-value]')[0].textContent;

  const select = document.getElementById(event.target.dataset.selectId);
  const selectOptions = Array.from(select.options);
  const optionToToggle = selectOptions.filter(opt => opt.value == choice)[0];

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
});
