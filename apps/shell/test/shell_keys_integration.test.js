'use strict';

const fs = require('fs');
const path = require('path');
const vm = require('vm');

const read = (name) => fs.readFileSync(path.join(__dirname, '..', name), 'utf8');
const keysSource = read('public/javascripts/ood_shell_keys.js');
const shellSource = read('public/javascripts/ood_shell.2.js');
const view = read('views/index.hbs');
const htermSource = read('public/javascripts/hterm_all_1.92.1.mod_1.js');
// Exercise the actual hterm wrapper that scrolls and updates cursor blinking,
// without constructing the full browser-only terminal.
const htermKeystroke = vm.runInNewContext('(' + htermSource.match(
  /hterm\.Terminal\.prototype\.onVTKeystroke = (function\(string\) \{[\s\S]*?\n\});/
)[1] + ')');

function events() {
  const listeners = new Map();
  return {
    addEventListener(type, fn) {
      if (!listeners.has(type)) listeners.set(type, []);
      listeners.get(type).push(fn);
    },
    fire(type, fields = {}) {
      const ev = { button: 0, detail: 1, prevented: false, ...fields };
      ev.preventDefault = () => { ev.prevented = true; };
      (listeners.get(type) || []).forEach((fn) => fn(ev));
      return ev;
    }
  };
}

function clock() {
  let now = 0;
  let nextId = 1;
  const timers = new Map();
  const schedule = (fn, delay, interval = 0) => {
    const id = nextId++;
    timers.set(id, { fn, due: now + delay, interval });
    return id;
  };
  return {
    Date: { now: () => now },
    setTimeout: (fn, delay) => schedule(fn, delay),
    setInterval: (fn, delay) => schedule(fn, delay, delay),
    clearTimeout: (id) => timers.delete(id),
    clearInterval: (id) => timers.delete(id),
    tick(ms) {
      const until = now + ms;
      while (true) {
        const entry = [...timers].filter(([, timer]) => timer.due <= until)
          .sort((a, b) => a[1].due - b[1].due)[0];
        if (!entry) break;
        const [id, timer] = entry;
        now = timer.due;
        if (timer.interval) timer.due += timer.interval;
        else timers.delete(id);
        timer.fn();
      }
      now = until;
    }
  };
}

