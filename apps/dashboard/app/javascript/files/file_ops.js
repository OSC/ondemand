import {CONTENTID, EVENTNAME as DATATABLE_EVENTNAME} from './data_table.js';
import {EVENTNAME as CLIPBOARD_EVENTNAME} from './clip_board.js';
import {EVENTNAME as SWAL_EVENTNAME} from './sweet_alert.js';
import _ from 'lodash';
import { transfersPath, csrfToken } from '../config.js';

export {EVENTNAME};

const EVENTNAME = {
  changeDirectory: 'changeDirectory',
  changeDirectoryPrompt: 'changeDirectoryPrompt',
  copyFile: 'copyFile',
  createFile: 'createFile',
  createDirectory: 'createDirectory',
  deleteFile: 'deleteFile',
  deletePrompt: 'deletePrompt',
  download: 'download',
  moveFile: 'moveFile',
  newFile: 'newFile',
  newFilePrompt: 'newFilePrompt',
  newDirectoryPrompt: 'newDirectoryPrompt',
  newDirectory: 'newDirectory',
  renameFile: 'renameFile',
  renameFilePrompt: 'renameFilePrompt',
}


let fileOps = null;
export {fileOps};

jQuery(function() {
  fileOps = new FileOps();  

  $('#directory-contents tbody, #path-breadcrumbs, #favorites').on('click', 'a.d', function(event){
    if(fileOps.clickEventIsSignificant(event)){
      event.preventDefault();
      event.cancelBubble = true;
      if(event.stopPropagation) event.stopPropagation();

      const eventData = {
        'path': this.getAttribute("href"),
      };
  
      $(CONTENTID).trigger(DATATABLE_EVENTNAME.goto, eventData);
  
    }
  });

  $('#directory-contents tbody').on('click', 'tr td:first-child input[type=checkbox]', function (e) {
    if (this.dataset['dlUrl'] == 'undefined' && this.checked) {
      $("#download-btn").attr('disabled', true);
    } else if ($("input[data-dl-url='undefined']:checked" ).length == 0) {
      $("#download-btn").attr('disabled', false);
    }
  });
  
  $('#directory-contents tbody').on('dblclick', 'tr td:not(:first-child)', function(){
    // handle doubleclick
    let a = this.parentElement.querySelector('a');
    if(a.classList.contains('d')) {
      const eventData = {
        'path': a.getAttribute("href"),
      };
  
      $(CONTENTID).trigger(DATATABLE_EVENTNAME.goto, eventData);
    }
  });

  $('#directory-contents tbody').on('click', '.download-file', function(e){
    e.preventDefault();

    const table = $(CONTENTID).DataTable();
    const row = e.currentTarget.dataset.rowIndex;

    const eventData = {
      selection:  table.rows(row).data()
    };

    $(CONTENTID).trigger(EVENTNAME.download, eventData);
  });

  $("#refresh-btn").on("click", function () {
    $(CONTENTID).trigger(DATATABLE_EVENTNAME.reloadTable);
  });

  $("#new-file-btn").on("click", function () {
    $(CONTENTID).trigger(EVENTNAME.newFilePrompt);
  });

  $("#new-dir-btn").on("click", function () {
      $(CONTENTID).trigger(EVENTNAME.newDirectoryPrompt);
  });

  $("#download-btn").on("click", function () {
    let table = $(CONTENTID).DataTable();
    let selection = table.rows({ selected: true }).data();
    const eventData = {
        selection: selection
    };

    $(CONTENTID).trigger(EVENTNAME.download, eventData);

  });

  $("#delete-btn").on("click", function () {

    let table = $(CONTENTID).DataTable();
    let files = table.rows({ selected: true }).data().toArray().map((f) => f.name);
    const eventData = {
        files: files
    };

    $(CONTENTID).trigger(EVENTNAME.deletePrompt, eventData);

  });

  $(document).on("click", '#goto-btn', function () {
      $(CONTENTID).trigger(EVENTNAME.changeDirectoryPrompt);
  });

  $(document).on('click', '.rename-file', function (e) {
    e.preventDefault();
    let table = $(CONTENTID).DataTable();
    let rowId = e.currentTarget.dataset.rowIndex;
    let row = table.row(rowId).data();
    let fileName = $($.parseHTML(row.name)).text();

    const eventData = {
        file: fileName,
    };
    
    $(CONTENTID).trigger(EVENTNAME.renameFilePrompt, eventData);

  });

  $(document).on('click', '.delete-file', function (e) {
      e.preventDefault();
      let table = $(CONTENTID).DataTable();
      let rowId = e.currentTarget.dataset.rowIndex;
      let row = table.row(rowId).data();
      let fileName = $($.parseHTML(row.name)).text();

      const eventData = {
          files: [fileName]
      };

      $(CONTENTID).trigger(EVENTNAME.deletePrompt, eventData);

  });

  $(CONTENTID).on(EVENTNAME.newFilePrompt, function () {
    fileOps.newFilePrompt();
  });

  $(CONTENTID).on(EVENTNAME.newDirectoryPrompt, function () {
    fileOps.newDirectoryPrompt();
  });

  $(CONTENTID).on(EVENTNAME.renameFilePrompt, function (e, options) {
    fileOps.renameFilePrompt(options.file);
  });

  $(CONTENTID).on(EVENTNAME.renameFile, function (e, options) {
    fileOps.renameFile(options.files, options.result.value);
  });

  $(CONTENTID).on(EVENTNAME.createFile, function (e, options) {
    fileOps.newFile(options.result.value);
  });

  $(CONTENTID).on(EVENTNAME.createDirectory, function (e, options) {
    fileOps.newDirectory(options.result.value);
  });

  $(CONTENTID).on(EVENTNAME.download, function (e, options) {
    if(options.selection.length == 0) {
      const eventData = {
          'title': 'Select a file, files, or directory to download',
          'message': 'You have selected none.',
      };

      $(CONTENTID).trigger(SWAL_EVENTNAME.showError, eventData);

    } else {
      fileOps.download(options.selection);
    }
  });

  $(CONTENTID).on(EVENTNAME.deletePrompt, function (e, options) {
    if(options.files.length == 0) {
      const eventData = {
          'title': 'Select a file, files, or directory to delete.',
          'message': 'You have selected none.',
      };

      $(CONTENTID).trigger(SWAL_EVENTNAME.showError, eventData);

    } else {
      fileOps.deletePrompt(options.files);
    }
  });

  $(CONTENTID).on(EVENTNAME.deleteFile, function (e, options) {    
    fileOps.delete(options.files, options.from_fs);
  });

  $(CONTENTID).on(EVENTNAME.moveFile, function (e, options) {
    fileOps.move(options.files, options.token, options.from_fs, options.to_fs);
  });

  $(CONTENTID).on(EVENTNAME.copyFile, function (e, options) {
    fileOps.copy(options.files, options.token, options.from_fs, options.to_fs);
  });

  $(CONTENTID).on(EVENTNAME.changeDirectoryPrompt, function () {
    fileOps.changeDirectoryPrompt();
  });

  $(CONTENTID).on(EVENTNAME.changeDirectory, function (e, options) {
    fileOps.changeDirectory(options.result.value);
  });

});

