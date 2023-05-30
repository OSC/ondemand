/**
 * Given a directory name, find the associated Globus endpoint
 * @params {string} directory Directory name
 * @return {string|undefined} Globus endpoint ID
 */
function getEndpoint(directory) {
  for (const [prefix, endpoint] of Object.entries(globus_endpoints)) {
    if(directory.startsWith(prefix)) {
      return endpoint
    }
  }
}

/**
 * Generate a link to the Globus transfer app
 * @params {string} directory Directory name
 * @return {string|null} Globus transfer app URL with directory and endpoint populated
 */
export function getGlobusLink(directory) {
  let endpoint = getEndpoint(directory);
  let url = null;

  if (endpoint) {
    url = "https://app.globus.org/file-manager?origin_id=" + endpoint + "&origin_path=" + directory;
  }

  return url;
}

/**
 * Enable or disable the Globus button and update the tooltip based on current directory
 * @params {string} directory Directory name
 * @params {object} JQuery object
 * @return undefined
 */
export function updateGlobusButton(directory, button) {
  endpoint = getEndpoint(directory);
  if (endpoint) {
    button.prop("disabled", false);
    button.prop("title", "Open the current directory with Globus");
  } 
  else {
    button.prop("disabled", true);
    button.prop("title", "No Globus endpoint associated with this directory");
  }
}
