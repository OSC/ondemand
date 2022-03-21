let fileOps = null;

$(document).ready(function () {
  fileOps = new FileOps();
  $("#directory-contents").on("newFile", function () {
    fileOps.newFilePrompt();
  });

  $("#directory-contents").on("fileOpsCreateFile", function (e, options) {
    fileOps.newFile(options.value);
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

        $("#directory-contents").trigger('table_request', eventData);

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
}