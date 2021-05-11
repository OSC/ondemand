import ClipboardJS from 'clipboard'
import Swal from 'sweetalert2'

window.ClipboardJS = ClipboardJS
window.Swal        = Swal.mixin({
  showClass: {
    popup: 'swal2-noanimation',
    backdrop: 'swal2-noanimation'
  },
  hideClass: {
    popup: '',
    backdrop: ''
  }
});
