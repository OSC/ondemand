import Swal from 'sweetalert2'

export { Swal, alertError, loading, doneLoading };

global.Swal = Swal.mixin({
  showClass: {
    popup: 'swal2-noanimation',
    backdrop: 'swal2-noanimation'
  },
  hideClass: {
    popup: '',
    backdrop: ''
  }
});

$(document).ready(function(){

});

function alertError(error_title, error_message){
  Swal.fire(error_title, error_message, 'error');
}

function loading(title){
  Swal.fire({
    title: title,
    allowOutsideClick: false,
    showConfirmButton: false,
    willOpen: () => { Swal.showLoading()  }
  });
}

function doneLoading(){
  Swal.close();
}
