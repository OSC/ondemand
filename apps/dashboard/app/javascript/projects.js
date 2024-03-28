import { jobsInfoPath } from './config.js';
import { cssBadgeForState } from './utils.js';


jQuery(function() {
  $('[data-job-poller="true"]').each((_index, ele) => {
    pollForJobInfo(ele);
  });

  $("[data-toggle='project']").each((_index, ele) => {
    updateProjectSize(ele);
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
        setTimeout(pollForJobInfo, 30000, element);
      }
    })
    .catch((error) => {
      element.innerHTML = jobInfoDiv(jobId, 'undetermined', error.message, 'Unable to find the job details');
     });
}

function jobInfoDiv(jobId, state, stateTitle='', stateDescription='') {
  return `<div class="job-info justify-content-center d-grid">
            <span class="mr-2">${jobId}</span>
            <span class="job-info-title badge ${cssBadgeForState(state)}" title="${stateTitle}">${state.toUpperCase()}</span>
            <span class="job-info-description text-muted">${stateDescription}</span>
          </div>`;
}

function updateProjectSize(element) {
  const UNDETERMINED = 'Undetermined Size';
  const $container = $(element);

  const projectPath = $container.data('url');
  $.ajax({
    url: projectPath,
    type: 'GET',
    headers: {
      'Accept': 'application/json'
    },
    success: function (projectData) {
      const projectSize = projectData.size === 0 ? UNDETERMINED : projectData.human_size;
      $container.text(`(${projectSize})`);
    },
    error: function (request, status, error) {
      console.log("An error occurred getting project size!\n" + error);
      $container.text(`(${UNDETERMINED})`);
    }
  });
}
