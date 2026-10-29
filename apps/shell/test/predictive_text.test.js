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
function loadOodShell() {
  const context = vm.createContext({});
  vm.runInContext(fs.readFileSync(SOURCE, 'utf8'), context);
  return context.OodShell;
}

/**
 * Build an OodShell attached to a fake hterm terminal whose input element
 * starts with hterm's defaults (autocorrect off, autocapitalize none). `calls`
 * records every attribute write and focus change, in order.
 */
function setup({ focused = false } = {}) {
  const calls = [];
  const attributes = {
    autocorrect: 'off',
    autocapitalize: 'none',
    spellcheck: 'false',
    autocomplete: 'off'
  };
  const screen = {
    getAttribute: (name) => attributes[name],
    setAttribute: (name, value) => {
      attributes[name] = value;
      calls.push(`set ${name}=${value}`);
    }
  };
  const termDocument = { querySelector: () => screen, activeElement: focused ? screen : null };
  const term = {
    getDocument: () => termDocument,
    blur: () => calls.push('blur'),
    focus: () => calls.push('focus')
  };

  const OodShell = loadOodShell();
  const shell = new OodShell({}, 'ws://localhost', 'default');
  shell.term = term;

  return { OodShell, shell, term, termDocument, attributes, calls };
}

describe('Predictive text', () => {
  test('is off unless asked for', () => {
    const { OodShell } = setup();

    expect(new OodShell({}, 'ws://localhost', 'default').predictiveText).toBe(false);
    expect(new OodShell({}, 'ws://localhost', 'default', true).predictiveText).toBe(true);
  });

  test('turns on word suggestions without touching spellcheck or autocomplete', () => {
    const { shell, attributes } = setup();
    shell.setPredictiveText(true);

    expect(attributes).toEqual({
      autocorrect: 'on',
      autocapitalize: 'sentences',
      spellcheck: 'false',
      autocomplete: 'off'
    });
  });

  test('turns word suggestions back off', () => {
    const { shell, attributes } = setup();
    shell.setPredictiveText(true);
    shell.setPredictiveText(false);

    expect(attributes.autocorrect).toBe('off');
    expect(attributes.autocapitalize).toBe('none');
  });

  test('refocuses a focused terminal so the keyboard re-reads the attributes', () => {
    const { shell, calls } = setup({ focused: true });
    shell.setPredictiveText(true);

    expect(calls).toEqual([
      'set autocorrect=on',
      'set autocapitalize=sentences',
      'blur',
      'focus'
    ]);
  });

  test('does not focus a terminal that was not focused', () => {
    const { shell, calls } = setup({ focused: false });
    shell.setPredictiveText(true);

    expect(calls).not.toContain('focus');
    expect(calls).not.toContain('blur');
  });

  test('does nothing when the setting is already applied', () => {
    const { shell, calls } = setup({ focused: true });
    shell.setPredictiveText(false);

    expect(calls).toEqual([]);
  });

  test('remembers the setting if the terminal does not exist yet', () => {
    const { shell } = setup();
    shell.term = null;

    expect(() => shell.setPredictiveText(true)).not.toThrow();
    expect(shell.predictiveText).toBe(true);
  });

  test('remembers the setting if the terminal has no input element yet', () => {
    const { shell, termDocument, calls } = setup();
    termDocument.querySelector = () => null;

    expect(() => shell.setPredictiveText(true)).not.toThrow();
    expect(shell.predictiveText).toBe(true);
    expect(calls).toEqual([]);
  });
});

/**
 * Start a terminal the way the page does (runTerminal, then hterm calling
 * onTerminalReady) against fake hterm objects, and return the input element's
 * attributes. The touch features are stubbed out because they have their own
 * tests and this one is only about the predictive text wiring.
 */
function startTerminal(predictiveText) {
  const attributes = { autocorrect: 'off', autocapitalize: 'none' };
  const screen = {
    getAttribute: (name) => attributes[name],
    setAttribute: (name, value) => { attributes[name] = value; },
    addEventListener() {}
  };
  const termDocument = { querySelector: () => screen, activeElement: null };

  class FakeTerminal {
    constructor() {
      this.options_ = {};
      this.io = { push: () => ({}) };
    }
    decorate() {}
    setAccessibilityEnabled() {}
    installKeyboard() {}
    getDocument() { return termDocument; }
  }

  const context = vm.createContext({
    hterm: { Terminal: FakeTerminal },
    window: {},
    navigator: { maxTouchPoints: 0 }
  });
  vm.runInContext(fs.readFileSync(SOURCE, 'utf8'), context);
  const OodShell = context.OodShell;
  ['installTouchKeyboard', 'installMobileSelection', 'installPinchZoom'].forEach((name) => {
    if (OodShell.prototype[name]) {
      OodShell.prototype[name] = () => {};
    }
  });

  const shell = new OodShell({}, 'ws://localhost', 'default', predictiveText);
  shell.runTerminal();
  // hterm calls onTerminalReady with the terminal as `this`.
  shell.term.onTerminalReady();
  return attributes;
}

describe('Terminal start-up', () => {
  test('applies a saved predictive text preference once the terminal is ready', () => {
    expect(startTerminal(true)).toMatchObject({ autocorrect: 'on', autocapitalize: 'sentences' });
  });

  test('keeps hterm\'s defaults when predictive text is off', () => {
    expect(startTerminal(false)).toMatchObject({ autocorrect: 'off', autocapitalize: 'none' });
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
