import Handlebars from 'handlebars';
import {CONTENTID, EVENTNAME as DATATABLE_EVENTNAME} from './data_table.js';
import {EVENTNAME as CLIPBOARD_EVENTNAME} from './clip_board.js';
import {EVENTNAME as SWAL_EVENTNAME} from './sweet_alert.js';

export {EVENTNAME};

const EVENTNAME = {
  changeDirectory: 'changeDirectory',
  changeDirectoryPrompt: 'changeDirectoryPrompt',
  copyFile: 'copyFile',
  createFile: 'createFile',
  createFolder: 'createFolder',
  deleteFile: 'deleteFile',
  deletePrompt: 'deletePrompt',
  download: 'download',
  moveFile: 'moveFile',
  newFile: 'newFile',
  newFilePrompt: 'newFilePrompt',
  newFolderPrompt: 'newFolderPrompt',
  newFolder: 'newFolder',
  renameFile: 'renameFile',
  renameFilePrompt: 'renameFilePrompt',
}


let fileOps = null;

let reportTransferTemplate = null;

jQuery(function() {
  fileOps = new FileOps();
  
  $(CONTENTID.table).on(EVENTNAME.newFilePrompt, function () {
    fileOps.newFilePrompt();
  });

  $(CONTENTID.table).on(EVENTNAME.newFolderPrompt, function () {
    fileOps.newFolderPrompt();
  });

  $(CONTENTID.table).on(EVENTNAME.renameFilePrompt, function (e, options) {
    fileOps.renameFilePrompt(options.file);
  });

  $(CONTENTID.table).on(EVENTNAME.renameFile, function (e, options) {
    fileOps.renameFile(options.files, options.result.value);
  });

  $(CONTENTID.table).on(EVENTNAME.createFile, function (e, options) {
    fileOps.newFile(options.result.value);
  });

  $(CONTENTID.table).on(EVENTNAME.createFolder, function (e, options) {
    fileOps.newFolder(options.result.value);
  });

  $(CONTENTID.table).on(EVENTNAME.download, function (e, options) {
    if(options.selection.length == 0) {
      const eventData = {
          'title': 'Select a file, files, or directory to download',
          'message': 'You have selected none.',
      };

      $(CONTENTID.table).trigger(SWAL_EVENTNAME.showError, eventData);

    } else {
      fileOps.download(options.selection);
    }
  });

  $(CONTENTID.table).on(EVENTNAME.deletePrompt, function (e, options) {
    if(options.files.length == 0) {
      const eventData = {
          'title': 'Select a file, files, or directory to delete.',
          'message': 'You have selected none.',
      };

      $(CONTENTID.table).trigger(SWAL_EVENTNAME.showError, eventData);

    } else {
      fileOps.deletePrompt(options.files);
    }
  });

  $(CONTENTID.table).on(EVENTNAME.deleteFile, function (e, options) {    
    fileOps.delete(options.files);
  });

  $(CONTENTID.table).on(EVENTNAME.moveFile, function (e, options) {
    fileOps.move(options.files, options.token);
  });

  $(CONTENTID.table).on(EVENTNAME.copyFile, function (e, options) {
    fileOps.copy(options.files, options.token);
  });

  $(CONTENTID.table).on(EVENTNAME.changeDirectoryPrompt, function () {
    fileOps.changeDirectoryPrompt();
  });

  $(CONTENTID.table).on(EVENTNAME.changeDirectory, function (e, options) {
    fileOps.changeDirectory(options.result.value);
  });

});

class FileOps {
  _timeout = 2000;
  _attempts = 0;
  _filesPath = filesPath;

  constructor() {
  }

  changeDirectory(path) {
    this.goto(filesPath + path);
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

    $(CONTENTID.table).trigger(SWAL_EVENTNAME.showInput, eventData);

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

    $(CONTENTID.table).trigger(SWAL_EVENTNAME.showInput, eventData);

  }

  
  removeFiles(files) {
    this.transferFiles(files, "rm", "remove files")
  } 

  renameFile(fileName, newFileName) {
    let files = {};
    files[`${history.state.currentDirectory}/${fileName}`] = `${history.state.currentDirectory}/${newFileName}`;
    this.transferFiles(files, "mv", "rename file")
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

    $(CONTENTID.table).trigger(SWAL_EVENTNAME.showInput, eventData);

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

    $(CONTENTID.table).trigger(SWAL_EVENTNAME.showInput, eventData);

  }

