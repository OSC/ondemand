import Swal from 'sweetalert2'
import {CONTENTID, EVENTNAME as DATATABLE_EVENTNAME} from './data_table.js';

export {EVENTNAME};

const EVENTNAME = {
  showError: 'showError',
  showInput: 'showInput',
  showLoading: 'showLoading',
  showPrompt: 'showPrompt',
  closeSwal: 'closeSwal',
}

let sweetAlert = null;

jQuery(function() {
  sweetAlert = new SweetAlert();
  $(CONTENTID).on(EVENTNAME.showError, function(e,options) {
    sweetAlert.alertError(options.title, options.message);
  });

  $(CONTENTID).on(EVENTNAME.showPrompt, function(e,options) {
    sweetAlert.alertError(options.title, options.message);
  });

  $(CONTENTID).on(EVENTNAME.showInput, function(e,options) {
    sweetAlert.input(options);
  });

  $(CONTENTID).on(EVENTNAME.showLoading, function(e,options) {
    sweetAlert.loading(options.message);
  });

  $(CONTENTID).on(EVENTNAME.closeSwal, function() {
    sweetAlert.close();
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
      willOpen: () => { Swal.showLoading()  }
    });
  }
  
  close() {
    Swal.close();
  }  
}
