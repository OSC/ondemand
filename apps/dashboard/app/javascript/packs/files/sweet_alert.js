import Swal from 'sweetalert2'
import {CONTENTID, TRIGGERID} from './data_table.js';

let sweetAlert = null;

jQuery(function() {
  sweetAlert = new SweetAlert();
  $(CONTENTID.table).on(TRIGGERID.showError, function(e,options) {
    sweetAlert.alertError(options.title, options.message);
  });

  $(CONTENTID.table).on(TRIGGERID.showPrompt, function(e,options) {
    sweetAlert.alertError(options.title, options.message);
  });

  $(CONTENTID.table).on(TRIGGERID.showInput, function(e,options) {
    sweetAlert.input(options);
  });

  $(CONTENTID.table).on(TRIGGERID.showLoading, function(e,options) {
    sweetAlert.loading(options.message);
  });

  $(CONTENTID.table).on(TRIGGERID.closeSwal, function() {
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

        $(CONTENTID.table).trigger(options.action, eventData);
      } else {
        $(CONTENTID.table).trigger(TRIGGERID.reloadTable);
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
