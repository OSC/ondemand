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

function userCSS(baseURI) {
  // Support providing both absolute and relative (to shell app) stylesheets
  const css = process.env.OOD_SHELL_USER_CSS_URL || "stylesheets/fonts.css";
  if (css.startsWith("/")) {
    return css;
  }
  return `${baseURI}/${css}`;
}

// Parse a comma separated list of URL query parameter names (OOD_SHELL_URL_PARAMS)
// that are exported as environment variables for use by the OOD_SSH_WRAPPER command.
function urlParamNames(config) {
  if (!config) {
    return [];
  }

  const names = config.split(',').map((name) => name.trim()).filter((name) => name !== '');
  return Array.from(new Set(names)).filter((name) => {
    if (name === 'csrf') {
      console.warn('OOD_SHELL_URL_PARAMS: ignoring reserved parameter name "csrf"');
      return false;
    } else if (!/^[A-Za-z0-9_]+$/.test(name)) {
      console.warn(`OOD_SHELL_URL_PARAMS: ignoring invalid parameter name "${name}"`);
      return false;
    }
    return true;
  });
}

// Map the allowed query parameters of the url to OOD_SHELL_URL_PARAM_<NAME> environment
// variables. Only the first value of a repeated parameter is used, and values containing
// NUL bytes or longer than 4096 characters are dropped.
function urlParamsEnv(url, names) {
  const env = {};
  if (names.length === 0) {
    return env;
  }

  const params = new URL(url, 'http://localhost').searchParams;
  names.forEach((name) => {
    const value = params.get(name);
    if (value === null || value.includes('\0') || value.length > 4096) {
      return;
    }

    env[`OOD_SHELL_URL_PARAM_${name.toUpperCase()}`] = value;
  });

  return env;
}

module.exports = {
  hostInAllowList,
  definedHosts,
  userCSS,
  urlParamNames,
  urlParamsEnv,
}
