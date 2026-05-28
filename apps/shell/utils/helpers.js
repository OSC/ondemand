const { minimatch } = require('minimatch');
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
        return yaml.load(fs.readFileSync(yml));
      } catch(err) {
        console.log(`error reading ${yml}`);
        console.log(err);
      }
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

  // alphabetically sort hosts
  const origHosts = hosts['hosts'];
  hosts['hosts'] = origHosts.sort();

  // couldn't find a defined default, so let's just make one now if we can
  if(hosts['default'] === null && hosts['hosts'].length > 0) {
    hosts['default'] = hosts['hosts'][0];
  }

  return hosts;
}

function shellFonts() {
  const defaultFonts = '"Iosevka Web", "DejaVu Sans Mono", "Noto Sans Mono", "Everson Mono", FreeMono, Menlo, Terminal, monospace';
  return (process.env.OOD_SHELL_FONTS || defaultFonts).split(",").map(s => s.trim());
}

function userCSS(baseURI) {
  // Support providing both absolute and relative (to shell app) stylesheets
  const css = process.env.OOD_SHELL_USER_CSS_URL || "stylesheets/fonts.css";
  if (css.startsWith("/")) {
    return css;
  }
  return `${baseURI}/${css}`;
}

module.exports = {
  hostInAllowList,
  definedHosts,
  shellFonts,
  userCSS,
}
