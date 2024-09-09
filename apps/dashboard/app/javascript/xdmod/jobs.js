'use strict';

export function jobsPanel(context, helpers){
  const div = document.createElement('div');
  div.classList.add('xdmod');

  div.append(card(context, helpers));

  return div;
}

export function jobAnalyticsTable(context, jobHelpers) {
  if(context.error !== undefined) {
    return errorBody(context.error, jobHelpers);
  }

  const dataByKey = context.data.reduce((acc, obj) => {
    acc[obj.key] = obj;
    return acc;
  }, {});
  const cpuEfficiency = jobHelpers.efficiency_label(dataByKey['CPU User']?.value, false)
  const memEfficiency = jobHelpers.efficiency_label(dataByKey['Memory Headroom']?.value, true)
  const walltimeEfficiency = jobHelpers.efficiency_label(dataByKey['Walltime Accuracy']?.value, false)
  const analyticsContent = `<td>${cpuEfficiency}</td>
                            <td>${memEfficiency}</td>
                            <td>${walltimeEfficiency}</td>`;
  return analyticsTable(analyticsContent);
}

function card(context, helpers) {
  const div = document.createElement('div');
  div.classList.add('card', 'mt-3');

  div.append(cardHeader(helpers));
  div.append(cardBody(context, helpers));

  return div;
}

function cardHeader(helpers) {
  const div = document.createElement('div');
  div.classList.add('card-header');
  div.innerHTML = `<a href="${helpers.xdmod_url()}" class="float-end">Open XDMoD <span class="fa fa-external-link-square-alt"></span></a>
                   <h3>${helpers.title()} - ${helpers.date_range()}</h3>`;

  return div;
}

function cardBody(context, helpers) {
  if(context.error !== undefined) {
    return errorBody(context.error, helpers);
  } else if(context.loading !== undefined) {
    return loadingBody();
  } else {
    return successBody(context, helpers);
  }
}

function errorBody(error, helpers) {
  const div = simpleCardBody();
  
  const content = `<div class="alert alert-danger mb-0">
                      ${error} Please ensure you are <a href="${helpers.xdmod_url()}">logged into Open XDMoD first</a>, and then try again.
                    </div>`;
  div.innerHTML = content;
  return div;
}

function loadingBody() {
  const div = simpleCardBody();
  div.innerHTML = '<p class="card-text">LOADING...</p>';

  return div;
}

function successBody(context, helpers) {
  const div = simpleCardBody();
  div.append(table(context, helpers));

  return div;
}

function simpleCardBody() {
  const div = document.createElement('div');
  div.classList.add('card-body');

  return div;
}

function table(context, helpers) {
  const div = document.createElement('div');
  div.classList.add('table-responsive');

  const tableElement = document.createElement('table');
  // <table class="table table-sm table-striped table-condensed">
  tableElement.classList.add('table', 'table-sm', 'table-striped', 'table-condensed');

  const thead = document.createElement('thead');
  thead.innerHTML = '<tr> \
                      <th></th> \
                      <th>ID</th> \
                      <th>Name</th> \
                      <th>Date</th> \
                    </tr>';

  const tbody = document.createElement('tbody');
  tbody.append(...tableRows(context, helpers));

  tableElement.append(thead);
  tableElement.append(tbody);

  div.append(tableElement);

  return div;
}

function tableRows(context, helpers) {
  const jobs = context.results;
  if (jobs === undefined || jobs.length == 0) {
    return [ noDataRow() ];
  }

  const rows = [];

  // <tr title="{{job_name}} - {{local_job_id}}">
  //   <td class="text-nowrap"><a target="_blank" href="{{job_url}}">{{local_job_id}}&nbsp;<span class="fa fa-external-link-square-alt"></span></a></td>
  //   <td class="overflow-hidden d-inline-block text-truncate mw-150px">{{job_name}}</td>
  //   <td>{{date}}</td>
  //   <td>{{cpu_label cpu_user}}</td>
  // </tr>
  jobs.forEach(job => {
    const tr = document.createElement('tr');
    tr.title = `${job.job_name} - ${job.local_job_id}`;
    // Job Analytics metadata => Required for the AJAX request and collapse behaviour
    tr.setAttribute('data-xdmod-jobid', job.jobid);
    tr.setAttribute('data-bs-toggle', 'collapse');
    tr.setAttribute('data-bs-target', `#details_${job.jobid}`);
    tr.setAttribute('aria-expanded', 'false');

    // Job analytics collapse icons
    const td0 = document.createElement('td');
    td0.innerHTML = `
      <button class="btn btn-default btn-xs">
        <i class="fa fa-plus fa-fw app-icon closed" aria-hidden="true"></i>
        <i class="fa fa-minus fa-fw app-icon open" aria-hidden="true"></i>
      </button>`
    
    //  <td class="text-nowrap">
    //    <a target="_blank" href="{{job_url}}">{{local_job_id}}&nbsp;<span class="fa fa-external-link-square-alt"></span>
    //    </a>
    //  </td>
    const td1 = document.createElement('td');
    td1.classList.add('text-nowrap');
    td1.append(jobLink(helpers.job_url(job.jobid), job.local_job_id));

    //<td class="overflow-hidden d-inline-block text-truncate mw-150px">{{job_name}}</td>
    const td2 = document.createElement('td');
    td2.classList.add('overflow-hidden', 'text-truncate', 'mw-150px');
    td2.innerText = job.job_name;

    // <td>{{date}}</td>
    const td3 = document.createElement('td');
    td3.innerText = helpers.date(job);

    // <td>{{cpu_label cpu_user}}</td>
    // Not used with new analytics data
    // const td4 = document.createElement('td');
    // td4.innerHTML = helpers.efficiency_label(job.cpu_user);

    tr.append(td0, td1, td2, td3);

    rows.push(tr);

    // Add job analytics placeholder
    const analyticsRow = document.createElement('tr');
    const analyticsData = analyticsTable('<td colspan="3">LOADING...</td>')
    analyticsRow.innerHTML = `
      <td colspan="4" class="hiddenRow">
        <div class="collapse" id="details_${job.jobid}">
          ${analyticsData}
        </div>
      </td>`;
    rows.push(analyticsRow);
  });

  return rows;
}

function analyticsTable(analyticsContent) {
  const analyticsTable = `
      <table class="table table-sm table-condensed">
        <thead>
        <tr>
          <th>CPU</th>
          <th>Mem</th>
          <th>Walltime</th>
        </tr>
        </thead>
        <tbody>
        <tr>
          ${analyticsContent}
        </tr>
        </tbody>
      </table>`;
  return analyticsTable;
}

function jobLink(url, id){
  const a = document.createElement('a');
  a.href = url;
  a.innerHTML = `${id} ${linkSpan()}`;

  return a;
}

function linkSpan(){
  return '<span class="fa fa-external-link-square-alt"></span>';
}

// <tr><td colspan="7">No data available.</td></tr>
function noDataRow() {
  const td = document.createElement('td');
  td.setAttribute('colspan', '7');
  td.innerHTML = 'No data available.';

  const tr = document.createElement('tr');
  tr.append(td);

  return tr;
}
