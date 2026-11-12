'use strict';
const fs = require('fs');
const path = require('path');
const vm = require('vm');

const source = fs.readFileSync(path.join(__dirname, '..', 'public', 'javascripts', 'ood_shell.2.js'), 'utf8');

class Target {
  constructor() {
    this.listeners = {};
    this.children = [];
    this.attributes = {};
    this.disabled = false;
    this.style = {};
  }
  addEventListener(type, callback, options = {}) {
    (this.listeners[type] ||= []).push({ callback, capture: !!options.capture });
  }
  dispatch(type, fields = {}) {
    const event = {
      type, defaultPrevented: false, stopped: false,
      preventDefault() { this.defaultPrevented = true; },
      stopImmediatePropagation() { this.stopped = true; },
      ...fields
    };
    const listeners = (this.listeners[type] || []).slice().sort((a, b) => Number(b.capture) - Number(a.capture));
    for (const listener of listeners) {
      if (event.stopped) break;
      listener.callback(event);
    }
    return event;
  }
  appendChild(child) { this.children.push(child); }
  setAttribute(name, value) { this.attributes[name] = value; }
  getAttribute(name) { return this.attributes[name] ?? null; }
  removeAttribute(name) { delete this.attributes[name]; }
  contains(node) { return node === this.textNode; }
}

function setup({ touch = true, clipboard } = {}) {
  const screen = new Target();
  screen.textNode = {};
  screen.setAttribute('contenteditable', 'true');
  const doc = new Target();
  let selected = false;
  const selection = {
    get isCollapsed() { return !selected; },
    get rangeCount() { return selected ? 1 : 0; },
    getRangeAt() { return { commonAncestorContainer: screen.textNode }; },
    removeAllRanges() { selected = false; }
  };
  doc.getSelection = () => selection;
  doc.querySelector = () => screen;
  const page = { createElement: () => new Target() };
  const container = new Target();
  container.insertBefore = (child) => container.appendChild(child);
  doc.defaultView = { frameElement: {} };
  const writes = [];
  const pastes = [];
  if (clipboard === undefined) {
    clipboard = {
      writeText: (text) => { writes.push(text); return Promise.resolve(); },
      readText: () => Promise.resolve('paste\ntext')
    };
  }
  const term = {
    useDefaultWindowCopy: false,
    getDocument: () => doc,
    getSelectionText: () => selected ? 'selected text' : null,
    blur: jest.fn(),
    focus: jest.fn(),
    onPasteData_: (text) => pastes.push(text)
  };
  let htermTouches = 0;
  screen.addEventListener('touchstart', (event) => { htermTouches++; event.preventDefault(); });
  const context = vm.createContext({
    window: { matchMedia: () => ({ matches: touch }), setTimeout, clearTimeout },
    document: page,
    navigator: { maxTouchPoints: touch ? 1 : 0, clipboard }
  });
  vm.runInContext(source, context);
  const shell = new context.OodShell(container, '', '');
  shell.installMobileSelection(term);
  const toolbar = container.children[0];
  return {
    shell, term, screen, doc, toolbar, writes, pastes, selection,
    get htermTouches() { return htermTouches; },
    select() { selected = true; doc.dispatch('selectionchange'); },
    deselect() { selected = false; doc.dispatch('selectionchange'); },
    ...(toolbar && { selectButton: toolbar.children[0], copy: toolbar.children[1],
      paste: toolbar.children[2], status: toolbar.children[3] })
  };
}

const flush = () => new Promise((resolve) => setImmediate(resolve));

test('leaves desktop behavior alone', () => {
  expect(setup({ touch: false }).toolbar).toBeUndefined();
});

test('selection mode passes browser touch defaults and restores hterm behavior', () => {
  const s = setup();
  expect(s.screen.dispatch('touchstart').defaultPrevented).toBe(true);
  s.selectButton.dispatch('click');
  expect(s.term.blur).toHaveBeenCalledTimes(1);
  expect(s.screen.getAttribute('contenteditable')).toBe('false');
  expect(s.screen.style.overscrollBehavior).toBe('contain');
  expect(s.term.useDefaultWindowCopy).toBe(true);
  expect(s.screen.dispatch('touchstart').defaultPrevented).toBe(false);
  expect(s.htermTouches).toBe(1);
  s.selectButton.dispatch('click');
  expect(s.screen.getAttribute('contenteditable')).toBe('true');
  expect(s.screen.style.overscrollBehavior).toBeUndefined();
  expect(s.term.useDefaultWindowCopy).toBe(false);
  expect(s.screen.dispatch('touchstart').defaultPrevented).toBe(true);
});

