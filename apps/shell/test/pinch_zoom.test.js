'use strict';
const fs = require('fs');
const path = require('path');
const vm = require('vm');

const source = fs.readFileSync(path.join(__dirname, '..', 'public', 'javascripts', 'ood_shell.2.js'), 'utf8');
const loadOodShell = (globals) => vm.runInNewContext(source + '\nOodShell;', globals);
const finger = (identifier, clientX, clientY = 0) => ({ identifier, clientX, clientY });
const pair = (distance) => [finger(1, 0), finger(2, distance)];

// Dispatch synchronously so listener exceptions fail the test that caused them.
function setup() {
  const listeners = {};
  const screen = {
    addEventListener: jest.fn((type, listener) => { listeners[type] = listener; })
  };
  const term = {
    fontSize: 15,
    getFontSize() { return this.fontSize; },
    setFontSize: jest.fn((size) => { term.fontSize = size; }),
    scrollPort_: { lastTouch_: {} },
    getDocument: () => ({ querySelector: () => screen })
  };
  const OodShell = loadOodShell({
    window: {
      requestAnimationFrame: (callback) => setTimeout(callback, 16),
      cancelAnimationFrame: clearTimeout
    }
  });
  const shell = new OodShell({}, 'ws://localhost', 'default');
  shell.installPinchZoom(term);
  const fire = (type, touches) => {
    const event = { type, touches, defaultPrevented: false,
      preventDefault() { this.defaultPrevented = true; } };
    listeners[type](event);
    return event;
  };
  return { term, shell, screen, fire };
}

beforeEach(() => jest.useFakeTimers());
afterEach(() => jest.useRealTimers());

describe('Pinch zoom', () => {
  test.each([
    [100, 200, 30],
    [200, 100, 8],
    [100, 1000, 40],
    [1000, 10, 8],
    [100, 141, 21]
  ])('scales distance %i to %i as %ipx, within 8–40px', (start, end, size) => {
    const { term, fire } = setup();
    fire('touchstart', pair(start));
    fire('touchmove', pair(end));
    jest.runOnlyPendingTimers();
    expect(term.getFontSize()).toBe(size);
  });

  test('applies the latest size once per frame and skips unchanged sizes', () => {
    const { term, fire } = setup();
    fire('touchstart', pair(100));
    [120, 140, 200].forEach((distance) => fire('touchmove', pair(distance)));
    expect(jest.getTimerCount()).toBe(1);
    jest.runOnlyPendingTimers();
    expect(term.setFontSize).toHaveBeenCalledTimes(1);
    expect(term.setFontSize).toHaveBeenCalledWith(30);
    fire('touchmove', pair(201));
    jest.runOnlyPendingTimers();
    expect(term.setFontSize).toHaveBeenCalledTimes(1);
  });

  test('claims pinch moves in a non-passive capture listener before hterm', () => {
    const { screen, fire } = setup();
    fire('touchstart', pair(100));
    expect(fire('touchmove', pair(200)).defaultPrevented).toBe(true);
    expect(screen.addEventListener).toHaveBeenCalledWith('touchmove',
      expect.any(Function), { capture: true, passive: false });
  });

  test.each([[[]], [[finger(1, 0)]], [[...pair(100), finger(3, 300)]]])(
    'leaves a non-pinch touch list alone: %j', (touches) => {
      const { term, fire } = setup();
      fire('touchstart', touches);
      expect(fire('touchmove', touches).defaultPrevented).toBe(false);
      expect(jest.getTimerCount()).toBe(0);
      expect(term.getFontSize()).toBe(15);
    }
  );

  test('ignores two-finger moves without a pinch start', () => {
    const { term, fire } = setup();
    expect(fire('touchmove', pair(200)).defaultPrevented).toBe(false);
    expect(jest.getTimerCount()).toBe(0);
    expect(term.getFontSize()).toBe(15);
  });

  test.each([
    ['touchend', [finger(2, 200, 50)], 30],
    ['touchcancel', [finger(2, 200, 50)], 15],
    ['touchstart', [finger(1, 0), finger(2, 200, 50), finger(3, 300)], 30]
  ])('%s settles the pending frame and refreshes remaining touches', (type, touches, size) => {
    const { term, fire } = setup();
    fire('touchstart', pair(100));
    fire('touchmove', pair(200));
    fire(type, touches);
    expect(term.getFontSize()).toBe(size);
    expect(jest.getTimerCount()).toBe(0);
    expect(term.scrollPort_.lastTouch_[2]).toEqual({ id: 2, x: 200, y: 50 });
    expect(fire('touchmove', touches).defaultPrevented).toBe(false);
    jest.runOnlyPendingTimers();
    expect(term.getFontSize()).toBe(size);
  });

  test('rebases the pinch when a third finger lifts', () => {
    const { term, fire } = setup();
    fire('touchstart', pair(100));
    fire('touchmove', pair(200));
    fire('touchstart', [...pair(200), finger(3, 300)]);
    fire('touchend', pair(200));
    expect(fire('touchmove', pair(100)).defaultPrevented).toBe(true);
    jest.runOnlyPendingTimers();
    expect(term.getFontSize()).toBe(15);
  });

  test('ignores coincident starting fingers and zero-distance moves', () => {
    const { term, fire } = setup();
    fire('touchstart', pair(0));
    expect(fire('touchmove', pair(100)).defaultPrevented).toBe(false);
    fire('touchstart', pair(100));
    fire('touchmove', pair(0));
    jest.runOnlyPendingTimers();
    expect(term.setFontSize).not.toHaveBeenCalled();
  });

  test('stops claiming touches after both fingers lift', () => {
    const { fire } = setup();
    fire('touchstart', pair(100));
    fire('touchend', [finger(2, 100)]);
    fire('touchend', []);
    expect(fire('touchmove', pair(200)).defaultPrevented).toBe(false);
  });

  test('still ends a pinch if the private hterm cache is unavailable', () => {
    const { term, fire } = setup();
    term.scrollPort_ = null;
    fire('touchstart', pair(100));
    fire('touchmove', pair(200));
    fire('touchend', []);
    expect(term.getFontSize()).toBe(30);
  });

  test('ignores a missing terminal screen', () => {
    const { term, shell } = setup();
    term.getDocument = () => ({ querySelector: () => null });
    expect(() => shell.installPinchZoom(term)).not.toThrow();
  });
});

test('installs pinch zoom when hterm becomes ready', () => {
  const term = {
    options_: {}, io: { push: () => ({}) },
    decorate() {}, setAccessibilityEnabled() {}, installKeyboard() {}
  };
  const OodShell = loadOodShell({ hterm: { Terminal: function () { return term; } }, window: {} });
  const shell = new OodShell({}, 'ws://localhost', 'default');
  jest.spyOn(shell, 'installTouchKeyboard').mockImplementation(() => {});
  const install = jest.spyOn(shell, 'installPinchZoom').mockImplementation(() => {});
  shell.runTerminal();
  shell.term.onTerminalReady();
  expect(install).toHaveBeenCalledTimes(1);
  expect(install).toHaveBeenCalledWith(term);
});