class FileOps {
  _timeout = 2000;
  _failures = 0;
  // this seems to not be used anywhere?
  _filesPath = history.state.currentFilesPath;

  constructor() {
  }

  clickEventIsSignificant(event) {
    return !(
      // (event.target && (event.target as any).isContentEditable)
         event.defaultPrevented
      || event.which > 1
      || event.altKey
      || event.ctrlKey
      || event.metaKey
      || event.shiftKey
    )
  }

  changeDirectory(path) {
    const eventData = {
      'path': history.state.currentFilesPath + path,
    };

    $(CONTENTID).trigger(DATATABLE_EVENTNAME.goto, eventData);

  }

  changeDirectoryPrompt() {
    const eventData = {
      action: 'changeDirectory',
      'inputOptions': {
        title: 'Change Directory',
        input: 'text',
        inputLabel: 'Path',
        inputValue:  history.state.currentDirectory,
        inputAttributes: {
          spellcheck: 'false',
        },
        showCancelButton: true,
        inputValidator: (value) => {
          if (! value || ! value.startsWith('/')) {
            // TODO: validate filenames against listing
            return 'Provide an absolute pathname'
          }
        }
      }
    };

    $(CONTENTID).trigger(SWAL_EVENTNAME.showInput, eventData);

  }

  deletePrompt(files) {
    const eventData = {
      action: EVENTNAME.deleteFile,
      files: files,
      'inputOptions': {
        title: files.length == 1 ? `Delete ${files[0]}?` : `Delete ${files.length} selected files?`,
        text: 'Are you sure you want to delete the files: ' + files.join(', '),
        showCancelButton: true,
      }
    };

    $(CONTENTID).trigger(SWAL_EVENTNAME.showInput, eventData);

  }

  
  removeFiles(files) {
    this.transferFiles(files, "rm", "remove files", history.state.currentFilesystem)
  } 

  renameFile(fileName, newFileName) {
    let files = {};
    files[`${history.state.currentDirectory}/${fileName}`] = `${history.state.currentDirectory}/${newFileName}`;
    this.transferFiles(files, "mv", "rename file", history.state.currentFilesystem, history.state.currentFilesystem)
  }

