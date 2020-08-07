/**
 * Helper functions tested
 */
const helpers = require('../utils/helpers')

//generateHostAllowlist
describe('Helper function generate_host_allowlist()', () => {
  test('it should turn a colon-delimited string into a set', () => {
    expect(helpers.generateHostAllowlist('pitzer.osc.edu:owens.osc.edu:*.ten.osc.edu')).toMatchObject(new Set(['pitzer.osc.edu', 'owens.osc.edu', '*.ten.osc.edu']));
  })

  test('it should return an empty set for an undefined allowlist', () => {
    expect(helpers.generateHostAllowlist(null)).toMatchObject(new Set);
  })
})

//pitzer expansion has v2.metadata.hidden = true so it is not included
describe('Helper function generateClusterSshhosts()', () => {
  test('it should include host & default values in the cluster configs', () => {
    expect(helpers.generateClusterSshhosts('./test/clusters.d')).toMatchObject([
      {host: 'owens.osc.edu', default: true},
      {host: 'pitzer.osc.edu', default: false},
      {host: 'ruby.osc.edu', default: undefined}
    ]);
  })
})

describe('Helper function generateDefaultSshhost()', () => {
  test('it should return the hostname where cluster.default = true', () => {
    const cluster_sshhosts = [{host: 'owens.osc.edu', default: true}, {host: 'pitzer.osc.edu', default: false}, {host: 'ruby.osc.edu', default: undefined}];
    expect(helpers.generateDefaultSshhost(cluster_sshhosts)).toBe('owens.osc.edu')
  })

  test('it should return the first hostname if no cluster.default = true', () => {
    const cluster_sshhosts_2 = [{host: 'pitzer.osc.edu', default: false}, {host: 'ruby.osc.edu', default: undefined}];
    expect(helpers.generateDefaultSshhost(cluster_sshhosts_2)).toBe('pitzer.osc.edu')
  })
})

describe('Helper function addToHostAllowlist()', () => {
  const cluster_sshhosts = [
    {host: 'owens.osc.edu', default: true},
    {host: 'pitzer.osc.edu', default: false},
    {host: 'ruby.osc.edu', default: undefined}
  ]

  test('it should add hosts from cluster_sshhosts and default_sshhost to host_allowlist', () => {
    expect(helpers.addToHostAllowlist(new Set(['pitzer.osc.edu']), cluster_sshhosts, 'owens.osc.edu')).toMatchObject(new Set(['owens.osc.edu', 'pitzer.osc.edu', 'ruby.osc.edu']));
  })

  test('it should add hosts to host_allowlist when default_sshhost is same value in cluster_sshhosts', () => {
    expect(helpers.addToHostAllowlist(new Set, cluster_sshhosts, 'armstrong.osc.edu')).toMatchObject(new Set(['owens.osc.edu', 'pitzer.osc.edu', 'ruby.osc.edu', 'armstrong.osc.edu']));
  })
})

describe('Helper function hostInAllowList()', () => {
  const ALLOW_LIST = new Set(['owens.osc.edu', 'pitzer.osc.edu', '*.ten.osc.edu'])
  test('it should be true for hostnames in allowlist', () => {
    expect(helpers.hostInAllowList(ALLOW_LIST, 'pitzer.osc.edu')).toBeTruthy()
    expect(helpers.hostInAllowList(ALLOW_LIST, 'owens.osc.edu')).toBeTruthy()
  })

  test('it should be false for hostname not in the allowlist', () => {
    expect(helpers.hostInAllowList(ALLOW_LIST, 'localhost')).not.toBeTruthy()
  })

  test('it should be true for hostname that matches wildcard FQDN', () => {
    expect(helpers.hostInAllowList(ALLOW_LIST, 'p1001.ten.osc.edu')).toBeTruthy()
  })

  test('it should be false for hostname not matched by wildcard FQDN', () => {
    expect(helpers.hostInAllowList(ALLOW_LIST, 'p1001.eleven.osc.edu')).not.toBeTruthy()
  })
})

describe('Helper function hostAndDirFromURL()', () => {
  const default_sshhost = 'owens.osc.edu';
  test('it should capture hostname and directory path is undefined', () => {
    let url = 'https://ondemand-test.osc.edu/pun/dev/shell/ssh/pitzer.osc.edu';
    expect(helpers.hostAndDirFromURL(url, default_sshhost)).toMatchObject(['pitzer.osc.edu', null]);
  })

  test('it should set hostname to default_sshhost', () => {
    let url = 'https://ondemand-test.osc.edu/pun/dev/shell/ssh/default';
    expect(helpers.hostAndDirFromURL(url, default_sshhost)).toMatchObject(['owens.osc.edu', null]);
  })

  test('it should capture directory path', () => {
    let url = 'https://ondemand-test.osc.edu/pun/dev/shell/ssh/default/path/to/directory';
    expect(helpers.hostAndDirFromURL(url, default_sshhost)).toMatchObject(['owens.osc.edu', '/path/to/directory']);
  })
}) 