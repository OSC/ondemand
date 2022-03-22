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
    fileOps.newFile(options.value);
  });

  $("#directory-contents").on("fileOpsCreateFolder", function (e, options) {
    fileOps.newFolder(options.value);
  });

  $("#directory-contents").on("fileOpsUpload", function (e, options) {
    fileOps.newFolder(options.value);
  });

  $("#directory-contents").on("fileOpsDownload", function (e, options) {
    fileOps.download(options.selection);
  });

});

class FileOps {
  constructor() {
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
  
}