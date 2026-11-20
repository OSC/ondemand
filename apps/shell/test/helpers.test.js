'use strict';
const path = require('path');
const fs = require('fs');

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

  test('when an unreadable yml file is present', () => {
    const unreadableYmlPath = path.join(process.env.OOD_CLUSTERS, 'pitzer.yml');
    fs.chmodSync(unreadableYmlPath, 0);
    try {
      let hosts = helpers.definedHosts();
      let defaultHost = hosts['default'];
      let allHosts = hosts['hosts'];
      // owens.yml has default in it
      expect(defaultHost).toEqual('owens.osc.edu');
      expect(allHosts).toEqual(['owens.osc.edu', 'ruby.osc.edu']);
      fs.chmodSync(unreadableYmlPath, 0o644);
    } catch (err) {
      // wait to send error until file permissions are restored 
      fs.chmodSync(unreadableYmlPath, 0o644);
      throw err;
    }
  })
});

describe('Helper function userCSS()', () => {
  const OLD_ENV = process.env;

  beforeEach(() => {
    jest.resetModules();
    process.env = { ...OLD_ENV };
  });

  afterAll(() => {
    process.env = OLD_ENV;
  });

  test('returns the default relative stylesheet joined to baseURI', () => {
    expect(helpers.userCSS('/pun/sys/shell')).toEqual('/pun/sys/shell/stylesheets/fonts.css');
  });

  test('returns a relative OOD_SHELL_USER_CSS_URL joined to baseURI', () => {
    process.env.OOD_SHELL_USER_CSS_URL = 'stylesheets/custom.css';
    expect(helpers.userCSS('/pun/sys/shell')).toEqual('/pun/sys/shell/stylesheets/custom.css');
  });

  test('ignores baseURI when OOD_SHELL_USER_CSS_URL is absolute', () => {
    process.env.OOD_SHELL_USER_CSS_URL = '/public/custom.css';
    expect(helpers.userCSS('/something/else')).toEqual('/public/custom.css');
  });
});


describe('Helper function urlParamNames()', () => {
  beforeEach(() => {
    jest.spyOn(console, 'warn').mockImplementation(() => {});
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  test('returns an empty list when unset or empty', () => {
    expect(helpers.urlParamNames(undefined)).toEqual([]);
    expect(helpers.urlParamNames('')).toEqual([]);
  });

  test('splits, trims and deduplicates names', () => {
    expect(helpers.urlParamNames(' job_id, path ,,job_id')).toEqual(['job_id', 'path']);
  });

  test('ignores csrf and invalid names', () => {
    expect(helpers.urlParamNames('csrf,job-id,bad=name,job_id')).toEqual(['job_id']);
    expect(console.warn).toHaveBeenCalledTimes(3);
  });
});

describe('Helper function urlParamsEnv()', () => {
  const URL = '/pun/sys/shell/ssh/login.example.org/home/user?job_id=12345&path=%2Fhome%2Fuser%2Fsome%20dir&other=1&csrf=abc';

  test('returns no variables when no names are allowed', () => {
    expect(helpers.urlParamsEnv(URL, [])).toEqual({});
  });

  test('exports allowed parameters only, decoded and with uppercased names', () => {
    expect(helpers.urlParamsEnv(URL, ['job_id', 'path'])).toEqual({
      'OOD_SHELL_URL_PARAM_JOB_ID': '12345',
      'OOD_SHELL_URL_PARAM_PATH': '/home/user/some dir',
    });
  });

  test('skips allowed parameters missing from the url', () => {
    expect(helpers.urlParamsEnv('/pun/sys/shell/ssh/default', ['job_id'])).toEqual({});
  });

  test('keeps empty values', () => {
    expect(helpers.urlParamsEnv('/ssh/default?job_id=', ['job_id'])).toEqual({ 'OOD_SHELL_URL_PARAM_JOB_ID': '' });
  });

  test('uses the first value of a repeated parameter', () => {
    expect(helpers.urlParamsEnv('/ssh/default?job_id=1&job_id=2', ['job_id'])).toEqual({ 'OOD_SHELL_URL_PARAM_JOB_ID': '1' });
  });

  test('drops values with NUL bytes or over 4096 characters', () => {
    expect(helpers.urlParamsEnv('/ssh/default?job_id=1%002', ['job_id'])).toEqual({});
    expect(helpers.urlParamsEnv(`/ssh/default?job_id=${'a'.repeat(4097)}`, ['job_id'])).toEqual({});
    expect(helpers.urlParamsEnv(`/ssh/default?job_id=${'a'.repeat(4096)}`, ['job_id'])).toEqual({ 'OOD_SHELL_URL_PARAM_JOB_ID': 'a'.repeat(4096) });
  });

  test('matches parameter names case sensitively', () => {
    expect(helpers.urlParamsEnv('/ssh/default?JOB_ID=1', ['job_id'])).toEqual({});
  });
});
