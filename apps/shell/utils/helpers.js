const path         = require('path');
const fs           = require('fs');
const glob         = require('glob');
const yaml         = require('js-yaml');
const host_path_rx = '/ssh/([^\\/\\?]+)([^\\?]+)?(\\?.*)?$';

let host_whitelist = new Set;

exports.host_and_dir_from_url = function (url, default_sshhost) {
  if (process.env.SSHHOST_WHITELIST) {
    host_whitelist = new Set(process.env.SSHHOST_WHITELIST.split(':'));
  }

  glob.sync(path.join((process.env.OOD_CLUSTERS || '/etc/ood/config/clusters.d'), '*.y*ml'))
    .map(yml => yaml.safeLoad(fs.readFileSync(yml)))
    .filter(config => (config.v2 && config.v2.login && config.v2.login.host) && !(config.v2 && config.v2.metadata && config.v2.metadata.hidden))
    .forEach((config) => {
      let host = config.v2.login.host; //Already did checking above
      let isDefault = config.v2.login.default;
      host_whitelist.add(host);
      if (isDefault) default_sshhost = host;
    });

  if (default_sshhost) host_whitelist.add(default_sshhost);

  let match = url.match(host_path_rx),
    hostname = default_sshhost,
    directory = null;

  if (match) {
    hostname = match[1] === "default" ? default_sshhost : match[1];
    directory = match[2] ? decodeURIComponent(match[2]) : null;
  }

  return [hostname, directory];
}

exports.host_whitelist = host_whitelist
