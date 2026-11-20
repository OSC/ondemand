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

// Sticky Ctrl with the physical Backspace key.
//
// hterm sends the opposite byte for Ctrl+Backspace than for plain Backspace
// (its key map is bs('\x7f', '\b') for plain and bs('\b', '\x7f') for Ctrl), so
// an armed on-screen Ctrl must do the same. The expected bytes below come from
// the key map in the vendored hterm bundle rather than from the handler under
// test. Do not "fix" the handler to send the plain Backspace byte.
//
// Updating the vendored hterm bundle: if this suite fails to load the bundle,
// or the Backspace key definition (keyCode 8) changes, check how hterm now
// encodes Ctrl+Backspace and update the handler in installKeys to match.
const jsDir = path.join(__dirname, '..', 'public', 'javascripts');
const oodShellSource = fs.readFileSync(path.join(jsDir, 'ood_shell.2.js'), 'utf8');
const loadOodShell = (globals) => vm.runInNewContext(oodShellSource + '\nOodShell;', globals);
const codes = (str) => Array.from(str, (ch) => ch.charCodeAt(0));

// A real hterm.Keyboard.KeyMap, evaluated from the vendored bundle.
function loadHtermKeyMap(backspaceSendsBackspace) {
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
  const hterm = vm.runInContext('hterm', sandbox);
  return new hterm.Keyboard.KeyMap({ backspaceSendsBackspace });
}

// What hterm sends for Backspace (keyCode 8) with and without Ctrl held.
function htermBackspace(backspaceSendsBackspace) {
  const keyDef = loadHtermKeyMap(backspaceSendsBackspace).keyDefs[8];
  return { plain: keyDef.normal({}, keyDef), ctrl: keyDef.control({}, keyDef) };
}

// installKeys() wired to just enough of a page and terminal to run its
// Backspace listener. onVTKeystroke follows hterm's Terminal, which hands the
// string to the io object that runTerminal binds to OodShell#onVTKeystroke.
function setupKeys({ backspaceSendsBackspace = false } = {}) {
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
    keyboard: { backspaceSendsBackspace },
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

  test('the default encodings are BS for Ctrl+Backspace and DEL for Backspace', () => {
    // A readable statement of what the test above reads from hterm.
    const { plain, ctrl } = htermBackspace(false);
    expect(codes(plain)).toEqual([0x7f]);
    expect(codes(ctrl)).toEqual([0x08]);
  });

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
