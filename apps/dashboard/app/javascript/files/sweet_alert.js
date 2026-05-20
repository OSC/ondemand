import {CONTENTID, EVENTNAME as DATATABLE_EVENTNAME} from './data_table.js';
import { pageSpin, stopPageSpin, getBoolean, storeBoolean } from '../utils';
export {EVENTNAME};

const EVENTNAME = {
  showInput: 'showInput',
  showLoading: 'showLoading',
  closeSwal: 'closeSwal',
}

const UPLOAD_OVERWRITE_STORAGE_KEY = 'files-upload-overwrite-warning-disabled';
const MODAL_ID = '#files_input_modal';

let uploadOverwriteOkHandler = null;
let uploadOverwriteHiddenHandler = null;

function cleanupBootstrapModalStack() {
  document.querySelectorAll('.modal-backdrop').forEach((backdrop) => {
    backdrop.remove();
  });
  document.body.classList.remove('modal-open');
  document.body.style.removeProperty('overflow');
  document.body.style.removeProperty('padding-right');
}

function modifyInput(options) {
  resetUploadOverwriteModal();

  const title = options.inputOptions.title;
  const titleElement = document.getElementById('files_input_modal_title');
  titleElement.textContent = title;

  const label = options.inputOptions.inputLabel;
  const labelElement = document.getElementById('files_input_modal_label');
  labelElement.textContent = label;

  const wrapper = document.getElementById('files_input_modal_input_wrapper');
  const span = document.getElementById('files_input_modal_text_span');

  // deleting files does not have a input box. It just has the span
  // to display an 'Are you sure' message.
  if(options.inputOptions.input && options.inputOptions.input == 'text') {
    wrapper.classList.remove('d-none');
    span.textContent = '';
  } else {
    wrapper.classList.add('d-none');
    if(options.inputOptions.text) {
      span.textContent = options.inputOptions.text;
    }
  }

  if(options.inputOptions.inputValue) {
    const input = document.getElementById('files_input_modal_input');
    input.value = options.inputOptions.inputValue;
  }

  attachOKHandler(options);
}

function attachOKHandler(options) {
  const button = document.getElementById('files_input_modal_ok_button');
  button.onclick = () => {
    const input = document.getElementById('files_input_modal_input');
    const value = input.value;
    const eventData = {
      files: options.files ? options.files : null,
      result: {
        value: value
      }
    };

    const validator = options.inputOptions.inputValidator;
    let error = undefined;
    if(validator && typeof(validator) == 'function') {
      error = validator(value);
    }

    if(error) {
      OODAlertError(error);
    } else {
      $(CONTENTID).trigger(options.action, eventData);
    }

    input.value = '';
    $(MODAL_ID).modal('hide');
  };
}

function resetUploadOverwriteModal() {
  const modalElement = document.getElementById('files_input_modal');
  const okButton = document.getElementById('files_input_modal_ok_button');
  const neverShowWrapper = document.getElementById('files_input_modal_never_show_wrapper');
  const neverShowCheckbox = document.getElementById('files_input_modal_never_show');

  if (neverShowWrapper) {
    neverShowWrapper.classList.add('d-none');
  }
  
  if (neverShowCheckbox) {
    neverShowCheckbox.checked = false;
  }
  okButton.onclick = null;
  okButton.textContent = modalElement.dataset.defaultOkLabel || okButton.textContent;

  if (uploadOverwriteOkHandler) {
    okButton.removeEventListener('click', uploadOverwriteOkHandler);
    uploadOverwriteOkHandler = null;
  }

  if (uploadOverwriteHiddenHandler) {
    modalElement.removeEventListener('hidden.bs.modal', uploadOverwriteHiddenHandler);
    uploadOverwriteHiddenHandler = null;
  }

  const span = document.getElementById('files_input_modal_text_span');
  if (span) {
    span.replaceChildren();
  }
}

function hideUploadOverwriteModal() {
  resetUploadOverwriteModal();
  $(MODAL_ID).modal('hide');
  cleanupBootstrapModalStack();
}

