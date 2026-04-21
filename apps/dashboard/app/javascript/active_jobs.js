'use strict';

import oboe from 'oboe';
import { supportPath } from './config.js';
import { cssBadgeForState, capitalizeFirstLetter } from './utils.js'

window.fetch_table_data = fetch_table_data;
window.create_datatable = create_datatable;
window.set_cluster_id = set_cluster_id;
window.set_filter_id = set_filter_id;
window.closeExtendedDetails = closeExtendedDetails;

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

const support_path = supportPath();

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

function clean_options(options) {
  if (!options) options = {};
  if (!options.doneCallback) options.doneCallback = null;
  if (!options.base_uri) options.base_uri = window.location.pathname.replace('/activejobs','');
  return options;
}

function resetExtendedDataButtons() {
  $('button.fa-minus').each((_i, button) => {
    button.classList.replace('fa-minus', 'fa-plus');
  });
}

function closeExtendedDetails() {
  resetExtendedDataButtons();
  const ele = document.getElementById('job_details');
  ele.innerHTML = null;
}

function fetch_job_data(tr, row, options) {
  const btn = tr.find('button.details-control')[0];

  // just clearing out the previous selection.
  if(btn.classList.contains('fa-minus')) {
    btn.classList.replace('fa-minus', 'fa-plus');
    const details = document.getElementById('job_details');
    details.innerHTML = null;

    return;
  }

  resetExtendedDataButtons();

  btn.classList.replace('fa-plus', 'fa-minus');

    let data = {
      pbsid: row.data().pbsid,
      cluster: row.data().cluster,
    };
    let jobDataUrl = `${options.base_uri}/activejobs/json?${new URLSearchParams(data)}`;

    fetch(jobDataUrl, { headers: {
        'Accpet': 'application/json',
      }})
      .then(response => response.ok ? Promise.resolve(response) : Promise.reject(new Error('Request failed')))
      .then(response => response.json())
      .then(response => {
        const ele = document.getElementById('job_details');
        ele.innerHTML = response.html_extended_data_table;
      })
      .catch(error => console.log(error));
}

function fetch_table_data(table, options){
  options = clean_options(options);

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
      show_errors([activeJobsConfig.errorStatusCode + errorReport.statusCode]);
    }
    else{
      //FIXME: this error appears even when the above 404 occurs, for example
      // that is because a 404 response for json request returns a plain text response
      // and parsing that as json fails
       show_errors([activeJobsConfig.errorParsing]);
    }

    table.processing(false);
  });
}


function status_label(status){
  const labelClass = cssBadgeForState(status);
  var label = activeJobsConfig.labelUndetermined;

  if(status === "queued_held") {
    label = activeJobsConfig.labelHold;
  } else if(status && status !== "undetermined") {
    label = capitalizeFirstLetter(status);
  }

  return `<span class="badge ${labelClass}">${escapeHtml(label)}</span>`;
}

