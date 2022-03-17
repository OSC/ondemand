import { Swal } from './sweet_alert.js';
import { DataTable } from './DataTable.js';
import { FileOps } from './FileOps.js';
/*
import {} from './fileops.js';
import {} from './uppy.js';
import {} from './clipboard.js';
*/

export { Swal, triggerReloadTable };


$(document).ready(function() {
    let dataTable = new DataTable();
    let fileOps = null;

    $("#new-file-btn").on("click", function() {
        const eventData = {
            type: "newFile"
        };

        $("#directory-contents").trigger('table_request', eventData);
    });
    
    if( ! alert ) {
        dataTable.reloadTable();
    }

    $("#directory-contents").on("table_request", function(event, options) {
        switch (options.type) {
            case 'reloadTable':
                dataTable.reloadTable();
                break;
            case 'newFile':
                fileOps = new FileOps(dataTable);
                fileOps.newFilePrompt();
                break;
            case 'createFile':
                fileOps = new FileOps(dataTable);
                fileOps.newFile(options.fileName);
                triggerReloadTable();
                break;
            case 'getDataFromJsonResponse':
                dataTable.dataFromJsonResponse(options.response);
                break;
            default:
                triggerReloadTable();
                break;
        }

        
    });

    // Options represents the functionality of the Files App that you want to include.

    /* END Basic table functionality. */

});
  
function triggerReloadTable() {
    $("#directory-contents").trigger('table-request', { type: 'reloadTable' });
}
