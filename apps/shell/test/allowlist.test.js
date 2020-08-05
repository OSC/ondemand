/**
 * Helper functions tested
 */
const helpers = require('../utils/helpers')

//generate_host_allowlist
describe('Helper function generate_host_allowlsit', () => {
  test('it should turn a colon-delimited string into a set', () => {
    let allowlist = 'pitzer.osc.edu:owens.osc.edu:*.ten.osc.edu'
    let host_allowlist = new Set(['pitzer.osc.edu', 'owens.osc.edu', '*.ten.osc.edu']);
    expect(helpers.generate_host_allowlist(allowlist)).toMatchObject(host_allowlist);
  })

  test('it should return an empty set for an undefined allowlist', () => {
    let allowlist;
    let host_allowlist = new Set;
    expect(helpers.generate_host_allowlist(allowlist)).toMatchObject(host_allowlist);
  })
})


const owens = {host: 'owens.osc.edu', default: true};
const pitzer = {host: 'pitzer.osc.edu', default: false};
const ruby = {host: 'ruby.osc.edu', default: undefined}; // Testing case where default is NOT set
//pitzer expansion has v2.metadata.hidden = true so it is not included
const cluster_sshhosts = [owens, pitzer, ruby];
describe('Helper function generate_cluster_sshhosts', () => {
  test('it should include host & default values in the cluster configs', () => {
    expect(helpers.generate_cluster_sshhosts('./test/clusters.d')).toMatchObject(cluster_sshhosts);
  })
})

describe('Helper function generate_default_sshhost', () => {
  test('it should return the hostname where cluster.default = true', () => {
    expect(helpers.generate_default_sshhost(cluster_sshhosts)).toBe('owens.osc.edu')
  })

  test('it should return the first hostname if no cluster.default = true', () => {
    const cluster_sshhosts_2 = [pitzer, ruby];
    expect(helpers.generate_default_sshhost(cluster_sshhosts_2)).toBe('pitzer.osc.edu')
  })
})

describe('Helper function add_to_host_allowlist', () => {
  test('it should add hosts from cluster_sshhosts and default_sshhost to host_allowlist', () => {
    let host_allowlist = new Set(['pitzer.osc.edu']);
    let default_sshhost = 'owens.osc.edu';
    //cluster_sshhosts defined previously
    let expected_host_allowlist = new Set(['owens.osc.edu', 'pitzer.osc.edu', 'ruby.osc.edu']);
    expect(helpers.add_to_host_allowlist(host_allowlist, cluster_sshhosts, default_sshhost)).toMatchObject(expected_host_allowlist);
  })

  test('it should add hosts to host_allowlist when default_sshhost is same value in cluster_sshhosts', () => {
    let host_allowlist = new Set;
    let default_sshhost = 'armstrong.osc.edu'
    //cluster_sshhosts defined previously
    let expected_host_allowlist = new Set(['owens.osc.edu', 'pitzer.osc.edu', 'ruby.osc.edu', 'armstrong.osc.edu']);
    expect(helpers.add_to_host_allowlist(host_allowlist, cluster_sshhosts, default_sshhost)).toMatchObject(expected_host_allowlist);
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

describe('Helper function host_and_dir_from_url', () => {
  const host_path_rx = '/ssh/([^\\/\\?]+)([^\\?]+)?(\\?.*)?$';
  const default_sshhost = 'owens.osc.edu';
  test('it should capture hostname and directory path is undefined', () => {
    let url = 'https://ondemand-test.osc.edu/pun/dev/shell/ssh/pitzer.osc.edu';
    expect(helpers.host_and_dir_from_url(url, host_path_rx, default_sshhost)).toMatchObject(['pitzer.osc.edu', null]);
  })

  test('it should set hostname to default_sshhost', () => {
    let url = 'https://ondemand-test.osc.edu/pun/dev/shell/ssh/default';
    expect(helpers.host_and_dir_from_url(url, host_path_rx, default_sshhost)).toMatchObject(['owens.osc.edu', null]);
  })

  test('it should capture directory path', () => {
    let url = 'https://ondemand-test.osc.edu/pun/dev/shell/ssh/default/path/to/directory';
    expect(helpers.host_and_dir_from_url(url, host_path_rx, default_sshhost)).toMatchObject(['owens.osc.edu', '/path/to/directory']);
  })
})