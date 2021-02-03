/**
 * Helper functions tested
 */
const helpers = require('../utils/helpers')

describe('Helper function hostAllowlistAndDefaultHost()', () => {
  let cluster_path = "./test/clusters.d"

  test('generates allowlist and default_sshhost correctly', () => {
    let ood_default_sshhost = "owens.osc.edu"
    let ood_sshhost_allowlist = "owens.osc.edu:pitzer.osc.edu:*.ten.osc.edu"

    expect(helpers.hostAllowlistAndDefaultHost(ood_sshhost_allowlist, cluster_path, ood_default_sshhost)).toMatchObject([new Set(['owens.osc.edu', 'pitzer.osc.edu', 'ruby.osc.edu', "*.ten.osc.edu"]), "owens.osc.edu" ])
  })

  test('if default_sshhost is not declared', () => {
    let ood_default_sshhost
    let ood_sshhost_allowlist = "owens.osc.edu:pitzer.osc.edu:*.ten.osc.edu"

    expect(helpers.hostAllowlistAndDefaultHost(ood_sshhost_allowlist, cluster_path, ood_default_sshhost)).toMatchObject([new Set(['owens.osc.edu', 'pitzer.osc.edu', 'ruby.osc.edu', "*.ten.osc.edu"]), "owens.osc.edu" ])
  })

  test('allowlist not declared, allowlist generated from default_sshhost and cluster configs', () => {
    let ood_default_sshhost = "armstrong.osc.edu"
    let ood_sshhost_allowlist

    expect(helpers.hostAllowlistAndDefaultHost(ood_sshhost_allowlist, cluster_path, ood_default_sshhost)).toMatchObject([new Set(['armstrong.osc.edu', 'owens.osc.edu', 'pitzer.osc.edu', 'ruby.osc.edu']), "armstrong.osc.edu" ])
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