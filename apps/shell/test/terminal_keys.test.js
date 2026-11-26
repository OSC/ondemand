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
    expect(applyModifiers('\x1b[1;2A', ...CTRL)).toBe('\x1b[1;6A');
    expect(applyModifiers('\x1b[1;5C', ...CTRL)).toBe('\x1b[1;5C');
    expect(applyModifiers('\x1b[6;5~', ...ALT)).toBe('\x1b[6;7~');
  });

  test('other input passes through unchanged', () => {
    expect(applyModifiers('hello', ...CTRL)).toBe('hello');
    expect(applyModifiers('\x1bx', ...CTRL)).toBe('\x1bx');
    expect(applyModifiers('\x1b[15;2~', ...CTRL)).toBe('\x1b[15;2~');
  });
});

// Compare sticky Ctrl+Backspace with the checked-in hterm key map.
const jsDir = path.join(__dirname, '..', 'public', 'javascripts');
const oodShellSource = fs.readFileSync(path.join(jsDir, 'ood_shell.2.js'), 'utf8');
const loadOodShell = (globals) => vm.runInNewContext(oodShellSource + '\nOodShell;', globals);
const codes = (str) => Array.from(str, (ch) => ch.charCodeAt(0));

function loadHterm() {
  const bundle = fs.readdirSync(jsDir).find((name) => /^hterm_all_.*\.js$/.test(name));
  const sandbox = {
    console, Blob, URL, TextEncoder, TextDecoder, setTimeout, clearTimeout,
    navigator: { userAgent: '', platform: 'Linux', language: 'en' },
    document: {}, location: { href: 'http://localhost/' }
  };
  sandbox.window = sandbox;
  sandbox.self = sandbox;
  vm.createContext(sandbox);
  vm.runInContext(fs.readFileSync(path.join(jsDir, bundle), 'utf8'), sandbox, { filename: bundle });
  return vm.runInContext('hterm', sandbox);
}

test.each([false, true])('sticky Ctrl matches hterm on BackTab with Alt=%s', (alt) => {
  const { Keyboard } = loadHterm();
  const send = jest.fn();
  const keyboard = new Keyboard({
    passCtrlTab: false, contextMenu: { hide() {} }, onVTKeystroke: send
  });
  keyboard.onKeyDown_({
    keyCode: 9, shiftKey: true, ctrlKey: true, altKey: alt, metaKey: false,
    preventDefault() {}, stopPropagation() {}
  });

  expect(send).toHaveBeenCalledTimes(1);
  expect(applyModifiers('\x1b[Z', true, alt)).toBe(send.mock.calls[0][0]);
});

// What hterm sends for Backspace (keyCode 8) with and without Ctrl held.
function htermBackspace(backspaceSendsBackspace) {
  const { Keyboard } = loadHterm();
  const keyDef = new Keyboard.KeyMap({ backspaceSendsBackspace }).keyDefs[8];
  return { plain: keyDef.normal({}, keyDef), ctrl: keyDef.control({}, keyDef) };
}

// installKeys() wired to just enough of a page and terminal to run its
// Backspace listener. onVTKeystroke follows hterm's Terminal, which hands the
// string to the io object that runTerminal binds to OodShell#onVTKeystroke.
function setupKeys({ backspaceSendsBackspace = false, applicationCursor = false } = {}) {
  const listeners = [];
  const screen = { addEventListener: (type, fn) => { if (type === 'keydown') listeners.push(fn); } };
  const makeElement = () => ({
    hidden: true,
    disabled: true,
    attributes: {},
    addEventListener: jest.fn(),
    setAttribute(name, value) { this.attributes[name] = String(value); }
  });
  const keys = makeElement();
  const toggle = makeElement();
  const modifierButtons = { ctrl: makeElement(), alt: makeElement() };
  const document = {
    getElementById: (id) => ({ terminal_keys: keys, terminal_keys_toggle: toggle })[id],
    querySelector: (selector) => modifierButtons[/data-modifier="(\w+)"/.exec(selector)[1]]
  };
  const window = {
    localStorage: { getItem: () => null, setItem: () => {} },
    matchMedia: () => ({ matches: true })
  };

  const OodShell = loadOodShell({ document, window });
  const shell = new OodShell({}, 'ws://localhost', 'default');
  shell.socket = { send: jest.fn() };
  shell.term = {
    keyboard: { backspaceSendsBackspace, applicationCursor },
    getDocument: () => ({ querySelector: () => screen, hasFocus: () => true }),
    onVTKeystroke: (str) => shell.onVTKeystroke(str)
  };
  shell.installKeys();

  const keydown = (overrides = {}) => {
    const ev = {
      key: 'Backspace', isComposing: false, defaultPrevented: false,
      ctrlKey: false, altKey: false, metaKey: false,
      preventDefault: jest.fn(), stopPropagation: jest.fn(),
      ...overrides
    };
    listeners.forEach((listener) => listener(ev));
    return ev;
  };
  const sent = () => shell.socket.send.mock.calls.map(([json]) => JSON.parse(json).input);
  return { shell, keydown, sent, modifierButtons };
}

