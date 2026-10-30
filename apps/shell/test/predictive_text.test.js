'use strict';
const fs = require('fs');
const path = require('path');
const vm = require('vm');

const SOURCE = path.join(__dirname, '..', 'public', 'javascripts', 'ood_shell.2.js');
const TEMPLATE = path.join(__dirname, '..', 'views', 'index.hbs');

/**
 * Evaluate ood_shell.2.js in an isolated context that only has the browser
 * globals supplied by the caller, and return its OodShell constructor. The
 * file is a plain browser script rather than a module, so this is how it is
 * exercised without a browser.
 */
function loadOodShell(globals = {}) {
  const context = vm.createContext(globals);
  vm.runInContext(fs.readFileSync(SOURCE, 'utf8'), context);
  return context.OodShell;
}

const KEYS = { backspace: '<BS>', left: '<L>', right: '<R>' };

/** Dispatch a fake event to target's listeners and report what they did. */
function fire(target, type, props = {}) {
  const ev = Object.assign({
    type,
    target,
    propagationStopped: false,
    defaultPrevented: false,
    stopPropagation() { this.propagationStopped = true; },
    preventDefault() { this.defaultPrevented = true; }
  }, props);
  (target.listeners[type] || []).forEach((listener) => listener(ev));
  return ev;
}

/** Just enough of a DOM element for the input proxy. */
class FakeElement {
  constructor(doc, tagName) {
    this.ownerDocument = doc;
    this.tagName = tagName.toUpperCase();
    this.className = '';
    this.attributes = {};
    this.listeners = {};
    this.style = {};
    this.value = '';
  }

  get value() { return this._value; }
  set value(text) {
    this._value = text;
    this.selectionStart = this.selectionEnd = text.length;
  }

  setAttribute(name, value) { this.attributes[name] = String(value); }
  getAttribute(name) { return name in this.attributes ? this.attributes[name] : null; }
  addEventListener(type, listener) { (this.listeners[type] = this.listeners[type] || []).push(listener); }
  appendChild(child) { (this.children = this.children || []).push(child); }
  setSelectionRange(start, end) { this.selectionStart = start; this.selectionEnd = end; }

  focus() {
    const doc = this.ownerDocument;
    if (doc.activeElement === this) {
      return;
    }
    if (doc.activeElement) {
      doc.activeElement.blur();
    }
    doc.activeElement = this;
    doc.log.push(`focus ${this.tagName}`);
    fire(this, 'focus');
  }

  blur() {
    const doc = this.ownerDocument;
    if (doc.activeElement !== this) {
      return;
    }
    doc.activeElement = null;
    doc.log.push(`blur ${this.tagName}`);
    fire(this, 'blur');
  }
}

/**
 * Build an OodShell on a fake hterm terminal. `sent` collects everything the
 * terminal would send to the shell; `doc.log` records focus changes.
 */
function setup({ predictiveText = false, primaryScreen = true, focused = null } = {}) {
  const doc = { activeElement: null, listeners: {}, log: [], selection: { isCollapsed: true } };
  doc.addEventListener = (type, listener) => { (doc.listeners[type] = doc.listeners[type] || []).push(listener); };
  doc.createElement = (tagName) => new FakeElement(doc, tagName);
  doc.getSelection = () => doc.selection;
  doc.body = new FakeElement(doc, 'body');
  const screen = new FakeElement(doc, 'x-screen');
  doc.querySelector = (selector) => (selector === 'x-screen' ? screen : null);

  const sent = [];
  const term = {
    keyboard: { applicationCursor: false, backspaceSendsBackspace: false },
    findBar: { hasFocus: false },
    focusChanges: [],
    getDocument: () => doc,
    focus: () => screen.focus(),
    blur: () => screen.blur(),
    onVTKeystroke: (text) => sent.push(text),
    onFocusChange_: (focused) => term.focusChanges.push(focused),
    onPasteData_: (text) => sent.push(`[paste ${text}]`),
    isPrimaryScreen: () => primaryScreen
  };

  const OodShell = loadOodShell({ setTimeout: (fn) => fn() });
  const shell = new OodShell({}, 'ws://localhost', 'default', predictiveText);
  shell.term = term;
  if (focused === 'screen') {
    screen.focus();
  }
  doc.log.length = 0;

  return { OodShell, shell, term, doc, screen, sent };
}

/** Type into the input proxy the way the browser does once a key goes through. */
function edit(proxy, value, caret = value.length, props = {}) {
  proxy.value = value;
  proxy.setSelectionRange(caret, caret);
  fire(proxy, 'input', props);
}

