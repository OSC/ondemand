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
  this.sendingInputProxyEdits = false;
  // The proxy's text as the shell received it (smart punctuation as ASCII).
  this.sentText = '';
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
  // Anything the shell gets besides the input proxy's own edits (keys hterm
  // sends, a paste, mouse or focus reports) can change its line in ways the
  // proxy can't follow, so the proxy's typed line starts over.
  if (!this.sendingInputProxyEdits) {
    this.resetInputProxy();
  }

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

/**
 * Focuses whichever element takes keyboard input. With refresh set, an element
 * that already has focus is blurred first: Apple/WebKit can leave it focused
 * after the software keyboard is dismissed, and only a fresh focus brings the
 * keyboard back.
 */
OodShell.prototype.focusInput = function (refresh) {
  const termDocument = this.term.getDocument();
  if (this.predictiveText && this.inputProxy) {
    if (refresh && termDocument.activeElement === this.inputProxy) {
      this.inputProxy.blur();
    }
    this.inputProxy.focus();
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

  // hterm's keyboard handlers sit on the document body and see these events
  // as they bubble, so keys work as they do on hterm's screen: hterm sends
  // Enter, arrows, Tab, Ctrl+key and the like itself, and leaves characters
  // to keypress and textInput. Stopping those here lets the textarea take the
  // characters instead. Backspace also stays with the textarea while it has
  // text, so the keyboard keeps its word context, as does IME input.
  proxy.addEventListener('keydown', function (ev) {
    if (ev.isComposing || ev.keyCode === 229 ||
        (ev.key === 'Backspace' && proxy.value !== '' &&
         !ev.ctrlKey && !ev.altKey && !ev.metaKey)) {
      ev.stopPropagation();
    }
  });
  ['keypress', 'textInput'].forEach(function (type) {
    proxy.addEventListener(type, function (ev) {
      ev.stopPropagation();
    });
  });

  // For keyboards that don't send an Enter or Backspace keydown.
  proxy.addEventListener('beforeinput', function (ev) {
    if (ev.inputType === 'insertLineBreak' ||
        ev.inputType === 'insertParagraph') {
      ev.preventDefault();
      term.onVTKeystroke('\r');
    } else if (ev.inputType === 'deleteContentBackward' &&
               proxy.value === '') {
      ev.preventDefault();
      term.onVTKeystroke(shell.backspaceKey());
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

  // The same path as pasting onto hterm's screen, so bracketed paste still
  // applies.
  proxy.addEventListener('paste', function (ev) {
    ev.preventDefault();
    const text = ev.clipboardData.getData('text/plain');
    if (text) {
      term.onPasteData_(text);
    }
  });

  // hterm moves the document selection to its cursor whenever it redraws,
  // which would pull the keyboard's context out of the textarea. It skips that
  // while its find bar's input has focus; this textarea claims the same. The
  // cursor is drawn focused or not, as hterm does for its own screen.
  const onFocusChange = function (ev) {
    const focused = ev.type === 'focus';
    if (focused) {
      proxy.setSelectionRange(proxy.value.length, proxy.value.length);
    }
    term.findBar.hasFocus = focused;
    term.onFocusChange_(focused);
  };
  proxy.addEventListener('focus', onFocusChange);
  proxy.addEventListener('blur', onFocusChange);

  // The shell's cursor stays at the end of what was sent, so the caret has to
  // as well. If it moves by itself (dragging across the iOS space bar), the
  // typed line starts over from there.
  termDocument.addEventListener('selectionchange', function () {
    if (termDocument.activeElement === proxy &&
        !shell.inputProxyComposing &&
        proxy.selectionStart === proxy.selectionEnd &&
        proxy.selectionEnd < proxy.value.length &&
        OodShell.toAscii(proxy.value) === shell.sentText) {
      shell.resetInputProxy();
    }
  });

  // hterm's screen still gets focus in places (a mouse click, after a paste,
  // when the find bar closes). Pass it on to the textarea once any selecting
  // is over, unless that left text selected for the user to copy. None of
  // these need to keep a touch gesture: taps focus the textarea directly.
  const reclaimFocus = function () {
    if (!shell.predictiveText || termDocument.activeElement !== screen) {
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

/** What the shell's line editor expects for Backspace, per hterm's setting. */
OodShell.prototype.backspaceKey = function () {
  return this.term.keyboard.backspaceSendsBackspace ? '\b' : '\x7f';
};

/** Forgets the typed line; whatever is typed next starts a new one. */
OodShell.prototype.resetInputProxy = function () {
  this.sentText = '';
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
  const backspace = this.backspaceKey();
  const lines = proxy.value.split(/\r\n|\r|\n/);
  const last = lines.pop();
  let keystrokes = '';

  // A line break that got in (dictating "new line", say) submits the text
  // before it, and what follows it starts the next line.
  lines.forEach(function (line) {
    keystrokes += OodShell.retype(this.sentText, OodShell.toAscii(line),
                                  backspace) + '\r';
    this.sentText = '';
  }, this);
  if (lines.length > 0) {
    proxy.value = last;
  }

  const text = OodShell.toAscii(last);
  keystrokes += OodShell.retype(this.sentText, text, backspace);
  this.sentText = text;

  if (keystrokes) {
    this.sendingInputProxyEdits = true;
    this.term.onVTKeystroke(keystrokes);
    this.sendingInputProxyEdits = false;
  }

  // Full-screen programs such as vim, less and top run on the alternate screen
  // and treat letters as commands, where replaying an autocorrection would run
  // stray commands. Keep no word context there.
  if (!this.term.isPrimaryScreen()) {
    this.resetInputProxy();
  }
};

// iOS Smart Punctuation rewrites these as you type once autocorrect is on
// ("--" becomes an em dash, quotes curl). Shells need the ASCII.
OodShell.ASCII = {
  '\u2018': "'", '\u2019': "'", '\u201a': "'", '\u201b': "'",
  '\u201c': '"', '\u201d': '"', '\u201e': '"', '\u201f': '"',
  '\u2013': '-', '\u2014': '--', '\u2026': '...', '\u00a0': ' '
};

OodShell.toAscii = function (text) {
  return Array.from(text, function (char) {
    return OodShell.ASCII[char] || char;
  }).join('');
};

/**
 * The keystrokes that turn the shell's line from `from` into `to`: a
 * backspace for each character after the part they share, then the rest of
 * `to`. Retyping the tail keeps the shell's cursor at the end of what was
 * sent, so no arrow keys are needed and the line editor only has to
 * understand Backspace. Counts code points, as the shell does.
 */
OodShell.retype = function (from, to, backspace) {
  const before = Array.from(from);
  const after = Array.from(to);
  let same = 0;
  while (same < before.length && same < after.length &&
         before[same] === after[same]) {
    same++;
  }
  return backspace.repeat(before.length - same) + after.slice(same).join('');
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
