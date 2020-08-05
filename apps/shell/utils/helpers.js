const minimatch = require('minimatch');
const glob      = require('glob');
const path      = require('path');
const yaml      = require('js-yaml');
const fs        = require('fs');

/**
 * Generates a set from ood_sshhost_allowlist if exists
 * 
 * @param {string} ood_sshhost_allowlist 
 */
function generate_host_allowlist(ood_sshhost_allowlist){
  let host_allowlist = new Set;
  if (ood_sshhost_allowlist){
    host_allowlist = new Set(ood_sshhost_allowlist.split(':'));
  }
  return host_allowlist;
}

/**
 * Returns an array of hashes with information about each cluster
 * 
 * @param {string} clusters_d_path process.env.OOD_CLUSTERS if written
 */
function generate_cluster_sshhosts(clusters_d_path){
  let arr = [];
  glob.sync(path.join((clusters_d_path || '/etc/ood/config/clusters.d'), '*.y*ml'))
  .map(yml => yaml.safeLoad(fs.readFileSync(yml)))
  .filter(config => (config.v2 && config.v2.login && config.v2.login.host) && ! (config.v2 && config.v2.metadata && config.v2.metadata.hidden))
  .forEach((config) => {
    cluster_info = {}
    cluster_info['host'] = config.v2.login.host;
    cluster_info['default'] = config.v2.login.default;
    arr.push(cluster_info);
  });
  return arr;
}

/**
 * Returns host with property default:true, else returns first available host
 * 
 * @param {Array} cluster_sshhosts 
 */
function generate_default_sshhost(cluster_sshhosts){
  let default_sshhost;
  cluster_sshhosts.forEach((cluster) => {
    if (!default_sshhost) default_sshhost = cluster.host;
    if (cluster.default) default_sshhost = cluster.host;
  });
  return default_sshhost;
}

/**
 * Add hosts from cluster_sshhosts to host_allowlist
 * 
 * @param {set - object} host_allowlist allowlsit generated from ENV variable (if any)
 * @param {Array} cluster_sshhosts Contains host for each cluster
 * @param {string} default_sshhost Adds to host_allowlist - Might be different from cluster_sshhosts
 */
function add_to_host_allowlist(host_allowlist, cluster_sshhosts, default_sshhost){
  host_allowlist.add(default_sshhost);
  cluster_sshhosts.forEach((cluster) => {
    host_allowlist.add(cluster.host);
  });
  return host_allowlist;
}

/**
 * Returns if host is in allowlist
 * 
 * @param {set - object} allowlist 
 * @param {string} host 
 */
function hostInAllowList(allowlist, host) {
  allowlist = Array.from(allowlist);
  return allowlist.some((value) => minimatch(host, value));
}

/**
 * If the url has a match with host_path_rx, the respective capture groups are returned
 * 
 * @param {string} url request url
 * @param {string - regex} host_path_rx regex used to match and caputre the url
 * @param {string} default_sshhost returned hostname if default
 */
function host_and_dir_from_url(url, host_path_rx, default_sshhost){
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
  generate_host_allowlist,
  generate_cluster_sshhosts,
  generate_default_sshhost,
  add_to_host_allowlist,
  hostInAllowList,
  host_and_dir_from_url,
}
