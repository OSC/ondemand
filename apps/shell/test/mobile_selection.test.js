'use strict';
const fs = require('fs');
const path = require('path');
const vm = require('vm');

const SOURCE = path.join(__dirname, '..', 'public', 'javascripts', 'ood_shell.2.js');

/**
 * Evaluate ood_shell.2.js in an isolated context that only has the browser
 * globals supplied by the caller, and return its OodShell constructor. The
 * file is a plain browser script rather than a module, so this is how it is
 * exercised without a browser.
 */
function loadOodShell(globals) {
  const context = vm.createContext(globals);
  vm.runInContext(fs.readFileSync(SOURCE, 'utf8'), context);
  return context.OodShell;
}

/**
 * A synchronous stand-in for EventTarget. Node's own EventTarget reports an
 * exception thrown by a listener as an uncaught exception, which takes down
 * the whole test run; this lets it surface as a failure of the test that
 * dispatched the event.
 */
class FakeEventTarget {
  constructor() {
    this.listeners = {};
  }

  addEventListener(type, listener) {
    (this.listeners[type] = this.listeners[type] || []).push(listener);
  }

  dispatchEvent(event) {
    (this.listeners[event.type] || []).forEach((listener) => listener.call(this, event));
  }
}

/** A minimal event with the fields ood_shell.2.js reads. */
function fakeEvent(type, fields = {}) {
  return Object.assign({
    type,
    timeStamp: 0,
    defaultPrevented: false,
    preventDefault() { this.defaultPrevented = true; }
  }, fields);
}

/**
 * A minimal stand-in for a DOM element: an event target that records its
 * children and has a fixed size.
 */
function fakeElement() {
  const element = new FakeEventTarget();
  element.children = [];
  element.style = {};
  element.hidden = false;
  element.appendChild = (child) => element.children.push(child);
  element.getBoundingClientRect = () => ({ width: 120, height: 36 });
  return element;
}

/** What the browser reports when nothing is selected. */
function collapsedSelection() {
  return { isCollapsed: true, rangeCount: 0, collapseToEnd() {} };
}

// Identity tokens for "a node inside the terminal" and "a node outside it".
const TERMINAL_TEXT = {};
const OUTSIDE_TEXT = {};

/**
 * Build an OodShell wired to fake browser and hterm objects, with both the
 * selection toolbar and the tap-to-focus handler installed.
 */
function setup({ coarsePointer = true, canPaste = true, frameTop = 50 } = {}) {
  const animationFrames = [];
  const page = { createElement: fakeElement, body: fakeElement() };
  const viewport = new FakeEventTarget();
  let frameOffset = frameTop;

  // hterm renders into an iframe; this is that iframe's document.
  const termDocument = new FakeEventTarget();
  let selection = collapsedSelection();
  const screen = new FakeEventTarget();
  screen.contains = (node) => node === TERMINAL_TEXT;
  termDocument.querySelector = () => screen;
  termDocument.getSelection = () => selection;
  termDocument.defaultView = {
    frameElement: { getBoundingClientRect: () => ({ top: frameOffset, left: 0 }) }
  };

  const term = {
    getDocument: () => termDocument,
    getSelectionText: jest.fn(() => 'ls -la'),
    copyStringToClipboard: jest.fn(),
    paste: jest.fn(),
    focus: jest.fn(),
    blur: jest.fn()
  };

  const OodShell = loadOodShell({
    window: {
      innerWidth: 400,
      requestAnimationFrame: (callback) => animationFrames.push(callback),
      matchMedia: () => ({ matches: coarsePointer }),
      visualViewport: viewport
    },
    document: page,
    navigator: {
      maxTouchPoints: 5,
      clipboard: canPaste ? { readText: () => Promise.resolve('') } : undefined
    }
  });
  const shell = new OodShell({}, 'ws://localhost', 'default');
  shell.installMobileSelection(term);
  shell.installTouchKeyboard(term);

  const toolbar = page.body.children[0];
  const flushAnimationFrames = () => animationFrames.splice(0).forEach((callback) => callback());

  return {
    term,
    toolbar,
    copyButton: toolbar.children[0],
    pasteButton: toolbar.children[1],
    viewport,
    moveFrame: (top) => { frameOffset = top; },
    isTextSelected: () => !selection.isCollapsed,

    // Select text inside (or outside) the terminal, as the browser would.
    select(node, rect) {
      selection = {
        isCollapsed: false,
        rangeCount: 1,
        getRangeAt: () => ({ commonAncestorContainer: node, getBoundingClientRect: () => rect }),
        collapseToEnd() { selection = collapsedSelection(); }
      };
      termDocument.dispatchEvent(fakeEvent('selectionchange'));
      flushAnimationFrames();
    },

    // Collapse the selection, announcing it only when the browser would.
    deselect({ announce = true } = {}) {
      selection = collapsedSelection();
      if (announce) {
        termDocument.dispatchEvent(fakeEvent('selectionchange'));
      }
      flushAnimationFrames();
    },

    flushAnimationFrames,

    // A short, stationary single-finger tap on the terminal.
    tap() {
      const touch = { identifier: 1, clientX: 10, clientY: 10 };
      screen.dispatchEvent(fakeEvent('touchstart', { timeStamp: 0, touches: [touch] }));
      screen.dispatchEvent(fakeEvent('touchend', {
        timeStamp: 100,
        touches: [],
        changedTouches: [touch]
      }));
    }
  };
}

const SELECTION_RECT = { top: 200, bottom: 220, left: 100, width: 80 };