describe('TypedLine', () => {
  let line;
  beforeEach(() => {
    line = new (loadOodShell().TypedLine)();
  });
  const update = (text, caret = text.length) => line.update(text, caret, KEYS);

  test('sends each typed character', () => {
    expect(update('l')).toBe('l');
    expect(update('ls')).toBe('s');
    expect(update('ls ')).toBe(' ');
  });

  test('replays an autocorrection as backspaces and the corrected word', () => {
    update('teh');
    expect(update('the ')).toBe('<BS><BS>he ');
    expect(line.text()).toBe('the ');
  });

  test('replays a tapped suggestion that completes the word', () => {
    update('the qu');
    expect(update('the quick ')).toBe('ick ');
  });

  test('sends a backspace per deleted character, including deleting a word at once', () => {
    update('git status');
    expect(update('git statu')).toBe('<BS>');
    expect(update('git ')).toBe('<BS><BS><BS><BS><BS>');
  });

  test('sends smart punctuation as ASCII and deletes all of what it sent', () => {
    update('ls -');
    expect(update('ls \u2014')).toBe('<BS>--');
    expect(update('ls \u2014all \u201chi\u2019s\u201d')).toBe('all "hi\'s"');
    // Deleting the em dash: back over 'all "hi\'s"', then both hyphens.
    expect(update('ls all \u201chi\u2019s\u201d', 3)).toBe('<L>'.repeat(10) + '<BS><BS>');
  });

  test('moves the cursor with arrows when the caret moves', () => {
    update('abc');
    expect(line.moveTo(1, KEYS)).toBe('<L><L>');
    expect(line.moveTo(3, KEYS)).toBe('<R><R>');
    expect(line.moveTo(3, KEYS)).toBe('');
  });

  test('inserts at the caret in the middle of the line', () => {
    update('abc');
    line.moveTo(1, KEYS);
    expect(update('aXbc', 2)).toBe('X');
    expect(line.caret).toBe(2);
  });

  test('picks the repeated character at the caret when typing doubles a letter', () => {
    update('ab');
    line.moveTo(1, KEYS);
    expect(update('aab', 2)).toBe('a');
  });

  test('catches up when the caret moved without being followed', () => {
    update('abc');
    // The terminal cursor is still at the end; the textarea's caret was at 1.
    expect(update('aXbc', 2)).toBe('<L><L>X');
  });

  test('counts characters by code point, as the shell does', () => {
    update('ok \ud83d\udc4d');
    expect(update('ok ')).toBe('<BS>');
  });

  test('reset forgets the line', () => {
    update('abc');
    line.reset();
    expect(line.text()).toBe('');
    expect(update('d')).toBe('d');
  });
});

describe('Predictive text setting', () => {
  test('is off unless asked for', () => {
    const OodShell = loadOodShell();

    expect(new OodShell({}, 'ws://localhost', 'default').predictiveText).toBe(false);
    expect(new OodShell({}, 'ws://localhost', 'default', true).predictiveText).toBe(true);
  });

  test('remembers the setting if the terminal does not exist yet', () => {
    const { shell } = setup();
    shell.term = null;

    expect(() => shell.setPredictiveText(true)).not.toThrow();
    expect(shell.predictiveText).toBe(true);
  });

  test('adds a textarea that lets the keyboard predict and correct', () => {
    const { shell, doc } = setup();
    shell.setPredictiveText(true);

    const proxy = shell.inputProxy;
    expect(proxy.tagName).toBe('TEXTAREA');
    expect(doc.body.children).toContain(proxy);
    expect(proxy.attributes).toMatchObject({
      autocorrect: 'on',
      autocapitalize: 'none',
      spellcheck: 'true',
      autocomplete: 'off',
      writingsuggestions: 'false'
    });
    expect(proxy.style.display).toBe('');
  });

  test('leaves hterm\'s screen settings alone', () => {
    const { shell, screen } = setup();
    shell.setPredictiveText(true);
    shell.setPredictiveText(false);

    expect(screen.attributes).toEqual({});
  });

  test('moves a focused keyboard to the textarea and back', () => {
    const { shell, doc, screen } = setup({ focused: 'screen' });

    shell.setPredictiveText(true);
    expect(doc.activeElement).toBe(shell.inputProxy);

    shell.setPredictiveText(false);
    expect(doc.activeElement).toBe(screen);
    expect(shell.inputProxy.style.display).toBe('none');
  });

  test('does not focus a terminal that was not focused', () => {
    const { shell, doc } = setup();
    shell.setPredictiveText(true);

    expect(doc.log).toEqual([]);
  });

  test('taps focus the textarea while it is on, and the screen while it is off', () => {
    const { shell, doc, screen } = setup();
    shell.focusInput(false);
    expect(doc.activeElement).toBe(screen);

    shell.setPredictiveText(true);
    shell.focusInput(true);
    expect(doc.activeElement).toBe(shell.inputProxy);
  });

  test('a refresh blurs before focusing so WebKit brings the keyboard back', () => {
    const { shell, doc } = setup({ predictiveText: true });
    shell.setPredictiveText(true);
    shell.focusInput(false);
    doc.log.length = 0;

    shell.focusInput(true);
    expect(doc.log).toEqual(['blur TEXTAREA', 'focus TEXTAREA']);
  });
});

