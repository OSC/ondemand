/** @jest-environment jsdom */
'use strict';

const fs = require('fs');
const path = require('path');
const handlebars = require('hbs').handlebars;
const OodShellKeys = require('../public/javascripts/ood_shell_keys');

const read = (name) => fs.readFileSync(path.join(__dirname, '..', name), 'utf8');
handlebars.registerHelper('assetHash', () => 'test');
const renderView = handlebars.compile(read('views/index.hbs'));
// Load the complete library instead of extracting a function with a regex.
window.eval(read('public/javascripts/hterm_all_1.92.1.mod_1.js') + '\nwindow.hterm = hterm;');
const bundledHterm = window.hterm;
window.OodShellKeys = OodShellKeys;
window.eval(read('public/javascripts/ood_shell.2.js'));

// jsdom handles the DOM and event propagation. Simulate only the pointer APIs
// and hit testing that it does not implement.
function fire(target, type, fields = {}) {
  const ev = new Event(type, { bubbles: true, cancelable: true });
  Object.entries({ button: 0, detail: 1, clientX: 10, clientY: 10, ...fields }).forEach(([name, value]) => {
    Object.defineProperty(ev, name, { value });
  });
  target.dispatchEvent(ev);
  return ev;
}

beforeEach(() => {
  jest.useFakeTimers();
  jest.spyOn(window, 'addEventListener');
  jest.spyOn(document, 'addEventListener');
});

afterEach(() => {
  // Remove the page-level listeners owned by each shell fixture.
  for (const target of [window, document]) {
    target.addEventListener.mock.calls.forEach(([type, fn, options]) => {
      target.removeEventListener(type, fn, options);
    });
  }
  jest.clearAllTimers();
  jest.useRealTimers();
  jest.restoreAllMocks();
  document.body.replaceChildren();
});

