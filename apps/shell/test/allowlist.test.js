/**
 * Allowlist helper function tests
 */
const helpers = require('../utils/helpers')

/**
 * Constants used during test
 */
const ALLOW_LIST = new Set(['owens.osc.edu', 'pitzer.osc.edu', '*.ten.osc.edu'])

describe('Helper function generateWildcardGlob()', () => {
  test('it should generate wildcard glob', () => {
    let wildcardGlob = helpers.generateWildcardGlob(Array.from(ALLOW_LIST))
    expect(wildcardGlob).toBe('@(*.ten.osc.edu)')
  })

  test('it should not have trailing character in wildcard glob', () => {
    let wildcardGlob = helpers.generateWildcardGlob(Array.from(ALLOW_LIST))
    expect(wildcardGlob).not.toBe('@(*.ten.osc.edu|)')
  })

  test('it should not parse hosts with without wildcards in the FQDN', () => {
    let wildcardGlob = helpers.generateWildcardGlob(Array.from(ALLOW_LIST))
    expect(wildcardGlob).not.toBe('@(owens.osc.edu|pitzer.osc.edu|*.ten.osc.edu)')
  })
})

describe('Helper function hostInAllowList()', () => {
  test('it should be true for hostnames in allowlist', () => {
    expect(helpers.hostInAllowList(ALLOW_LIST, 'pitzer.osc.edu')).toBeTruthy()
    expect(helpers.hostInAllowList(ALLOW_LIST, 'owens.osc.edu')).toBeTruthy()
  })

  test('it should be true for hostname that matches wildcard FQDN', () => {
    expect(helpers.hostInAllowList(ALLOW_LIST, 'p1001.ten.osc.edu')).toBeTruthy()
  })

  test('it should be false for hostname not matched by wildcard FQDN', () => {
    expect(helpers.hostInAllowList(ALLOW_LIST, 'p1001.eleven.osc.edu')).not.toBeTruthy()
  })
})