describe('Shift+Up/Down with an on-screen modifier', () => {
  test.each([
    ['ArrowUp', 'ctrl', '\x1b[1;6A'],
    ['ArrowDown', 'alt', '\x1b[1;4B']
  ])('sends %s with Shift and sticky %s instead of scrolling', (key, modifier, sequence) => {
    const { shell, keydown, sent } = setupKeys();
    shell.setModifier(modifier, true);

    const event = keydown({ key, shiftKey: true });

    expect(event.preventDefault).toHaveBeenCalled();
    expect(event.stopPropagation).toHaveBeenCalled();
    expect(sent()).toEqual([sequence]);
    expect(shell.modifiers[modifier]).toBe(false);
  });

  test.each([
    [false, false],
    [true, true]
  ])('leaves Shift+Up to hterm when applicationCursor=%s and Ctrl=%s', (applicationCursor, ctrl) => {
    const { shell, keydown, sent } = setupKeys({ applicationCursor });
    shell.setModifier('ctrl', ctrl);

    const event = keydown({ key: 'ArrowUp', shiftKey: true });

    expect(event.preventDefault).not.toHaveBeenCalled();
    expect(sent()).toEqual([]);
  });
});

describe('Backspace with Ctrl armed on the on-screen keys', () => {
  test.each([false, true])(
    'sends what hterm sends for Ctrl+Backspace (backspaceSendsBackspace: %s)',
    (backspaceSendsBackspace) => {
      const expected = htermBackspace(backspaceSendsBackspace);
      const { shell, keydown, sent } = setupKeys({ backspaceSendsBackspace });
      shell.setModifier('ctrl', true);

      const ev = keydown();

      expect(ev.preventDefault).toHaveBeenCalled();
      expect(ev.stopPropagation).toHaveBeenCalled();
      expect(sent().map(codes)).toEqual([codes(expected.ctrl)]);
      // hterm swaps the two bytes for Ctrl, so this is not the plain Backspace byte.
      expect(codes(expected.ctrl)).not.toEqual(codes(expected.plain));
    }
  );


  test('uses up the armed Ctrl', () => {
    const { shell, keydown, modifierButtons } = setupKeys();
    shell.setModifier('ctrl', true);
    expect(modifierButtons.ctrl.attributes['aria-pressed']).toBe('true');

    keydown();

    expect(shell.modifiers.ctrl).toBe(false);
    expect(modifierButtons.ctrl.attributes['aria-pressed']).toBe('false');
  });

  test('does nothing when Ctrl is not armed', () => {
    const { keydown, sent } = setupKeys();

    const ev = keydown();

    expect(ev.preventDefault).not.toHaveBeenCalled();
    expect(ev.stopPropagation).not.toHaveBeenCalled();
    expect(sent()).toEqual([]);
  });

  test.each([
    ['a physical Ctrl key is held', { ctrlKey: true }],
    ['Alt is held', { altKey: true }],
    ['Meta is held', { metaKey: true }],
    ['an input method is composing', { isComposing: true }],
    ['the event was already handled', { defaultPrevented: true }]
  ])('leaves the key to hterm when %s', (_name, overrides) => {
    const { shell, keydown, sent } = setupKeys();
    shell.setModifier('ctrl', true);

    const ev = keydown(overrides);

    expect(ev.preventDefault).not.toHaveBeenCalled();
    expect(sent()).toEqual([]);
    expect(shell.modifiers.ctrl).toBe(true);
  });

  test('leaves other keys alone and keeps Ctrl armed', () => {
    const { shell, keydown, sent } = setupKeys();
    shell.setModifier('ctrl', true);

    const ev = keydown({ key: 'a' });

    expect(ev.preventDefault).not.toHaveBeenCalled();
    expect(sent()).toEqual([]);
    expect(shell.modifiers.ctrl).toBe(true);
  });
});
