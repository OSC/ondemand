'use strict';

/**
 * Tests for the on-screen terminal keys used on touch devices.
 * Only the DOM-free logic is covered here.
 */
const OodShellKeys = require('../public/javascripts/ood_shell_keys');

const { ctrlChar, applyModifiers, encodeKey, ModifierState } = OodShellKeys;

const ESC = '\x1b';

// A keys object with no toolbar that records everything it sends.
function newKeys(appCursor = false) {
  const sent = [];
  const keys = new OodShellKeys(null, {
    send: (str) => sent.push(str),
    applicationCursor: () => appCursor
  });
  return { keys, sent };
}

describe('ctrlChar()', () => {
  test('maps letters to control characters regardless of case', () => {
    expect(ctrlChar('a')).toBe('\x01');
    expect(ctrlChar('c')).toBe('\x03');
    expect(ctrlChar('C')).toBe('\x03');
    expect(ctrlChar('x')).toBe('\x18');
    expect(ctrlChar('z')).toBe('\x1a');
  });

  test('maps punctuation the way xterm does', () => {
    expect(ctrlChar(' ')).toBe('\x00');
    expect(ctrlChar('@')).toBe('\x00');
    expect(ctrlChar('[')).toBe(ESC);
    expect(ctrlChar('\\')).toBe('\x1c');
    expect(ctrlChar(']')).toBe('\x1d');
    expect(ctrlChar('^')).toBe('\x1e');
    expect(ctrlChar('_')).toBe('\x1f');
    expect(ctrlChar('/')).toBe('\x1f');
    expect(ctrlChar('?')).toBe('\x7f');
  });

  test('maps Ctrl+2 through Ctrl+8 like the bundled hterm', () => {
    expect(ctrlChar('2')).toBe('\x00');
    expect(ctrlChar('3')).toBe(ESC);
    expect(ctrlChar('4')).toBe('\x1c');
    expect(ctrlChar('5')).toBe('\x1d');
    expect(ctrlChar('6')).toBe('\x1e');
    expect(ctrlChar('7')).toBe('\x1f');
    expect(ctrlChar('8')).toBe('\x7f');
  });

  test('maps shifted punctuation aliases, including the toolbar symbols', () => {
    expect(ctrlChar('|')).toBe('\x1c');
    expect(ctrlChar('~')).toBe('\x1e');
    expect(ctrlChar('{')).toBe(ESC);
    expect(ctrlChar('}')).toBe('\x1d');
    expect(ctrlChar('`')).toBe('\x00');
  });

  test('is null for characters with no control equivalent', () => {
    expect(ctrlChar('1')).toBeNull();
    expect(ctrlChar('é')).toBeNull();
  });

  test('is null for anything but a single character', () => {
    expect(ctrlChar('')).toBeNull();
    expect(ctrlChar('ab')).toBeNull();
    expect(ctrlChar(undefined)).toBeNull();
    expect(ctrlChar(3)).toBeNull();
  });
});

describe('applyModifiers()', () => {
  test('leaves text alone without modifiers', () => {
    expect(applyModifiers('c', {})).toBe('c');
    expect(applyModifiers('c', { ctrl: false, alt: false })).toBe('c');
    expect(applyModifiers('c')).toBe('c');
  });

  test('ctrl turns a character into a control character', () => {
    expect(applyModifiers('c', { ctrl: true })).toBe('\x03');
    expect(applyModifiers(' ', { ctrl: true })).toBe('\x00');
  });

  test('alt prefixes ESC, as emacs and readline expect for Meta', () => {
    expect(applyModifiers('x', { alt: true })).toBe(ESC + 'x');
  });

  test('ctrl and alt combine', () => {
    expect(applyModifiers('x', { ctrl: true, alt: true })).toBe(ESC + '\x18');
  });

  test('ctrl with no control equivalent sends the character unchanged', () => {
    expect(applyModifiers('1', { ctrl: true })).toBe('1');
    expect(applyModifiers('1', { ctrl: true, alt: true })).toBe(ESC + '1');
  });

  test('only single characters are transformed', () => {
    expect(applyModifiers('hello', { ctrl: true })).toBe('hello');
    expect(applyModifiers('hello', { alt: true })).toBe('hello');
  });
});

