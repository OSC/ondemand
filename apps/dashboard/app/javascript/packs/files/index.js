import ClipboardJS from 'clipboard'
import Swal from 'sweetalert2'
import { Uppy, BasePlugin } from '@uppy/core'
import Dashboard from '@uppy/dashboard'
import XHRUpload from '@uppy/xhr-upload'
import Handlebars from 'handlebars';
import _ from 'lodash';
import 'datatables.net';
import 'datatables.net-bs4/js/dataTables.bootstrap4';
import 'datatables.net-select';
import 'datatables.net-select-bs4';

window.ClipboardJS = ClipboardJS
window.Uppy = Uppy
window.BasePlugin = BasePlugin
window.Dashboard = Dashboard
window.XHRUpload = XHRUpload
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
window.alertError = alertError;
window.dataFromJsonResponse = dataFromJsonResponse;
window.newFile = newFile;
window.newDirectory = newDirectory;
window.reloadTable = reloadTable;
window.goto = goto;
window.loading = loading;
window.doneLoading = doneLoading;
window.$ = $;
window.jQuery = jQuery;
window._ = _;
window.Handlebars = Handlebars;

function alertError(error_title, error_message){
  Swal.fire(error_title, error_message, 'error');
}

function dataFromJsonResponse(response){
  return new Promise((resolve, reject) => {
    Promise.resolve(response)
    .then(response => response.ok ? Promise.resolve(response) : Promise.reject(new Error(response.statusText)))
    .then(response => response.json())
    .then(data => data.error_message ? Promise.reject(new Error(data.error_message)) : resolve(data))
    .catch((e) => reject(e))
  });
}

function newFile(filename){
  fetch(`${history.state.currentDirectoryUrl}/${encodeURI(filename)}?touch=true`, {method: 'put', headers: { 'X-CSRF-Token': csrf_token }})
  .then(response => dataFromJsonResponse(response))
  .then(() => reloadTable())
  .catch(e => alertError('Error occurred when attempting to create new file', e.message));
}

function newDirectory(filename){
  fetch(`${history.state.currentDirectoryUrl}/${encodeURI(filename)}?dir=true`, {method: 'put', headers: { 'X-CSRF-Token': csrf_token }})
  .then(response => dataFromJsonResponse(response))
  .then(() => reloadTable())
  .catch(e => alertError('Error occurred when attempting to create new directory', e.message));
}

function reloadTable(url){
  var request_url = url || history.state.currentDirectoryUrl;

  return fetch(request_url, {headers: {'Accept':'application/json'}})
    .then(response => dataFromJsonResponse(response))
    .then(function(data) {
      $('#shell-wrapper').replaceWith((data.shell_dropdown_html))

      table.clear();
      table.rows.add(data.files);
      table.draw();

      $('#open-in-terminal-btn').attr('href', data.shell_url);
      $('#open-in-terminal-btn').removeClass('disabled');

      return Promise.resolve(data);
    })
    .catch((e) => {
      Swal.fire(e.message, `Error occurred when attempting to access ${request_url}`, 'error');

      $('#open-in-terminal-btn').addClass('disabled');
      return Promise.reject(e);
    });
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
