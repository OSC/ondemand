import { Swal } from './sweet_alert.js';
import { reloadTable } from './datatable.js';
/*
import {} from './fileops.js';
import {} from './uppy.js';
import {} from './clipboard.js';
*/

export { Swal };

$(document).ready(function() {
    /*
        BEGIN Basic table functionality.
        This section is the minimum functionality required to show the table.
        
        var tableOptions = {
            'functionality': [
                'download', 'upload', 'terminal', 'new-file','new-directory','copy-move','delete'
            ], 
        };

    */
    
    if(! alert) {
        reloadTable();
    }
    // Options represents the functionality of the Files App that you want to include.

    /* END Basic table functionality. */

});
  