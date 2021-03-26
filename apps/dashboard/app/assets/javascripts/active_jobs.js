//= require oboe/dist/oboe-browser.min
//= require datatables.net-plugins/api/processing()

$(document).ready(function(){
    $('[data-toggle="tooltip"]').tooltip();
});

var entityMap = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#39;',
  '/': '&#x2F;',
  '`': '&#x60;',
  '=': '&#x3D;'
};

function escapeHtml (string) {
  return String(string).replace(/[&<>"'`=\/]/g, function fromEntityMap (s) {
    return entityMap[s];
  });
}

function human_time(seconds_total) {
  var hours = parseInt(seconds_total / 3600),
      minutes = parseInt((seconds_total - (hours * 3600)) / 60),
      seconds = parseInt((seconds_total - (3600 * hours) - (60 * minutes))),
      hours_str = ('' + hours).padStart(2, "0"),
      minutes_str = ('' + minutes).padStart(2, "0"),
      seconds_str = ('' + seconds).padStart(2, "0");

  return hours_str + ":" + minutes_str + ":" + seconds_str;
}

function fetch_job_data(tr, row, options) {
  let btn = tr.find('button.details-control');
  if (row.child.isShown()) {
    // This row is already open - close it
    row.child.hide();
    tr.removeClass("shown");

    btn.removeClass("fa-chevron-down");
    btn.addClass("fa-chevron-right");
    btn.attr("aria-expanded", false);
  } else {
    tr.addClass("shown");

    btn.removeClass("fa-chevron-right");
    btn.addClass("fa-chevron-down");
    btn.attr("aria-expanded", true);

    let data = {
      pbsid: row.data().pbsid,
      cluster: row.data().cluster,
    };
    let jobDataUrl = `${options.base_uri}/activejobs/json?${new URLSearchParams(data)}`;

    $.getJSON(jobDataUrl, function (data) {
      // Open this row
      row.child(data.html_ganglia_graphs_table).show();
      // Add the data panel to the view
      $(`div[data-jobid="${escapeHtml(row.data().pbsid)}"]`)
        .hide()
        .html(data.html_extended_panel)
        .fadeIn(250);
      // Update the status label in the parent row
      tr.find(".status-label").html(data.status);
    }).fail(function (jqXHR, textStatus, errorThrown) {
      let error_panel = `
        <div class="alert alert-danger" role="alert">
          <strong>Error:</strong> The information could not be displayed.
          <em>${jqXHR.status} (${errorThrown})</em>
        </div>
      `;

      $(`div[data-jobid="${row.data().pbsid}]"`)
        .hide()
        .html(error_panel)
        .fadeIn(250);
    });
  }
}

function fetch_table_data(table, options){
  if (!options) options = {};
  if (!options.doneCallback) options.doneCallback = null;
  if (!options.base_uri) options.base_uri = window.location.pathname;

  oboe({
    url: options.base_uri + '/activejobs.json?'+get_request_params(),
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content'),
      'X-Requested-With': 'XMLHttpRequest',
      'Content-Type': 'application/json'
    }
  }).start(function(){
    table.processing(true);
  }).node('data.*', function(jobs){
    // data is an array of arrays, where each array has one or more jobs
    // this is called once for each array of jobs
    table.rows.add(jobs).draw();
    table.processing(false);
  }).node('errors.*', function(error){
    // errors is a single array of error messages
    // this is called once for each error msg
    show_errors([error]);
  }).done(function(){
    table.processing(false);

    if(options.doneCallback){
       options.doneCallback();
    }
  }).fail(function(errorReport){
    if(errorReport.statusCode != null){
      show_errors(["Request for jobs failed with status code: " + errorReport.statusCode]);
    }
    else{
      //FIXME: this error appears even when the above 404 occurs, for example
      // that is because a 404 responce for json request returns a plain text response
      // and parsing that as json fails
       show_errors(["Request for jobs failed due to body parsing error."])
    }

    table.processing(false);
  });
}


function status_label(status){
  var label = "Undetermined", labelclass = "label-default";

  if(status == "completed"){
    label = "Completed";
    labelclass = "label-success";
  }

  if(status == "running"){
    label = "Running";
    labelclass = "label-primary";
  }
  if(status == "queued"){
    label = "Queued";
    labelclass = "label-info";
  }
  if(status == "queued_held"){
    label = "Hold";
    labelclass = "label-warning";
  }
  if(status == "suspended"){
    label = "Suspend";
    labelclass = "label-warning";
  }

  return `<span class="label ${labelclass}">${escapeHtml(label)}</span>`;
}

