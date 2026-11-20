'use strict';
const fs = require('fs');
const path = require('path');
const vm = require('vm');

const source = fs.readFileSync(path.join(__dirname, '..', 'public', 'javascripts', 'ood_shell.2.js'), 'utf8');

function setup(enabled = true) {
  const listeners = {};
  const input = { value: '' };
  const form = {
    hidden: true,
    elements: { namedItem: () => input },
    addEventListener: (name, handler) => { listeners[name] = handler; },
    reset: () => { input.value = ''; }
  };
  const container = { querySelector: () => form };
  const context = vm.createContext({ WebSocket: { OPEN: 1 }, window: {} });
  vm.runInContext(source, context);
  const shell = new context.OodShell(container, '', '', enabled);
  shell.socket = { readyState: 1, send: jest.fn() };
  shell.term = { onPasteData_: jest.fn(), io: { print: jest.fn() } };
  shell.installTextComposer();
  const submit = () => {
    const event = { preventDefault: jest.fn() };
    listeners.submit(event);
    expect(event.preventDefault).toHaveBeenCalled();
  };
  return { shell, input, form, submit };
}

test('opens the opt-in composer without changing normal terminal input', () => {
  const { shell, input, form } = setup(false);
  expect(form.hidden).toBe(true);
  shell.setPredictiveText(true);
  expect(form.hidden).toBe(false);
  shell.onVTKeystroke('password');
  expect(shell.socket.send).toHaveBeenCalledWith(JSON.stringify({ input: 'password' }));
  expect(input.value).toBe('');
});

test('sends the finished text once through hterm paste and clears it', () => {
  const { shell, input, submit } = setup();
  input.value = 'teh';
  input.value = 'the “text”';
  expect(shell.term.onPasteData_).not.toHaveBeenCalled();
  submit();
  expect(shell.term.onPasteData_).toHaveBeenCalledTimes(1);
  expect(shell.term.onPasteData_).toHaveBeenCalledWith('the “text”');
  expect(input.value).toBe('');
  submit();
  expect(shell.term.onPasteData_).toHaveBeenCalledTimes(1);
});

test('disabling the composer discards unsent text', () => {
  const { shell, input, form, submit } = setup();
  input.value = 'unsent';
  shell.setPredictiveText(false);
  expect(form.hidden).toBe(true);
  expect(input.value).toBe('');
  submit();
  expect(shell.term.onPasteData_).not.toHaveBeenCalled();
});

test('closing the WebSocket blocks submission and discards the draft on close', () => {
  const { shell, input, form, submit } = setup();
  input.value = 'unsent';
  shell.socket.readyState = 2;
  submit();
  expect(shell.term.onPasteData_).not.toHaveBeenCalled();
  shell.socket.readyState = 3;
  shell.closeTerminal({ code: 1000 });
  expect(form.hidden).toBe(true);
  expect(input.value).toBe('');
});
