import {triggerReloadTable, Swal } from './index.js';
import {alertError} from './sweet_alert.js';

export { FileOps };

class FileOps {    
    _table = null;
    _swal = Swal;

    constructor(table) {
        this._table = table;
    }
    
    newFilePrompt() {
        this._swal.fire({
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
          .then (function(result){
            if(result.isConfirmed) {
                const eventData = {
                    type: "createFile",
                    fileName: result.value
                };
        
                $("#directory-contents").trigger('table_request', eventData);
                        
            } else {
                triggerReloadTable();
            }
          })
          .then((filename) => this.newFile(filename));      
    }
    
    newFile(filename) {
        fetch(`${history.state.currentDirectoryUrl}/${encodeURI(filename)}?touch=true`, {method: 'put', headers: { 'X-CSRF-Token': csrf_token }})
        .then( function(response) {
            const eventData = {
                type: "getDataFromJsonResponse",
                response: response
            };
    
            $("#directory-contents").trigger('table_request', eventData);

        })
        .then( function() {
            $("#directory-contents").trigger('table_request', {type: "reloadTable" });
        })
        .catch( function(e) {
            alertError('Error occurred when attempting to create new file', e.message);
        });
      }
      
}