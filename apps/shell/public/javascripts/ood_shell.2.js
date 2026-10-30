// Object that defines a terminal element
function OodShell(element, url, profile, predictiveText) {
  this.element = element;
  this.url     = url;
  this.profile   = profile || "default";
  this.predictiveText = !!predictiveText;
  this.socket  = null;
  this.term    = null;
  // While predictive text is on, keyboard input goes to this <textarea>
  // instead of hterm's screen (see installInputProxy).
  this.inputProxy = null;
  this.inputProxyComposing = false;
  this.typedLine = new OodShell.TypedLine();
}

OodShell.prototype.createTerminal = function () {
  this.installVisualViewportSizing();
  this.socket = new WebSocket(this.url);
  this.socket.onopen    = this.runTerminal.bind(this);
  this.socket.onmessage = this.getMessage.bind(this);
  this.socket.onclose   = this.closeTerminal.bind(this);
};


OodShell.prototype.runTerminal = function () {
  const that = this;

  // Create an instance of hterm.Terminal
  this.term = new hterm.Terminal({ profileId: this.profile });

  // Handler that fires when terminal is initialized and ready for use
  this.term.onTerminalReady = function () {
    // Create a new terminal IO object and give it the foreground.
    // (The default IO object just prints warning messages about unhandled
    // things to the JS console.)
    const io = this.io.push();

    // Set up event handlers for io
    io.onVTKeystroke    = that.onVTKeystroke.bind(that);
    io.sendString       = that.sendString.bind(that);
    io.onTerminalResize = that.onTerminalResize.bind(that);

    // Capture all keyboard input
    this.installKeyboard();

    // hterm prevents Safari's normal tap-to-focus by preventing touch defaults.
    that.installTouchKeyboard(this);

    // Apply the saved predictive text preference to the terminal's input.
    that.setPredictiveText(that.predictiveText);
  };

  // Patch cursor setting
  this.term.options_.cursorVisible = true;

  // Connect terminal to sacrificial DOM node
  this.term.decorate(this.element);
  this.term.setAccessibilityEnabled(true);

  // Warn user if he/she unloads page
  window.onbeforeunload = function() {
    return 'Leaving this page will terminate your terminal session.';
  };
};

// This depends on hterm using a contenteditable x-screen with non-capture
// touch handlers that call preventDefault(). Re-test after hterm touch changes.
OodShell.prototype.installTouchKeyboard = function (term) {
  const shell = this;
  const screen = term.getDocument().querySelector('x-screen');
  let touchStart = null;
  // Capture observes the gesture before hterm's non-capture handler calls
  // preventDefault(); passive leaves hterm responsible for touch scrolling.
  const touchOptions = { passive: true, capture: true };
  // Apple/WebKit can leave contenteditable focused after dismissing the
  // software keyboard; use a capability check rather than UA sniffing.
  const needsTouchFocusRefresh = navigator.maxTouchPoints > 0 &&
                                 typeof CSS !== 'undefined' &&
                                 typeof CSS.supports === 'function' &&
                                 CSS.supports('-webkit-touch-callout', 'none');
  if (!screen) {
    return;
  }

  screen.addEventListener('touchstart', function (ev) {
    if (ev.touches.length !== 1) {
      touchStart = null;
      return;
    }
    const touch = ev.touches[0];
    touchStart = {
      x: touch.clientX,
      y: touch.clientY,
      time: ev.timeStamp
    };
  }, touchOptions);

  screen.addEventListener('touchmove', function (ev) {
    if (touchStart === null) {
      return;
    }
    if (ev.touches.length !== 1) {
      touchStart = null;
      return;
    }

    const touch = ev.touches[0];
    const dx = touch.clientX - touchStart.x;
    const dy = touch.clientY - touchStart.y;
    if ((dx * dx + dy * dy) > 100) {
      touchStart = null;
    }
  }, touchOptions);

  screen.addEventListener('touchend', function (ev) {
    if (touchStart === null) {
      return;
    }
    if (ev.touches.length !== 0 || ev.changedTouches.length !== 1) {
      touchStart = null;
      return;
    }

    const touch = ev.changedTouches[0];
    const dx = touch.clientX - touchStart.x;
    const dy = touch.clientY - touchStart.y;
    const duration = ev.timeStamp - touchStart.time;
    // Safari requires focus to remain synchronous with the user gesture.
    if ((dx * dx + dy * dy) <= 100 && duration < 500) {
      // WebKit may need a fresh focus transition after keyboard dismissal.
      shell.focusInput(needsTouchFocusRefresh);
    }

    touchStart = null;
  }, touchOptions);
  screen.addEventListener('touchcancel', function () {
    touchStart = null;
  }, touchOptions);
};

