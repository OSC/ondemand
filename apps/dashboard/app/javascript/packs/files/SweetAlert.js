import Swal from 'sweetalert2'

let sweetAlert = null;

$(document).ready(function(){
  sweetAlert = new SweetAlert();
  $("#directory-contents").on("swalShowError", function(e,options) {
    sweetAlert.alertError(options.title, options.message);
  });

  $("#directory-contents").on("swalShowPrompt", function(e,options) {
    sweetAlert.alertError(options.title, options.message);
  });

  $("#directory-contents").on("swalShowInput", function(e,options) {
    sweetAlert.input(options);
  });

  $("#directory-contents").on("swalShowLoading", function(e,options) {
    sweetAlert.loading(options.message);
  });

  $("#directory-contents").on("swalClose", function() {
    sweetAlert.close();
  });

});

class SweetAlert {
  _swal = null;

  constructor() {
    this._swal = Swal;
    this.setMixin();
  }

  input(options) {
    this._swal.fire(options.inputOptions)
    .then (function(result){
      if(result.isConfirmed) {
        const eventData = {
          result: result,
          files: options.files ? options.files : null
        };

        $("#directory-contents").trigger(options.action, eventData);
      } else {
        $("#directory-contents").trigger('reloadTable');
      }
    });
  }

  setMixin() {
    this._swal.mixIn = ({
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
    this._swal.fire(error_title, error_message, 'error');
  }
  
  async loading(title) {
    this._swal.fire({
      title: title,
      allowOutsideClick: false,
      showConfirmButton: false,
      willOpen: () => { this._swal.showLoading()  }
    });
  }
  
  close() {
    this._swal.close();
  }  
}