describe('Input proxy', () => {
  function ready(options) {
    const env = setup(Object.assign({ predictiveText: true }, options));
    env.shell.setPredictiveText(true);
    env.proxy = env.shell.inputProxy;
    env.proxy.focus();
    env.sent.length = 0;
    return env;
  }

  test('sends what is typed, and keeps it in the textarea as keyboard context', () => {
    const { proxy, sent } = ready();
    edit(proxy, 't');
    edit(proxy, 'te');
    edit(proxy, 'teh');
    edit(proxy, 'the ');

    expect(sent.join('')).toBe('teh\x7f\x7fhe ');
    expect(proxy.value).toBe('the ');
  });

  test('keeps text keys from hterm and passes the rest to it', () => {
    const { shell, proxy } = ready();
    const keydown = (props) => fire(proxy, 'keydown', props).propagationStopped;

    expect(keydown({ key: 'a' })).toBe(true);
    expect(keydown({ key: ' ' })).toBe(true);
    expect(keydown({ key: '\u00e9' })).toBe(true);
    expect(keydown({ key: 'Unidentified', keyCode: 229 })).toBe(true);
    expect(keydown({ key: 'Enter', isComposing: true })).toBe(true);
    expect(keydown({ key: 'Enter' })).toBe(false);
    expect(keydown({ key: 'ArrowUp' })).toBe(false);
    expect(keydown({ key: 'Tab' })).toBe(false);
    expect(keydown({ key: 'c', ctrlKey: true })).toBe(false);
    expect(keydown({ key: '1', location: 3 })).toBe(false);
    expect(keydown({ key: 'Shift' })).toBe(false);

    edit(proxy, 'x');
    expect(keydown({ key: 'Backspace' })).toBe(true);
    shell.resetInputProxy();
    expect(keydown({ key: 'Backspace' })).toBe(false);
  });

  test('a keypress follows its keydown', () => {
    const { proxy } = ready();
    fire(proxy, 'keydown', { key: 'a' });
    expect(fire(proxy, 'keypress').propagationStopped).toBe(true);
    fire(proxy, 'keydown', { key: 'Enter' });
    expect(fire(proxy, 'keypress').propagationStopped).toBe(false);
  });

  test('hterm never sees textInput, which would send the text twice', () => {
    const { proxy } = ready();
    expect(fire(proxy, 'textInput', { data: 'a' }).propagationStopped).toBe(true);
  });

  test('Enter, arrows and control keys start a new typed line', () => {
    const { proxy } = ready();
    edit(proxy, 'ls');
    fire(proxy, 'keydown', { key: 'Enter' });
    expect(proxy.value).toBe('');

    edit(proxy, 'cd');
    fire(proxy, 'keydown', { key: 'Shift' });
    expect(proxy.value).toBe('cd');
    fire(proxy, 'keydown', { key: 'Tab' });
    expect(proxy.value).toBe('');
  });

  test('Return from a keyboard without an Enter keydown still submits', () => {
    const { proxy, sent } = ready();
    edit(proxy, 'ls');
    const ev = fire(proxy, 'beforeinput', { inputType: 'insertLineBreak' });

    expect(ev.defaultPrevented).toBe(true);
    expect(sent).toEqual(['ls', '\r']);
    expect(proxy.value).toBe('');
  });

  test('Backspace at the start of the textarea deletes what the shell had before it', () => {
    const { proxy, sent } = ready();
    const ev = fire(proxy, 'beforeinput', { inputType: 'deleteContentBackward' });

    expect(ev.defaultPrevented).toBe(true);
    expect(sent).toEqual(['\x7f']);
  });

  test('a line break in the text submits what came before it', () => {
    const { proxy, sent } = ready();
    edit(proxy, 'make');
    edit(proxy, 'make\nls');

    expect(sent.join('')).toBe('make\rls');
    expect(proxy.value).toBe('ls');
  });

  test('waits for an IME to commit', () => {
    const { proxy, sent } = ready();
    fire(proxy, 'compositionstart');
    edit(proxy, 'n', 1, { isComposing: true });
    edit(proxy, '\u306b', 1, { isComposing: true });
    expect(sent).toEqual([]);

    fire(proxy, 'compositionend');
    expect(sent).toEqual(['\u306b']);
  });

  test('follows the caret when it moves on its own', () => {
    const { proxy, doc, sent } = ready();
    edit(proxy, 'abc');
    sent.length = 0;

    proxy.setSelectionRange(1, 1);
    fire(doc, 'selectionchange');
    expect(sent).toEqual(['\x1b[D\x1b[D']);

    // A selection, or a change still being made, moves nothing.
    proxy.setSelectionRange(0, 2);
    fire(doc, 'selectionchange');
    proxy.value = 'abcd';
    fire(doc, 'selectionchange');
    expect(sent).toEqual(['\x1b[D\x1b[D']);
  });

  test('uses hterm\'s backspace and cursor key settings', () => {
    const { proxy, term, doc, sent } = ready();
    term.keyboard.backspaceSendsBackspace = true;
    term.keyboard.applicationCursor = true;
    edit(proxy, 'ab');
    edit(proxy, 'a');
    proxy.setSelectionRange(0, 0);
    fire(doc, 'selectionchange');

    expect(sent).toEqual(['ab', '\b', '\x1bOD']);
  });

  test('keeps no word context on the alternate screen', () => {
    const { proxy, sent } = ready({ primaryScreen: false });
    edit(proxy, 'd');
    edit(proxy, 'd');

    expect(sent).toEqual(['d', 'd']);
    expect(proxy.value).toBe('');
  });

  test('pastes through hterm and starts a new typed line', () => {
    const { proxy, sent } = ready();
    edit(proxy, 'echo ');
    const ev = fire(proxy, 'paste', { clipboardData: { getData: () => 'hi' } });

    expect(ev.defaultPrevented).toBe(true);
    expect(sent).toEqual(['echo ', '[paste hi]']);
    expect(proxy.value).toBe('');
  });

  test('keeps hterm from moving the selection out while focused, and shows the cursor focused', () => {
    const { proxy, term } = ready();
    expect(term.findBar.hasFocus).toBe(true);
    expect(term.focusChanges).toEqual([true]);

    proxy.blur();
    expect(term.findBar.hasFocus).toBe(false);
    expect(term.focusChanges).toEqual([true, false]);
  });

  test('puts the caret where the shell cursor is on focus', () => {
    const { shell, proxy } = ready();
    edit(proxy, 'abc');
    shell.typedLine.moveTo(1, KEYS);
    proxy.blur();
    proxy.setSelectionRange(3, 3);
    proxy.focus();

    expect(proxy.selectionEnd).toBe(1);
  });

  test('passes focus hterm gives its screen on to the textarea', () => {
    const { proxy, screen, doc } = ready();
    screen.focus();
    fire(doc, 'focus', { target: screen });

    expect(doc.activeElement).toBe(proxy);
  });

  test('leaves the screen focused while text on it is selected', () => {
    const { screen, doc } = ready();
    fire(doc, 'mousedown');
    screen.focus();
    fire(doc, 'focus', { target: screen });
    doc.selection = { isCollapsed: false };
    fire(doc, 'mouseup');

    expect(doc.activeElement).toBe(screen);
  });
});