function setUploadOverwriteContent(modalElement, titleElement, spanElement, conflictingFilenames) {
  const dataset = modalElement.dataset;

  if (conflictingFilenames.length === 1) {
    titleElement.textContent = dataset.uploadOverwriteTitle;
    spanElement.textContent = dataset.uploadOverwriteMessageSingle.replace('%{filename}', conflictingFilenames[0]);
    return;
  }

  titleElement.textContent = dataset.uploadOverwriteTitleMultiple;
  spanElement.textContent = '';

  spanElement.appendChild(document.createTextNode(`${dataset.uploadOverwriteMessageMultiple}:`));

  const list = document.createElement('ul');
  list.className = 'mb-0 mt-2';

  conflictingFilenames.forEach((filename) => {
    const item = document.createElement('li');
    item.textContent = filename;
    list.appendChild(item);
  });

  spanElement.appendChild(list);
}

function showUploadOverwriteModal(conflictingFilenames) {
  resetUploadOverwriteModal();

  const modalElement = document.getElementById('files_input_modal');
  const titleElement = document.getElementById('files_input_modal_title');
  const wrapper = document.getElementById('files_input_modal_input_wrapper');
  const span = document.getElementById('files_input_modal_text_span');
  const neverShowWrapper = document.getElementById('files_input_modal_never_show_wrapper');
  const neverShowCheckbox = document.getElementById('files_input_modal_never_show');
  const okButton = document.getElementById('files_input_modal_ok_button');

  if (!modalElement.dataset.defaultOkLabel) {
    modalElement.dataset.defaultOkLabel = okButton.textContent;
  }

  setUploadOverwriteContent(modalElement, titleElement, span, conflictingFilenames);
  wrapper.classList.add('d-none');
  if (neverShowWrapper) {
    neverShowWrapper.classList.remove('d-none');
  }
  okButton.textContent = modalElement.dataset.uploadOverwriteContinue;

  return new Promise((resolve, reject) => {
    let continued = false;

    const cleanup = () => {
      if (uploadOverwriteOkHandler) {
        okButton.removeEventListener('click', uploadOverwriteOkHandler);
        uploadOverwriteOkHandler = null;
      }

      if (uploadOverwriteHiddenHandler) {
        modalElement.removeEventListener('hidden.bs.modal', uploadOverwriteHiddenHandler);
        uploadOverwriteHiddenHandler = null;
      }
    };

    uploadOverwriteOkHandler = () => {
      continued = true;

      if (neverShowCheckbox.checked) {
        storeBoolean(UPLOAD_OVERWRITE_STORAGE_KEY, true);
      }

      cleanup();
      hideUploadOverwriteModal();
      resolve(true);
    };

    uploadOverwriteHiddenHandler = () => {
      cleanup();
      hideUploadOverwriteModal();

      if (!continued) {
        reject();
      }
    };

    okButton.addEventListener('click', uploadOverwriteOkHandler);
    modalElement.addEventListener('shown.bs.modal', () => {
      modalElement.addEventListener('hidden.bs.modal', uploadOverwriteHiddenHandler, { once: true });
    }, { once: true });

    $(MODAL_ID).modal('show');
    okButton.focus();
  });
}

export function confirmUploadOverwrite(conflictingFilenames) {
  if (getBoolean(UPLOAD_OVERWRITE_STORAGE_KEY) || conflictingFilenames.length === 0) {
    return Promise.resolve(true);
  }

  return showUploadOverwriteModal(conflictingFilenames).then(() => true, () => false);
}

jQuery(function() {

  $(CONTENTID).on(EVENTNAME.showInput, function(e, options) {
    modifyInput(options);
    $('#files_input_modal').modal('show');
  });

  $(CONTENTID).on(EVENTNAME.showLoading, function(e,options) {
    pageSpin();
  });

  $(CONTENTID).on(EVENTNAME.closeSwal, function() {
    stopPageSpin();
  });

});
