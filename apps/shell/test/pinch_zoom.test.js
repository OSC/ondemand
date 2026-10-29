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

/** A minimal touch event with the fields ood_shell.2.js reads. */
function touchEvent(type, touches) {
  return {
    type,
    touches,
    changedTouches: touches,
    defaultPrevented: false,
    preventDefault() { this.defaultPrevented = true; }
  };
}

/** A finger at (x, y). */
function finger(identifier, x, y = 0) {
  return { identifier, clientX: x, clientY: y };
}

/**
 * Build an OodShell with pinch zoom installed on a fake hterm terminal that
 * starts at a 15px font.
 */
function setup() {
  const animationFrames = new Map();
  let nextFrame = 1;
  const screen = new FakeEventTarget();
  const term = {
    fontSize: 15,
    getFontSize() { return this.fontSize; },
    setFontSize(px) { this.fontSize = px; },
    // hterm's private per-finger position cache, used for one-finger scrolling.
    scrollPort_: { lastTouch_: {} },
    getDocument: () => ({ querySelector: () => screen })
  };

  const OodShell = loadOodShell({
    window: {
      requestAnimationFrame: (callback) => {
        const id = nextFrame++;
        animationFrames.set(id, callback);
        return id;
      },
      cancelAnimationFrame: (id) => animationFrames.delete(id)
    }
  });
  new OodShell({}, 'ws://localhost', 'default').installPinchZoom(term);

  return {
    term,
    screen,
    flushAnimationFrames: () => {
      const callbacks = Array.from(animationFrames.values());
      animationFrames.clear();
      callbacks.forEach((callback) => callback());
    },
    pendingAnimationFrames: () => animationFrames.size,

    // Put two fingers down, `distance` pixels apart.
    pinchStart(distance) {
      screen.dispatchEvent(touchEvent('touchstart', [finger(1, 0), finger(2, distance)]));
    },

    // Move two fingers so they are `distance` pixels apart.
    pinchMove(distance) {
      const event = touchEvent('touchmove', [finger(1, 0), finger(2, distance)]);
      screen.dispatchEvent(event);
      return event;
    }
  };
}

