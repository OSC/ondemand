'use strict';

let newFieldTemplate = undefined;

function addNewField(_event) {
  const lastOption = $('.new_script').find('.form-group').last();
  lastOption.after(newFieldTemplate.html());

  const justAdded = lastOption.next();
  const deleteButton = justAdded.find('.btn-danger');
  const addButton = justAdded.find('.btn-success');

  deleteButton.on('click', (event) => { deleteInProgressField(event) });
  addButton.on('click', (event) => { addInProgressField(event) });
}

function deleteInProgressField(event) {  
  const entireDiv = event.target.parentElement.parentElement;
  entireDiv.remove();
}

function addInProgressField(event) {  
  console.log('TODO');
}

jQuery(() => {
  newFieldTemplate = $('#new_field_template');
  $('#add_new_field_button').on('click', (event) => { addNewField(event) });
});