describe('encodeKey()', () => {
  test('esc and tab', () => {
    expect(encodeKey('esc')).toBe(ESC);
    expect(encodeKey('tab')).toBe('\t');
    expect(encodeKey('esc', { alt: true })).toBe(ESC + ESC);
    expect(encodeKey('tab', { alt: true })).toBe(ESC + '\t');
  });

  test('Shift Tab includes Shift in modified sequences', () => {
    expect(encodeKey('backtab')).toBe(ESC + '[Z');
    expect(encodeKey('backtab', { ctrl: true })).toBe(ESC + '[1;6Z');
    expect(encodeKey('backtab', { alt: true })).toBe(ESC + '[1;4Z');
  });

  test('arrows use CSI in normal mode', () => {
    expect(encodeKey('up', {}, false)).toBe(ESC + '[A');
    expect(encodeKey('down', {}, false)).toBe(ESC + '[B');
    expect(encodeKey('right', {}, false)).toBe(ESC + '[C');
    expect(encodeKey('left', {}, false)).toBe(ESC + '[D');
  });

  test('arrows use SS3 in application cursor mode (vim, emacs, less)', () => {
    expect(encodeKey('up', {}, true)).toBe(ESC + 'OA');
    expect(encodeKey('down', {}, true)).toBe(ESC + 'OB');
    expect(encodeKey('right', {}, true)).toBe(ESC + 'OC');
    expect(encodeKey('left', {}, true)).toBe(ESC + 'OD');
  });

  test('modified arrows use the xterm modifier parameter in either mode', () => {
    expect(encodeKey('left', { alt: true }, false)).toBe(ESC + '[1;3D');
    expect(encodeKey('left', { ctrl: true }, false)).toBe(ESC + '[1;5D');
    expect(encodeKey('right', { ctrl: true, alt: true }, false)).toBe(ESC + '[1;7C');
    expect(encodeKey('up', { ctrl: true }, true)).toBe(ESC + '[1;5A');
  });

  test('home and end', () => {
    expect(encodeKey('home', {}, false)).toBe(ESC + '[H');
    expect(encodeKey('end', {}, false)).toBe(ESC + '[F');
    expect(encodeKey('home', {}, true)).toBe(ESC + 'OH');
    expect(encodeKey('end', {}, true)).toBe(ESC + 'OF');
    expect(encodeKey('end', { ctrl: true }, false)).toBe(ESC + '[1;5F');
  });

  test('page up and page down', () => {
    expect(encodeKey('pageup')).toBe(ESC + '[5~');
    expect(encodeKey('pagedown')).toBe(ESC + '[6~');
    expect(encodeKey('pageup', { ctrl: true })).toBe(ESC + '[5;5~');
  });

  test('is null for unknown names, including inherited object properties', () => {
    expect(encodeKey('bogus')).toBeNull();
    expect(encodeKey('constructor')).toBeNull();
    expect(encodeKey('toString')).toBeNull();
    expect(encodeKey('__proto__')).toBeNull();
  });
});

describe('ModifierState', () => {
  test('cycles off -> once -> lock -> off', () => {
    const state = new ModifierState();
    expect(state.ctrl).toBe('off');
    state.cycle('ctrl');
    expect(state.ctrl).toBe('once');
    state.cycle('ctrl');
    expect(state.ctrl).toBe('lock');
    state.cycle('ctrl');
    expect(state.ctrl).toBe('off');
  });

  test('ctrl and alt are independent', () => {
    const state = new ModifierState();
    state.cycle('alt');
    expect(state.active()).toEqual({ ctrl: false, alt: true });
  });

  test('ignores unknown modifier names', () => {
    const state = new ModifierState();
    state.cycle('shift');
    expect(state.active()).toEqual({ ctrl: false, alt: false });
  });

  test('consume uses up one-shot modifiers but keeps locked ones', () => {
    const state = new ModifierState();
    state.cycle('ctrl');
    state.cycle('alt');
    state.cycle('alt');
    state.consume();
    expect(state.ctrl).toBe('off');
    expect(state.alt).toBe('lock');
  });
});

