import { jobsInfoPath } from './config.js';
import { cssBadgeForState } from './utils.js';


jQuery(function() {
  $('[data-job-poller="true"]').each((_index, ele) => {
    pollForJobInfo(ele);
  });
});

function pollForJobInfo(element) {

  const jobId = element.dataset['jobId'];
  const jobCluster = element.dataset['jobCluster'];
  const url = `${jobsInfoPath()}/${jobCluster}/${jobId}`;

  if(jobId === "" || jobCluster === "") {
    element.innerHTML = "";
    return;
  }

  fetch(url, { headers: { 'Accept': 'application/json' }, cache: 'no-store' })
    .then((response) => { 
      if (!response.ok) {
        if(response.status === 404) {
          throw new Error('404 response while looking for job', { cause: response });
        } else{
          throw new Error('Not 2xx response while looking for job', { cause: response });
        }
      } else {
        return response.json();
      }
    })
    .then((data) => {
      const state = data['state'];
      element.innerHTML = jobInfoDiv(jobId, state);
      if(state !== 'completed') {
        // keep going
        setTimeout(pollForJobInfo, 10000, element);
      }
    })
    .catch((error) => {
      element.innerHTML = jobInfoDiv(jobId, 'undetermined', error.message, 'Unable to find the job details');
     });
}

function jobInfoDiv(jobId, state, stateTitle='', stateDescription='') {
  return `<div class="job-info">
            <span class="mr-2">${jobId}</span>
            <span class="job-info-title badge ${cssBadgeForState(state)}" title="${stateTitle}">${state.toUpperCase()}</span>
            <span class="job-info-description text-muted">${stateDescription}</span>
          </div>`;
}