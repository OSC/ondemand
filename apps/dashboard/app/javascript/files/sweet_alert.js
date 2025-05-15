import Swal from 'sweetalert2';
import { OODAlert } from '../alert';
import {CONTENTID, EVENTNAME as DATATABLE_EVENTNAME} from './data_table.js';
import { pageSpin, stopPageSpin } from '../utils';

export {EVENTNAME};

const EVENTNAME = {
  showError: 'showError',
  showInput: 'showInput',
  showLoading: 'showLoading',
  showPrompt: 'showPrompt',
  closeSwal: 'closeSwal',
}

let sweetAlert = null;

function modifyInput(options) {
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
      OODAlert(error);
    } else {
      $(CONTENTID).trigger(options.action, eventData);
    }

    input.value = '';
    $('#files_input_modal').modal('hide');
  };
}

jQuery(function() {
  sweetAlert = new SweetAlert();

  $(CONTENTID).on(EVENTNAME.showError, function(e,options) {
    OODAlert(options.message);
  });

  $(CONTENTID).on(EVENTNAME.showPrompt, function(e,options) {
    sweetAlert.alertError(options.title, options.message);
  });

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

class SweetAlert {

  constructor() {
    this.setMixin();
  }

  input(options) {
    Swal.fire(options.inputOptions)
    .then (function(result){
      if(result.isConfirmed) {
        const eventData = {
          result: result,
          files: options.files ? options.files : null
        };

        $(CONTENTID).trigger(options.action, eventData);
      } else {
        $(CONTENTID).trigger(DATATABLE_EVENTNAME.reloadTable);
      }
    });
  }

  setMixin() {
    Swal.mixIn = ({
      showClass: {
        popup: 'swal2-noanimation',
        backdrop: 'swal2-noanimation'
      },
      hideClass: {
        popup: '',
        backdrop: ''
      }    
    });
  }

  alertError(error_title, error_message) {
    Swal.fire(error_title, error_message, 'error');
  }
  
  async loading(title) {
    Swal.fire({
      title: title,
      allowOutsideClick: false,
      showConfirmButton: false,
      returnFocus: false,
      willOpen: () => { Swal.showLoading()  }
    });
  }
  
  close() {
    Swal.close();
  }  
}
