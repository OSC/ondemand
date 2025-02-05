import _ from 'lodash';
import {xdmodUrl, analyticsPath} from './config';
import {today, startOfYear, thirtyDaysAgo, reportErrorForAnalytics} from './utils';
import { jobsPanel } from './xdmod/jobs';

const jobsPageLimit = 10;

const jobHelpers = {
  realm: 'Jobs',
  title: function(){
    return "Recently Completed Jobs";
  },
  date_range: function() {
    return thirtyDaysAgo() + " to " + today();
  },
  page_limit: function(){
    return Math.min(jobsPageLimit, parseInt(this.totalCount));
  },
  xdmod_url: function(){
    return xdmodUrl();
  },
  start_time: function(){ return new Date(this.start_time_ts*1000).toLocaleString(); },
  end_time: function(){ return new Date(this.end_time_ts*1000).toLocaleString(); },
  //FIXME: would be nice to use 1 representation of walltime across all of OnDemand
  // but this is in hours and minutes
  walltime: function(){
    let duration = this.end_time_ts - this.start_time_ts;
    let hours = Math.floor(duration / (60 * 60));
    duration -= hours * (60 * 60);
    let minutes = Math.floor(duration / (60));
    duration -= minutes * (60);
    let seconds = Math.floor(duration);

    return hours.toString().padStart(2, "0") + ":" +
           minutes.toString().padStart(2, "0") + ":" +
           seconds.toString().padStart(2, "0");
  },
  // month/day
  date: function(job){
    let d = new Date(job.start_time_ts*1000),
        month = d.getMonth()+1,
        day = d.getUTCDate();

    return `${month}/${day}`;
  },
  job_url: function(id){ return `${xdmodUrl()}/#job_viewer?action=show&realm=${this.realm}&jobref=${id}`;  },
  efficiency_label: function(efficiencyValue, inverse = false){
    const value = (parseFloat(efficiencyValue)*100).toFixed(1);
    let label = "N/A";

    if(! isNaN(value)){
      let severity = "warning";

      if(efficiencyValue > 0.74){
        severity = inverse ? "danger" : "success";
      }
      else if(efficiencyValue < 0.25){
        severity = inverse ? "success" : "danger";
      }

      label = `<span class="badge bg-${severity}">${value.toString().padStart(4,0)}</span>`;
    }

    return label;
  }
};

var efficiencyHelpers = {
  title: function(){
    return this.unit_title + " Efficiency Report";
  },
  date_range: function() {
    return thirtyDaysAgo() + " to " + today();
  },
  xdmod_url: function(){
    return xdmodUrl();
  },
  bad_percent: function(){
    return (parseFloat(this.bad_ratio)).toFixed();
  },
  good_percent: function(){
    return (100 - parseFloat(this.bad_ratio)).toFixed();
  }
};

function promiseLoginToXDMoD(){
  return new Promise(function(resolve, reject){

    var promise_to_receive_message_from_iframe = new Promise(function(resolve, reject){
      window.addEventListener("message", function(event){
        if (event.origin !== xdmodUrl()){
          console.log('Received message from untrusted origin, discarding');
          return;
        }
        else if(event.data.application == 'xdmod'){
          if(event.data.action == 'loginComplete'){
            resolve();
          }
            else if(event.data.action == 'error'){
              console.log('ERROR: ' + event.data.info);
              let iframe = document.querySelector("#xdmod_login_iframe");
              reject(new Error(`XDMoD Login iFrame at URL ${iframe && iframe.src} posted error message with info ${event.data.info}`));
          }
        }
      }, false);
    });

    fetch(xdmodUrl() + '/rest/auth/idpredirect?returnTo=%2Fgui%2Fgeneral%2Flogin.php')
      .then(response => response.ok ? Promise.resolve(response) : Promise.reject(new Error('Login failed: IDP redirect failed')))
      .then(response => response.json())
      .then(function(data){
        return new Promise(function(resolve, reject){
          var xdmodLogin = document.createElement('iframe');
          xdmodLogin.style = 'visibility: hidden; position: absolute;left: -1000px';
          xdmodLogin.id = 'xdmod_login_iframe'
          xdmodLogin.src = data;
          document.body.appendChild(xdmodLogin);
          xdmodLogin.onload = function(){
            resolve();
          }
          xdmodLogin.onerror = function(){
            reject(new Error('Login failed: Failed to load XDMoD login page'));
          }
        });
      })
      .then(() => {
        return Promise.race([promise_to_receive_message_from_iframe, new Promise(function(resolve, reject){
          setTimeout(reject, 5000, new Error('Login failed: Timeout waiting for login to complete'));
        })]);
      })
      .then(() => {
        resolve();
      })
      .catch((e)=> {
        reject(e);
      });
  });
}

