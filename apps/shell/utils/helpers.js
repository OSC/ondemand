const glob = require('glob');
const path = require('path');
const yaml = require('js-yaml');
const fs = require('fs');

const HOST_PATH_RX = '/ssh/([^\\/\\?]+)([^\\?]+)?(\\?.*)?$';

let defaultSshHost = () => {
  return process.env.DEFAULT_SSHHOST ? process.env.DEFAULT_SSHHOST : null;
};

const wsErrorMessage = (message) => {
  return (
    [
      'HTTP/1.1 401 Unauthorized',
      'Content-Type: text/html; charset=UTF-8',
      'Content-Encoding: UTF-8',
      'Connection: close',
      `X-OOD-Failure-Reason: ${message}`,
    ].join('\r\n') + '\r\n\r\n'
  );
};

const hostAllowList = () => {
  let hostAllowList = new Set();

  if (process.env.SSHHOST_WHITELIST) {
    hostAllowList = new Set(process.env.SSHHOST_WHITELIST.split(':'));
  }

  glob
    .sync(
      path.join(
        process.env.OOD_CLUSTERS || '/etc/ood/config/clusters.d',
        '*.y*ml',
      ),
    )
    .map((yml) => yaml.safeLoad(fs.readFileSync(yml)))
    .filter(
      (config) =>
        config.v2 &&
        config.v2.login &&
        config.v2.login.host &&
        !(config.v2 && config.v2.metadata && config.v2.metadata.hidden),
    )
    .forEach((config) => {
      const host = config.v2.login.host;
      const isDefault = config.v2.login.default;
      hostAllowList.add(host);
      if (isDefault) {
        defaultSshHost = host;
      }
    });

  if (defaultSshHost) {
    hostAllowList.add(defaultSshHost);
  }

  return hostAllowList;
};

const parseUrl = (url) => {
  const match = url.match(HOST_PATH_RX);
  let hostname = defaultSshHost();
  let directory = null;

  if (match) {
    hostname = match[1] === 'default' ? defaultSshHost() : match[1];
    directory = match[2] ? decodeURIComponent(match[2]) : null;
  }

  return [hostname, directory];
};

function defaultServerOrigin(headers) {
  let origin;

  if (headers['x-forwarded-proto'] && headers['x-forwarded-host']) {
    origin = headers['x-forwarded-proto'] + '://' + headers['x-forwarded-host'];
  }

  return origin;
}

function customServerOrigin(defaultValue = null) {
  let customOrign;

  if (process.env.OOD_SHELL_ORIGIN_CHECK) {
    // if ENV is set, do not use default!
    if (process.env.OOD_SHELL_ORIGIN_CHECK.startsWith('http')) {
      customOrign = process.env.OOD_SHELL_ORIGIN_CHECK;
    }
  } else {
    customOrign = defaultValue;
  }

  return customOrign;
}

module.exports = {
  parseUrl,
  hostAllowList,
  defaultServerOrigin,
  customServerOrigin,
  wsErrorMessage,
};