function fixture(options = {}) {
  const timer = clock();
  const window = { ...events(), matchMedia: () => ({ matches: options.coarse !== false }) };
  if (!options.legacy) window.PointerEvent = function () {};
  const document = { ...events(), hidden: false };
  const saved = new Map();
  if (options.saved !== undefined) saved.set('ood_shell_mobile_keys', options.saved);
  window.localStorage = {
    getItem(key) {
      if (options.blockStorage) throw new Error('storage blocked');
      return saved.has(key) ? saved.get(key) : null;
    },
    setItem(key, value) {
      if (options.blockStorage) throw new Error('storage blocked');
      saved.set(key, value);
    }
  };

  const toolbar = { ...events(), hidden: true };
  const nodes = new Map();
  const buttons = [];
  for (const [, attrs, text] of view.matchAll(/<button\b([^>]*)>([^<]*)<\/button>/g)) {
    const attributes = new Map();
    for (const [, name, value] of attrs.matchAll(/([\w-]+)(?:="([^"]*)")?/g)) {
      attributes.set(name, value === undefined ? '' : value);
    }
    let capture = null;
    const button = {
      ...events(),
      disabled: attributes.has('disabled'),
      textContent: text,
      dataset: Object.fromEntries([...attributes].filter(([name]) => name.startsWith('data-'))
        .map(([name, value]) => [name.slice(5), value])),
      hasAttribute: (name) => attributes.has(name),
      getAttribute: (name) => attributes.get(name),
      setAttribute: (name, value) => attributes.set(name, value),
      setPointerCapture(id) {
        if (options.captureError) throw new Error('pointer no longer active');
        capture = id;
      },
      hasPointerCapture: (id) => capture === id,
      releasePointerCapture(id) {
        capture = null;
        toolbar.fire('lostpointercapture', { pointerId: id, target: button });
      }
    };
    button.closest = () => button;
    if (attributes.has('id')) nodes.set(attributes.get('id'), button);
    else buttons.push(button);
  }
  const toggle = nodes.get('mobile_keys_toggle');
  toolbar.contains = (button) => buttons.includes(button);
  toolbar.querySelectorAll = () => buttons;
  toolbar.querySelector = (selector) => {
    const name = selector.match(/data-mod="([^"]+)"/)[1];
    return buttons.find((button) => button.dataset.mod === name);
  };
  nodes.set('mobile_keys', toolbar);
  document.getElementById = (id) => nodes.get(id);

  const sent = [];
  let term;
  const screen = events();
  const termDocument = { activeElement: screen, querySelector: () => screen };
  const counts = { scroll: 0, blink: 0, focus: 0 };
  class Socket {
    constructor() { this.readyState = 0; }
    send(str) { sent.push(JSON.parse(str)); }
  }
  Socket.OPEN = 1;
  const context = vm.createContext({
    window, document, navigator: { maxTouchPoints: 1 }, WebSocket: Socket,
    ...timer,
    hterm: {
      Terminal: function () {
        term = this;
        this.options_ = {};
        this.keyboard = { applicationCursor: false };
        this.io = { push() { return this; }, print() {} };
        this.installKeyboard = this.decorate = this.setAccessibilityEnabled = () => {};
        this.getDocument = () => termDocument;
        this.focus = () => { counts.focus++; termDocument.activeElement = screen; };
        this.scrollOnKeystroke_ = true;
        this.scrollPort_ = { scrollRowToBottom() { counts.scroll++; } };
        this.getRowCount = () => 200;
        this.pauseCursorBlink_ = () => { counts.blink++; };
        this.onVTKeystroke = htermKeystroke;
      }
    }
  });
  vm.runInContext(keysSource, context);
  vm.runInContext(shellSource, context);
  const shell = new context.OodShell({}, 'ws://example');
  shell.createTerminal();
  const open = () => { shell.socket.readyState = Socket.OPEN; shell.socket.onopen(); };
  const ready = () => { open(); term.onTerminalReady(); };
  if (options.ready !== false) ready();
  const button = (field, value) => buttons.find((node) => node.dataset[field] === value);
  const press = (node, pointerId = 1) => toolbar.fire('pointerdown', { target: node, pointerId });
  return {
    shell, keys: shell.keys, toolbar, toggle, buttons, window, document, context,
    sent, saved, counts, timer, button, press, open, ready, termDocument,
    term: () => term
  };
}

