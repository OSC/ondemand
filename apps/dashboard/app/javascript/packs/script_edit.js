'use strict';

let newFieldTemplate = undefined;

const helpTextLookup = {
  "bc_num_hours": "How long the job can run for.",
  "auto_queues": "Which queue the job will submit too.",
  "bc_num_slots": "How many nodes the job will run on."
}

function addNewField(_event) {
  const lastOption = $('.new_script').find('.form-group').last();
  lastOption.after(newFieldTemplate.html());

  const justAdded = lastOption.next();
  const deleteButton = justAdded.find('.btn-danger');
  const addButton = justAdded.find('.btn-success');
  const selectMenu = justAdded.find('select');

  deleteButton.on('click', (event) => { deleteInProgressField(event) });
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

function deleteInProgressField(event) {  
  const entireDiv = event.target.parentElement.parentElement.parentElement;
  entireDiv.remove();
}

function addInProgressField(event) {  
  console.log('TODO');
}

jQuery(() => {
  newFieldTemplate = $('#new_field_template');
  $('#add_new_field_button').on('click', (event) => { addNewField(event) });
});