  newFile(filename) {
    let myFileOp = new FileOps();
    fetch(`${history.state.currentDirectoryUrl}/${encodeURI(filename)}?touch=true`, { method: 'put', headers: { 'X-CSRF-Token': csrf_token } })
      .then(response => this.dataFromJsonResponse(response))
      .then(function () {
        myFileOp.reloadTable();
      })
      .catch(function (e) {
        myFileOp.alertError('Error occurred when attempting to create new file', e.message);
      });
  }

  newFolderPrompt() {

    const eventData = {
      action: EVENTNAME.createFolder,
      'inputOptions': {
        title: 'New Folder',
        input: 'text',
        inputLabel: 'Folder name',
        showCancelButton: true,
        inputValidator: (value) => {
          if (!value || value.includes("/")) {
            // TODO: validate filenames against listing
            return 'Provide a directory name that does not have / in it'
          }
        }
      }
    };

    $(CONTENTID.table).trigger(SWAL_EVENTNAME.showInput, eventData);

  }

  newFolder(filename) {
    let myFileOp = new FileOps();
    fetch(`${history.state.currentDirectoryUrl}/${encodeURI(filename)}?dir=true`, {method: 'put', headers: { 'X-CSRF-Token': csrf_token }})
      .then(response => this.dataFromJsonResponse(response))
      .then(function () {
        myFileOp.reloadTable();
      })
      .catch(function (e) {
        myFileOp.alertError('Error occurred when attempting to create new folder', e.message);
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
          'X-CSRF-Token': csrf_token,
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
        const eventData = {
          'title': 'Error while downloading',
          'message': e.message,
        };

        this.doneLoading();
        this.alertError('Error while downloading', data.error_message);
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

    this.removeFiles(files.map(f => [history.state.currentDirectory, f].join('/')), csrf_token);
  }

  transferFiles(files, action, summary){

    this._attempts = 0;

    this.showSwalLoading(_.startCase(summary));
  
    return fetch(transfersPath, {
      method: 'post',
      body: JSON.stringify({
        command: action,
        files: files
      }),
      headers: { 'X-CSRF-Token': csrf_token }
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
      }

      this.fadeOutTransferStatus(data);
      this.doneLoading();
      this.reloadTable();

    })
    .then(() => this.doneLoading())
    .catch(e => this.alertError('Error occurred when attempting to ' + summary, e.message))
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
  
  reportTransferTemplate = (function(){
    let template_str  = $('#transfer-template').html();
    return Handlebars.compile(template_str);
  })();

  poll(data) {
    $.getJSON(data.show_json_url, function (newdata) {
      // because of getJSON not being an actual piece of the object, we need to instantiate an instance FileOps for this section of code.
      let myFileOp = new FileOps();
      myFileOp.findAndUpdateTransferStatus(newdata);

      if(newdata.completed) {
        if(! newdata.error_message) {
          if(newdata.target_dir == history.state.currentDirectory) {
            myFileOp.reloadTable();
          }

          // 3. fade out after 5 seconds
          myFileOp.fadeOutTransferStatus(newdata)
        }
      }
      else {
        // not completed yet, so poll again
        setTimeout(function(){
          myFileOp._attempts++;
        }, myFileOp._timeout);
      }
    }).fail(function() {
      if (myFileOp._attempts >= 3) {
        myFileOp.alertError('Operation may not have happened', 'Failed to retrieve file operation status.');  
      } else {
        setTimeout(function(){
          tmyFileOphis._attempts++;
        }, myFileOp._timeout);
      }
    });
  }
  

  reportTransfer(data) {
    // 1. add the transfer label
    this.findAndUpdateTransferStatus(data);
    this.poll(data);
  } 

  move(files, token) {
    this.transferFiles(files, 'mv', 'move files');
  }

  copy(files, token) {
    this.transferFiles(files, 'cp', 'copy files');  
  }

  alertError(title, message) {
    const eventData = {
      'title': title,
      'message': message,
    };

    $(CONTENTID.table).trigger(SWAL_EVENTNAME.showError, eventData);

  }

  doneLoading() {
    $(CONTENTID.table).trigger(SWAL_EVENTNAME.closeSwal);
  }

  clearClipboard() {
    $(CONTENTID.table).trigger(CLIPBOARD_EVENTNAME.clearClipboard);
  }

  reloadTable(url) {
    const eventData = {
      'url': url,
    };

    $(CONTENTID.table).trigger(DATATABLE_EVENTNAME.reloadTable, eventData);
  }

  showSwalLoading (message) {
    const eventData = {
      'message': message,
    };

    $(CONTENTID.table).trigger(SWAL_EVENTNAME.showLoading, eventData);

  }

  goto(url) {
    window.open(url,"_self");
  }  
}