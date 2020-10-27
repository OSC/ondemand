/**
 * Allowlist helper function tests
 */
const helpers = require('../utils/helpers')
const HostAllowlist = require('../utils/host-allowlist')

/**
 * Constants used during test
 */
describe('Helper function hostInAllowList()', () => {
  let ood_default_sshhost = "owens.osc.edu"
  let ood_sshhost_allowlist = "owens.osc.edu:pitzer.osc.edu:*.ten.osc.edu"
  let cluster_path = "./test/clusters.d"
  let host_allowlist = new HostAllowlist(ood_sshhost_allowlist, cluster_path, ood_default_sshhost);

  test('it should be true for hostnames in allowlist', () => {
    expect(host_allowlist.hostInAllowlist('pitzer.osc.edu')).toBeTruthy()
    expect(host_allowlist.hostInAllowlist('owens.osc.edu')).toBeTruthy()
  })

  test('it should be false for hostname not in the allowlist', () => {
    expect(host_allowlist.hostInAllowlist('localhost')).not.toBeTruthy()
  })

  test('it should be true for hostname that matches wildcard FQDN', () => {
    expect(host_allowlist.hostInAllowlist('p1001.ten.osc.edu')).toBeTruthy()
  })

  test('it should be false for hostname not matched by wildcard FQDN', () => {
    expect(host_allowlist.hostInAllowlist('p1001.eleven.osc.edu')).not.toBeTruthy()
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

describe('Class HostAllowlist', () => {
  let cluster_path = "./test/clusters.d"

  test('generates allowlist and default_sshhost correctly', () => {
    let ood_default_sshhost = "owens.osc.edu"
    let ood_sshhost_allowlist = "owens.osc.edu:pitzer.osc.edu:*.ten.osc.edu"
    let host_allowlist = new HostAllowlist(ood_sshhost_allowlist, cluster_path, ood_default_sshhost);

    expect(host_allowlist.allowlist).toMatchObject(new Set(['owens.osc.edu', 'pitzer.osc.edu', 'ruby.osc.edu', "*.ten.osc.edu"]))
    expect(host_allowlist.default_sshhost).toBe("owens.osc.edu")

  })

  test('if default_sshhost is not declared', () => {
    let ood_default_sshhost
    let ood_sshhost_allowlist = "owens.osc.edu:pitzer.osc.edu:*.ten.osc.edu"
    let host_allowlist = new HostAllowlist(ood_sshhost_allowlist, cluster_path, ood_default_sshhost);

    expect(host_allowlist.allowlist).toMatchObject(new Set(['owens.osc.edu', 'pitzer.osc.edu', 'ruby.osc.edu', "*.ten.osc.edu"]))
    expect(host_allowlist.default_sshhost).toBe("owens.osc.edu")
  })

  test('allowlist not declared, allowlist generated from default_sshhost and cluster configs', () => {
    let ood_default_sshhost = "armstrong.osc.edu"
    let ood_sshhost_allowlist
    let host_allowlist = new HostAllowlist(ood_sshhost_allowlist, cluster_path, ood_default_sshhost);

    expect(host_allowlist.allowlist).toMatchObject(new Set(['armstrong.osc.edu', 'owens.osc.edu', 'pitzer.osc.edu', 'ruby.osc.edu']))
    expect(host_allowlist.default_sshhost).toBe("armstrong.osc.edu")
  })

})