var promiseLoggedIntoXDMoD = (function(){
  return _.memoize(function(){
    return fetch(xdmodUrl() + '/rest/v1/users/current', { credentials: 'include' })
      .then((response) => {
        if(response.ok){
          return Promise.resolve(response.json());
        }
        else{
          return promiseLoginToXDMoD()
                .then(() => fetch(xdmodUrl() + '/rest/v1/users/current', { credentials: 'include' }))
                .then(response => response.json());
        }
      })
      .then((user_data) => {
        if(user_data && user_data.success && user_data.results && user_data.results.person_id){
          jobHelpers.realm = user_data.results.raw_data_allowed_realms?.includes('SUPREMM') ? 'SUPREMM' : 'Jobs';
          return Promise.resolve(user_data);
        }
        else{
          return Promise.reject(new Error('Attempting to fetch current user info from Open XDMoD failed'));
        }
      });
  });
})();

function jobsUrl(user){
  var url = new URL(`${xdmodUrl()}/rest/v1/warehouse/search/jobs`);
  url.searchParams.set('_dc', Date.now());
  url.searchParams.set('start_date', thirtyDaysAgo());
  url.searchParams.set('end_date', today());
  url.searchParams.set('realm', jobHelpers.realm);
  url.searchParams.set('limit', jobsPageLimit);
  url.searchParams.set('start', 0);
  url.searchParams.set('verbose', true);
  url.searchParams.set('params', JSON.stringify({person: user?.results?.person_id}));
  return url;
}

function aggregateDataUrl(user){
  var url = new URL(`${xdmodUrl()}/rest/v1/warehouse/aggregatedata`);
  url.searchParams.set('_dc', Date.now());
  url.searchParams.set('start', 0);
  url.searchParams.set('limit', 1);
  url.searchParams.set('config', JSON.stringify({
    "realm":"JobEfficiency",
    "group_by":"person",
    "aggregation_unit":"day",
    "start_date": thirtyDaysAgo(),
    "end_date": today(),
    "filters": {"person": user?.results?.person_id},
    "order_by":{
      "field":"core_time_bad",
      "dirn":"desc"
    },
    "statistics": ["core_time","core_time_bad","bad_core_ratio","job_count","job_count_bad","bad_job_ratio"]
  }));

  return url;
}

const jobPanelId = 'jobsPanelDiv';
const jobEfficiencyPanelId = 'jobsEfficiencyReportPanelDiv';
const coreEfficiencyPanelId = 'coreHoursEfficiencyReportPanelDiv';

function renderJobs(context) {
  const panel = document.getElementById(jobPanelId);
  const jobs = jobsPanel(context, jobHelpers);

  panel.replaceChildren(jobs);
}

