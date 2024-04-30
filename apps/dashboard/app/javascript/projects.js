import { rootPath } from './config.js';
import { replaceHTML } from './turbo_shim';


jQuery(function() {
  $('[data-job-poller="true"]').each((_index, ele) => {
    pollForJobInfo(ele);
  });

  $("[data-toggle='project']").each((_index, ele) => {
    updateProjectSize(ele);
  });
});

function jobDetailsPath(cluster, jobId) {
  const baseUrl = rootPath();
  const config = document.getElementById('project_config');
  const projectId = config.dataset['projectId'];

  return `${baseUrl}/projects/${projectId}/jobs/${cluster}/${jobId}`;
}

function pollForJobInfo(element) {
  const cluster = element.dataset['jobCluster'];
  const jobId = element.dataset['jobId'];

  if(cluster === undefined || jobId === undefined){ return; }

  const url = jobDetailsPath(cluster, jobId);

  fetch(url, { headers: { Accept: "text/vnd.turbo-stream.html" } })
    .then(response => response.ok ? Promise.resolve(response) : Promise.reject(response.text()))
    .then((r) => r.text())
    .then((html) => replaceHTML(element.id, html))
    .then(setTimeout(pollForJobInfo, 30000, element))
    .catch((err) => {
      console.log('Cannot not retrive job details due to error:');
      console.log(err);
    });
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