OodShell.prototype.installVisualViewportSizing = function () {
  const viewport = window.visualViewport;
  const element = this.element;
  let resizeFrame = null;
  let lastHeight = null;

  if (!viewport) {
    return;
  }

  const resize = function () {
    if (resizeFrame !== null) {
      return;
    }

    resizeFrame = window.requestAnimationFrame(function () {
      // scale preserves layout-space height during pinch zoom; WebKit may
      // introduce small precision differences in height * scale.
      const height = Math.round(viewport.height * viewport.scale);

      if (height > 0 && height !== lastHeight) {
        element.style.height = height + 'px';
        lastHeight = height;
      }
      resizeFrame = null;
    });
  };

  resize();
  viewport.addEventListener('resize', resize);
  viewport.addEventListener('scroll', resize);
  window.addEventListener('resize', resize);
};

OodShell.prototype.getMessage = function (ev) {
  this.term.io.print(ev.data);
}

OodShell.prototype.closeTerminal = function (ev) {
  let errorDiv;

  // Do not need to warn user if he/she unloads page
  window.onbeforeunload = null;

  // Inform user they lost connection
  if ( this.term === null ) {
    errorDiv = document.createElement('div');
    errorDiv.className = 'error';
    errorDiv.innerHTML = 'Failed to establish a websocket connection. Be sure you are using a browser that supports websocket connections.';
    this.element.appendChild(errorDiv);
  } else if (ev.code === 3146) {
    document.querySelector('iframe').remove();
    errorDiv = document.createElement('div');
    errorDiv.className = 'error';
    errorDiv.innerHTML = ev.reason;
    this.element.appendChild(errorDiv);
  } else {
    this.term.io.print('\r\nYour connection to the remote server has been terminated.');
  }
}

OodShell.prototype.onVTKeystroke = function (str) {
  // Do something useful with str here.
  // For example, Secure Shell forwards the string onto the NaCl plugin.
  this.socket.send(JSON.stringify({
    input: str
  }));
};

OodShell.prototype.sendString = function (str) {
  // Just like a keystroke, except str was generated by the
  // terminal itself.
  // Most likely you'll do the same this as onVTKeystroke.
  this.onVTKeystroke(str)
};

OodShell.prototype.changeTheme = function (theme) {
  this.term.setProfile(theme);
}

/**
 * Turns the on-screen keyboard's word suggestions on or off.
 *
 * hterm takes keystrokes on a contenteditable <x-screen> but never lets the
 * typed text into it, so even with autocorrect allowed there the keyboard sees
 * no words before the caret and has nothing to predict from or correct. With
 * predictive text on, input goes to a real textarea instead (see
 * installInputProxy). hterm's screen keeps its autocorrect-off settings and
 * takes input exactly as before when this is off.
 */
OodShell.prototype.setPredictiveText = function (enabled) {
  this.predictiveText = !!enabled;

  // Before the terminal is ready there is nothing to attach to;
  // onTerminalReady applies the setting once there is.
  const termDocument = this.term && this.term.getDocument();
  if (!termDocument || !termDocument.body) {
    return;
  }

  const screen = termDocument.querySelector('x-screen');
  const active = termDocument.activeElement;
  const wasFocused = !!active &&
                     (active === screen || active === this.inputProxy);

  if (this.predictiveText) {
    this.installInputProxy();
  }
  if (this.inputProxy) {
    this.resetInputProxy();
    if (!this.predictiveText) {
      // Hiding a focused element doesn't reliably fire blur.
      this.inputProxy.blur();
    }
    this.inputProxy.style.display = this.predictiveText ? '' : 'none';
  }

  // Hand the keyboard to whichever element takes input now. Mobile WebKit
  // only re-reads keyboard settings on a fresh focus transition, and the
  // checkbox calls this inside the user's tap so the keyboard can stay up.
  if (wasFocused) {
    this.focusInput(true);
  }
};