describe('mobile keys and the shell', () => {
  test('buttons stay disabled until both the socket and terminal are ready', () => {
    const f = fixture({ ready: false });
    f.press(f.button('mod', 'ctrl'));
    expect(f.keys.state.ctrl).toBe('off');
    expect(f.toggle.disabled).toBe(true);
    expect(f.buttons.every((button) => button.disabled)).toBe(true);
    f.open();
    expect(f.keys.enabled).toBe(false);
    f.term().onTerminalReady();
    expect(f.buttons.some((button) => button.disabled)).toBe(false);
    expect(f.toggle.disabled).toBe(false);
    f.press(f.button('key', 'tab'));
    expect(f.sent).toEqual([{ input: '\t' }]);
  });

  test('toolbar input uses hterm scrolling and cursor activity', () => {
    const f = fixture();
    f.press(f.button('key', 'left'));
    expect(f.counts.scroll).toBe(1);
    expect(f.counts.blink).toBe(1);
    expect(f.sent).toEqual([{ input: '\x1b[D' }]);
  });

  test('a late terminal-ready callback does not re-enable a disconnected toolbar', () => {
    const f = fixture({ ready: false });
    f.open();
    f.shell.socket.readyState = 3;
    f.shell.closeTerminal({ code: 1000 });
    f.term().onTerminalReady();
    expect(f.keys.enabled).toBe(false);
    expect(f.toolbar.hidden).toBe(true);
    expect(f.toggle.disabled).toBe(true);
  });

  test('encoded toolbar input is modified once and shortcuts ignore locked Alt', () => {
    const f = fixture();
    f.keys.toggleModifier('ctrl');
    f.keys.toggleModifier('alt');
    f.keys.pressText('x');
    expect(f.sent).toEqual([{ input: '\x1b\x18' }]);
    f.keys.toggleModifier('alt');
    f.keys.toggleModifier('alt');
    f.press(f.button('ctrl', 'c'));
    expect(f.sent[1]).toEqual({ input: '\x03' });
    expect(f.keys.state.alt).toBe('lock');
  });

  test('typing consumes one-shots but terminal replies and paste do not', () => {
    const f = fixture();
    f.keys.toggleModifier('ctrl');
    f.shell.sendString('\x1b[0n');
    f.shell.sendString('pasted text');
    expect(f.keys.state.ctrl).toBe('once');
    f.term().onVTKeystroke('c');
    expect(f.sent).toEqual([{ input: '\x1b[0n' }, { input: 'pasted text' }, { input: '\x03' }]);
  });

  test('toolbar respects the current foreground IO and restores its input flag on errors', () => {
    const f = fixture();
    f.term().io.onVTKeystroke = () => { throw new Error('foreground IO'); };
    let message;
    try { f.keys.pressKey('left'); } catch (err) { message = err.message; }
    expect(message).toBe('foreground IO');
    expect(f.shell.sendingMobileKey).toBe(false);
    expect(f.sent).toEqual([]);
  });

  test('cursor mode is read for each press on the same terminal', () => {
    const f = fixture();
    f.keys.pressKey('up');
    f.term().keyboard.applicationCursor = true;
    f.keys.pressKey('up');
    expect(f.sent).toEqual([{ input: '\x1b[A' }, { input: '\x1bOA' }]);
  });

  test('a toolbar press restores terminal focus after a menu interaction', () => {
    const f = fixture();
    f.termDocument.activeElement = {};
    f.press(f.button('mod', 'ctrl'));
    expect(f.counts.focus).toBe(1);
    f.term().onVTKeystroke('6');
    expect(f.sent).toEqual([{ input: '\x1e' }]);
  });

  test('Home, End and page navigation buttons exist and send their sequences', () => {
    const f = fixture();
    for (const name of ['home', 'end', 'pageup', 'pagedown']) f.keys.activate(f.button('key', name));
    expect(f.sent).toEqual([
      { input: '\x1b[H' }, { input: '\x1b[F' }, { input: '\x1b[5~' }, { input: '\x1b[6~' }
    ]);
  });
});

