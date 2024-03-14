'use strict';

const activeJobsConfig = $('#active_jobs_config')[0].dataset;

var filter_id = null;
var cluster_id = null;

if (activeJobsConfig.filterId.includes('localStorage')) {
  filter_id = localStorage.getItem('jobfilter');
} else {
  filter_id = activeJobsConfig.filterId;
};

if (filter_id == null || filter_id == undefined) {
  filter_id = activeJobsConfig.filterId.match(/localStorage(.*)/)[1];
}

if (activeJobsConfig.clusterId.includes('localStorage')) {
  cluster_id = localStorage.getItem('jobcluster');
} else {
  cluster_id = activeJobsConfig.clusterId;
}

if (cluster_id == null || cluster_id == undefined) {
  cluster_id = 'all';
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
    console.log(`${activeJobsConfig.gitString},${marks[0].startTime},${marks[1].startTime},${marks.slice(-1)[0].startTime}`);
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