test('copy keeps the selection snapshot through focus loss during a tap', async () => {
  const s = setup();
  s.selectButton.dispatch('click');
  s.select();
  expect(s.copy.disabled).toBe(false);
  s.copy.dispatch('touchstart');
  s.deselect();
  expect(s.copy.disabled).toBe(false);
  s.copy.dispatch('click');
  await flush();
  expect(s.writes).toEqual(['selected text']);
  expect(s.selectButton.textContent).toBe('Select text');
  expect(s.status.textContent).toBe('Copied.');
});

test('cancelled copy gesture and ordinary deselection discard the snapshot', () => {
  const s = setup();
  s.selectButton.dispatch('click');
  s.select();
  s.copy.dispatch('touchstart');
  s.deselect();
  s.copy.dispatch('touchcancel');
  expect(s.copy.disabled).toBe(true);
});

test('copy rejection is reported without leaving selection mode', async () => {
  const s = setup({ clipboard: { writeText: () => Promise.reject(new Error('denied')) } });
  s.selectButton.dispatch('click');
  s.select();
  s.copy.dispatch('click');
  await flush();
  expect(s.status.textContent).toContain('Copy failed');
  expect(s.selectButton.textContent).toBe('Done');
});

test('paste works without a selection and delegates to hterm paste processing', async () => {
  const s = setup();
  s.paste.dispatch('click');
  await flush();
  expect(s.pastes).toEqual(['paste\ntext']);
  expect(s.status.textContent).toBe('Pasted.');
});

test('paste rejection is reported and unavailable clipboard controls are disabled', async () => {
  const s = setup({ clipboard: { readText: () => Promise.reject(new Error('denied')) } });
  s.paste.dispatch('click');
  await flush();
  expect(s.status.textContent).toContain('Paste failed');
  const unavailable = setup({ clipboard: null });
  unavailable.selectButton.dispatch('click');
  unavailable.select();
  expect(unavailable.copy.disabled).toBe(true);
  expect(unavailable.paste.disabled).toBe(true);
});


test('installs mobile controls when hterm is ready', () => {
  class FakeTerminal {
    constructor() { this.options_ = {}; this.io = { push: () => ({}) }; }
    decorate() {}
    setAccessibilityEnabled() {}
    installKeyboard() {}
  }
  const context = vm.createContext({ hterm: { Terminal: FakeTerminal }, window: {} });
  vm.runInContext(source, context);
  context.OodShell.prototype.installMobileSelection = jest.fn();
  context.OodShell.prototype.installTouchKeyboard = jest.fn();
  const shell = new context.OodShell({}, '', '');
  shell.runTerminal();
  shell.term.onTerminalReady();
  expect(context.OodShell.prototype.installMobileSelection).toHaveBeenCalledTimes(1);
});


test('selection mode suppresses the keyboard focus gesture; ordinary taps still focus', () => {
  const s = setup();
  s.shell.installTouchKeyboard(s.term);
  const touch = { clientX: 10, clientY: 10 };
  const tap = () => {
    s.screen.dispatch('touchstart', { touches: [touch], timeStamp: 0 });
    s.screen.dispatch('touchend', { touches: [], changedTouches: [touch], timeStamp: 100 });
  };
  tap();
  expect(s.term.focus).toHaveBeenCalledTimes(1);
  s.selectButton.dispatch('click');
  tap();
  expect(s.term.focus).toHaveBeenCalledTimes(1);
  s.selectButton.dispatch('click');
  tap();
  expect(s.term.focus).toHaveBeenCalledTimes(2);
});


test('synchronous clipboard exceptions are reported', () => {
  const clipboard = {
    writeText: () => { throw new Error('denied'); },
    readText: () => { throw new Error('denied'); }
  };
  const s = setup({ clipboard });
  s.selectButton.dispatch('click');
  s.select();
  s.copy.dispatch('click');
  expect(s.status.textContent).toContain('Copy failed');
  s.paste.dispatch('click');
  expect(s.status.textContent).toContain('Paste failed');
});

test('an earlier clipboard request does not clear a newer selection', async () => {
  let finishWrite;
  const clipboard = { writeText: () => new Promise((resolve) => { finishWrite = resolve; }) };
  const s = setup({ clipboard });
  s.selectButton.dispatch('click');
  s.select();
  s.copy.dispatch('click');
  s.deselect();
  s.select();
  finishWrite();
  await flush();
  expect(s.selectButton.textContent).toBe('Done');
  expect(s.selection.rangeCount).toBe(1);
});
