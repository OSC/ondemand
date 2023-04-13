'use strict';

let newFieldTemplate = undefined;

const helpTextLookup = {
  "bc_num_hours": "How long the job can run for.",
  "auto_queues": "Which queue the job will submit too.",
  "bc_num_slots": "How many nodes the job will run on."
}

function addNewField(_event) {
  const lastOption = $('.new_script').find('.editable-form-field').last();
  lastOption.after(newFieldTemplate.html());

  const justAdded = lastOption.next();
  const deleteButton = justAdded.find('.btn-danger');
  const addButton = justAdded.find('.btn-success');
  const selectMenu = justAdded.find('select');

  deleteButton.on('click', (event) => { removeInProgressField(event) });
  addButton.on('click', (event) => { addInProgressField(event) });
  selectMenu.on('change', (event) => { addHelpTextForOption(event) });

  // initialize the help text
  addHelpTextForOption({ target: selectMenu.get(0) });
}

function addHelpTextForOption(event) {
  const helpText = helpTextLookup[event.target.value];
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
  console.log('TODO');
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
});