  renameFilePrompt(fileName) {
    const eventData = {
      action: EVENTNAME.renameFile,
      files: fileName,
      'inputOptions': {
        title: 'Rename',
        input: 'text',
        inputLabel: 'Filename',
        inputValue: fileName,
        inputAttributes: {
          spellcheck: 'false',
        },
        showCancelButton: true,
        inputValidator: (value) => {
          if (! value) {
            // TODO: validate filenames against listing
            return 'Provide a filename to rename this to';
          } else if (value.includes('/') || value.includes('..')) {
           return 'Filename cannot include / or ..';
          }
        }
      }
    };

    $(CONTENTID).trigger(SWAL_EVENTNAME.showInput, eventData);

  }



  newFilePrompt() {

    const eventData = {
      action: EVENTNAME.createFile,
      'inputOptions': {
        title: 'New File',
        input: 'text',
        inputLabel: 'Filename',
        showCancelButton: true,
        inputValidator: (value) => {
          if (!value) {
            // TODO: validate filenames against listing
            return 'Provide a non-empty filename.'
          }
          else if (value.includes("/")) {
            // TODO: validate filenames against listing
            return 'Illegal character (/) not allowed in filename.'
          }
        }
      }
    };

    $(CONTENTID).trigger(SWAL_EVENTNAME.showInput, eventData);

  }

  newFile(filename) {
    let myFileOp = new FileOps();
    fetch(`${history.state.currentDirectoryUrl}/${encodeURI(filename)}?touch=true`, { method: 'put', headers: { 'X-CSRF-Token': csrfToken() } })
      .then(response => this.dataFromJsonResponse(response))
      .then(function () {
        myFileOp.reloadTable();
      })
      .catch(function (e) {
        myFileOp.alertError('Error occurred when attempting to create new file', e.message);
      });
  }

  newDirectoryPrompt() {

    const eventData = {
      action: EVENTNAME.createDirectory,
      'inputOptions': {
        title: 'New Directory',
        input: 'text',
        inputLabel: 'Directory name',
        showCancelButton: true,
        inputValidator: (value) => {
          if (!value || value.includes("/")) {
            // TODO: validate filenames against listing
            return 'Provide a directory name that does not have / in it'
          }
        }
      }
    };

    $(CONTENTID).trigger(SWAL_EVENTNAME.showInput, eventData);

  }

  newDirectory(filename) {
    let myFileOp = new FileOps();
    fetch(`${history.state.currentDirectoryUrl}/${encodeURI(filename)}?dir=true`, {method: 'put', headers: { 'X-CSRF-Token': csrfToken() }})
      .then(response => this.dataFromJsonResponse(response))
      .then(function () {
        myFileOp.reloadTable();
      })
      .catch(function (e) {
        myFileOp.alertError('Error occurred when attempting to create new directory', e.message);
      });
  }

  download(selection) {
    selection.toArray().forEach( (f) => {
      if(f.type == 'd') {
        this.downloadDirectory(f);
      } else if (f.type == 'f') {
        this.downloadFile(f);
      }
    });
  }

