'use strict';
const fs = require('fs');
const path = require('path');
const vm = require('vm');

/**
 * On-screen terminal key encoding tests. ood_shell.2.js is a browser script,
 * so run it in a sandbox to reach OodShell.
 */
const context = {};
vm.runInNewContext(fs.readFileSync(path.join(__dirname, '../public/javascripts/ood_shell.2.js'), 'utf8'), context);
const { applyModifiers } = context.OodShell;

const CTRL = [true, false];
const ALT = [false, true];
const BOTH = [true, true];

describe('applyModifiers()', () => {
  test('Ctrl turns a character into its control character', () => {
    expect(applyModifiers('c', ...CTRL)).toBe('\x03');
    expect(applyModifiers('C', ...CTRL)).toBe('\x03');
    expect(applyModifiers('@', ...CTRL)).toBe('\x00');
    expect(applyModifiers('[', ...CTRL)).toBe('\x1b');
    expect(applyModifiers('|', ...CTRL)).toBe('\x1c');
    expect(applyModifiers('~', ...CTRL)).toBe('\x1e');
    expect(applyModifiers('_', ...CTRL)).toBe('\x1f');
  });

  test('Ctrl with Space, digits, / and ? matches hterm', () => {
    expect(applyModifiers(' ', ...CTRL)).toBe('\x00');
    expect(applyModifiers('2', ...CTRL)).toBe('\x00');
    expect(applyModifiers('3', ...CTRL)).toBe('\x1b');
    expect(applyModifiers('7', ...CTRL)).toBe('\x1f');
    expect(applyModifiers('8', ...CTRL)).toBe('\x7f');
    expect(applyModifiers('/', ...CTRL)).toBe('\x1f');
    expect(applyModifiers('?', ...CTRL)).toBe('\x7f');
  });

  test('Ctrl leaves characters without a control character alone', () => {
    expect(applyModifiers('1', ...CTRL)).toBe('1');
    expect(applyModifiers('-', ...CTRL)).toBe('-');
    expect(applyModifiers('\t', ...CTRL)).toBe('\t');
    expect(applyModifiers('\x1b', ...CTRL)).toBe('\x1b');
  });

  test('Alt sends ESC first', () => {
    expect(applyModifiers('x', ...ALT)).toBe('\x1bx');
    expect(applyModifiers('\t', ...ALT)).toBe('\x1b\t');
    expect(applyModifiers('\x1b', ...ALT)).toBe('\x1b\x1b');
    expect(applyModifiers('x', ...BOTH)).toBe('\x1b\x18');
  });

  test('cursor and editing keys get the xterm modifier parameter', () => {
    expect(applyModifiers('\x1b[A', ...CTRL)).toBe('\x1b[1;5A');
    expect(applyModifiers('\x1bOD', ...ALT)).toBe('\x1b[1;3D');
    expect(applyModifiers('\x1b[H', ...BOTH)).toBe('\x1b[1;7H');
    expect(applyModifiers('\x1b[5~', ...CTRL)).toBe('\x1b[5;5~');
  });

  test('other input passes through unchanged', () => {
    expect(applyModifiers('hello', ...CTRL)).toBe('hello');
    expect(applyModifiers('\x1bx', ...CTRL)).toBe('\x1bx');
    expect(applyModifiers('\x1b[1;2A', ...CTRL)).toBe('\x1b[1;2A');
  });
});
