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
          // TODO
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
      // TODO, show an error in the HTML
     });
}

function jobInfoDiv(jobId, state) {
  return `<div>
            <span class="mr-2">${jobId}</span>
            <span class="badge ${cssBadgeForState(state)}">${state.toUpperCase()}</span>
          </div>`;
}