/**
 * Start a terminal the way the page does (runTerminal, then hterm calling
 * onTerminalReady) against fake hterm objects, and return the shell. The
 * touch features are stubbed out because they have their own tests and this
 * one is only about the predictive text wiring.
 */
function startTerminal(predictiveText) {
  const { doc } = setup();

  class FakeTerminal {
    constructor() {
      this.options_ = {};
      this.io = { push: () => ({}) };
    }
    decorate() {}
    setAccessibilityEnabled() {}
    installKeyboard() {}
    getDocument() { return doc; }
  }

  const OodShell = loadOodShell({
    hterm: { Terminal: FakeTerminal },
    window: {},
    navigator: { maxTouchPoints: 0 }
  });
  OodShell.prototype.installTouchKeyboard = () => {};

  const shell = new OodShell({}, 'ws://localhost', 'default', predictiveText);
  shell.runTerminal();
  // hterm calls onTerminalReady with the terminal as `this`.
  shell.term.onTerminalReady();
  return shell;
}

describe('Terminal start-up', () => {
  test('applies a saved predictive text preference once the terminal is ready', () => {
    expect(startTerminal(true).inputProxy).not.toBeNull();
  });

  test('adds nothing when predictive text is off', () => {
    expect(startTerminal(false).inputProxy).toBeNull();
  });
});

describe('index.hbs', () => {
  const template = fs.readFileSync(TEMPLATE, 'utf8');

  test('the script only looks up elements that exist in the markup', () => {
    const looked = [...template.matchAll(/getElementById\(["']([\w-]+)["']\)/g)].map((m) => m[1]);

    expect(looked.length).toBeGreaterThan(0);
    looked.forEach((id) => {
      expect(template).toContain(`id="${id}"`);
    });
  });

  test('has a labelled predictive text checkbox', () => {
    expect(template).toMatch(/<input[^>]*type="checkbox"[^>]*id="predictive_text"/);
    expect(template).toContain('<label for="predictive_text"');
  });
});
