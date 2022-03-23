import Handlebars from 'handlebars';

let fileOps = null;

$(document).ready(function () {
  fileOps = new FileOps();
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
        $("#directory-contents").trigger('reloadTable');
      })
      .catch(function (e) {
        const eventData = {
          'title': 'Error occurred when attempting to create new file',
          'message': e.message,
        };

        $("#directory-contents").trigger('swalShowError', eventData);

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
        $("#directory-contents").trigger('reloadTable');
      })
      .catch(function (e) {
        const eventData = {
          'title': 'Error occurred when attempting to create new folder',
          'message': e.message,
        };

        $("#directory-contents").trigger('swalShowError', eventData);

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
  
    const eventData = {
      'message': 'preparing to download directory: ' + file.name,
    };

    $("#directory-contents").trigger('swalShowLoading', eventData);
  
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
          $("#directory-contents").trigger('swalClose');
          this.downloadFile(file)
        } else {
          const eventData = {
            'title': 'Error while downloading',
            'message': data.error_message,
          };

          $("#directory-contents").trigger('swalClose');
          $("#directory-contents").trigger('showError', eventData);

        }
      })
      .catch(e => {
        const eventData = {
          'title': 'Error while downloading',
          'message': e.message,
        };

        $("#directory-contents").trigger('swalClose');
        $("#directory-contents").trigger('showError', eventData);
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
    $("#directory-contents").trigger('swalClose');
    $("#directory-contents").trigger('reloadTable');

  }    
  
  delete(files) {
    const eventData = {
      'message': 'Deleting files...: ',
    };

    $("#directory-contents").trigger('swalShowLoading', eventData);

    this.removeFiles(files.map(f => [history.state.currentDirectory, f].join('/')), csrf_token);
  }

  async transferFiles(files, action, summary) {
    const eventData = {
      'message': _.startCase(summary),
    };

    $("#directory-contents").trigger('swalShowLoading', eventData);
  
    try {
      const response = await fetch(transfersPath, {
        method: 'post',
        body: JSON.stringify({
          command: action,
          files: files
        }),
        headers: { 'X-CSRF-Token': csrf_token }
      });
      const data = await this.dataFromJsonResponse(response);
      if (!data.completed) {
        // was async, gotta report on progress and start polling
        this.reportTransfer(data);
      }
      else {
        if (data.target_dir == history.state.currentDirectory) {
          $("#directory-contents").trigger('reloadTable');
        }
      }

      if (action == 'mv' || action == 'cp') {
        $("#directory-contents").trigger('clipboardClear');
        $("#directory-contents").trigger('reloadTable');
      }

      return;
    } catch (e) {
      const eventData = {
        'title': 'Error occurred when attempting to ' + summary,
        'message': e.message,
      };

      $("#directory-contents").trigger('showError', eventData);
    }
  }
  
  reportTransfer(data) {
    // 1. add the transfer label
    findAndUpdateTransferStatus(data);

    let attempts = 0

    // 2. poll for the updates
    var poll = function() {
      $.getJSON(data.show_json_url, function (newdata) {
        this.findAndUpdateTransferStatus(newdata);

        if(newdata.completed) {
          if(! newdata.error_message) {
            if(newdata.target_dir == history.state.currentDirectory) {
              // reloadTable();
            }

            // 3. fade out after 5 seconds
            this.fadeOutTransferStatus(newdata)
          }
        }
        else {
          // not completed yet, so poll again
          setTimeout(poll, 1000);
        }
      }).fail(function() {
        if (attempts >= 3) {
          // Swal.fire('Operation may not have happened', 'Failed to retrieve file operation status.', 'error');
        } else {
          setTimeout(poll, 1000);
          attempts++;
        }
      });
    }

    poll();

  }
  
  findAndUpdateTransferStatus(data) {
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

  move(files, token) {
    this.transferFiles(files, 'mv', 'move files');
    $("#directory-contents").trigger('swalClose');  
  }

  copy(files, token) {
    this.transferFiles(files, 'cp', 'copy files');  
    $("#directory-contents").trigger('swalClose');
  }

  reportTransferTemplate = (function(){
    let template_str  = $('#transfer-template').html();
    return Handlebars.compile(template_str);
  })();
 
}