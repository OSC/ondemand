const minimatch = require('minimatch')

function generateWildcardGlob(allowlist) {
  let wildcards = allowlist.filter((host) => host.indexOf('*') != -1)  
  let globExpression = `@(${ wildcards.join('|') })`;
  return globExpression;
}

function hostInAllowList(allowlist, host) {
  allowlist = Array.from(allowlist);
  let wildcard = generateWildcardGlob(allowlist);
  console.log(wildcard)

  return allowlist.some(() => {
    return allowlist.includes(host) ? true : minimatch(host, wildcard) ? true : false;
  });
}

module.exports = {
  hostInAllowList
}