/** The input proxy while it is the element taking input, otherwise null. */
OodShell.prototype.activeInputProxy = function () {
  return this.predictiveText ? this.inputProxy : null;
};

/**
 * Focuses whichever element takes keyboard input. With refresh set, an element
 * that already has focus is blurred first: Apple/WebKit can leave it focused
 * after the software keyboard is dismissed, and only a fresh focus brings the
 * keyboard back.
 */
OodShell.prototype.focusInput = function (refresh) {
  const termDocument = this.term.getDocument();
  const proxy = this.activeInputProxy();
  if (proxy) {
    if (refresh && termDocument.activeElement === proxy) {
      proxy.blur();
    }
    proxy.focus();
    return;
  }

  if (refresh &&
      termDocument.activeElement === termDocument.querySelector('x-screen')) {
    this.term.blur();
  }
  this.term.focus();
};

/**
 * Creates the textarea that takes keyboard input while predictive text is on.
 *
 * Keyboards predict from, autocorrect, and replace words in the text before
 * the caret of a real text field. This textarea holds the current line as the
 * user typed it, the browser edits it natively (typing, autocorrections,
 * tapped suggestions, dictation, deleting by word), and after each edit
 * sendInputProxyEdits sends the shell the keystrokes that make its line match.
 *
 * It sits invisibly at the terminal cursor, so the page scrolls to the right
 * place when the keyboard opens, and ignores pointer events so touches and
 * clicks still reach hterm.
 */
