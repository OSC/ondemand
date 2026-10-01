'use strict';

/*
 * launcher_edit.js drives the "Add new option" dropdown from its own newFieldData object, 
 * which lists every launcher field. On the workflow page we only want to expose a subset of the options.
 */

const ALLOWED = [
  'auto_accounts',
  'auto_environment_variable',
  'auto_queues',
  'auto_batch_clusters',
  'bc_num_hours',
  'auto_job_name'
];
const REPEATABLE = ['auto_environment_variable'];

// Mirrors the labels in launcher_edit.js's newFieldData, used when we
// need to re-insert a repeatable option that launcher_edit.js skipped.
const REPEATABLE_LABELS = {
  auto_environment_variable: 'Environment Variable'
};

function filterDropdown(selectEl) {
  Array.from(selectEl.options).forEach((opt) => {
    if (ALLOWED.indexOf(opt.value) === -1) {
      opt.remove();
    }
  });

  REPEATABLE.forEach((id) => {
    if (ALLOWED.indexOf(id) === -1) return;
    const present = Array.from(selectEl.options).some((opt) => opt.value === id);
    if (!present) {
      const opt = document.createElement('option');
      opt.value = id;
      opt.text = REPEATABLE_LABELS[id] || id;
      selectEl.add(opt);
    }
  });
}

function refreshAddButtonLabel() {
  const btn = document.getElementById('add_new_field_button');
  if (!btn) return;

  const remaining = ALLOWED.some((id) => {
    if (REPEATABLE.indexOf(id) !== -1) return true;
    return document.getElementById('launcher_' + id) === null;
  });
  btn.textContent = remaining ? 'Add new option' : 'No more options';
  btn.disabled = !remaining;
}

// launcher_edit.js remove/edit click handler uses: $('.new_launcher').find('.editable-form-field')...
// The workflow form has no `.new_launcher` thus Remove button does nothing.
// Newly-added fields are unaffected because addInProgressField attach handlers.
function wireExistingFieldHandlers() {
  const card = document.getElementById('workflow_advanced_card');
  if (!card) return;

  card.querySelectorAll('.editable-form-field .btn-danger').forEach((btn) => {
    btn.addEventListener('click', (event) => {
      const entireDiv = event.target.parentElement;
      entireDiv.remove();
      refreshAddButtonLabel();
    });
  });

  card.querySelectorAll('.editable-form-field .btn-primary').forEach((editBtn) => {
    editBtn.addEventListener('click', (event) => {
      const entireDiv = event.target.parentElement;
      const editField = entireDiv.querySelector('.edit-group');
      if (editField) editField.classList.remove('d-none');

      const saveButton = entireDiv.querySelector('.btn-success');
      if (saveButton) saveButton.classList.remove('d-none');
      event.target.disabled = true;

      if (saveButton) {
        saveButton.onclick = (e) => {
          const div = e.target.parentElement;
          const ef = div.querySelector('.edit-group');
          if (ef) ef.classList.add('d-none');
          const sb = div.querySelector('.btn-success');
          const eb = div.querySelector('.btn-primary');
          if (sb) sb.classList.add('d-none');
          if (eb) eb.disabled = false;
        };
      }
    });
  });
}

document.addEventListener('DOMContentLoaded', () => {
  const btn = document.getElementById('add_new_field_button');
  if (!btn) return;

  // We wait one tick after that click fires so the options exist
  btn.addEventListener('click', () => {
    setTimeout(() => {
      const sel = document.getElementById('add_new_field_select');
      if (sel) filterDropdown(sel);
    }, 0);
  });

  wireExistingFieldHandlers();
  refreshAddButtonLabel();

  const card = document.getElementById('workflow_advanced_card');
  if (card) {
    card.addEventListener('click', () => {
      setTimeout(refreshAddButtonLabel, 0);
    });
  }
});
