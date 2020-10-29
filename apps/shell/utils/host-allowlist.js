const minimatch = require('minimatch');
const glob      = require('glob');
const path      = require('path');
const yaml      = require('js-yaml');
const fs        = require('fs');

class HostAllowlist {
  constructor(ood_sshhost_allowlist, clusters_d_path, ood_default_sshhost) {
    this.allowlist = ood_sshhost_allowlist ? new Set(ood_sshhost_allowlist.split(':')) : new Set();
    this.clusters = new Array();
    this.default_sshhost = ood_default_sshhost || undefined;

    const clusterConfigs = path.join((clusters_d_path || '/etc/ood/config/clusters.d'));
    let yamlFiles = glob.sync(path.join(clusterConfigs, '*.y*ml'));

    yamlFiles.map(location => {
      try {
        let parsed = yaml.safeLoad(fs.readFileSync(location, 'utf8'));

        if (parsed != undefined) {
          this.clusters.push(parsed);
        }
      } catch (err) {
        const { name, reason } = err
        console.error(name, reason)
      }
    })

    this.clusters = this.clusters
      .filter(config => config != undefined)
      .filter(config => (config.v2 && config.v2.login && config.v2.login.host) && ! (config.v2 && config.v2.metadata && config.v2.metadata.hidden))
      .map(config => {
        let hidden = config.v2.login.hidden;
        let host = config.v2.login.host || 'localhost';
        let isDefault = config.v2.login.default || false;

        if (!hidden) { // If the cluster is not hidden, add the host to the allowlist.
          this.addToAllowlist(host);
        };

        return {
          host,
          default: isDefault,
        };
      });

    // Find default cluster configuration.
    if (this.clusters.length > 0) {
      let found = this.clusters.find(cluster => cluster.default) || this.clusters.shift(); // Find cluster with "default", if not found then use first cluster in array.
      this.default_sshhost = ood_default_sshhost == undefined ? found.host : ood_default_sshhost; // ood_default_sshhost takes precedence over default cluster found.
    }

    if (this.default_sshhost != undefined) {
      this.addToAllowlist(this.default_sshhost);
    }
  }

  default_sshhost() {
    return this.default_sshhost;
  }

  allowlist() {
    return this.allowlist;
  }

  addToAllowlist(host) {
    this.allowlist.add(host);
  }

  hostInAllowlist(host) {
    var arrAllowlist = Array.from(this.allowlist);
    return arrAllowlist.some((value) => minimatch(host, value))
  }
}

module.exports = HostAllowlist