const minimatch = require('minimatch')

function hostInAllowList(allowlist, host) {
  allowlist = Array.from(allowlist);
  return allowlist.some((value) => minimatch(host, value))
}

module.exports = {
  hostInAllowList,
}