OodShell.prototype.installInputProxy = function () {
  if (this.inputProxy) {
    return this.inputProxy;
  }

  const shell = this;
  const term = this.term;
  const termDocument = term.getDocument();
  const screen = termDocument.querySelector('x-screen');
  const proxy = termDocument.createElement('textarea');
  this.inputProxy = proxy;

  proxy.className = 'ood-shell-input-proxy';
  proxy.setAttribute('aria-label', 'Terminal input');
  proxy.setAttribute('rows', '1');
  proxy.setAttribute('autocorrect', 'on');
  // Commands are mostly lowercase, and the line starts over after each Enter.
  proxy.setAttribute('autocapitalize', 'none');
  // Since iOS 15, turning spell checking off is how a field hides the
  // suggestion bar. Nothing gets underlined because nothing here is visible.
  proxy.setAttribute('spellcheck', 'true');
  proxy.setAttribute('autocomplete', 'off');
  // Inline predictions would be invisible here, and the next space would
  // accept them.
  proxy.setAttribute('writingsuggestions', 'false');
  proxy.style.cssText = [
    'position: absolute',
    'left: calc(var(--hterm-screen-padding-size) + ' +
      'var(--hterm-charsize-width) * var(--hterm-cursor-offset-col))',
    'top: calc(var(--hterm-screen-padding-size) + ' +
      'var(--hterm-charsize-height) * var(--hterm-cursor-offset-row))',
    'width: var(--hterm-charsize-width)',
    'height: var(--hterm-charsize-height)',
    'margin: 0',
    'padding: 0',
    'border: 0',
    'outline: none',
    'resize: none',
    'overflow: hidden',
    'white-space: pre',
    'opacity: 0',
    'color: transparent',
    'background: transparent',
    'caret-color: transparent',
    // iOS zooms the page in when a field with smaller text is focused.
    'font-size: 16px',
    'pointer-events: none'
  ].join('; ');
  termDocument.body.appendChild(proxy);

  // hterm's keyboard handlers sit on the document body and would see these
  // events as they bubble. Text keys stop here and edit the textarea; every
  // other key carries on to hterm, which sends it and prevents the default.
  // The keypress that follows a keydown goes the same way.
  let route = 'text';
  proxy.addEventListener('keydown', function (ev) {
    route = shell.routeInputProxyKey(ev);
    if (route === 'text') {
      ev.stopPropagation();
    } else if (route === 'command') {
      // Enter, arrows, Tab, Ctrl+key and the like change the shell's line in
      // ways the textarea can't follow, so the typed line starts over.
      shell.resetInputProxy();
    }
  });
  proxy.addEventListener('keypress', function (ev) {
    if (route === 'text') {
      ev.stopPropagation();
    }
  });
  // hterm would send this text itself; the input listener sends it instead.
  proxy.addEventListener('textInput', function (ev) {
    ev.stopPropagation();
  });

  proxy.addEventListener('beforeinput', function (ev) {
    if (ev.inputType === 'insertLineBreak' ||
        ev.inputType === 'insertParagraph') {
      // Return from a keyboard that didn't send an Enter keydown.
      ev.preventDefault();
      shell.resetInputProxy();
      term.onVTKeystroke('\r');
    } else if (ev.inputType === 'deleteContentBackward' &&
               proxy.selectionEnd === 0) {
      // Backspace with nothing left in the textarea deletes what the shell
      // had before it.
      ev.preventDefault();
      term.onVTKeystroke(shell.lineEditingKeys().backspace);
    }
  });
  proxy.addEventListener('input', function (ev) {
    // Text being composed in an IME is sent once it is committed.
    if (!shell.inputProxyComposing && !ev.isComposing) {
      shell.sendInputProxyEdits();
    }
  });
  proxy.addEventListener('compositionstart', function () {
    shell.inputProxyComposing = true;
  });
  proxy.addEventListener('compositionend', function () {
    shell.inputProxyComposing = false;
    shell.sendInputProxyEdits();
  });

  proxy.addEventListener('paste', function (ev) {
    ev.preventDefault();
    const text = ev.clipboardData ? ev.clipboardData.getData('text/plain') : '';
    shell.resetInputProxy();
    if (!text) {
      return;
    }
    if (typeof term.onPasteData_ === 'function') {
      // The same path as pasting onto hterm's screen, so bracketed paste
      // still applies.
      term.onPasteData_(text);
    } else {
      term.onVTKeystroke(text.replace(/\r\n|\n/g, '\r'));
    }
  });

  proxy.addEventListener('focus', function () {
    // Start with the caret where the shell's cursor is.
    const offset = Array.from(proxy.value)
      .slice(0, shell.typedLine.caret).join('').length;
    proxy.setSelectionRange(offset, offset);
    shell.onInputProxyFocusChange(true);
  });
  proxy.addEventListener('blur', function () {
    shell.onInputProxyFocusChange(false);
  });

  // Dragging across the iOS space bar moves the caret without an edit; move
  // the shell's cursor with it.
  termDocument.addEventListener('selectionchange', function () {
    if (termDocument.activeElement === proxy) {
      shell.followInputProxyCaret();
    }
  });

  // hterm's screen still gets focus in places (a mouse click, after a paste,
  // when the find bar closes). Pass it on to the textarea once any selecting
  // is over, unless that left text selected for the user to copy. None of
  // these need to keep a touch gesture: taps focus the textarea directly.
  const reclaimFocus = function () {
    if (shell.activeInputProxy() !== proxy ||
        termDocument.activeElement !== screen) {
      return;
    }
    const selection = termDocument.getSelection();
    if (selection && !selection.isCollapsed) {
      return;
    }
    proxy.focus();
  };
  let mouseDown = false;
  termDocument.addEventListener('mousedown', function () {
    mouseDown = true;
  }, true);
  termDocument.addEventListener('mouseup', function () {
    mouseDown = false;
    reclaimFocus();
  }, true);
  termDocument.addEventListener('focus', function (ev) {
    if (ev.target === screen && !mouseDown) {
      setTimeout(reclaimFocus);
    }
  }, true);

  return proxy;
};