describe('pointer lifecycle', () => {
  test('repeat waits 400ms, then repeats every 60ms, and stops on release', () => {
    const f = fixture();
    const left = f.button('key', 'left');
    f.press(left);
    expect(left.hasPointerCapture(1)).toBe(true);
    f.timer.tick(399);
    expect(f.sent.length).toBe(1);
    f.timer.tick(1);
    expect(f.sent.length).toBe(2);
    f.timer.tick(120);
    expect(f.sent.length).toBe(4);
    f.window.fire('pointerup', { pointerId: 1 });
    f.timer.tick(1000);
    expect(f.sent.length).toBe(4);
    expect(left.hasPointerCapture(1)).toBe(false);
  });

  test('releasing or cancelling another finger leaves the held arrow repeating', () => {
    const f = fixture();
    f.press(f.button('key', 'left'), 1);
    f.press(f.button('mod', 'ctrl'), 2);
    f.window.fire('pointerup', { pointerId: 2 });
    f.window.fire('pointercancel', { pointerId: 3 });
    f.timer.tick(400);
    expect(f.sent).toEqual([{ input: '\x1b[D' }, { input: '\x1b[1;5D' }]);
    f.window.fire('pointerup', { pointerId: 1 });
  });

  test('cancel, lost capture and blur each stop the repeating key', () => {
    for (const type of ['pointercancel', 'lostpointercapture', 'blur']) {
      const f = fixture();
      f.press(f.button('key', 'left'));
      const target = type === 'lostpointercapture' ? f.toolbar : f.window;
      target.fire(type, { pointerId: 1 });
      f.timer.tick(1000);
      expect(f.sent.length).toBe(1);
    }
  });

  test('a failed capture does not start a repeat after the pointer has already ended', () => {
    const f = fixture({ captureError: true });
    f.press(f.button('key', 'left'));
    f.timer.tick(1000);
    expect(f.sent.length).toBe(1);
  });

  test('pointer clicks are deduplicated, while keyboard activation still works', () => {
    const f = fixture();
    const ctrl = f.button('mod', 'ctrl');
    f.press(ctrl);
    f.timer.tick(1500);
    f.window.fire('pointerup', { pointerId: 1 });
    f.toolbar.fire('click', { target: ctrl, detail: 1 });
    expect(f.keys.state.ctrl).toBe('once');
    f.toolbar.fire('click', { target: ctrl, detail: 0 });
    expect(f.keys.state.ctrl).toBe('lock');
  });

  test('each finger has its own click suppression after simultaneous presses', () => {
    const f = fixture();
    const left = f.button('key', 'left');
    const ctrl = f.button('mod', 'ctrl');
    f.press(left, 1);
    f.press(ctrl, 2);
    f.window.fire('pointerup', { pointerId: 2 });
    f.toolbar.fire('click', { target: ctrl, detail: 1 });
    f.window.fire('pointerup', { pointerId: 1 });
    f.toolbar.fire('click', { target: left, detail: 1 });
    expect(f.sent).toEqual([{ input: '\x1b[D' }]);
    expect(f.keys.state.ctrl).toBe('once');
  });

  test('the touch fallback handles presses even though touchstart suppresses clicks', () => {
    const f = fixture({ legacy: true });
    const left = f.button('key', 'left');
    const ev = f.toolbar.fire('touchstart', { changedTouches: [{ identifier: 7, target: left }] });
    expect(ev.prevented).toBe(true);
    f.timer.tick(400);
    expect(f.sent.length).toBe(2);
    f.window.fire('touchend', { changedTouches: [{ identifier: 7 }] });
    f.timer.tick(1000);
    expect(f.sent.length).toBe(2);
    expect(left.hasPointerCapture(7)).toBe(false);
  });

  test('hiding the page clears modifiers and repeat; disconnect disables all controls', () => {
    const f = fixture();
    f.press(f.button('key', 'left'));
    f.keys.toggleModifier('alt');
    f.keys.toggleModifier('alt');
    f.document.hidden = true;
    f.document.fire('visibilitychange');
    f.timer.tick(1000);
    expect(f.sent.length).toBe(1);
    expect(f.keys.state.alt).toBe('off');
    f.shell.closeTerminal({ code: 1000 });
    expect(f.toolbar.hidden).toBe(true);
    expect(f.toggle.disabled).toBe(true);
    expect(f.buttons.every((button) => button.disabled)).toBe(true);
    f.keys.pressControl('c');
    expect(f.sent.length).toBe(1);
  });
});

describe('toolbar visibility', () => {
  test('touch shows keys by default and a fine pointer defaults to hidden', () => {
    expect(fixture().toolbar.hidden).toBe(false);
    const fine = fixture({ coarse: false });
    expect(fine.toolbar.hidden).toBe(true);
    fine.toggle.fire('click', { target: fine.toggle, detail: 0 });
    expect(fine.toolbar.hidden).toBe(false);
    expect(fine.toggle.getAttribute('aria-expanded')).toBe('true');
  });

  test('a saved choice overrides pointer capability', () => {
    expect(fixture({ saved: 'false' }).toolbar.hidden).toBe(true);
    expect(fixture({ saved: 'true', coarse: false }).toolbar.hidden).toBe(false);
  });

  test('the show/hide pointer press runs once, saves the choice and clears modifiers', () => {
    const f = fixture();
    f.keys.toggleModifier('ctrl');
    const ev = f.toggle.fire('pointerdown', { target: f.toggle, pointerId: 1 });
    expect(ev.prevented).toBe(true);
    f.window.fire('pointerup', { pointerId: 1 });
    f.toggle.fire('click', { target: f.toggle, detail: 1 });
    expect(f.toolbar.hidden).toBe(true);
    expect(f.keys.state.ctrl).toBe('off');
    expect(f.saved.get('ood_shell_mobile_keys')).toBe('false');
  });

  test('blocked storage does not prevent showing or hiding the keys', () => {
    const f = fixture({ blockStorage: true });
    f.toggle.fire('click', { target: f.toggle, detail: 0 });
    expect(f.toolbar.hidden).toBe(true);
  });
});
