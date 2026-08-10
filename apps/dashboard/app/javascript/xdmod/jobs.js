'use strict';

import {reportErrorForAnalytics} from '../utils';

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
  div.append(detailsPanel());
  div.append(table(context, helpers));

  return div;
}

function simpleCardBody() {
  const div = document.createElement('div');
  div.classList.add('card-body');

  return div;
}

function detailsPanelId(){
  return 'xdmod_job_details';
}

function detailsPanel() {
  const div = document.createElement('div');
  div.classList.add('job-analytics', 'collapse');
  div.id = detailsPanelId();

  return div;
}

function table(context, helpers) {
  const div = document.createElement('div');
  div.classList.add('table-responsive');

  const tableElement = document.createElement('table');
  // <table class="table table-sm table-striped table-condensed">
  tableElement.classList.add('table', 'table-sm', 'table-striped', 'table-condensed');

  const thead = document.createElement('thead');
  // Empty th to accommodate for the job analytics button
  thead.innerHTML = '<tr> \
                      <th class="sr-only">Analytics Toggle</th> \
                      <th class="id">ID</th> \
                      <th class="name">Name</th> \
                      <th class="date">Date</th> \
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

    // Job analytics collapse icons
    const td0 = document.createElement('td');
    const button = document.createElement('button');
    button.title = `Click to expand analytics information on job ${job.local_job_id} above this table.`;
    button.setAttribute('data-bs-toggle', 'collapse');
    button.setAttribute('data-bs-target', `#${detailsPanelId()}`);
    button.setAttribute('aria-expanded', 'false');
    button.classList.add('btn', 'btn-default', 'btn-xs');
    button.innerHTML = `<i class="fa fa-plus fa-fw app-icon closed" aria-hidden="true"></i>
                        <i class="fa fa-minus fa-fw app-icon open" aria-hidden="true"></i>`;
    // OK to call this on open or close because the response is cached.
    button.onclick = (event) => handleButtonClick(event, job, helpers);
    td0.appendChild(button);
    
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

    tr.append(td0, td1, td2, td3);

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

function renderJobAnalytics(analyticsData, jobData, containerId, helpers) {
  if(analyticsData.error !== undefined) {
    const errorMessage = errorBody(analyticsData.error, helpers);
    const analyticsContainer = document.getElementById(containerId);
    analyticsContainer.closest('tr').classList.add('error');
    analyticsContainer.replaceChildren(errorMessage);
    return;
  }

  // Index Job analytics data by analytics key
  const dataByKey = analyticsData.data.reduce((acc, obj) => {
    acc[obj.key] = obj;
    return acc;
  }, {});

  // Default to jobData form the job search results.
  // As the Jobs realm might not have any analytics metrics.
  const cpuEfficiency = dataByKey['CPU User']?.value || jobData.cpu_user;
  const memEfficiency = dataByKey['Memory Headroom']?.value;
  const walltimeEfficiency = dataByKey['Walltime Accuracy']?.value || jobData.walltime_accuracy;
  const div = document.createElement('div');
  div.classList.add('job-analytics-content');
  div.innerHTML = `<span><strong>CPU:</strong> ${helpers.efficiency_label(cpuEfficiency, false)}</span>
                   <span><strong>Mem:</strong> ${helpers.efficiency_label(memEfficiency, true)}</span>
                   <span><strong>Walltime:</strong> ${helpers.efficiency_label(walltimeEfficiency, false)}</span>`;

  document.getElementById(containerId).replaceChildren(div);
}

function jobAnalyticsUrl(jobId, helpers){
  let url = new URL(`${helpers.xdmod_url()}/rest/v1.0/warehouse/search/jobs/analytics`);
  url.searchParams.set('_dc', Date.now());
  url.searchParams.set('realm', helpers.realm);
  url.searchParams.set('jobid', jobId);
  return url;
}

function jobDataCacheKey(jobid) {
  return `xdmod_extended_data_${jobid}`;
}

function cacheJobData(responseData, requestData) {
  localStorage.setItem(jobDataCacheKey(requestData.jobid), JSON.stringify(responseData));
}

function getCachedJobData(jobid) {
  return localStorage.getItem(jobDataCacheKey(jobid));
}

function handleButtonClick(event, jobData, helpers) {
  // FIXME: have to reset all the buttons because Boostrap aria-expands all these
  // buttons because they have the same target. Should be a better way to do this.
  const button = event.target.closest('button');
  const expanded = button.ariaExpanded;

  if(expanded) {
    const allButtons = document.querySelectorAll(`tr button[data-bs-target="#${detailsPanelId()}"]`);
    others = Array.from(allButtons).filter(b => b !== button);
    others.forEach(b => b.ariaExpanded = false);
  }

  getJobAnalytics(jobData, helpers);
}

function getJobAnalytics(jobData, helpers) {
  const analyticsContainer = detailsPanelId();

  const cache = JSON.parse(getCachedJobData(jobData.jobid));
  if(cache !== null) {
    renderJobAnalytics(cache, jobData, analyticsContainer, helpers);
  } else {
    fetch(jobAnalyticsUrl(jobData.jobid, helpers), { credentials: 'include', cache: 'force-cache' })
      .then(response => response.ok ? Promise.resolve(response) : Promise.reject(new Error(response.statusText)))
      .then(response => response.json())
      .then((data) => {
        cacheJobData(data, jobData);
        renderJobAnalytics(data, jobData, analyticsContainer, helpers);
      })
      .catch((error) => {
        console.error(error);
        renderJobAnalytics({error: error}, jobData, analyticsContainer, helpers);
        reportErrorForAnalytics('xdmod_jobs_analytics_widget_error', error);
      });
  }
}
