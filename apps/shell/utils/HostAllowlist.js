const minimatch = require('minimatch');
const glob      = require('glob');
const path      = require('path');
const yaml      = require('js-yaml');
const fs        = require('fs');

class HostAllowlist {
    constructor(ood_sshhost_allowlist, clusters_d_path, ood_default_sshhost){
        this.allowlist = ood_sshhost_allowlist ? new Set(ood_sshhost_allowlist.split(':')) : new Set();
  
        //Filter through cluster configs, return array of hashes with host and default
        let cluster_sshhosts = glob.sync(path.join((clusters_d_path || '/etc/ood/config/clusters.d'), '*.y*ml'))
        .map(yml => yaml.safeLoad(fs.readFileSync(yml)))
        .filter(config => (config.v2 && config.v2.login && config.v2.login.host) && ! (config.v2 && config.v2.metadata && config.v2.metadata.hidden))
        .map(config => {
            return { host: config.v2.login.host, default: config.v2.login.default }
        })
    
        //Add to allowlist
        if (ood_default_sshhost) { 
            this.addToAllowlist(ood_default_sshhost);
        }
        cluster_sshhosts.forEach(cluster => {
            this.addToAllowlist(cluster.host);
        });

        this.default_sshhost = ood_default_sshhost || cluster_sshhosts.find(cluster => cluster.default || ([first] = cluster_sshhosts)).host;
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