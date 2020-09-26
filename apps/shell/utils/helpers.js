const minimatch = require('minimatch');
const glob      = require('glob');
const path      = require('path');
const yaml      = require('js-yaml');
const fs        = require('fs');

/**
 * Returns if host is in allowlist
 * 
 * @param {set - object} allowlist 
 * @param {string} host 
 * 
 * @return {boolean}
 */
function hostInAllowList(allowlist, host) {
  allowlist = Array.from(allowlist);
  return allowlist.some((value) => minimatch(host, value));
}

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

/**
 * 
 * @param {string} ood_sshhost_allowlist colon-delimited list
 * @param {string} cluster_path path to clusters_d
 * @param {string} default_sshhost user defined default
 * 
 * @return {[set, string]}
 */
function hostAllowlistAndDefaultHost(ood_sshhost_allowlist, cluster_path, ood_default_sshhost){
  let allowlist = ood_sshhost_allowlist ? new Set(ood_sshhost_allowlist.split(':')) : new Set();
  
  //Filter through cluster configs, return array of hashes with host and default
  let cluster_sshhosts = glob.sync(path.join((cluster_path || '/etc/ood/config/clusters.d'), '*.y*ml'))
  .map(yml => yaml.safeLoad(fs.readFileSync(yml)))
  .filter(config => (config.v2 && config.v2.login && config.v2.login.host) && ! (config.v2 && config.v2.metadata && config.v2.metadata.hidden))
  .map(config => {
    return {host: config.v2.login.host, default: config.v2.login.default}
  })

  //Add to allowlist
  allowlist.add(default_sshhost);
  cluster_sshhosts.forEach(cluster => {
    allowlist.add(cluster.host);
  });

  let default_sshhost = ood_default_sshhost || cluster_sshhosts.find(cluster => cluster.default || ([first] = cluster_sshhosts)).host

  return [allowlist, default_sshhost]
}

module.exports = {
  hostInAllowList,
  hostAndDirFromURL,
  hostAllowlistAndDefaultHost,
}