function renderEfficiencyPanel(panelId, context) {
  const panel = document.getElementById(panelId);
  if (!panel) return;

  const card = document.createElement('div');
  card.className = 'card mt-3';

  const cardHeader = document.createElement('div');
  cardHeader.className = 'card-header';

  const link = document.createElement('a');
  link.href = efficiencyHelpers.xdmod_url();
  link.className = 'float-end';
  link.innerHTML = 'Open XDMoD <span class="fa fa-external-link-square-alt"></span>';
  cardHeader.appendChild(link);

  const title = document.createElement('h3');
  title.innerHTML = `${efficiencyHelpers.title.call(context)} - ${efficiencyHelpers.date_range()}`;
  cardHeader.appendChild(title);

  card.appendChild(cardHeader);

  const cardBody = document.createElement('div');
  cardBody.className = 'card-body';

  if (context.error) {
    const alert = document.createElement('div');
    alert.className = 'alert alert-danger mb-0';
    alert.innerHTML = `${context.error} Please ensure you are <a href="${efficiencyHelpers.xdmod_url()}">logged into Open XDMoD first</a>, and then try again.`;
    cardBody.appendChild(alert);
  } else if (context.nodata) {
    const paragraph = document.createElement('p');
    paragraph.className = 'card-text';
    paragraph.textContent = context.msg;
    cardBody.appendChild(paragraph);
  } else {
    const efficiencyParagraph = document.createElement('p');
    efficiencyParagraph.className = 'd-flex justify-content-between card-text font-weight-bold';
    efficiencyParagraph.innerHTML = `<span class="text-success">${efficiencyHelpers.good_percent.call(context)}% efficient</span> <span class="text-danger">${efficiencyHelpers.bad_percent.call(context)}% inefficient</span>`;
    cardBody.appendChild(efficiencyParagraph);

    const progressDiv = document.createElement('div');
    progressDiv.className = 'progress progress-custom';

    const progressBarSuccess = document.createElement('div');
    progressBarSuccess.className = 'progress-bar bg-success';
    progressBarSuccess.style.width = `${efficiencyHelpers.good_percent.call(context)}%`;
    progressBarSuccess.setAttribute('role', 'progressbar');
    progressBarSuccess.setAttribute('aria-label', 'percent efficient');
    progressBarSuccess.setAttribute('aria-valuenow', efficiencyHelpers.good_percent.call(context));
    progressBarSuccess.setAttribute('aria-valuemin', '0');
    progressBarSuccess.setAttribute('aria-valuemax', '100');
    progressDiv.appendChild(progressBarSuccess);

    const progressBarDanger = document.createElement('div');
    progressBarDanger.className = 'progress-bar bg-danger';
    progressBarDanger.style.width = `${efficiencyHelpers.bad_percent.call(context)}%`;
    progressBarDanger.setAttribute('role', 'progressbar');
    progressBarDanger.setAttribute('aria-label', 'percent inefficient');
    progressBarDanger.setAttribute('aria-valuenow', efficiencyHelpers.bad_percent.call(context));
    progressBarDanger.setAttribute('aria-valuemin', '0');
    progressBarDanger.setAttribute('aria-valuemax', '100');
    progressDiv.appendChild(progressBarDanger);

    cardBody.appendChild(progressDiv);

    const countParagraph = document.createElement('p');
    countParagraph.className = 'card-text text-center mt-2';
    countParagraph.innerHTML = `<span class="text-danger">${context.count_bad} inefficient ${context.unit} </span> &frasl; ${context.count} total ${context.unit}`;
    cardBody.appendChild(countParagraph);
  }

  card.appendChild(cardBody);
  panel.replaceChildren(card);
}

function renderJobsEfficiency(context) {
  renderEfficiencyPanel(jobEfficiencyPanelId, _.merge(context, {unit: "jobs", unit_title: "Jobs"}));
}

function renderCoreHoursEfficiency(context) {
  renderEfficiencyPanel(coreEfficiencyPanelId, _.merge(context, {unit: "core hours", unit_title: "Core Hours"}));
}

function createJobsWidget() {
  const panel = document.getElementById(jobPanelId);
  if(!panel){
    return;
  }

  promiseLoggedIntoXDMoD()
    .then((user_data) => fetch(jobsUrl(user_data), { credentials: 'include' }))
    .then(response => response.ok ? Promise.resolve(response) : Promise.reject(new Error(response.statusText)))
    .then(response => response.json())
    .then((data) => renderJobs(data))
    .catch((error) => {
      console.error(error);
      renderJobs({error: error});

      reportErrorForAnalytics('xdmod_jobs_widget_error', error);
    });
}

function createEfficiencyWidgets() {
  const jobPanel = document.getElementById(jobEfficiencyPanelId);
  const corePanel = document.getElementById(coreEfficiencyPanelId);

  if(!jobPanel || !corePanel) {
    return;
  }

  promiseLoggedIntoXDMoD()
  .then((user_data) => fetch(aggregateDataUrl(user_data), { credentials: 'include' }))
  .then(response => response.ok ? Promise.resolve(response) : Promise.reject(new Error(response.statusText)))
  .then(response => response.json())
  .then((data) => {
    if(data && data["success"] && Array.isArray(data["results"])){
      let results = data["results"][0];
      if(results){
        renderJobsEfficiency({
          bad_ratio: results.bad_job_ratio,
          count_bad: results.job_count_bad,
          count: results.job_count
        });
        renderCoreHoursEfficiency({
          bad_ratio: results.bad_core_ratio,
          count_bad: Math.round(results.core_time_bad),
          count: Math.round(results.core_time)
        });
      }
      else{
        renderJobsEfficiency({nodata: true, msg: 'No data available.'});
        renderCoreHoursEfficiency({nodata: true, msg: 'No data available.'});
      }
    }
    else{
      throw new Error('Job data returned by request is invalid.')
    }
  })
  .catch((error) => {
    console.error(error);
    renderJobsEfficiency({error: error});
    renderCoreHoursEfficiency({error: error});

    reportErrorForAnalytics('xdmod_jobs_widget_error', error);
  });
}

jQuery(() => {
  // initialize the panels
  renderJobs({ loading: true });
  renderJobsEfficiency({nodata: true, msg: 'LOADING...'});
  renderCoreHoursEfficiency({nodata: true, msg: 'LOADING...'});

  createJobsWidget();
  createEfficiencyWidgets();
});