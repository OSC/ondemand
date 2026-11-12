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
//
// Updating the vendored hterm bundle: expect this suite to fail if
// ScrollPort.onTouch_ was renamed, moved or rewritten. That is deliberate.
// Check that the new handler still skips events that are already
// defaultPrevented and that hterm still listens for touches on x-screen
// rather than on the document or window, then update the lookup below.
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

// An element reduced to the listeners that were added to it.
function makeElement() {
  const listeners = {};
  return {
    isConnected: true,
    listeners,
    addEventListener: jest.fn((type, fn, options) => {
      (listeners[type] = listeners[type] || []).push({ fn, options });
    }),
    removeEventListener: jest.fn((type, fn) => {
      listeners[type] = (listeners[type] || []).filter((l) => l.fn !== fn);
    })
  };
}

// Dispatch synchronously so listener exceptions fail the test that caused them.
//
// Events are routed like a browser routes touches: the document's capture
// listeners, then the listeners on the element the touch landed on, then
// hterm's on x-screen. A touch keeps sending events to the element it landed
// on, but once that element has left the document, the document and x-screen
// no longer see them.
function setup({ fontSize = 15, hterm = null } = {}) {
  const doc = makeElement();
  const rows = [makeElement(), makeElement()];
  const term = {
    fontSize,
    getFontSize() { return this.fontSize; },
    setFontSize: jest.fn((size) => { term.fontSize = size; }),
    getDocument: () => doc
  };
  const OodShell = loadOodShell({});
  const shell = new OodShell({}, 'ws://localhost', 'default');
  shell.socket = { send: jest.fn() };
  shell.installPinchZoom(term);

  const fire = (type, touches, { target = rows[0], changed } = {}) => {
    const event = {
      type, touches, target, defaultPrevented: false, cancelable: true,
      changedTouches: changed ||
        (type === 'touchstart' ? [{ ...touches[touches.length - 1], target }] : []),
      preventDefault() { this.defaultPrevented = true; }
    };
    const run = (element) => (element.listeners[type] || []).slice()
      .forEach((listener) => listener.fn(event));
    if (target.isConnected) {
      run(doc);
    }
    run(target);
    if (target.isConnected && hterm) {
      hterm(event);
    }
    return event;
  };
  // Put fingers down one at a time, as a hand does.
  const land = (touches, options) => touches.forEach((_, i) =>
    fire('touchstart', touches.slice(0, i + 1), options));
  // Land two fingers SLOP further apart than `start`, then pinch through the
  // dead zone so that the size is measured from `start`.
  const engage = (start) => {
    land(pair(start + SLOP));
    return fire('touchmove', pair(start));
  };
  return { term, shell, doc, rows, fire, land, engage };
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
      expect(term.getFontSize()).toBe(size);
    }
  );

  test('two-finger moves inside the dead zone are left to hterm', () => {
    const { term, fire, land } = setup();
    land(pair(100));
    expect(fire('touchmove', pair(100 + SLOP - 1)).defaultPrevented).toBe(false);
    expect(fire('touchmove', [finger(1, 0, 50), finger(2, 100, 50)]).defaultPrevented)
      .toBe(false);
    expect(term.setFontSize).not.toHaveBeenCalled();
  });

  test('the dead zone is measured from where the fingers landed, so a pause does not reset it',
    () => {
      const { fire, land } = setup();
      land(pair(100));
      expect(fire('touchmove', pair(100 + SLOP - 1)).defaultPrevented).toBe(false);
      expect(fire('touchmove', pair(100 + SLOP - 1)).defaultPrevented).toBe(false);
      expect(fire('touchmove', pair(100 + 2 * (SLOP - 1))).defaultPrevented).toBe(true);
    }
  );

  test('leaving the dead zone claims the move without changing the size', () => {
    const { term, engage } = setup();
    expect(engage(100).defaultPrevented).toBe(true);
    expect(term.setFontSize).not.toHaveBeenCalled();
  });

  test('sets the size only when the rounded size changes', () => {
    const { term, fire, engage } = setup();
    engage(100);
    fire('touchmove', pair(120));
    expect(term.setFontSize).toHaveBeenCalledTimes(1);
    expect(term.setFontSize).toHaveBeenCalledWith(18);
    fire('touchmove', pair(121));
    expect(term.setFontSize).toHaveBeenCalledTimes(1);
    fire('touchmove', pair(200));
    expect(term.setFontSize).toHaveBeenCalledTimes(2);
    expect(term.setFontSize).toHaveBeenLastCalledWith(30);
  });

  test.each([[[finger(1, 0)]], [[...pair(100), finger(3, 300)]]])(
    'leaves a non-pinch touch list alone: %j', (touches) => {
      const { term, fire, land } = setup();
      land(touches);
      expect(fire('touchmove', touches).defaultPrevented).toBe(false);
      expect(term.getFontSize()).toBe(15);
    }
  );

  test('keeps claiming moves until every finger lifts', () => {
    const { fire, land, engage } = setup();
    engage(100);
    fire('touchend', [finger(2, 100)]);
    expect(fire('touchmove', [finger(2, 100, 40)]).defaultPrevented).toBe(true);
    fire('touchend', []);
    land([finger(3, 0)]);
    expect(fire('touchmove', [finger(3, 0, 40)]).defaultPrevented).toBe(false);
  });

  // Phones send touchcancel when the system takes over a finger, such as an
  // edge swipe, and the other finger may still be down.
  test('a cancelled finger leaves the gesture claimed until the last finger lifts', () => {
    const { fire, land, engage } = setup();
    engage(100);
    fire('touchcancel', [finger(2, 100)]);
    expect(fire('touchmove', [finger(2, 100, 40)]).defaultPrevented).toBe(true);
    fire('touchend', []);
    land([finger(3, 0)]);
    expect(fire('touchmove', [finger(3, 0, 40)]).defaultPrevented).toBe(false);
  });

  test('a third finger pauses the pinch and the remaining pair carries on from the current size',
    () => {
      const { term, fire, engage } = setup();
      engage(100);
      fire('touchmove', pair(200));
      fire('touchstart', [...pair(200), finger(3, 300)]);
      expect(term.getFontSize()).toBe(30);
      const sets = term.setFontSize.mock.calls.length;
      expect(fire('touchmove', [finger(1, 0), finger(2, 400), finger(3, 300)]).defaultPrevented)
        .toBe(true);
      expect(term.setFontSize).toHaveBeenCalledTimes(sets);
      fire('touchend', pair(400));
      // No second dead zone: the pair measures from where it is.
      expect(fire('touchmove', pair(200)).defaultPrevented).toBe(true);
      expect(term.getFontSize()).toBe(15);
    }
  );

  test('ignores coincident fingers', () => {
    const { term, fire, land, engage } = setup();
    land(pair(0));
    expect(fire('touchmove', pair(100)).defaultPrevented).toBe(false);
    fire('touchend', []);
    engage(100);
    fire('touchmove', pair(0));
    expect(term.setFontSize).toHaveBeenCalledTimes(0);
  });

  describe('listeners', () => {
    test('the document gets only touchstart', () => {
      const { doc } = setup();
      expect(doc.addEventListener).toHaveBeenCalledTimes(1);
      expect(doc.addEventListener).toHaveBeenCalledWith('touchstart',
        expect.any(Function), { capture: true, passive: true });
    });

    test('the rest go on the touched element, and only touchmove is non-passive', () => {
      const { rows, land } = setup();
      land(pair(100));
      expect(rows[0].addEventListener).toHaveBeenCalledTimes(3);
      expect(rows[0].addEventListener).toHaveBeenCalledWith('touchmove',
        expect.any(Function), { capture: true, passive: false });
      ['touchend', 'touchcancel'].forEach((type) => {
        expect(rows[0].addEventListener).toHaveBeenCalledWith(type,
          expect.any(Function), { capture: true, passive: true });
      });
      expect(rows[1].addEventListener).not.toHaveBeenCalled();
    });

    test('fingers on different rows are each followed', () => {
      const { term, rows, fire } = setup();
      fire('touchstart', [finger(1, 0)], { target: rows[0] });
      fire('touchstart', pair(100 + SLOP), { target: rows[1] });
      expect(rows[0].addEventListener).toHaveBeenCalledTimes(3);
      expect(rows[1].addEventListener).toHaveBeenCalledTimes(3);
      fire('touchmove', pair(100), { target: rows[1] });
      fire('touchmove', pair(200), { target: rows[0] });
      expect(term.getFontSize()).toBe(30);
    });

    test('are removed when the last finger lifts', () => {
      const { rows, fire, land, engage } = setup();
      engage(100);
      fire('touchend', [finger(2, 100)]);
      expect(rows[0].removeEventListener).not.toHaveBeenCalled();
      fire('touchend', []);
      expect(rows[0].removeEventListener).toHaveBeenCalledTimes(3);
      expect(Object.values(rows[0].listeners).flat()).toEqual([]);
      land([finger(3, 0)]);
      expect(rows[0].addEventListener).toHaveBeenCalledTimes(6);
    });
  });

  // hterm rebuilds its rows when the font size changes, so the row a finger
  // landed on can leave the document mid-pinch. Its events then stop reaching
  // the document and x-screen, and only listeners on the row itself see them.
  describe('when hterm removes the touched row', () => {
    const sentColumns = (shell) =>
      shell.socket.send.mock.calls.map(([json]) => JSON.parse(json).resize.cols);

    test('the pinch carries on and ends cleanly', () => {
      const { term, shell, rows, fire, land, engage } = setup();
      engage(100);
      fire('touchmove', pair(150));
      rows[0].isConnected = false;
      fire('touchmove', pair(200));
      expect(term.getFontSize()).toBe(30);
      fire('touchend', [finger(2, 200)]);
      expect(fire('touchmove', [finger(2, 200, 40)]).defaultPrevented).toBe(true);
      fire('touchend', []);
      expect(shell.resizeHeld).toBe(false);

      rows[0].isConnected = true;
      land([finger(3, 0)]);
      expect(fire('touchmove', [finger(3, 0, 40)]).defaultPrevented).toBe(false);
    });

    test('the terminal size is still sent once, when the fingers lift', () => {
      const { term, shell, rows, fire, engage } = setup();
      term.setFontSize.mockImplementation((size) => {
        term.fontSize = size;
        setTimeout(() => shell.onTerminalResize(Math.floor(600 / size), 24), 0);
      });
      engage(100);
      fire('touchmove', pair(150));
      jest.runAllTimers();
      rows[0].isConnected = false;
      fire('touchmove', pair(200));
      jest.runAllTimers();
      expect(shell.socket.send).not.toHaveBeenCalled();
      fire('touchend', []);
      expect(sentColumns(shell)).toEqual([20]);
    });
  });
});

