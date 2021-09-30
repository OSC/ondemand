const minimatch = require('minimatch');
const glob      = require('glob');
const path      = require('path');
const yaml      = require('js-yaml');
const fs        = require('fs');

function hostInAllowList(allowlist, host) {
  allowlist = Array.from(allowlist);
  return allowlist.some((value) => minimatch(host, value))
}

function definedHosts() {
  const hosts = {
    'default': process.env.OOD_DEFAULT_SSHHOST || process.env.DEFAULT_SSHHOST || null,
    'hosts': []
  };

  glob.sync(path.join((process.env.OOD_CLUSTERS || '/etc/ood/config/clusters.d'), '*.y*ml'))
    .map((yml) => {
      try {
        return yaml.safeLoad(fs.readFileSync(yml));
      } catch(err) { /** just keep going. dashboard should have an alert about it */}
    }).filter(config => (config && config.v2 && config.v2.login && config.v2.login.host) && ! (config.v2 && config.v2.metadata && config.v2.metadata.hidden))
    .forEach((config) => {
      let host = config.v2.login.host; //Already did checking above
      if(config.v2.login.default && hosts['default'] === null) {
        hosts['default'] = host;
        hosts['hosts'].push(host);
      } else {
        hosts['hosts'].push(host);
      }
    });

  return hosts;
}

module.exports = {
  hostInAllowList,
  definedHosts
}
