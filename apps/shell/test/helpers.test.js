'use strict';

/**
 * Allowlist helper function tests
 */
const helpers = require('../utils/helpers')

/**
 * Constants used during test
 */
const ALLOW_LIST = new Set(['owens.osc.edu', 'pitzer.osc.edu', '*.ten.osc.edu'])

describe('Helper function hostInAllowList()', () => {
  test('it should be true for hostnames in allowlist', () => {
    expect(helpers.hostInAllowList(ALLOW_LIST, 'pitzer.osc.edu')).toBeTruthy();
    expect(helpers.hostInAllowList(ALLOW_LIST, 'owens.osc.edu')).toBeTruthy();
  })

  test('it should be false for hostname not in the allowlist', () => {
    expect(helpers.hostInAllowList(ALLOW_LIST, 'localhost')).not.toBeTruthy();
  })

  test('it should be true for hostname that matches wildcard FQDN', () => {
    expect(helpers.hostInAllowList(ALLOW_LIST, 'p1001.ten.osc.edu')).toBeTruthy();
  })

  test('it should be false for hostname not matched by wildcard FQDN', () => {
    expect(helpers.hostInAllowList(ALLOW_LIST, 'p1001.eleven.osc.edu')).not.toBeTruthy();
  })
});

describe('Helper function definedHosts()', () => {

  const OLD_ENV = process.env;

  beforeEach(() => {
    jest.resetModules();
    process.env = { 'OOD_CLUSTERS': 'test/clusters.d' };
  });

  afterAll(() => {
    process.env = OLD_ENV;
  });

  test('reads clusters.d files correctly', () => {
    let hosts = helpers.definedHosts();
    let defaultHost = hosts['default'];
    let allHosts = hosts['hosts'];

    // owens.yml has default in it
    expect(defaultHost).toEqual('owens.osc.edu');
    expect(allHosts).toEqual(['owens.osc.edu', 'pitzer.osc.edu', 'ruby.osc.edu']);
  });

  test('respects OOD_DEFAULT_SSHHOST', () => {
    process.env['OOD_DEFAULT_SSHHOST'] = 'the.default.host';

    let defaultHost = helpers.definedHosts()['default'];

    expect(defaultHost).toEqual('the.default.host');
  });

  test('respects DEFAULT_SSHHOST', () => {
    process.env['DEFAULT_SSHHOST'] = 'the.default.host';

    let defaultHost = helpers.definedHosts()['default'];

    expect(defaultHost).toEqual('the.default.host');
  });

  test('OOD_DEFAULT_SSHHOST has precedence over DEFAULT_SSHHOST', () => {
    process.env['DEFAULT_SSHHOST'] = 'the.old.default.host';
    process.env['OOD_DEFAULT_SSHHOST'] = 'the.new.default.host';

    let defaultHost = helpers.definedHosts()['default'];

    expect(defaultHost).toEqual('the.new.default.host');
  });

  test('when no default is defined', () => {
    // no default is defined in these cluster files or through an environment variable.
    // so, the default cluster is just the first one we found.
    process.env['OOD_CLUSTERS'] = 'test/no.defaults.clusters.d';

    let defaultHost = helpers.definedHosts()['default'];

    expect(defaultHost).toEqual('pitzer.osc.edu');
    expect(helpers.definedHosts()['hosts']).toEqual(['pitzer.osc.edu', 'ruby.osc.edu']);
  })
});

