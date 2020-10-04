/**
 * If the url has a match with host_path_rx, the respective capture groups are returned
 * 
 * @param {string} url request url
 * @param {string} default_sshhost returned hostname if default
 * 
 * @return {Array}
 */
function hostAndDirFromURL(url, default_sshhost){
  const host_path_rx = '/ssh/([^\\/\\?]+)([^\\?]+)?(\\?.*)?$';
  let match = url.match(host_path_rx), 
  hostname = null, 
  directory = null;

  if (match) {
    hostname = match[1] === "default" ? default_sshhost : match[1];
    directory = match[2] ? decodeURIComponent(match[2]) : null;
  }
  return [hostname, directory];
}

module.exports = {
  hostAndDirFromURL,
}