describe('Selection toolbar', () => {
  test('is hidden until text is selected', () => {
    const { toolbar } = setup();
    expect(toolbar.hidden).toBe(true);
  });

  test('appears above a selection inside the terminal', () => {
    const { toolbar, select } = setup();
    select(TERMINAL_TEXT, SELECTION_RECT);

    expect(toolbar.hidden).toBe(false);
    // frame offset + selection top - toolbar height - gap
    expect(toolbar.style.top).toBe('206px');
    // selection centre - half the toolbar width
    expect(toolbar.style.left).toBe('80px');
  });

  test('drops below the selection when there is no room above it', () => {
    const { toolbar, select } = setup({ frameTop: 0 });
    select(TERMINAL_TEXT, { top: 5, bottom: 25, left: 100, width: 80 });

    // selection bottom + gap
    expect(toolbar.style.top).toBe('33px');
  });

  test('stays inside the viewport horizontally', () => {
    const { toolbar, select } = setup();
    select(TERMINAL_TEXT, { top: 200, bottom: 220, left: 390, width: 10 });

    // viewport width - toolbar width - margin
    expect(toolbar.style.left).toBe('276px');
  });

  test('follows the selection when the visual viewport changes', () => {
    const { toolbar, select, moveFrame, viewport, flushAnimationFrames } = setup();
    select(TERMINAL_TEXT, SELECTION_RECT);

    moveFrame(0);
    viewport.dispatchEvent(fakeEvent('resize'));
    flushAnimationFrames();

    expect(toolbar.style.top).toBe('156px');
  });

  test('hides when the selection collapses', () => {
    const { toolbar, select, deselect } = setup();
    select(TERMINAL_TEXT, SELECTION_RECT);
    deselect();

    expect(toolbar.hidden).toBe(true);
  });

  test('ignores selections outside the terminal', () => {
    const { toolbar, select } = setup();
    select(OUTSIDE_TEXT, SELECTION_RECT);

    expect(toolbar.hidden).toBe(true);
  });

  test('never appears when the primary pointer is not a finger', () => {
    const { toolbar, select } = setup({ coarsePointer: false });
    select(TERMINAL_TEXT, SELECTION_RECT);

    expect(toolbar.hidden).toBe(true);
  });

  test('Copy sends the selected text to the clipboard without opening the keyboard', () => {
    const { toolbar, copyButton, term, select, isTextSelected } = setup();
    select(TERMINAL_TEXT, SELECTION_RECT);

    copyButton.dispatchEvent(fakeEvent('click'));

    expect(term.copyStringToClipboard).toHaveBeenCalledTimes(1);
    expect(term.copyStringToClipboard).toHaveBeenCalledWith('ls -la');
    expect(term.focus).not.toHaveBeenCalled();
    expect(toolbar.hidden).toBe(true);
    expect(isTextSelected()).toBe(false);
  });

  test('Copy still works if the browser drops the selection when the button is tapped', () => {
    const { copyButton, term, select, deselect } = setup();
    select(TERMINAL_TEXT, SELECTION_RECT);
    deselect({ announce: false });

    copyButton.dispatchEvent(fakeEvent('click'));

    expect(term.copyStringToClipboard).toHaveBeenCalledWith('ls -la');
  });

  test('Paste hands off to hterm', () => {
    const { toolbar, pasteButton, term, select } = setup();
    select(TERMINAL_TEXT, SELECTION_RECT);

    pasteButton.dispatchEvent(fakeEvent('click'));

    expect(term.paste).toHaveBeenCalledTimes(1);
    expect(toolbar.hidden).toBe(true);
  });

  test('offers Paste only when the browser can read the clipboard', () => {
    expect(setup({ canPaste: true }).pasteButton.hidden).toBe(false);
    expect(setup({ canPaste: false }).pasteButton.hidden).toBe(true);
  });
});

describe('Tap to focus', () => {
  test('still focuses the terminal on a tap', () => {
    const { term, tap } = setup();
    tap();

    expect(term.focus).toHaveBeenCalledTimes(1);
  });

  test('leaves the keyboard closed when a tap lands during a selection', () => {
    const { term, select, tap } = setup();
    select(TERMINAL_TEXT, SELECTION_RECT);
    tap();

    expect(term.focus).not.toHaveBeenCalled();
  });
});

/**
 * Start a terminal the way the page does (runTerminal, then hterm calling
 * onTerminalReady) against fake hterm objects, with every install* method
 * replaced by a spy. This checks that the feature is wired into start-up;
 * what each method does is tested separately.
 */
function startTerminal() {
  class FakeTerminal {
    constructor() {
      this.options_ = {};
      this.io = { push: () => ({}) };
    }
    decorate() {}
    setAccessibilityEnabled() {}
    installKeyboard() {}
    getDocument() { return { querySelector: () => null }; }
  }

  const OodShell = loadOodShell({
    hterm: { Terminal: FakeTerminal },
    window: {},
    navigator: { maxTouchPoints: 0 }
  });
  const installers = {};
  Object.getOwnPropertyNames(OodShell.prototype)
    .filter((name) => name.startsWith('install'))
    .forEach((name) => {
      installers[name] = jest.fn();
      OodShell.prototype[name] = installers[name];
    });

  const shell = new OodShell({}, 'ws://localhost', 'default');
  shell.runTerminal();
  // hterm calls onTerminalReady with the terminal as `this`.
  shell.term.onTerminalReady();
  return { shell, installers };
}

describe('Terminal start-up', () => {
  test('installs installMobileSelection when the terminal is ready', () => {
    const { shell, installers } = startTerminal();

    expect(installers.installMobileSelection).toHaveBeenCalledTimes(1);
    expect(installers.installMobileSelection).toHaveBeenCalledWith(shell.term);
  });
});