  downloadDirectory(file) {
    let filename = $($.parseHTML(file.name)).text(),
        canDownloadReq = `${history.state.currentDirectoryUrl}/${encodeURI(filename)}?can_download=${Date.now().toString()}`

    this.showSwalLoading('preparing to download directory: ' + file.name);
  
    fetch(canDownloadReq, {
        method: 'GET',
        headers: {
          'X-CSRF-Token': csrfToken(),
          'Accept': 'application/json'
        }
      })
      .then(response => this.dataFromJsonResponse(response))
      .then(data => {
        if (data.can_download) {
          this.doneLoading();
          this.downloadFile(file)
        } else {
          this.doneLoading();
          this.alertError('Error while downloading', data.error_message);
        }
      })
      .catch(e => {
        this.doneLoading();
        this.alertError('Error while downloading', e.message);
      })
  }
  
 
  downloadFile(file) {
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
  
  dataFromJsonResponse(response) {
    return new Promise((resolve, reject) => {
        Promise.resolve(response)
            .then(response => response.ok ? Promise.resolve(response) : Promise.reject(new Error(response.statusText)))
            .then(response => response.json())
            .then(data => data.error_message ? Promise.reject(new Error(data.error_message)) : resolve(data))
            .catch((e) => reject(e))
    });
  }
    
  
  delete(files) {
    this.showSwalLoading('Deleting files...: ');

    this.removeFiles(files.map(f => [history.state.currentDirectory, f].join('/')), csrfToken() );
  }

  transferFiles(files, action, summary, from_fs, to_fs){

    this._failures = 0;

    this.showSwalLoading(_.startCase(summary));
  
    return fetch(transfersPath(), {
      method: 'post',
      body: JSON.stringify({
        command: action,
        files: files,
        from_fs: from_fs,
        to_fs: to_fs,
      }),
      headers: { 'X-CSRF-Token': csrfToken() }
    })
    .then(response => this.dataFromJsonResponse(response))
    .then((data) => {
  
      if(! data.completed){
        // was async, gotta report on progress and start polling
        this.reportTransfer(data);
        this.findAndUpdateTransferStatus(data);
      } else {
        // if(data.target_dir == history.state.currentDirectory){
        // }
        // this.findAndUpdateTransferStatus(data);
      }
  
      if(action == 'mv' || action == 'cp') {
        this.reloadTable();
        this.clearClipboard();
        this.updateClipboard();
      }

      this.fadeOutTransferStatus(data);
      this.doneLoading();
      this.reloadTable();

    })
    .then(() => this.doneLoading())
    .catch(e => {
      this.doneLoading();
      this.alertError('Error occurred when attempting to ' + summary, e.message);
    })
  }
  
  findAndUpdateTransferStatus(data) {
    let id = `#${data.id}`;
  
    if($(id).length){
      $(id).replaceWith(this.reportTransferTemplate(data));
    } else{
      $('.transfers-status').append(this.reportTransferTemplate(data));
    }
  }
  
  fadeOutTransferStatus(data){
    let id = `#${data.id}`;
    $(id).fadeOut(4000);
  }

  reportTransferTemplate(data) {
    let html = '';
    
    if (data.completed) {
      if (data.error_summary) {
        html += `
          <div id="${data.id}" class="alert alert-danger alert-dismissible fade show" role="alert">
            <b><i class="fas fa-exclamation-triangle"></i> ${data.error_summary}</b>
            <button class="btn btn-outline-dark btn-sm ms-3 collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#${data.id}-error-report" aria-expanded="false" aria-controls="${data.id}-error-report">See details</button>
            <div id="${data.id}-error-report" class="collapse">
              <div class="mt-3 card">
                <pre class="card-body">${data.error_message}</pre>
              </div>
             </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
          </div>
        `;
      } else {
        html += `
          <span class="text-${data.bootstrap_class}" id="${data.id}">
            <b><i class="fas ${data.fa_label}"></i> ${data.summary}</b>
          </span>
        `;
      }
    } else {
      html += `
        <span class="text-${data.bootstrap_class}" id="${data.id}">
          <b><i class="fas ${data.fa_label}"></i> ${data.summary}</b>
        </span>
      `;
    }
    
    return html;
  };
  
  poll(data) {

    let that = this;

    $.getJSON(data.show_json_url, function (newdata) {
      that.findAndUpdateTransferStatus(newdata);

      if(newdata.completed) {
        if(! newdata.error_message) {
          if(newdata.target_dir == history.state.currentDirectory) {
            that.reloadTable();
          }
          // 3. fade out after 5 seconds
          that.fadeOutTransferStatus(newdata)
        }
      } else {
        // not completed yet, so poll again
        setTimeout(function() {
          that.poll(data);
        }, that._timeout);
      }
    }).fail(function() {
      if (that._failures >= 3) {
        that.alertError('Operation may not have happened', 'Failed to retrieve file operation status.');  
      } else {
        setTimeout(function(){
          that._failures++;
          that.poll(data);
        }, that._timeout);
      }
    });
  }
  

  reportTransfer(data) {
    // 1. add the transfer label
    this.findAndUpdateTransferStatus(data);
    this.poll(data);
  } 

  move(files, token, from_fs, to_fs) {
    this.transferFiles(files, 'mv', 'move files', from_fs, to_fs);
  }

  copy(files, token, from_fs, to_fs) {
    this.transferFiles(files, 'cp', 'copy files', from_fs, to_fs);
  }

  alertError(title, message) {
    const eventData = {
      'title': title,
      'message': message,
    };

    $(CONTENTID).trigger(SWAL_EVENTNAME.showError, eventData);

  }

  doneLoading() {
    $(CONTENTID).trigger(SWAL_EVENTNAME.closeSwal);
  }

  clearClipboard() {
    $(CONTENTID).trigger(CLIPBOARD_EVENTNAME.clearClipboard);
  }

  reloadTable(url) {
    const eventData = {
      'url': url,
    };

    $(CONTENTID).trigger(DATATABLE_EVENTNAME.reloadTable, eventData);
  }

  showSwalLoading(message) {
    const eventData = {
      'message': message,
    };

    $(CONTENTID).trigger(SWAL_EVENTNAME.showLoading, eventData);

  }

  updateClipboard() {
    $(CONTENTID).trigger(CLIPBOARD_EVENTNAME.updateClipboardView);
  }

}
