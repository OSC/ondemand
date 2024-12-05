var globus_endpoints;

$(document).ready(function() {
    globus_endpoints = $("#globus_endpoints").data("globusEndpoints");
});

/**
 * Given a directory name, return the associated Globus endpoint and path
 * @params {string} directory Directory name
 * @return {string|undefined} Globus endpoint ID
 */
function getEndpointInfo(directory) {
  for (const endpoint of globus_endpoints) {
    if (directory.startsWith(endpoint["path"])) {
      return endpoint;
    }
  }
}

/**
 * Generate a link to the Globus transfer app
 * @params {string} directory Directory name
 * @return {string|null} Globus transfer app URL with directory and endpoint populated
 */
export function getGlobusLink(directory) {
  let info = getEndpointInfo(directory);
  if (info) {
    let origin_path = directory.replace(info.path, info.endpoint_path);
    origin_path = origin_path.replace("//", "/");
    return "https://app.globus.org/file-manager?origin_id=" + info.endpoint + "&origin_path=" + origin_path;
  }
}

/**
 * Enable or disable the Globus button and update the tooltip based on current directory
 * @params {string} directory Filesystem directory name
 * @params {object} link The link object whose href value will change
 * @params {object} wrapper The wrapper containing the link whose tooltip title will change
 * @return undefined
 */
export function updateGlobusLink(directory, link, wrapper) {
  let info = getEndpointInfo(directory);
  if (info) {
    link.removeClass("disabled");
    wrapper.prop("title", "Open the current directory with Globus");
  } 
  else {
    link.addClass("disabled");
    wrapper.prop("title", "No Globus endpoint associated with this directory");
  }
}
