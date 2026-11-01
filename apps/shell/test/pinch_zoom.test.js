'use strict';
const fs = require('fs');
const path = require('path');
const vm = require('vm');

const jsDir = path.join(__dirname, '..', 'public', 'javascripts');
const source = fs.readFileSync(path.join(jsDir, 'ood_shell.2.js'), 'utf8');
const loadOodShell = (globals) => vm.runInNewContext(source + '\nOodShell;', globals);
const finger = (identifier, clientX, clientY = 0) => ({ identifier, clientX, clientY });
const pair = (distance) => [finger(1, 0), finger(2, distance)];
const SLOP = 20;

// hterm's own touch handler, taken from the vendored bundle so that an hterm
// update that changes how it treats prevented events fails these tests.
function loadHtermOnTouch() {
  const bundle = fs.readdirSync(jsDir).find((name) => /^hterm_all_.*\.js$/.test(name));
  const text = fs.readFileSync(path.join(jsDir, bundle), 'utf8');
  const start = text.indexOf('hterm.ScrollPort.prototype.onTouch_ = function');
  if (start === -1) {
    throw new Error(`hterm.ScrollPort.prototype.onTouch_ not found in ${bundle}`);
  }
  const end = text.indexOf('\n};\n', start);
  const fn = text.slice(text.indexOf('function', start), end + 2);
  return vm.runInNewContext(`(${fn})`, { hterm: { os: 'linux' }, window: {} });
}