// Render the real Handlebars view with a mock transport and terminal. Input
// still goes through the bundled hterm's actual keystroke wrapper.
function fixture(options = {}) {
  document.documentElement.innerHTML = renderView({ siteTitle: 'Test', host: 'example' });
  window.matchMedia = () => ({ matches: options.coarse !== false });
  window.PointerEvent = options.legacy ? undefined : MouseEvent;
  Object.defineProperty(navigator, 'maxTouchPoints', { configurable: true, value: 1 });
  Object.defineProperty(document, 'hidden', { configurable: true, value: false });
  Object.defineProperty(window, 'innerHeight', { configurable: true, value: options.height || 800 });
  const viewport = new EventTarget();
  viewport.height = options.height || 800;
  viewport.scale = 1;
  Object.defineProperty(window, 'visualViewport', {
    configurable: true, value: options.noViewport ? undefined : viewport
  });
  localStorage.clear();
  if (options.saved !== undefined) localStorage.setItem('ood_shell_mobile_keys', options.saved);
  if (options.blockStorage) {
    jest.spyOn(Storage.prototype, 'getItem').mockImplementation(() => { throw new Error('blocked'); });
    jest.spyOn(Storage.prototype, 'setItem').mockImplementation(() => { throw new Error('blocked'); });
  }

  const toolbar = document.getElementById('mobile_keys');
  const toggle = document.getElementById('mobile_keys_toggle');
  const more = toolbar.querySelector('[data-action="more"]');
  const extra = document.getElementById('mobile_keys_extra');
  const buttons = Array.from(toolbar.querySelectorAll('button'));
  for (const button of [...buttons, toggle]) {
    let capture = null;
    button.setPointerCapture = (id) => {
      if (options.captureError) throw new Error('pointer no longer active');
      capture = id;
    };
    button.hasPointerCapture = (id) => capture === id;
    button.releasePointerCapture = (id) => {
      capture = null;
      fire(button, 'lostpointercapture', { pointerId: id });
    };
  }
  let hit = null;
  document.elementFromPoint = jest.fn(() => hit);
  const press = (node, pointerId = 1) => {
    hit = node;
    return fire(node, 'pointerdown', { pointerId });
  };
  const release = (node, pointerId = 1) => {
    hit = node;
    return fire(window, 'pointerup', { pointerId });
  };
  const tap = (node, pointerId = 1) => {
    press(node, pointerId);
    release(node, pointerId);
    fire(node, 'click');
  };

  const sent = [];
  let term;
  let screen;
  const counts = { scroll: jest.fn(), blink: jest.fn(), focus: jest.fn(() => screen.focus()) };
  class Socket {
    constructor() { this.readyState = 0; }
    send(str) { sent.push(JSON.parse(str)); }
  }
  Socket.OPEN = 1;
  window.WebSocket = Socket;
  window.hterm = {
    Terminal: function () {
      term = this;
      const frame = document.createElement('iframe');
      this.options_ = {};
      this.keyboard = { applicationCursor: false };
      this.io = { push() { return this; }, print() {} };
      this.installKeyboard = this.setAccessibilityEnabled = () => {};
      this.decorate = (element) => {
        element.appendChild(frame);
        frame.contentDocument.body.innerHTML = '<x-screen tabindex="0"></x-screen>';
        screen = frame.contentDocument.querySelector('x-screen');
        screen.focus();
      };
      this.getDocument = () => frame.contentDocument;
      this.focus = counts.focus;
      this.scrollOnKeystroke_ = true;
      this.scrollPort_ = { scrollRowToBottom: counts.scroll };
      this.getRowCount = () => 200;
      this.pauseCursorBlink_ = counts.blink;
      this.onVTKeystroke = bundledHterm.Terminal.prototype.onVTKeystroke;
    }
  };
  const shell = new window.OodShell(document.getElementById('terminal'), 'ws://example');
  shell.createTerminal();
  const open = () => { shell.socket.readyState = Socket.OPEN; shell.socket.onopen(); };
  const ready = () => { open(); term.onTerminalReady(); };
  if (options.ready !== false) ready();
  jest.advanceTimersByTime(20);
  const button = (field, value) => toolbar.querySelector('[data-' + field + '="' + value + '"]');
  return {
    shell, keys: shell.keys, toolbar, toggle, more, extra, buttons, sent, counts,
    viewport, button, press, release, tap, open, ready, term: () => term,
    hit: (node) => { hit = node; }
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
    f.tap(f.button('key', 'tab'));
    expect(f.sent).toEqual([{ input: '\t' }]);
  });

  test('toolbar input uses hterm scrolling and cursor activity', () => {
    const f = fixture();
    f.press(f.button('key', 'left'));
    expect(f.counts.scroll).toHaveBeenCalledTimes(1);
    expect(f.counts.blink).toHaveBeenCalledTimes(1);
    expect(f.sent).toEqual([{ input: '\x1b[D' }]);
  });

  test('a late terminal-ready callback does not re-enable disconnected keys', () => {
    const f = fixture({ ready: false });
    f.open();
    f.shell.socket.readyState = 3;
    f.shell.closeTerminal({ code: 1000 });
    f.term().onTerminalReady();
    expect(f.keys.enabled).toBe(false);
    expect(f.toolbar.hidden).toBe(true);
    expect(f.toggle.disabled).toBe(true);
  });

  test('encoded input is modified once and shortcuts ignore locked Alt', () => {
    const f = fixture();
    f.keys.toggleModifier('ctrl');
    f.keys.toggleModifier('alt');
    f.keys.pressText('x');
    expect(f.sent).toEqual([{ input: '\x1b\x18' }]);
    f.keys.toggleModifier('alt');
    f.keys.toggleModifier('alt');
    f.tap(f.button('ctrl', 'c'));
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

  test('toolbar respects foreground IO and restores its flag on errors', () => {
    const f = fixture();
    f.term().io.onVTKeystroke = () => { throw new Error('foreground IO'); };
    expect(() => f.keys.pressKey('left')).toThrow('foreground IO');
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

  test('a press restores focus after a menu interaction, but repeats do not', () => {
    const f = fixture();
    document.getElementById('colors').focus();
    f.press(f.button('key', 'left'));
    expect(f.counts.focus).toHaveBeenCalledTimes(1);
    jest.advanceTimersByTime(520);
    expect(f.counts.focus).toHaveBeenCalledTimes(1);
    expect(f.sent).toHaveLength(4);
  });

  test('an already focused terminal is not refocused', () => {
    const f = fixture();
    f.press(f.button('mod', 'ctrl'));
    expect(f.counts.focus).not.toHaveBeenCalled();
    f.term().onVTKeystroke('6');
    expect(f.sent).toEqual([{ input: '\x1e' }]);
  });

  test('Home, End, page navigation and Shift Tab send their sequences', () => {
    const f = fixture();
    for (const name of ['home', 'end', 'pageup', 'pagedown', 'backtab']) {
      f.keys.activate(f.button('key', name));
    }
    expect(f.sent).toEqual([
      { input: '\x1b[H' }, { input: '\x1b[F' }, { input: '\x1b[5~' },
      { input: '\x1b[6~' }, { input: '\x1b[Z' }
    ]);
  });

  test('Ctrl with the pipe and tilde buttons sends control characters', () => {
    const f = fixture();
    for (const symbol of ['|', '~']) {
      f.tap(f.button('mod', 'ctrl'));
      f.tap(f.button('text', symbol));
    }
    expect(f.sent).toEqual([{ input: '\x1c' }, { input: '\x1e' }]);
  });
});

describe('pointer lifecycle', () => {
  test('repeat waits 400ms, then repeats every 60ms, and stops on release', () => {
    const f = fixture();
    const left = f.button('key', 'left');
    f.press(left);
    expect(left.hasPointerCapture(1)).toBe(true);
    jest.advanceTimersByTime(399);
    expect(f.sent).toHaveLength(1);
    jest.advanceTimersByTime(1);
    expect(f.sent).toHaveLength(2);
    jest.advanceTimersByTime(120);
    expect(f.sent).toHaveLength(4);
    f.release(null);
    jest.advanceTimersByTime(1000);
    expect(f.sent).toHaveLength(4);
    expect(left.hasPointerCapture(1)).toBe(false);
  });

  test('another finger ending leaves the held arrow repeating', () => {
    const f = fixture();
    f.press(f.button('key', 'left'), 1);
    f.press(f.button('mod', 'ctrl'), 2);
    f.release(null, 2);
    fire(window, 'pointercancel', { pointerId: 3 });
    jest.advanceTimersByTime(400);
    expect(f.sent).toEqual([{ input: '\x1b[D' }, { input: '\x1b[1;5D' }]);
    f.release(null, 1);
  });

  test.each(['pointercancel', 'lostpointercapture', 'blur'])('%s stops a repeating key', (type) => {
    const f = fixture();
    const left = f.button('key', 'left');
    f.press(left);
    fire(type === 'lostpointercapture' ? left : window, type, { pointerId: 1 });
    jest.advanceTimersByTime(1000);
    expect(f.sent).toHaveLength(1);
  });

  test('a failed capture does not start a repeat after the pointer has ended', () => {
    const f = fixture({ captureError: true });
    f.press(f.button('key', 'left'));
    jest.advanceTimersByTime(1000);
    expect(f.sent).toHaveLength(1);
  });

  test('long pointer presses are deduplicated while keyboard activation works', () => {
    const f = fixture();
    const ctrl = f.button('mod', 'ctrl');
    f.press(ctrl);
    jest.advanceTimersByTime(1500);
    f.release(ctrl);
    fire(ctrl, 'click');
    expect(f.keys.state.ctrl).toBe('once');
    fire(ctrl, 'click', { detail: 0 });
    expect(f.keys.state.ctrl).toBe('lock');
  });

  test('each finger has its own click suppression after simultaneous presses', () => {
    const f = fixture();
    const left = f.button('key', 'left');
    const ctrl = f.button('mod', 'ctrl');
    f.press(left, 1);
    f.press(ctrl, 2);
    f.release(ctrl, 2);
    fire(ctrl, 'click');
    f.release(left, 1);
    fire(left, 'click');
    expect(f.sent).toEqual([{ input: '\x1b[D' }]);
    expect(f.keys.state.ctrl).toBe('once');
  });

  test.each(['c', 'z', 'd', 'x'])('Control %s is sent once on release, not on press', (letter) => {
    const f = fixture();
    const button = f.button('ctrl', letter);
    f.press(button);
    expect(f.sent).toEqual([]);
    f.release(button);
    fire(button, 'click');
    expect(f.sent).toEqual([{ input: OodShellKeys.ctrlChar(letter) }]);
  });

  test('sliding off a shortcut cancels it despite pointer capture', () => {
    const f = fixture();
    const button = f.button('ctrl', 'd');
    f.keys.toggleModifier('alt');
    f.press(button);
    expect(button.hasPointerCapture(1)).toBe(true);
    f.hit(document.getElementById('terminal'));
    fire(button, 'pointerup', { pointerId: 1 });
    fire(button, 'click');
    expect(f.sent).toEqual([]);
    expect(f.keys.state.alt).toBe('once');
  });

  test.each(['pointercancel', 'lostpointercapture', 'blur'])('%s abandons a pending shortcut', (type) => {
    const f = fixture();
    const button = f.button('ctrl', 'd');
    f.press(button);
    fire(type === 'lostpointercapture' ? button : window, type, { pointerId: 1 });
    f.release(button);
    fire(button, 'click');
    expect(f.sent).toEqual([]);
  });

  test('a different pointer cannot release a pending shortcut', () => {
    const f = fixture();
    const button = f.button('ctrl', 'd');
    f.press(button, 1);
    f.release(button, 2);
    expect(f.sent).toEqual([]);
    f.release(button, 1);
    expect(f.sent).toEqual([{ input: '\x04' }]);
  });

  test('failed capture abandons a shortcut without consuming a modifier', () => {
    const f = fixture({ captureError: true });
    const button = f.button('ctrl', 'd');
    f.keys.toggleModifier('alt');
    f.press(button);
    f.release(button);
    fire(button, 'click');
    expect(f.sent).toEqual([]);
    expect(f.keys.state.alt).toBe('once');
  });

  test('the legacy touch fallback repeats navigation and releases shortcuts', () => {
    const f = fixture({ legacy: true });
    const left = f.button('key', 'left');
    fire(left, 'touchstart', { changedTouches: [{ identifier: 7, target: left }] });
    jest.advanceTimersByTime(400);
    expect(f.sent).toHaveLength(2);
    fire(window, 'touchend', { changedTouches: [{ identifier: 7 }] });
    jest.advanceTimersByTime(1000);
    expect(f.sent).toHaveLength(2);
    const shortcut = f.button('ctrl', 'd');
    fire(shortcut, 'touchstart', { changedTouches: [{ identifier: 8, target: shortcut }] });
    expect(f.sent).toHaveLength(2);
    f.hit(shortcut);
    fire(window, 'touchend', { changedTouches: [{ identifier: 8, clientX: 10, clientY: 10 }] });
    expect(f.sent[2]).toEqual({ input: '\x04' });
  });

  test('the legacy touch fallback abandons cancelled shortcuts', () => {
    const f = fixture({ legacy: true });
    const shortcut = f.button('ctrl', 'd');
    fire(shortcut, 'touchstart', { changedTouches: [{ identifier: 8, target: shortcut }] });
    f.hit(shortcut);
    fire(window, 'touchcancel', { changedTouches: [{ identifier: 8, clientX: 10, clientY: 10 }] });
    fire(window, 'touchend', { changedTouches: [{ identifier: 8, clientX: 10, clientY: 10 }] });
    expect(f.sent).toEqual([]);
  });

  test('the legacy mouse fallback activates once on release', () => {
    const f = fixture({ legacy: true });
    const shortcut = f.button('ctrl', 'd');
    fire(shortcut, 'mousedown');
    expect(f.sent).toEqual([]);
    f.hit(shortcut);
    fire(window, 'mouseup');
    fire(shortcut, 'click');
    expect(f.sent).toEqual([{ input: '\x04' }]);
  });

  test('hiding the toolbar abandons a pending shortcut', () => {
    const f = fixture();
    const shortcut = f.button('ctrl', 'd');
    f.press(shortcut);
    f.keys.setVisible(false);
    f.release(shortcut);
    fire(shortcut, 'click');
    expect(f.sent).toEqual([]);
  });

  test('hiding the page clears modifiers, repeat and pending input', () => {
    const f = fixture();
    const shortcut = f.button('ctrl', 'd');
    f.press(f.button('key', 'left'), 1);
    f.press(shortcut, 2);
    f.keys.toggleModifier('alt');
    Object.defineProperty(document, 'hidden', { configurable: true, value: true });
    fire(document, 'visibilitychange');
    f.release(shortcut, 2);
    jest.advanceTimersByTime(1000);
    expect(f.sent).toHaveLength(1);
    expect(f.keys.state.alt).toBe('off');
  });

  test('disconnect hides the toolbar and abandons pending input', () => {
    const f = fixture();
    const shortcut = f.button('ctrl', 'd');
    f.press(shortcut);
    f.shell.closeTerminal({ code: 1000 });
    f.release(shortcut);
    expect(f.toolbar.hidden).toBe(true);
    expect(f.toggle.disabled).toBe(true);
    expect(f.buttons.every((button) => button.disabled)).toBe(true);
    f.keys.pressControl('c');
    expect(f.sent).toEqual([]);
  });
});

describe('visibility, compact layout and accessible state', () => {
  test('a coarse pointer defaults to visible and a fine pointer to hidden', () => {
    expect(fixture().toolbar.hidden).toBe(false);
    const f = fixture({ coarse: false });
    expect(f.toolbar.hidden).toBe(true);
    fire(f.toggle, 'click', { detail: 0 });
    expect(f.toolbar.hidden).toBe(false);
    expect(f.toggle.getAttribute('aria-expanded')).toBe('true');
  });

  test('a saved choice overrides pointer capability', () => {
    expect(fixture({ saved: 'false' }).toolbar.hidden).toBe(true);
    expect(fixture({ saved: 'true', coarse: false }).toolbar.hidden).toBe(false);
  });

  test('show/hide activates once on release, saves the choice and clears modifiers', () => {
    const f = fixture();
    f.keys.toggleModifier('ctrl');
    expect(f.press(f.toggle).defaultPrevented).toBe(true);
    expect(f.toolbar.hidden).toBe(false);
    f.release(f.toggle);
    fire(f.toggle, 'click');
    expect(f.toolbar.hidden).toBe(true);
    expect(f.keys.state.ctrl).toBe('off');
    expect(localStorage.getItem('ood_shell_mobile_keys')).toBe('false');
  });

  test('blocked storage does not prevent showing or hiding the keys', () => {
    const f = fixture({ blockStorage: true });
    fire(f.toggle, 'click', { detail: 0 });
    expect(f.toolbar.hidden).toBe(true);
  });

  test('a short viewport starts compact and More exposes secondary keys', () => {
    const f = fixture({ height: 300 });
    expect(f.extra.hidden).toBe(true);
    expect(f.more.hidden).toBe(false);
    f.tap(f.more);
    expect(f.extra.hidden).toBe(false);
    expect(f.more.getAttribute('aria-expanded')).toBe('true');
    f.tap(f.more);
    expect(f.extra.hidden).toBe(true);
    expect(f.sent).toEqual([]);
  });

  test('visual viewport changes collapse extras without changing the layout viewport', () => {
    const f = fixture();
    expect(f.extra.hidden).toBe(false);
    expect(f.more.hidden).toBe(true);
    f.viewport.height = 300;
    fire(f.viewport, 'resize');
    jest.advanceTimersByTime(20);
    expect(window.innerHeight).toBe(800);
    expect(f.extra.hidden).toBe(true);
    f.tap(f.more);
    fire(f.viewport, 'scroll');
    jest.advanceTimersByTime(20);
    expect(f.extra.hidden).toBe(false);
    f.viewport.height = 800;
    fire(f.viewport, 'resize');
    jest.advanceTimersByTime(20);
    expect(f.more.hidden).toBe(true);
    expect(f.extra.hidden).toBe(false);
  });

  test('window resizing updates compact mode without the Visual Viewport API', () => {
    const f = fixture({ noViewport: true });
    Object.defineProperty(window, 'innerHeight', { configurable: true, value: 300 });
    fire(window, 'resize');
    expect(f.extra.hidden).toBe(true);
  });

  test('modifier names stay stable while descriptions distinguish once and locked', () => {
    const f = fixture();
    const ctrl = f.button('mod', 'ctrl');
    const state = document.getElementById('mobile_ctrl_state');
    expect(ctrl.getAttribute('aria-label')).toBe('Control');
    f.keys.toggleModifier('ctrl');
    expect(ctrl.getAttribute('aria-pressed')).toBe('true');
    expect(state.textContent).toBe('Applies to the next key.');
    f.keys.toggleModifier('ctrl');
    expect(ctrl.getAttribute('aria-label')).toBe('Control');
    expect(state.textContent).toBe('Locked on.');
    f.keys.toggleModifier('ctrl');
    expect(ctrl.getAttribute('aria-pressed')).toBe('false');
    expect(state.textContent).toBe('Off.');
  });
});