OodShell.prototype.onInputProxyFocusChange = function (focused) {
  const term = this.term;
  // hterm moves the document selection to its cursor whenever it redraws,
  // which would pull the selection, and with it the keyboard's context, out
  // of the textarea. It skips that while its find bar's input has focus; this
  // textarea needs the same.
  if (term.findBar) {
    term.findBar.hasFocus = focused;
  }
  // Draw the cursor as focused or not, as hterm does for its own screen.
  if (typeof term.onFocusChange_ === 'function') {
    term.onFocusChange_(focused);
  }
};

OodShell.MODIFIER_KEYS = [
  'Alt', 'AltGraph', 'CapsLock', 'Control', 'Fn', 'Meta', 'OS', 'Shift'
];

/**
 * Decides who handles a keydown on the input proxy:
 *   'text'    the textarea edits itself and sendInputProxyEdits sends the
 *             result (characters, Backspace, and anything an IME is handling);
 *   'command' hterm sends it and the typed line starts over (Enter, arrows,
 *             Tab, Escape, function keys, Ctrl/Alt/Meta combinations, keypad);
 *   'hterm'   hterm handles it and the typed line stays (modifier keys, and
 *             Backspace with nothing before the caret).
 */
OodShell.prototype.routeInputProxyKey = function (ev) {
  const key = ev.key || '';

  if (ev.isComposing || ev.keyCode === 229 ||
      key === 'Process' || key === 'Dead' || key === 'Unidentified') {
    return 'text';
  }
  if (OodShell.MODIFIER_KEYS.indexOf(key) !== -1) {
    return 'hterm';
  }

  const altGraph = typeof ev.getModifierState === 'function' &&
                   ev.getModifierState('AltGraph');
  if ((ev.ctrlKey || ev.altKey || ev.metaKey) && !altGraph) {
    return 'command';
  }
  // hterm knows whether the keypad is in application mode.
  if (ev.location === 3) {
    return 'command';
  }
  if (key === 'Backspace') {
    return this.inputProxy.selectionEnd > 0 ? 'text' : 'hterm';
  }
  if (Array.from(key).length === 1) {
    return 'text';
  }
  return 'command';
};

/** What the shell's line editor expects for these keys, per hterm's settings. */
OodShell.prototype.lineEditingKeys = function () {
  const keyboard = this.term.keyboard || {};
  const cursorKey = keyboard.applicationCursor ? '\x1bO' : '\x1b[';
  return {
    backspace: keyboard.backspaceSendsBackspace ? '\b' : '\x7f',
    left: cursorKey + 'D',
    right: cursorKey + 'C'
  };
};

/** Forgets the typed line; whatever is typed next starts a new one. */
OodShell.prototype.resetInputProxy = function () {
  this.typedLine.reset();
  if (this.inputProxy && this.inputProxy.value !== '') {
    this.inputProxy.value = '';
  }
};

/**
 * Sends the shell whatever makes its line match the input proxy's text after
 * an edit, whether the user typed, deleted, or the keyboard replaced a word.
 */
OodShell.prototype.sendInputProxyEdits = function () {
  const proxy = this.inputProxy;
  const line = this.typedLine;
  const keys = this.lineEditingKeys();
  const lines = proxy.value.split(/\r\n|\r|\n/);
  let keystrokes = '';

  if (lines.length === 1) {
    keystrokes = line.update(proxy.value, proxy.selectionEnd, keys);
  } else {
    // A line break that got in (dictating "new line", say) submits the text
    // before it, and what follows it starts the next line.
    const rest = lines.pop();
    lines.forEach(function (text) {
      keystrokes += line.update(text, text.length, keys) + '\r';
      line.reset();
    });
    proxy.value = rest;
    keystrokes += line.update(rest, rest.length, keys);
  }

  if (keystrokes) {
    this.term.onVTKeystroke(keystrokes);
  }

  // Full-screen programs such as vim, less and top run on the alternate screen
  // and treat letters as commands, where replaying an autocorrection would run
  // stray commands. Keep no word context there.
  if (typeof this.term.isPrimaryScreen === 'function' &&
      !this.term.isPrimaryScreen()) {
    this.resetInputProxy();
  }
};

