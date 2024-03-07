
import _ from 'lodash';
import {xdmodUrl, analyticsPath} from './config';
import {today, startOfYear, thirtyDaysAgo} from './utils';
import Handlebars from 'handlebars';

const jobsPageLimit = 10;

const jobHelpers = {
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
  date: function(){
    // month/day
    let d = new Date(this.start_time_ts*1000),
        month = d.getMonth()+1,
        day = d.getUTCDate();

    return `${month}/${day}`;
  },
  job_url: function(){ return `${xdmodUrl()}/#job_viewer?action=show&realm=SUPREMM&jobref=" + this.jobid`;  },
  cpu_label: function(cpu){
    let value = (parseFloat(cpu)*100).toFixed(1),
        label = "N/A";

    if(! isNaN(value)){
      let severity = "warning";

      if(cpu > 0.74){
        severity = "success";
      }
      else if(cpu < 0.25){
        severity = "danger";
      }

      label = `<span class="badge badge-${severity}">${Handlebars.escapeExpression(value.toString().padStart(4,0))}</span>`;
    }

    return new Handlebars.SafeString(label);
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

function promiseLoginToXDMoD(xdmodUrl){
  return new Promise(function(resolve, reject){

    var promise_to_receive_message_from_iframe = new Promise(function(resolve, reject){
      window.addEventListener("message", function(event){
        if (event.origin !== xdmodUrl){
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

    fetch(xdmodUrl + '/rest/auth/idpredirect?returnTo=%2Fgui%2Fgeneral%2Flogin.php')
      .then(response => response.ok ? Promise.resolve(response) : Promise.reject())
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
  url.searchParams.set('realm', user?.results?.raw_data_allowed_realms?.includes('SUPREMM') ? 'SUPREMM' : 'Jobs');
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

function renderJobs(context){
  const templateSource = $('#jobs-template').html();
  const template = Handlebars.compile(templateSource);
  $(`#${jobPanelId}`).html(template(context, { helpers: jobHelpers }));
}

function renderJobsEfficiency(context) {
  const newConext = _.merge(context, {unit: "jobs", unit_title: "Jobs"});
  const templateSource = $('#job-efficiency-template').html();
  const template = Handlebars.compile(templateSource);
  $(`#${jobEfficiencyPanelId}`).html(template(newConext, { helpers: efficiencyHelpers }));
}

function renderCoreHoursEfficiency(context) {
  const newContext = _.merge(context, {unit: "core hours", unit_title: "Core Hours"});
  const templateSource = $('#job-efficiency-template').html();
  const template = Handlebars.compile(templateSource);
  $(`#${coreEfficiencyPanelId}`).html(template(newContext, {helpers: efficiencyHelpers}));
}

function createJobsWidget() {
  const panel = $(`#${jobPanelId}`);
  if(panel.length == 0){
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

      // error - report back for analytics purposes
      const analyticsUrl = new URL(analyticsPath('xdmod_jobs_widget_error'), document.location);
      analyticsUrl.searchParams.append('error', error);
      fetch(analyticsUrl);
    });
}

function createEfficiencyWidgets() {
  const jobPanel = $(`#${jobEfficiencyPanelId}`);
  const corePanel = $(`#${coreEfficiencyPanelId}`);

  if(jobPanel.length == 0 || corePanel.length == 0) {
    return;
  }

  promiseLoggedIntoXDMoD(xdmodUrl)
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

    // error - report back for analytics purposes
    const analyticsUrl = new URL(analyticsPath('xdmod_jobs_widget_error'), document.location);
    analyticsUrl.searchParams.append('error', error);
    fetch(analyticsUrl);
  });
}

jQuery(() => {
  createJobsWidget();
  createEfficiencyWidgets();
});