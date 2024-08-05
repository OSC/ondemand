'use strict';

export function jobsPanel(context, helpers){
  const div = document.createElement('div');
  div.classList.add('xdmod');

  div.append(card(context, helpers));

  return div;
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

  thead = document.createElement('thead');
  thead.innerHTML = '<tr> \
                      <th>ID</th> \
                      <th>Name</th> \
                      <th>Date</th> \
                      <th>CPU</th> \
                    </tr>';

  tbody = document.createElement('tbody');
  tbody.append(...tableRows(context, helpers));

  tableElement.append(thead);
  tableElement.append(tbody);

  div.append(tableElement);

  return div;
}

function tableRows(context, helpers) {
  jobs = context.results;
  if (jobs === undefined || jobs.length == 0) {
    return [ noDataRow() ];
  }

  rows = [];

  // <tr title="{{job_name}} - {{local_job_id}}">
  //   <td class="text-nowrap"><a target="_blank" href="{{job_url}}">{{local_job_id}}&nbsp;<span class="fa fa-external-link-square-alt"></span></a></td>
  //   <td class="overflow-hidden d-inline-block text-truncate mw-150px">{{job_name}}</td>
  //   <td>{{date}}</td>
  //   <td>{{cpu_label cpu_user}}</td>
  // </tr>
  jobs.forEach(job => {
    const tr = document.createElement('tr');
    tr.title = `${job.job_name} - ${job.local_job_id}`;
    
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
    const td4 = document.createElement('td');
    td4.innerHTML = helpers.cpu_label(job.cpu_user);

    tr.append(td1, td2, td3, td4);

    rows.push(tr);
  });

  return rows;
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