describe('Pinch zoom', () => {
  test('scales the font with the distance between the fingers', () => {
    const { term, pinchStart, pinchMove, flushAnimationFrames } = setup();
    pinchStart(100);
    pinchMove(200);
    flushAnimationFrames();

    expect(term.getFontSize()).toBe(30);
  });

  test('shrinks the font when the fingers move together', () => {
    const { term, pinchStart, pinchMove, flushAnimationFrames } = setup();
    pinchStart(200);
    pinchMove(100);
    flushAnimationFrames();

    // 15 * 0.5 = 7.5, rounded up
    expect(term.getFontSize()).toBe(8);
  });

  test('never goes above the largest font size', () => {
    const { term, pinchStart, pinchMove, flushAnimationFrames } = setup();
    pinchStart(100);
    pinchMove(1000);
    flushAnimationFrames();

    expect(term.getFontSize()).toBe(40);
  });

  test('never goes below the smallest font size', () => {
    const { term, pinchStart, pinchMove, flushAnimationFrames } = setup();
    pinchStart(1000);
    pinchMove(10);
    flushAnimationFrames();

    expect(term.getFontSize()).toBe(8);
  });

  test('applies only the latest finger position once per animation frame', () => {
    const { term, pinchStart, pinchMove, flushAnimationFrames, pendingAnimationFrames } = setup();
    const setFontSize = jest.spyOn(term, 'setFontSize');
    pinchStart(100);
    pinchMove(120);
    pinchMove(140);
    pinchMove(200);

    expect(pendingAnimationFrames()).toBe(1);
    flushAnimationFrames();

    expect(setFontSize).toHaveBeenCalledTimes(1);
    expect(term.getFontSize()).toBe(30);
  });

  test('claims the gesture so hterm does not also scroll', () => {
    const { pinchStart, pinchMove } = setup();
    pinchStart(100);

    // hterm skips events that are already defaultPrevented.
    expect(pinchMove(200).defaultPrevented).toBe(true);
  });

  test('leaves one-finger touches alone so they still scroll', () => {
    const { term, screen, flushAnimationFrames } = setup();
    screen.dispatchEvent(touchEvent('touchstart', [finger(1, 0)]));
    const move = touchEvent('touchmove', [finger(1, 0, 40)]);
    screen.dispatchEvent(move);
    flushAnimationFrames();

    expect(move.defaultPrevented).toBe(false);
    expect(term.getFontSize()).toBe(15);
  });

  test('ignores two-finger movement that did not start as a pinch', () => {
    const { term, pinchMove, flushAnimationFrames } = setup();
    const move = pinchMove(200);
    flushAnimationFrames();

    expect(move.defaultPrevented).toBe(false);
    expect(term.getFontSize()).toBe(15);
  });

  test('hands a pinch to hterm with current positions when a third finger lands', () => {
    const { term, screen, pinchStart, flushAnimationFrames, pendingAnimationFrames } = setup();
    pinchStart(100);
    const first = finger(1, 10, 40);
    const second = finger(2, 210, 60);
    const third = finger(3, 300, 80);
    screen.dispatchEvent(touchEvent('touchmove', [first, second]));
    screen.dispatchEvent(touchEvent('touchstart', [first, second, third]));

    expect(term.getFontSize()).toBe(30);
    expect(pendingAnimationFrames()).toBe(0);
    expect(term.scrollPort_.lastTouch_[1]).toEqual({ id: 1, x: 10, y: 40 });
    expect(term.scrollPort_.lastTouch_[2]).toEqual({ id: 2, x: 210, y: 60 });
    const move = touchEvent('touchmove', [first, second, third]);
    screen.dispatchEvent(move);
    flushAnimationFrames();
    expect(move.defaultPrevented).toBe(false);
    expect(term.getFontSize()).toBe(30);
  });

  test('applies the last move when a finger lifts before the animation frame', () => {
    const { term, screen, pinchStart, pinchMove, flushAnimationFrames, pendingAnimationFrames } = setup();
    pinchStart(100);
    pinchMove(200);
    screen.dispatchEvent(touchEvent('touchend', [finger(2, 200)]));

    expect(term.getFontSize()).toBe(30);
    expect(pendingAnimationFrames()).toBe(0);
    flushAnimationFrames();
    expect(term.getFontSize()).toBe(30);
  });

  test('cancels a pending resize and resyncs the remaining finger on touchcancel', () => {
    const { term, screen, pinchStart, pinchMove, flushAnimationFrames, pendingAnimationFrames } = setup();
    pinchStart(100);
    pinchMove(200);
    screen.dispatchEvent(touchEvent('touchcancel', [finger(2, 200, 50)]));

    expect(pendingAnimationFrames()).toBe(0);
    expect(term.scrollPort_.lastTouch_[2]).toEqual({ id: 2, x: 200, y: 50 });
    flushAnimationFrames();
    expect(term.getFontSize()).toBe(15);
    expect(pinchMove(300).defaultPrevented).toBe(false);
  });

  test('ignores a pinch whose starting distance is zero', () => {
    const { term, pinchStart, pinchMove, flushAnimationFrames } = setup();
    pinchStart(0);
    const move = pinchMove(100);
    flushAnimationFrames();

    expect(move.defaultPrevented).toBe(false);
    expect(term.getFontSize()).toBe(15);
  });

  test('stops claiming touches once both fingers are lifted', () => {
    const { screen, pinchStart, pinchMove } = setup();
    pinchStart(100);
    screen.dispatchEvent(touchEvent('touchend', [finger(2, 100)]));
    screen.dispatchEvent(touchEvent('touchend', []));

    expect(pinchMove(200).defaultPrevented).toBe(false);
  });

  test('resyncs hterm\'s touch cache when one finger lifts first', () => {
    const { term, screen, pinchStart, pinchMove } = setup();
    pinchStart(100);
    pinchMove(200);

    // Finger 1 lifts; finger 2 stays down at (50, 60).
    screen.dispatchEvent(touchEvent('touchend', [finger(2, 50, 60)]));

    // Without this, the next one-finger move would scroll by the distance from
    // finger 2's position before the pinch.
    expect(term.scrollPort_.lastTouch_[2]).toEqual({ id: 2, x: 50, y: 60 });
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
  test('installs installPinchZoom when the terminal is ready', () => {
    const { shell, installers } = startTerminal();

    expect(installers.installPinchZoom).toHaveBeenCalledTimes(1);
    expect(installers.installPinchZoom).toHaveBeenCalledWith(shell.term);
  });
});