function create_datatable(options){
    options = clean_options(options)

    $("#selected-filter-label").text($("#filter-id-"+filter_id).text());
    $("#selected-cluster-label").text($("#cluster-id-"+cluster_id).text());

    $("#" + filter_id).addClass("active");
    var table = $('#job_status_table').DataTable({
        autoWidth: true,            // Automatically calculate column width
        // Values only. DataTables 2 uses language.lengthLabels for the -1 label.
        "lengthMenu": [10, 25, 50, -1],
        "bStateSave": true,         // Save user selected table state
        "aaSorting": [],            // Turn off auto sort.
        "pageLength": 50,           // Set the number of rows
        "language": {
            "search": activeJobsConfig.searchFilter,
            "emptyTable": activeJobsConfig.emptyTable,
            "info": activeJobsConfig.info,
            "infoEmpty": activeJobsConfig.infoEmpty,
            "infoFiltered": activeJobsConfig.infoFiltered,
            "lengthMenu": activeJobsConfig.lengthMenu,
            "zeroRecords": activeJobsConfig.zeroRecords
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
                  let ariaLabel = activeJobsConfig.toggleVisibility.replace('%{jobname}', escapeHtml(jobname)).replace('%{cluster_title}', cluster_title);
                  return `<button class="details-control fa fa-plus btn btn-default" aria-label="${ariaLabel}"></button>`;
                },
            },
            {
                data:               "pbsid",
                "autoWidth":        true,
                render: function (data) {
                  var data = escapeHtml(data)
                  return `<span title="${data}">${data}</span>`;
                },
            },
            {
                data:               "jobname",
                width:              '25%',
                render: function (data) {
                  var data = escapeHtml(data)
                  return `<span title="${data}" class="text-break">${data}</span>`;
                },
            },
            {
                data:               "username",
                "autoWidth":        true,
                render: function (data) {
                  var data = escapeHtml(data)
                  return `<span title="${data}">${data}</span>`;
                },
            },
            {
                data:               "account",
                "autoWidth":        true,
                render: function (data) {
                  var data = escapeHtml(data)
                  return `<span title="${data}">${data}</span>`;
                },
            },
            {
                data:               "walltime_used",
                className:          "text-end",
                "autoWidth":        true,
                render: function (data, type, _row, _meta) {
                  if(type === 'display' || type === 'filter') {
                    const time = human_time(data);
                    return `<span title="${time}">${time}</span>`;
                  } else {
                    return data;
                  }
                },
            },
            {
                data:               "queue",
                "autoWidth":        true,
                "render":           function(data) {
                  var data = escapeHtml(data)
                  return `<span title="${data}">${data}</span>`;
                }
            },
            {
                data:               "status",
                className:          "status-label",
                "autoWidth":        true,
                "render":           function(data) {
                  return status_label(data);
                }
            },
            {
                data:               "cluster_title",
                "autoWidth":        true
            },
            {
                orderable:         false,
                data:               null,
                "autoWidth":        true,
                searchable:        false,
                render: function(data, type, row, meta) {
                  let { jobname, pbsid, cluster, delete_path } = data;
                  let support_ticket = "";
                  if (support_path != "") {
                    const support_url = new URL(support_path, document.location);
                    support_url.searchParams.set("job_id", pbsid);
                    support_url.searchParams.set("cluster", cluster);
                    let ariaSupport = activeJobsConfig.submitTicketAria.replace('%{pbsid}', pbsid);
                    support_ticket = `
                        <a
                          class="btn btn-primary btn-xs"
                          href="${escapeHtml(support_url.toString())}"
                          aria-labeled-by="title"
                          aria-label="${ariaSupport}"
                          data-toggle="tooltip"
                          title="${activeJobsConfig.submitTicketTitle}"
                        >
                          <i class='fas fa-medkit fa-fw' aria-hidden='true'></i>
                        </a>
                    `;
                  }
                  if(delete_path == "") {
                    return "";
                  } else if (data.status == "completed") {
                    // This will be empty when support ticket is disabled.
                    return `<div>${support_ticket}</div>`;
                  } else {
                    let confirmText = activeJobsConfig.deleteConfirm.replace('%{jobname}', escapeHtml(jobname)).replace('%{pbsid}', pbsid);
                    let ariaDelete = activeJobsConfig.deleteAria.replace('%{jobname}', escapeHtml(jobname)).replace('%{pbsid}', pbsid);
                    return `
                      <div>
                        <a
                          class="btn btn-danger btn-xs"
                          data-method="delete"
                          data-confirm="${confirmText}"
                          href="${escapeHtml(delete_path)}"
                          aria-labeled-by="title"
                          aria-label="${ariaDelete}"
                          data-toggle="tooltip"
                          title="${activeJobsConfig.deleteTitle}"
                        >
                          <i class='fas fa-trash-alt fa-fw' aria-hidden='true'></i>
                        </a>
                        ${support_ticket}
                      </div>
                    `;
                  }
                }
            }
        ]
    }).on( 'error.dt', function ( e, settings, techNote, message ) {
        // Event is fired when there's an error loading or parsing the datatable.
        show_errors([activeJobsConfig.errorRemote]);
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

const activeJobsConfig = $('#active_jobs_config')[0].dataset;

var filter_id = activeJobsConfig.filterId;
var cluster_id = activeJobsConfig.clusterId;

if (filter_id == "null") {
  filter_id = localStorage.getItem('jobfilter') || activeJobsConfig.defaultFilterId;
}

if (cluster_id == "null") {
  cluster_id = localStorage.getItem('jobcluster') || 'all';
}

var performance_tracking_enabled = false;

function report_performance(){
  var marks = performance.getEntriesByType('mark');
  marks.forEach(function(entry){
    console.log(entry.startTime + "," + entry.name);
  });

  // hack but only one mark for document ready, and rest are draw times
  if(marks.length > 1){
    console.log("version,documentReady,firstDraw,lastDraw");
    console.log(`${activeJobsConfig.oodVersion},${marks[0].startTime},${marks[1].startTime},${marks.slice(-1)[0].startTime}`);
  }
}

if (activeJobsConfig.consoleLogPerformanceReport) {
  performance_tracking_enabled = true;
  performance.mark('document ready - build table and make ajax request for jobs');
}

var table = create_datatable({
  drawCallback: function(settings){
    // do a performance mark every time we draw the table (which happens when new records are downloaded)
    if(performance_tracking_enabled && settings.aoData.length > 0){
      performance.mark('draw records - ' + settings.aoData.length);
    }
  }, base_uri: activeJobsConfig.baseUri});

fetch_table_data(table, {
  doneCallback: function(){
    // generate report after done fetching records
    if(performance_tracking_enabled){
      setTimeout(report_performance, 2000);
    }
  },
  base_uri: activeJobsConfig.baseUri});
