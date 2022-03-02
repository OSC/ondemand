import {Swal, alertError, doneLoading, loading} from './sweet_alert.js';
import {dataFromJsonResponse,Handlebars, table} from './datatable.js';
import {clearClipboard, updateViewForClipboard } from './clipboard.js';

export {copyFiles, downloadDirectory, downloadFile, getEmptyDirs, reportTransferTemplate};

var reportTransferTemplate = null;

$(document).ready(function(){

  reportTransferTemplate = (function(){
    let template_str  = $('#transfer-template').html();
    return Handlebars.compile(template_str);
  })();
  
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

  $('#clipboard-move-to-dir').on("click", () => {
    let clipboard = JSON.parse(localStorage.getItem('filesClipboard') || 'null');

    if(clipboard){
      clipboard.to = history.state.currentDirectory;

      if(clipboard.from == clipboard.to){
        console.error('clipboard from and to are identical')
        // TODO:
      }
      else{
        let files = {};
        clipboard.files.forEach((f) => {
          files[`${clipboard.from}/${f.name}`] = `${history.state.currentDirectory}/${f.name}`
        });

        moveFiles(files, csrf_token);
      }
    }
    else{
      console.error('files clipboard is empty');
    }
  });
  
  $('#clipboard-copy-to-dir').on("click", () => {
    let clipboard = JSON.parse(localStorage.getItem('filesClipboard') || 'null');

    if(clipboard){
      clipboard.to = history.state.currentDirectory;

      if(clipboard.from == clipboard.to){
        console.error('clipboard from and to are identical')

        // TODO: we want to support this use case
        // copy and paste as a new filename
        // but lots of edge cases
        // (overwrite or rename duplicates)
        // _copy
        // _copy_2
        // _copy_3
        // _copy_4
      }
      else{
        // [{"/from/file/path":"/to/file/path" }]
        let files = {};
        clipboard.files.forEach((f) => {
          files[`${clipboard.from}/${f.name}`] = `${history.state.currentDirectory}/${f.name}`
        });

        copyFiles(files, csrf_token);
      }
    }
    else{
      console.error('files clipboard is empty');
    }
  });

  $('#delete-btn').on("click", () => {
    let files = table.rows({selected: true}).data().toArray().map((f) => f.name);
    deleteFiles(files);
  });

  $('#directory-contents tbody').on('click', '.rename-file', function(e){
    e.preventDefault();
  
    let row = table.row(this.dataset.rowIndex).data();
  
    // if there was some other attribute that just had the name...
    let filename = $($.parseHTML(row.name)).text();
  
    Swal.fire({
      title: 'Rename',
      input: 'text',
      inputLabel: 'Filename',
      inputValue: filename,
      inputAttributes: {
        spellcheck: 'false',
      },
      showCancelButton: true,
      inputValidator: (value) => {
        if (! value) {
          // TODO: validate filenames against listing
          return 'Provide a filename to rename this to';
        }
        else if (value.includes('/') || value.includes('..')){
         return 'Filename cannot include / or ..';
        }
      }
    })
    .then((result) => result.isConfirmed ? Promise.resolve(result.value) : Promise.reject('cancelled'))
    .then((new_filename) => renameFile(filename, new_filename))
  });
    
  $('#directory-contents tbody').on('click', '.delete-file', function(e){
    e.preventDefault();
  
    let row = table.row(this.dataset.rowIndex).data();
    deleteFiles([row.name]);
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

function transferFiles(files, action, summary){
  loading(_.startCase(summary));

  return fetch(transfersPath, {
    method: 'post',
    body: JSON.stringify({
      command: action,
      files: files
    }),
    headers: { 'X-CSRF-Token': csrf_token }
  })
  .then(response => dataFromJsonResponse(response))
  .then((data) => {

    if(! data.completed){
      // was async, gotta report on progress and start polling
      reportTransfer(data);
    }
    else {
      if(data.target_dir == history.state.currentDirectory){
        reloadTable();
      }
    }

    if(action == 'mv' || action == 'cp'){
      clearClipboard();
      updateViewForClipboard();
    }
  })
  .then(() => doneLoading())
  .catch(e => alertError('Error occurred when attempting to ' + summary, e.message))
}

function copyFiles(files){
  transferFiles(files, "cp", "copy files")
}

function reportTransfer(data){
  // 1. add the transfer label
  findAndUpdateTransferStatus(data);

  let attempts = 0

  // 2. poll for the updates
  var poll = function() {
    $.getJSON(data.show_json_url, function (newdata) {
      findAndUpdateTransferStatus(newdata);

      if(newdata.completed) {
        if(! newdata.error_message) {
          if(newdata.target_dir == history.state.currentDirectory) {
            reloadTable();
          }

          // 3. fade out after 5 seconds
          fadeOutTransferStatus(newdata)
        }
      }
      else {
        // not completed yet, so poll again
        setTimeout(poll, 1000);
      }
    }).fail(function() {
      if (attempts >= 3) {
        Swal.fire('Operation may not have happened', 'Failed to retrieve file operation status.', 'error');
      } else {
        setTimeout(poll, 1000);
        attempts++;
      }
    });
  }

  poll();
}

function renameFile(filename, new_filename){
  let files = {};
  files[`${history.state.currentDirectory}/${filename}`] = `${history.state.currentDirectory}/${new_filename}`;
  transferFiles(files, "mv", "rename file")
}

function moveFiles(files, summary = "move files"){
  transferFiles(files, "mv", "move files")
}

function removeFiles(files){
  transferFiles(files, "rm", "remove files")
}

function findAndUpdateTransferStatus(data){
  let id = `#${data.id}`;

  if($(id).length){
    $(id).replaceWith(reportTransferTemplate(data));
  }
  else{
    $('.transfers-status').append(reportTransferTemplate(data));
  }
}

function fadeOutTransferStatus(data){
  let id = `#${data.id}`;
  $(id).fadeOut(4000);
}

function deleteFiles(files){
  if(! files.length > 0){
    return;
  }

  Swal.fire({
    title: files.length == 1 ? `Delete ${files[0]}?` : `Delete ${files.length} selected files?`,
    text: 'Are you sure you want to delete the files: ' + files.join(', '),
    showCancelButton: true,
  })
  .then((result) => {
    if(result.isConfirmed){
      loading('Deleting files...');
      removeFiles(files.map(f => [history.state.currentDirectory, f].join('/')), csrf_token);
    }
  })
}
