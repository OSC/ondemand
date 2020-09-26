const minimatch = require('minimatch');
const glob      = require('glob');
const path      = require('path');
const yaml      = require('js-yaml');
const fs        = require('fs');

function hostInAllowList(allowlist, host) {
  allowlist = Array.from(allowlist);
  return allowlist.some((value) => minimatch(host, value))
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

class HostAllowlist{
  constructor(ood_sshhost_allowlist, clusters_d_path, ood_default_sshhost){
    this.allowlist = ood_sshhost_allowlist ? new Set(ood_sshhost_allowlist.split(':')) : new Set();

    //Filter through cluster configs, return array of hashes with host and default
    let cluster_sshhosts = glob.sync(path.join((clusters_d_path || '/etc/ood/config/clusters.d'), '*.y*ml'))
    .map(yml => yaml.safeLoad(fs.readFileSync(yml)))
    .filter(config => (config.v2 && config.v2.login && config.v2.login.host) && ! (config.v2 && config.v2.metadata && config.v2.metadata.hidden))
    .map(config => {
      return {host: config.v2.login.host, default: config.v2.login.default}
    })
  
    //Add to allowlist
    if (ood_default_sshhost) {this.allowlist.add(ood_default_sshhost);}
    cluster_sshhosts.forEach(cluster => {
      this.allowlist.add(cluster.host);
    });
  
    this.default_sshhost = ood_default_sshhost || cluster_sshhosts.find(cluster => cluster.default || ([first] = cluster_sshhosts)).host
  }

  default_sshhost(){
    return this.default_sshhost;
  }

  allowlist(){
    return this.allowlist;
  }
}

module.exports = {
  hostInAllowList,
  hostAndDirFromURL,
  HostAllowlist,
}
