const minimatch = require('minimatch');
const glob      = require('glob');
const path      = require('path');
const yaml      = require('js-yaml');
const fs        = require('fs');

/**
 * Generates a set from ood_sshhost_allowlist if exists
 * 
 * @param {string} ood_sshhost_allowlist 
 * 
 * @return {set - object}
 */
function generateHostAllowlist(ood_sshhost_allowlist){
  return ood_sshhost_allowlist ? new Set(ood_sshhost_allowlist.split(':')) : new Set()
}

/**
 * Returns an array of hashes with information about each cluster
 * 
 * @param {string} clusters_d_path process.env.OOD_CLUSTERS if written
 * 
 * @return {Array} array values are hashes w/host and default
 */
function generateClusterSshhosts(clusters_d_path){
  return glob.sync(path.join((clusters_d_path || '/etc/ood/config/clusters.d'), '*.y*ml'))
  .map(yml => yaml.safeLoad(fs.readFileSync(yml)))
  .filter(config => (config.v2 && config.v2.login && config.v2.login.host) && ! (config.v2 && config.v2.metadata && config.v2.metadata.hidden))
  .map(config => {
    return {host: config.v2.login.host, default: config.v2.login.default}
  })
}

/**
 * Returns host with property default:true, else returns first available host
 * 
 * @param {Array} cluster_sshhosts 
 * 
 * @return {string} 
 */
function generateDefaultSshhost(cluster_sshhosts){
  return cluster_sshhosts.find(cluster => cluster.default || ([first] = cluster_sshhosts)).host
}

/**
 * Add hosts from cluster_sshhosts to host_allowlist
 * 
 * @param {set - object} host_allowlist allowlist generated from ENV variable (if any)
 * @param {Array} cluster_sshhosts Contains host for each cluster
 * @param {string} default_sshhost Adds to host_allowlist - Might be different from cluster_sshhosts
 * 
 * @return {set - object} updated allowlist
 */
function addToHostAllowlist(host_allowlist, cluster_sshhosts, default_sshhost){
  host_allowlist.add(default_sshhost);
  cluster_sshhosts.forEach(cluster => {
    host_allowlist.add(cluster.host);
  });
  return host_allowlist;
}

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

module.exports = {
  generateHostAllowlist,
  generateClusterSshhosts,
  generateDefaultSshhost,
  addToHostAllowlist,
  hostInAllowList,
  hostAndDirFromURL,
}
