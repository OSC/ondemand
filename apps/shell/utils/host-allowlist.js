const minimatch = require('minimatch');
const glob      = require('glob');
const path      = require('path');
const yaml      = require('js-yaml');
const fs        = require('fs');

class HostAllowlist {
  constructor(ood_sshhost_allowlist, clusters_d_path, ood_default_sshhost) {
    this.allowlist = ood_sshhost_allowlist ? new Set(ood_sshhost_allowlist.split(':')) : new Set()
    this.clusters = new Array()
    this.clusters_d_path = clusters_d_path

    this.clusters = this.getClusterConfigs()
      .filter(config => (config.v2 && config.v2.login && config.v2.login.host) && ! (config.v2 && config.v2.metadata && config.v2.metadata.hidden))
      .map(config => {
        let hidden = config.v2.login.hidden
        let host = config.v2.login.host || 'localhost'
        let isDefault = config.v2.login.default || false

        if (!hidden) { // If the cluster is not hidden, add the host to the allowlist.
          this.addToAllowlist(host)
        }

        return {
          host,
          default: isDefault,
        }
      })

    // Find default cluster configuration.
    let found = this.clusters.find(cluster => cluster.default) || this.clusters.shift() // Find cluster with "default", if not found then use first cluster in array.
    this.default_sshhost = ood_default_sshhost || found.host // ood_default_sshhost takes precedence over default cluster found.

    if (ood_default_sshhost) {
      this.addToAllowlist(ood_default_sshhost)
    }
  }

  getClusterConfigs() {
    const clusterConfigs = path.join((this.clusters_d_path || '/etc/ood/config/clusters.d'))
    let yamlFiles = glob.sync(path.join(clusterConfigs + '/**', '*.y*ml'))

    let data = yamlFiles
      .map(location => {
        // Attempt to parse yaml file.
        try {
          let parsed = yaml.safeLoad(fs.readFileSync(location, 'utf-8'))

          return parsed
        } catch (err) {
          const { name } = err

          if (name === 'YAMLException') {
            return err
          }
        }
      })

    return data
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