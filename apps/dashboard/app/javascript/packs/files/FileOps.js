import Handlebars from 'handlebars';

let fileOps = null;

let reportTransferTemplate = null;

$(document).ready(function () {
  fileOps = new FileOps();

  reportTransferTemplate = (function(){
    let template_str  = $('#transfer-template').html();
    return Handlebars.compile(template_str);
  })();
  

  $("#directory-contents").on("fileOpsNewFile", function () {
    fileOps.newFilePrompt();
  });

  $("#directory-contents").on("fileOpsNewFolder", function () {
    fileOps.newFolderPrompt();
  });

  $("#directory-contents").on("fileOpsCreateFile", function (e, options) {
    fileOps.newFile(options.result.value);
  });

  $("#directory-contents").on("fileOpsCreateFolder", function (e, options) {
    fileOps.newFolder(options.result.value);
  });

  // $("#directory-contents").on("fileOpsUpload", function (e, options) {
  //   fileOps.newFolder(options.value);
  // });

  $("#directory-contents").on("fileOpsDownload", function (e, options) {
    fileOps.download(options.selection);
  });

  $("#directory-contents").on("fileOpsDeletePrompt", function (e, options) {
    fileOps.deletePrompt(options.files);
  });

  $("#directory-contents").on("fileOpsDelete", function (e, options) {
    fileOps.delete(options.files);
  });

  $("#directory-contents").on("fileOpsMove", function (e, options) {
    fileOps.move(options.files, options.token);
  });

  $("#directory-contents").on("fileOpsCopy", function (e, options) {
    fileOps.copy(options.files, options.token);
  });

});

class FileOps {
  _handleBars = null;
  _timeout = 2000;
  
  constructor() {
    this._handleBars = Handlebars;
  }


  newFilePrompt() {

    const eventData = {
      action: 'fileOpsCreateFile',
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

    $("#directory-contents").trigger('swalShowInput', eventData);

  }

  newFile(filename) {
    fetch(`${history.state.currentDirectoryUrl}/${encodeURI(filename)}?touch=true`, { method: 'put', headers: { 'X-CSRF-Token': csrf_token } })
      .then(response => this.dataFromJsonResponse(response))
      .then(function () {
        this.reloadTable();
      })
      .catch(function (e) {
        this.alertError('Error occurred when attempting to create new file', e.message);
      });
  }

  newFolderPrompt() {

    const eventData = {
      action: 'fileOpsCreateFolder',
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

    $("#directory-contents").trigger('swalShowInput', eventData);

  }

  newFolder(filename) {
    fetch(`${history.state.currentDirectoryUrl}/${encodeURI(filename)}?dir=true`, {method: 'put', headers: { 'X-CSRF-Token': csrf_token }})
      .then(response => this.dataFromJsonResponse(response))
      .then(function () {
        this.reloadTable();
      })
      .catch(function (e) {
        this.alertError('Error occurred when attempting to create new folder', e.message);
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
 
   deletePrompt(files) {
    const eventData = {
      action: 'fileOpsDelete',
      files: files,
      'inputOptions': {
        title: files.length == 1 ? `Delete ${files[0]}?` : `Delete ${files.length} selected files?`,
        text: 'Are you sure you want to delete the files: ' + files.join(', '),
        showCancelButton: true,
      }
    };

    $("#directory-contents").trigger('swalShowInput', eventData);

  }

  
  removeFiles(files){
    this.transferFiles(files, "rm", "remove files")
    this.doneLoading();
    this.reloadTable();
  }    
  
  delete(files) {
    this.showSwalLoading('Deleting files...: ');

    this.removeFiles(files.map(f => [history.state.currentDirectory, f].join('/')), csrf_token);
  }

  transferFiles(files, action, summary){

    this.showSwalLoading(_.startCase(summary));
  
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
        this.reportTransfer(data);
      }
      else {
        if(data.target_dir == history.state.currentDirectory){
          this.reloadTable();
        }
      }
  
      if(action == 'mv' || action == 'cp') {
        this.clearClipboard();
      }
    })
    .then(
      () => this.doneLoading()
    )
    .catch(e => this.alertError('Error occurred when attempting to ' + summary, e.message))
  }
  
  findAndUpdateTransferStatus(data){
    let id = `#${data.id}`;
  
    if($(id).length){
      $(id).replaceWith(this.reportTransferTemplate(data));
    }
    else{
      $('.transfers-status').append(this.reportTransferTemplate(data));
    }
  }
  
  fadeOutTransferStatus(data){
    let id = `#${data.id}`;
    $(id).fadeOut(4000);
  }
  
  
  reportTransfer(data){
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
              this.reloadTable();
            }
  
            // 3. fade out after 5 seconds
            this.fadeOutTransferStatus(newdata)
          }
        }
        else {
          // not completed yet, so poll again
          setTimeout(function(){
            attempts++;
          }, this._timeout);
        }
      }).fail(function() {
        if (attempts >= 3) {
          this.alertError('Operation may not have happened', 'Failed to retrieve file operation status.');  
        } else {
          setTimeout(function(){
            attempts++;
          }, this._timeout);
        }
      });
    }
  
    poll();
  } 

  move(files, token) {
    this.transferFiles(files, 'mv', 'move files');
    this.doneLoading();
  }

  copy(files, token) {
    this.transferFiles(files, 'cp', 'copy files');  
    this.doneLoading();
  }

  alertError(title, message) {
    const eventData = {
      'title': title,
      'message': message,
    };

    $("#directory-contents").trigger('showError', eventData);

  }

  doneLoading() {
    $("#directory-contents").trigger('swalClose');
  }

  clearClipboard() {
    $("#directory-contents").trigger('clipboardClear');
  }

  reloadTable() {
    $("#directory-contents").trigger('reloadTable');
  }

  showSwalLoading (message) {
    const eventData = {
      'message': message,
    };

    $("#directory-contents").trigger('swalShowLoading', eventData);

  }
}