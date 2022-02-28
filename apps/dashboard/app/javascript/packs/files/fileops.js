import {Swal, alertError} from './sweet_alert.js';
import {dataFromJsonResponse} from './datatable.js';

export {getEmptyDirs, downloadDirectory, downloadFile};

$(document).ready(function(){

  $('#new-file-btn').on("click", () => {
    Swal.fire({
      title: 'New File',
      input: 'text',
      inputLabel: 'Filename',
      showCancelButton: true,
      inputValidator: (value) => {
        if (! value ) {
          // TODO: validate filenames against listing
          return 'Provide a non-empty filename.'
        }
        else if (value.includes("/")) {
          // TODO: validate filenames against listing
          return 'Illegal character (/) not allowed in filename.'
        }
      }
    })
    .then((result) => result.isConfirmed ? Promise.resolve(result.value) : Promise.reject('cancelled'))
    .then((filename) => newFile(filename));
  });
  
  $('#new-dir-btn').on("click", () => {
    Swal.fire({
      title: 'New Directory',
      input: 'text',
      inputLabel: 'Directory name',
      inputAttributes: {
        spellcheck: 'false',
      },
      showCancelButton: true,
      inputValidator: (value) => {
        if (! value || value.includes("/")) {
          // TODO: validate filenames against listing
          return 'Provide a directory name that does not have / in it'
        }
      },
    })
    .then((result) => result.isConfirmed ? Promise.resolve(result.value) : Promise.reject('cancelled'))
    .then((filename) => newDirectory(filename));
  });
    
  $('#download-btn').on("click", () => {
    let selection = table.rows({ selected: true }).data();
    if(selection.length == 0) {
      Swal.fire('Select a file, files, or directory to download', 'You have selected none.', 'error');
    }
    selection.toArray().forEach( (f) => {
      if(f.type == 'd') {
        downloadDirectory(f)
      }
      else if(f.type == 'f') {
        downloadFile(f)
      }
    })
  });
    
});

function newDirectory(filename){
  fetch(`${history.state.currentDirectoryUrl}/${encodeURI(filename)}?dir=true`, {method: 'put', headers: { 'X-CSRF-Token': csrf_token }})
  .then(response => dataFromJsonResponse(response))
  .then(() => reloadTable())
  .catch(e => alertError('Error occurred when attempting to create new directory', e.message));
}

function newFile(filename){
  fetch(`${history.state.currentDirectoryUrl}/${encodeURI(filename)}?touch=true`, {method: 'put', headers: { 'X-CSRF-Token': csrf_token }})
  .then(response => dataFromJsonResponse(response))
  .then(() => reloadTable())
  .catch(e => alertError('Error occurred when attempting to create new file', e.message));
}

function getEmptyDirs(entry){
  return new Promise((resolve) => {
    if(entry.isFile){
      resolve([]);
    }
    else{
      // getFilesAndDirectoriesFromDirectory has no return value, so turn this into a promise
      getFilesAndDirectoriesFromDirectory(entry.createReader(), [], function(error){ console.error(error)}, {
        onSuccess: (entries) => {
          if(entries.length == 0){
            // this is an empty directory
            resolve([entry]);
          }
          else{
            Promise.all(entries.map(e => getEmptyDirs(e))).then((dirs) => resolve(_.flattenDeep(dirs)));
          }
        }
      })
    }
  });
}

function downloadDirectory(file) {
  let filename = $($.parseHTML(file.name)).text(),
      canDownloadReq = `${history.state.currentDirectoryUrl}/${encodeURI(filename)}?can_download=${Date.now().toString()}`

  loading('preparing to download directory: ' + file.name)

  fetch(canDownloadReq, {
      method: 'GET',
      headers: {
        'X-CSRF-Token': csrf_token,
        'Accept': 'application/json'
      }
    })
    .then(response => dataFromJsonResponse(response))
    .then(data => {
      if (data.can_download) {
        doneLoading();
        downloadFile(file)
      } else {
        Swal.fire(dashboard_files_directory_download_error_modal_title, data.error_message, 'error')
      }
    })
    .catch(e => {
      Swal.fire(dashboard_files_directory_download_error_modal_title, e.message, 'error')
    })
}

function downloadFile(file) {
  // creating the temporary iframe is exactly what the CloudCmd does
  // so this just repeats the status quo

  let filename = $($.parseHTML(file.name)).text(),
      downloadUrl = `${history.state.currentDirectoryUrl}/${encodeURI(filename)}?download=${Date.now().toString()}`,
      iframe = document.createElement('iframe'),
      TIME = 30 * 1000;

  iframe.setAttribute('class', 'd-none');
  iframe.setAttribute('src', downloadUrl);

  document.body.appendChild(iframe);

  setTimeout(function() {
    document.body.removeChild(iframe);
  }, TIME);
}