// Dispatch synchronously so listener exceptions fail the test that caused them.
function setup({ fontSize = 15 } = {}) {
  const listeners = {};
  const doc = {
    addEventListener: jest.fn((type, listener) => { listeners[type] = listener; })
  };
  const screen = { ownerDocument: doc };
  const term = {
    fontSize,
    getFontSize() { return this.fontSize; },
    setFontSize: jest.fn((size) => { term.fontSize = size; }),
    getDocument: () => ({ querySelector: () => screen })
  };
  const OodShell = loadOodShell({
    window: {
      requestAnimationFrame: (callback) => setTimeout(callback, 16),
      cancelAnimationFrame: (id) => clearTimeout(id),
      setTimeout: (callback, delay) => setTimeout(callback, delay)
    }
  });
  const shell = new OodShell({}, 'ws://localhost', 'default');
  shell.socket = { send: jest.fn() };
  shell.installPinchZoom(term);
  const fire = (type, touches) => {
    const event = { type, touches, changedTouches: [], defaultPrevented: false,
      preventDefault() { this.defaultPrevented = true; } };
    listeners[type](event);
    return event;
  };
  // Land two fingers SLOP further apart than `start`, then pinch through the
  // dead zone so that the size is measured from `start`.
  const engage = (start) => {
    fire('touchstart', pair(start + SLOP));
    return fire('touchmove', pair(start));
  };
  return { term, shell, doc, listeners, fire, engage };
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
    const { term, fire, engage } = setup();
    engage(start);
    fire('touchmove', pair(end));
    jest.runOnlyPendingTimers();
    expect(term.getFontSize()).toBe(size);
  });

  test.each([
    [44, 100, 200, 44],
    [44, 200, 100, 22],
    [6, 200, 100, 6],
    [6, 100, 200, 12]
  ])('starting at %ipx, distance %i to %i gives %ipx without jumping into 8–40px',
    (fontSize, start, end, size) => {
      const { term, fire, engage } = setup({ fontSize });
      engage(start);
      fire('touchmove', pair(end));
      jest.runOnlyPendingTimers();
      expect(term.getFontSize()).toBe(size);
    }
  );

  test('two-finger moves inside the dead zone are left to hterm', () => {
    const { term, fire } = setup();
    fire('touchstart', pair(100));
    expect(fire('touchmove', pair(100 + SLOP - 1)).defaultPrevented).toBe(false);
    expect(fire('touchmove', [finger(1, 0, 50), finger(2, 100, 50)]).defaultPrevented)
      .toBe(false);
    expect(jest.getTimerCount()).toBe(0);
    expect(term.setFontSize).not.toHaveBeenCalled();
  });

  test('leaving the dead zone claims the move without changing the size', () => {
    const { term, engage } = setup();
    expect(engage(100).defaultPrevented).toBe(true);
    expect(jest.getTimerCount()).toBe(0);
    expect(term.setFontSize).not.toHaveBeenCalled();
  });

  test('applies the latest size once per frame and skips unchanged sizes', () => {
    const { term, fire, engage } = setup();
    engage(100);
    [120, 140, 200].forEach((distance) => fire('touchmove', pair(distance)));
    expect(jest.getTimerCount()).toBe(1);
    jest.runOnlyPendingTimers();
    expect(term.setFontSize).toHaveBeenCalledTimes(1);
    expect(term.setFontSize).toHaveBeenCalledWith(30);
    fire('touchmove', pair(201));
    jest.runOnlyPendingTimers();
    expect(term.setFontSize).toHaveBeenCalledTimes(1);
  });

  test('listens on the frame document in the capture phase', () => {
    const { doc } = setup();
    expect(doc.addEventListener).toHaveBeenCalledWith('touchmove',
      expect.any(Function), { capture: true, passive: false });
    ['touchstart', 'touchend', 'touchcancel'].forEach((type) => {
      expect(doc.addEventListener).toHaveBeenCalledWith(type,
        expect.any(Function), { capture: true, passive: true });
    });
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
    const { fire } = setup();
    expect(fire('touchmove', pair(200)).defaultPrevented).toBe(false);
  });

  test('keeps claiming moves until every finger lifts', () => {
    const { fire, engage } = setup();
    engage(100);
    fire('touchend', [finger(2, 100)]);
    expect(fire('touchmove', [finger(2, 100, 40)]).defaultPrevented).toBe(true);
    fire('touchend', []);
    fire('touchstart', [finger(3, 0)]);
    expect(fire('touchmove', [finger(3, 0, 40)]).defaultPrevented).toBe(false);
  });

  test('a third finger pauses the pinch and the remaining pair resumes from the current size',
    () => {
      const { term, fire, engage } = setup();
      engage(100);
      fire('touchmove', pair(200));
      fire('touchstart', [...pair(200), finger(3, 300)]);
      expect(term.getFontSize()).toBe(30);
      expect(fire('touchmove', [finger(1, 0), finger(2, 400), finger(3, 300)]).defaultPrevented)
        .toBe(true);
      expect(jest.getTimerCount()).toBe(0);
      fire('touchend', pair(400));
      expect(fire('touchmove', pair(400 + SLOP)).defaultPrevented).toBe(true);
      expect(term.getFontSize()).toBe(30);
      fire('touchmove', pair(210));
      jest.runOnlyPendingTimers();
      expect(term.getFontSize()).toBe(15);
    }
  );

  test.each(['touchend', 'touchcancel'])('%s applies the pending size', (type) => {
    const { term, fire, engage } = setup();
    engage(100);
    fire('touchmove', pair(200));
    fire(type, []);
    expect(term.getFontSize()).toBe(30);
    expect(fire('touchmove', pair(300)).defaultPrevented).toBe(false);
  });

  test('ignores coincident fingers', () => {
    const { term, fire, engage } = setup();
    fire('touchstart', pair(0));
    expect(fire('touchmove', pair(100)).defaultPrevented).toBe(false);
    fire('touchend', []);
    engage(100);
    fire('touchmove', pair(0));
    jest.runOnlyPendingTimers();
    expect(term.setFontSize).not.toHaveBeenCalled();
  });

  test('ignores a missing terminal screen', () => {
    const { term, shell } = setup();
    term.getDocument = () => ({ querySelector: () => null });
    expect(() => shell.installPinchZoom(term)).not.toThrow();
  });
});

