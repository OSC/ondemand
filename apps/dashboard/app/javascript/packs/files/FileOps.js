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
      .then(function (response) {
        const eventData = {
          type: "getDataFromJsonResponse",
          response: response
        };

        $("#directory-contents").trigger('getDataFromJsonResponse', eventData);

      })
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
      .then(function (response) {
        const eventData = {
          type: "getDataFromJsonResponse",
          response: response
        };

        $("#directory-contents").trigger('getDataFromJsonResponse', eventData);

      })
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


}