/** Moves the shell's cursor after the input proxy's caret moved by itself. */
OodShell.prototype.followInputProxyCaret = function () {
  const proxy = this.inputProxy;
  if (this.inputProxyComposing ||
      proxy.selectionStart !== proxy.selectionEnd ||
      proxy.value !== this.typedLine.text()) {
    return;
  }

  const caret = Array.from(proxy.value.slice(0, proxy.selectionEnd)).length;
  const keystrokes = this.typedLine.moveTo(caret, this.lineEditingKeys());
  if (keystrokes) {
    this.term.onVTKeystroke(keystrokes);
  }
};

OodShell.prototype.onTerminalResize = function (columns, rows) {
  // React to size changes here.
  // Secure Shell pokes at NaCl, which eventually results in
  // some ioctls on the host.
  this.socket.send(JSON.stringify({
    resize: {
      cols: columns,
      rows: rows
    }
  }));
};

/**
 * The line typed into the input proxy, as the shell received it: one unit per
 * code point of the textarea's text, each with the keystrokes it was sent as,
 * and caret, the shell's cursor position counted in units. update() turns any
 * change to the textarea's text into the keystrokes that make the shell's
 * line match it.
 */
OodShell.TypedLine = function () {
  this.reset();
};

// iOS Smart Punctuation rewrites these as you type once autocorrect is on
// ("--" becomes an em dash, quotes curl). Shells need the ASCII.
OodShell.TypedLine.ASCII = {
  '\u2018': "'", '\u2019': "'", '\u201a': "'", '\u201b': "'",
  '\u201c': '"', '\u201d': '"', '\u201e': '"', '\u201f': '"',
  '\u2013': '-', '\u2014': '--', '\u2026': '...', '\u00a0': ' '
};

OodShell.TypedLine.prototype.reset = function () {
  this.units = [];
  this.caret = 0;
};

/** The textarea text this line was built from. */
OodShell.TypedLine.prototype.text = function () {
  return this.units.map(function (unit) { return unit.char; }).join('');
};

/** How many characters the shell has for units from (inclusive) to to. */
OodShell.TypedLine.prototype.width = function (from, to) {
  let width = 0;
  for (let i = from; i < to; i++) {
    width += Array.from(this.units[i].sent).length;
  }
  return width;
};

/** Moves the shell's cursor to before unit target; returns the arrow keys. */
OodShell.TypedLine.prototype.moveTo = function (target, keys) {
  let keystrokes = '';
  if (target > this.caret) {
    keystrokes = keys.right.repeat(this.width(this.caret, target));
  } else if (target < this.caret) {
    keystrokes = keys.left.repeat(this.width(target, this.caret));
  }
  this.caret = target;
  return keystrokes;
};

/**
 * Updates the line to text, with the caret at UTF-16 offset caret (a
 * textarea's selectionEnd), and returns the keystrokes that do the same to the
 * shell's line: arrows to the end of the part that changed, a backspace for
 * each character of it, the replacement, then arrows to the new caret.
 */
OodShell.TypedLine.prototype.update = function (text, caret, keys) {
  const chars = Array.from(text);
  const target = Array.from(text.slice(0, caret)).length;
  const units = this.units;

  // The changed part runs from the first difference to the last one. When a
  // character repeats, which copy changed is ambiguous; it can't have started
  // after the caret, so look no further than that for the first difference.
  let start = 0;
  const limit = Math.min(this.caret, target);
  while (start < limit && units[start].char === chars[start]) {
    start++;
  }
  let oldEnd = units.length;
  let newEnd = chars.length;
  while (oldEnd > start && newEnd > start &&
         units[oldEnd - 1].char === chars[newEnd - 1]) {
    oldEnd--;
    newEnd--;
  }

  let keystrokes = this.moveTo(oldEnd, keys);
  keystrokes += keys.backspace.repeat(this.width(start, oldEnd));
  const inserted = chars.slice(start, newEnd).map(function (char) {
    return { char: char, sent: OodShell.TypedLine.ASCII[char] || char };
  });
  inserted.forEach(function (unit) {
    keystrokes += unit.sent;
  });

  this.units = units.slice(0, start).concat(inserted, units.slice(oldEnd));
  this.caret = start + inserted.length;
  return keystrokes + this.moveTo(target, keys);
};