function create_datatable(options){
    if (!options) options = {};
    if (!options.drawCallback) options.drawCallback = null;
    if (!options.base_uri) options.base_uri = window.location.pathname;

    $("#selected-filter-label").text($("#filter-id-"+filter_id).text());
    $("#selected-cluster-label").text($("#cluster-id-"+cluster_id).text());

    $("#" + filter_id).addClass("active");
    var table = $('#job_status_table').DataTable({
        autoWidth: true,            // Automatically calculate column width
        "lengthMenu": [ [10, 25, 50, -1], [10, 25, 50, "All"] ], // Manually set size of particular columns
        "bStateSave": true,         // Save user selected table state
        "aaSorting": [],            // Turn off auto sort.
        "pageLength": 50,           // Set the number of rows
        "oLanguage": {
            "sSearch": "Filter: "
        },
        "fnCreatedRow": function( nRow, aData, iDataIndex ) {
          $(nRow).children("td").css("overflow", "hidden");
          $(nRow).children("td").css("white-space", "nowrap");
          $(nRow).children("td").css("text-overflow", "ellipsis");
        },
        "fnInitComplete":           function( oSettings ) {
                                        for ( var i=0, iLen=oSettings.aoData.length ; i<iLen ; i++ )
                                        {
                                            // Add info background to user rows
                                            if (oSettings.aoData[i]._aData.username == JobStatusapp.username) {
                                                oSettings.aoData[i].nTr.className += " bg-info";
                                            }
                                        }
                                    },
        processing: true,           // Add the "processing" while json is being downloaded.
        drawCallback: function(settings){
          if(options.drawCallback){
            options.drawCallback(settings);
          }
        },
        columns: [
            {
                "orderable":        false,
                "data":             "extended_available",
                "defaultContent":   '',
                "width":            "20px",
                "searchable":       false,
                render: function (data, type, row, meta) {
                  let { cluster_title, jobname, } = row
                  return `<button class="details-control fa fa-chevron-right btn btn-default" aria-expanded="false" aria-label="Toggle visibility of job details for job ${escapeHtml(jobname)} on ${cluster_title}"></button>`;
                },
            },
            {
                data:               "pbsid",
                className:          "small",
                "autoWidth":        true,
                render: function (data) {
                  var data = escapeHtml(data)
                  return `<span title="${data}">${data}</span>`;
                },
            },
            {
                data:               "jobname",
                className:          "small",
                width:              '25%',
                render: function (data) {
                  var data = escapeHtml(data)
                  return `<span title="${data}">${data}</span>`;
                },
            },
            {
                data:               "username",
                className:          "small",
                "autoWidth":        true,
                render: function (data) {
                  var data = escapeHtml(data)
                  return `<span title="${data}">${data}</span>`;
                },
            },
            {
                data:               "account",
                className:          "small",
                "autoWidth":        true,
                render: function (data) {
                  var data = escapeHtml(data)
                  return `<span title="${data}">${data}</span>`;
                },
            },
            {
                data:               "walltime_used",
                className:          "small text-right",
                "autoWidth":        true,
                render: function (data) {
                  return `
                    <span title="${human_time(data)}">
                      ${human_time(data)}
                    </span>
                  `;
                },
            },
            {
                data:               "queue",
                className:          "small",
                "autoWidth":        true,
                "render":           function(data) {
                  var data = escapeHtml(data)
                  return `<span title="${data}">${data}</span>`;
                }
            },
            {
                data:               "status",
                className:          "small status-label",
                "autoWidth":        true,
                "render":           function(data) {
                  return status_label(data);
                }
            },
            {
                data:               "cluster_title",
                className:          "small",
                "autoWidth":        true
            },
            {
                data:               null,
                className:          "small",
                "autoWidth":        true,
                render: function(data, type, row, meta) {
                  let { jobname, pbsid, delete_path } = data
                  if(data.delete_path == "" || data.status == "completed") {
                    return ""
                  } else {
                    return `
                      <div>
                        <a
                          class="btn btn-danger btn-xs action-btn"
                          data-method="delete"
                          data-confirm="Are you sure you want to delete ${escapeHtml(jobname)} - ${pbsid}"
                          href="${escapeHtml(delete_path)}"
                          aria-labeled-by"title"
                          aria-label="Delete job ${escapeHtml(jobname)} with ID ${pbsid}"
                          data-toggle="tooltip"
                          title="Delete Job"
                        >
                          <i class='glyphicon glyphicon-trash' aria-hidden='true'></i>
                        </a>
                      </div>
                    `;
                  }
                }
            }
        ]
    }).on( 'error.dt', function ( e, settings, techNote, message ) {
        // Event is fired when there's an error loading or parsing the datatable.
        show_errors(['There was an error getting data from the remote server.']);
    } );

    // Override the Datatables default error message functionality
    //   https://datatables.net/reference/event/error
    $.fn.dataTable.ext.errMode = 'none'

    // Add event listener for opening and closing details
    $('#job_status_table tbody').on('click', '.details-control', function () {
        var tr = $(this).closest('tr');
        var row = table.row( tr );

        fetch_job_data(tr, row, options);
    });

    table.columns.adjust().draw();

    return table;
}

/* Add errors from an array to the #ajax-error-message div and remove hidden attribute */
function show_errors(errors) {
  for (var i = 0; i < errors.length; i++) {
    $("#ajax-error-message-text").append(`<div>${errors[i]}</div>`);
  }
  $("#ajax-error-message").removeAttr('hidden');
}

function get_request_params() {
    return jQuery.param({
        jobcluster: cluster_id,
        jobfilter:  filter_id
    });
}

function set_filter_id(id) {
    localStorage.setItem('jobfilter', id);
    filter_id = id;
    reload_page();
}

function set_cluster_id(id) {
    localStorage.setItem('jobcluster', id);
    cluster_id = id;
    reload_page();
}

function reload_page() {
    window.location = '?' + get_request_params();
}
