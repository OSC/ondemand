// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require_tree .

$(document).ready( function() {

    var table = $('#job_status_table').DataTable({
        ajax: './pages/json',       // 'pages#json'
        "sAjaxDataProp": "",        // There's no data header on the json.
        // "bAutoWidth": false,        // Fit this inside of the div.
        autoWidth: true,
        "aaSorting": [],            // Turn off auto sort.
        // deferRender: true,          // Render the view after the file is downloaded.
        // pagingType: 'full_numbers',
        // processing: true,           // Add the "processing" while json is being downloaded.
        //serverSide: true,
        columns: [
            {
                "className":        'details-control',
                "orderable":        false,
                "data":             null,
                "defaultContent":   ''
            },
            { data: "pbsid" },
            {
                data:               "jobname",
                css:                "word-wrap: break-word;"
            },
            { data: "username" },
            {
                data: "status",
                "render": function(data,type,row,meta) {
                         return status_label(data);
                }
            },
            { data: "cluster" }
        ]
    });
        // Optional, if you want full pagination controls.
        // Check dataTables documentation to learn more about available options.
        // http://datatables.net/reference/option/pagingType

    // Add event listener for opening and closing details
    $('#job_status_table tbody').on('click', 'td', function () {
        var tr = $(this).closest('tr');
        var row = table.row( tr );

        if ( row.child.isShown() ) {
            // This row is already open - close it
            row.child.hide();
            tr.removeClass('shown');
        }
        else {
            // Open this row
            row.child( format(row.data()) ).show();
            tr.addClass('shown');
        }
    });
});

/* Formatting function for dropdown row. */
function format ( d ) {
    // `d` is the original data object for the row
    return '<table cellpadding="5" cellspacing="0" border="0" style="padding-left:250px;">'+
        '<tr>'+
        '<td>PBSID:</td>'+
        '<td>'+d.pbsid+'</td>'+
        '</tr>'+
        '<tr>'+
        '<td>Job Name:</td>'+
        '<td>'+d.jobname+'</td>'+
        '</tr>'+
        '<tr>'+
        '<td>Cluster:</td>'+
        '<td>'+d.cluster+'</td>'+
        '</tr>'+
        '</table>';
}

function status_label( status ) {
    var label, labelclass;
    switch( status ) {
        case "C":
            label = "Completed";
            labelclass = "label-success";
            break;
        case "R":
            label = "Running";
            labelclass = "label-primary";
            break;
        case "Q":
            label = "Queued";
            labelclass = "label-info";
        case "H":
            label = "Hold";
            labelclass = "label-warning";
            break;
        case "E":
            label = "Exiting";
            labelclass = "label-info";
            break;
        case "S":
            label = "Suspend";
            labelclass = "label-warning";
            break;
        case "T":
            label = "Transiting";
            labelclass = "label-warning";
            break;
        case "W":
            label = "Waiting";
            labelclass = "label-info";
            break;
        default:
            label = "Not Submitted";
            labelclass = "label-default";
    }
    return "<span class='label "+labelclass+"'>"+label+"</span>";
}
