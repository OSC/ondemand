const minimatch = require('minimatch');
const glob      = require('glob');
const path      = require('path');
const yaml      = require('js-yaml');
const fs        = require('fs');

class HostAllowlist {
  constructor(ood_sshhost_allowlist, clusters_d_path, ood_default_sshhost) {
    this.allowlist = ood_sshhost_allowlist ? new Set(ood_sshhost_allowlist.split(':')) : new Set()
    this.clusters = new Array()

    const directory = path.join((clusters_d_path || '/etc/ood/config/clusters.d'))
    let yamlFiles = glob.sync(path.join(directory, '*.y*ml'))
  
    while (yamlFiles.length > 0) {
      try {
        // Destructure "v2" property out of yaml configuration.
        let { v2: version } = yaml.safeLoad(fs.readFileSync(yamlFiles.shift(), 'utf-8'))
  
        // Destructure "login" and "metadata" properties out of cluster configuration.
        let {
          login: {
            default: isDefault = version.login.default === undefined ? false : version.login.default, // If cluster configuration does not contain "default" property, set false.
            host = version.login.host === undefined ? 'localhost' : version.login.host // If host is not defined, set to "localhost".
          },
          metadata: {
            hidden = version.metadata.hidden === undefined ? true : version.metadata.hidden // If cluster configuration does not set "hidden" property, set true.
          }
        } = version
 
        this.clusters.push(version)

        if (isDefault) this.default_sshhost = host // Set cluster as default if "login.default" is true.
        if (!hidden) { // If the cluster is not hidden, add the host to the allowlist.
          this.addToAllowlist(host)
        }
      } catch (err) {
        const { name, reason, message } = err
        if (name === 'YAMLException', reason, message) {
          console.error(name, reason, message)
        }
      }
    }

    // Find default cluster configuration.
    let { login: { host } } = this.clusters.find(cluster => cluster.default) || this.clusters.shift() // Find cluster with "login.default", if not found then use first cluster found.
    this.default_sshhost = ood_default_sshhost || host // ood_default_sshhost takes precedence over default cluster found.

    if (ood_default_sshhost) {
      this.addToAllowlist(ood_default_sshhost)
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