describe('Resize messages', () => {
  // Like hterm, report the new column count from a timer.
  const reportResizes = ({ term, shell }, delay = 0) => {
    term.setFontSize.mockImplementation((size) => {
      term.fontSize = size;
      setTimeout(() => shell.onTerminalResize(Math.floor(600 / size), 24), delay);
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
    expect(sentColumns(shell)).toEqual([20]);
  });

  // This hterm reports before the fingers lift, but a slower report must still
  // reach the server. An earlier held size may be sent first.
  test('include a size reported after the fingers lift', () => {
    const context = setup();
    reportResizes(context, 50);
    const { shell, fire, engage } = context;
    engage(100);
    fire('touchmove', pair(150));
    jest.runAllTimers();
    fire('touchmove', pair(200));
    fire('touchend', []);
    jest.runAllTimers();
    expect(sentColumns(shell).at(-1)).toBe(20);
  });

  test('a second pinch is held and sent on its own', () => {
    const context = setup();
    reportResizes(context);
    const { shell, fire, engage } = context;
    engage(100);
    fire('touchmove', pair(200));
    jest.runAllTimers();
    fire('touchend', []);
    expect(sentColumns(shell)).toEqual([20]);
    engage(100);
    fire('touchmove', pair(50));
    jest.runAllTimers();
    expect(sentColumns(shell)).toEqual([20]);
    fire('touchend', []);
    expect(sentColumns(shell)).toEqual([20, 40]);
  });
});

describe('With hterm’s own touch handler', () => {
  const onTouch = loadHtermOnTouch();

  function gesture() {
    const scrollPort = {
      lastTouch_: {},
      screen_: { scrollTop: 500 },
      getScrollMax_: () => 1000,
      onTouch() {}
    };
    const context = setup({ hterm: (event) => onTouch.call(scrollPort, event) });
    const down = new Map();
    const place = (id, x, y) => {
      const touch = { ...finger(id, x, y), target: context.rows[0] };
      down.set(id, touch);
      return touch;
    };
    const dispatch = (type, changed) =>
      context.fire(type, [...down.values()], { changed });
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