describe('OodShellKeys (soft keyboard input)', () => {
  test('passes text through untouched when no modifier is armed', () => {
    const { keys } = newKeys();
    expect(keys.transform('x')).toBe('x');
    expect(keys.transform('hello')).toBe('hello');
  });

  test('a one-shot ctrl applies to the next character only', () => {
    const { keys } = newKeys();
    keys.toggleModifier('ctrl');
    expect(keys.transform('x')).toBe('\x18');
    expect(keys.transform('x')).toBe('x');
  });

  test('a locked ctrl applies until it is turned off', () => {
    const { keys } = newKeys();
    keys.toggleModifier('ctrl');
    keys.toggleModifier('ctrl');
    expect(keys.transform('a')).toBe('\x01');
    expect(keys.transform('e')).toBe('\x05');
    keys.toggleModifier('ctrl');
    expect(keys.transform('a')).toBe('a');
  });

  test('a one-shot modifier is used up even if the input is not a single character', () => {
    const { keys } = newKeys();
    keys.toggleModifier('ctrl');
    expect(keys.transform('hello')).toBe('hello');
    expect(keys.transform('c')).toBe('c');
  });

  test('ctrl and alt together', () => {
    const { keys } = newKeys();
    keys.toggleModifier('ctrl');
    keys.toggleModifier('alt');
    expect(keys.transform('x')).toBe(ESC + '\x18');
  });
});

describe('OodShellKeys (toolbar buttons)', () => {
  test('pressKey sends the key', () => {
    const { keys, sent } = newKeys();
    keys.pressKey('esc');
    keys.pressKey('tab');
    expect(sent).toEqual([ESC, '\t']);
  });

  test('pressKey asks the terminal for its cursor mode each time', () => {
    const normal = newKeys(false);
    normal.keys.pressKey('up');
    expect(normal.sent).toEqual([ESC + '[A']);

    const app = newKeys(true);
    app.keys.pressKey('up');
    expect(app.sent).toEqual([ESC + 'OA']);
  });

  test('an armed modifier applies to the next toolbar key and is used up', () => {
    const { keys, sent } = newKeys();
    keys.toggleModifier('ctrl');
    keys.pressKey('left');
    keys.pressKey('left');
    expect(sent).toEqual([ESC + '[1;5D', ESC + '[D']);
  });

  test('pressKey ignores unknown keys and keeps modifiers armed', () => {
    const { keys, sent } = newKeys();
    keys.toggleModifier('ctrl');
    keys.pressKey('bogus');
    expect(sent).toEqual([]);
    expect(keys.state.ctrl).toBe('once');
  });

  test('pressControl sends the control character', () => {
    const { keys, sent } = newKeys();
    keys.pressControl('c');
    keys.pressControl('z');
    keys.pressControl('d');
    expect(sent).toEqual(['\x03', '\x1a', '\x04']);
  });

  test('pressControl is not changed by armed modifiers, but uses up one-shots', () => {
    const { keys, sent } = newKeys();
    keys.toggleModifier('alt');
    keys.pressControl('c');
    expect(sent).toEqual(['\x03']);
    expect(keys.state.alt).toBe('off');
  });

  test('pressText sends symbols, applying armed modifiers', () => {
    const { keys, sent } = newKeys();
    keys.pressText('|');
    keys.toggleModifier('ctrl');
    keys.pressText('/');
    expect(sent).toEqual(['|', '\x1f']);
  });

  test('activate dispatches on the button data attributes', () => {
    const { keys, sent } = newKeys();
    keys.activate({ dataset: { key: 'esc' } });
    keys.activate({ dataset: { ctrl: 'c' } });
    keys.activate({ dataset: { text: '~' } });
    keys.activate({ dataset: { mod: 'ctrl' } });
    keys.activate({ dataset: {} });
    expect(sent).toEqual([ESC, '\x03', '~']);
    expect(keys.state.ctrl).toBe('once');
  });

  test('disable and stopRepeat work without a toolbar', () => {
    const { keys } = newKeys();
    expect(() => keys.disable()).not.toThrow();
    expect(() => keys.stopRepeat()).not.toThrow();
  });

  test('disabled keys neither send input nor arm modifiers', () => {
    const { keys, sent } = newKeys();
    keys.setEnabled(false);
    keys.toggleModifier('ctrl');
    keys.pressKey('left');
    keys.pressText('x');
    keys.pressControl('c');
    expect(keys.state.ctrl).toBe('off');
    expect(sent).toEqual([]);
    keys.setEnabled(true);
    keys.pressKey('left');
    expect(sent).toEqual([ESC + '[D']);
  });

  test('rejected input does not consume a one-shot modifier', () => {
    const keys = new OodShellKeys(null, { send: () => false });
    keys.toggleModifier('alt');
    keys.pressText('x');
    keys.pressKey('left');
    keys.pressControl('c');
    expect(keys.state.alt).toBe('once');
  });
});