describe('Resize messages', () => {
  // Like hterm, report the new column count from a timer.
  const reportResizes = ({ term, shell }) => {
    term.setFontSize.mockImplementation((size) => {
      term.fontSize = size;
      setTimeout(() => shell.onTerminalResize(Math.floor(600 / size), 24), 0);
    });
  };
  const sentColumns = (shell) =>
    shell.socket.send.mock.calls.map(([json]) => JSON.parse(json).resize.cols);

  test('are sent immediately outside a pinch', () => {
    const { shell } = setup();
    shell.onTerminalResize(80, 24);
    expect(shell.socket.send).toHaveBeenCalledWith(
      JSON.stringify({ resize: { cols: 80, rows: 24 } }));
  });

  test('are held during a pinch and the final size is sent once', () => {
    const context = setup();
    reportResizes(context);
    const { shell, fire, engage } = context;
    engage(100);
    [120, 150, 200].forEach((distance) => {
      fire('touchmove', pair(distance));
      jest.runAllTimers();
    });
    expect(shell.socket.send).not.toHaveBeenCalled();
    fire('touchend', []);
    jest.runAllTimers();
    expect(sentColumns(shell)).toEqual([20]);
  });

  test('include a step still pending when the fingers lift', () => {
    const context = setup();
    reportResizes(context);
    const { shell, fire, engage } = context;
    engage(100);
    fire('touchmove', pair(150));
    jest.runAllTimers();
    fire('touchmove', pair(200));
    fire('touchend', []);
    jest.runAllTimers();
    expect(sentColumns(shell)).toEqual([20]);
  });
});

describe('With hterm’s own touch handler', () => {
  const onTouch = loadHtermOnTouch();

  // Runs the document capture listener, then hterm's listener on x-screen.
  function gesture() {
    const context = setup();
    const scrollPort = {
      lastTouch_: {},
      screen_: { scrollTop: 500 },
      getScrollMax_: () => 1000,
      onTouch() {}
    };
    const down = new Map();
    const dispatch = (type, changedTouches) => {
      const event = { type, touches: [...down.values()], changedTouches,
        defaultPrevented: false, preventDefault() { this.defaultPrevented = true; } };
      context.listeners[type](event);
      onTouch.call(scrollPort, event);
      return event;
    };
    const place = (id, x, y) => {
      const touch = finger(id, x, y);
      down.set(id, touch);
      return touch;
    };
    return {
      ...context,
      scrollPort,
      start: (id, x, y) => dispatch('touchstart', [place(id, x, y)]),
      move: (moves) => dispatch('touchmove',
        Object.entries(moves).map(([id, [x, y]]) => place(Number(id), x, y))),
      end: (id) => {
        const touch = down.get(id);
        down.delete(id);
        return dispatch('touchend', [touch]);
      }
    };
  }

  test('one finger scrolls as before', () => {
    const { start, move, scrollPort } = gesture();
    start(1, 0, 100);
    move({ 1: [0, 130] });
    expect(scrollPort.screen_.scrollTop).toBe(470);
  });

  test('two fingers that keep their distance scroll as before', () => {
    const { start, move, scrollPort, term } = gesture();
    start(1, 0, 100);
    start(2, 100, 100);
    move({ 1: [0, 110], 2: [100, 110] });
    expect(scrollPort.screen_.scrollTop).toBe(480);
    expect(term.setFontSize).not.toHaveBeenCalled();
  });

  test('a pinch does not scroll, and the next swipe scrolls only by its own distance', () => {
    const { start, move, end, scrollPort, term } = gesture();
    start(1, 0, 100);
    start(2, 100, 100);
    move({ 2: [200, 300] });
    move({ 2: [300, 400] });
    jest.runOnlyPendingTimers();
    expect(term.getFontSize()).toBeGreaterThan(15);
    end(2);
    expect(move({ 1: [0, 160] }).defaultPrevented).toBe(true);
    expect(scrollPort.screen_.scrollTop).toBe(500);
    end(1);
    expect(scrollPort.lastTouch_).toEqual({});
    start(3, 0, 100);
    move({ 3: [0, 130] });
    expect(scrollPort.screen_.scrollTop).toBe(470);
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
