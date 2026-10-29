// Object that defines a terminal element
function OodShell(element, url, profile) {
  this.element = element;
  this.url     = url;
  this.profile   = profile || "default";
  this.socket  = null;
  this.term    = null;
  // Ctrl and Alt armed on the on-screen keys, applied to the next keystroke
  this.modifiers = { ctrl: false, alt: false };
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

    // Esc, Ctrl, Alt, arrows and the like, which soft keyboards lack
    that.installKeys();
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
      if (needsTouchFocusRefresh &&
          term.getDocument().activeElement === screen) {
        term.blur();
      }
      term.focus();
    }

    touchStart = null;
  }, touchOptions);
  screen.addEventListener('touchcancel', function () {
    touchStart = null;
  }, touchOptions);
};

// On-screen keys for phone and tablet keyboards. Touch devices show them by
// default; the Keys menu button shows or hides them and remembers the choice.
OodShell.prototype.installKeys = function () {
  const that = this;
  const keys = document.getElementById('terminal_keys');
  const toggle = document.getElementById('terminal_keys_toggle');
  const saved = window.localStorage.getItem('ood_shell_keys');
  let repeatTimer = null;
  let repeated = false;

  // decorate() appended the terminal; keep the keys below it, just above
  // the soft keyboard.
  this.element.appendChild(keys);

  const show = function (visible) {
    keys.hidden = !visible;
    toggle.setAttribute('aria-expanded', visible);
    that.setModifier('ctrl', false);
    that.setModifier('alt', false);
  };
  show(saved === null ? window.matchMedia('(pointer: coarse)').matches : saved === 'true');
  toggle.addEventListener('click', function () {
    show(keys.hidden);
    window.localStorage.setItem('ood_shell_keys', !keys.hidden);
  });

  // Keep focus in the terminal so that the soft keyboard stays open, and
  // don't open a menu on a long press.
  keys.addEventListener('mousedown', function (ev) { ev.preventDefault(); });
  keys.addEventListener('contextmenu', function (ev) { ev.preventDefault(); });

  // click covers taps, mice, keyboards and screen readers, and doesn't fire
  // when a finger slides off a key or scrolls the row of keys.
  keys.addEventListener('click', function (ev) {
    const button = ev.target.closest('button');
    // Releasing a key that repeated while held sends nothing more.
    if (button === null || (repeated && ev.detail > 0)) {
      return;
    }
    if (!that.term.getDocument().hasFocus()) {
      that.term.focus();
    }
    that.pressKey(button);
  });

  // Holding an arrow repeats it.
  keys.addEventListener('pointerdown', function (ev) {
    const button = ev.target.closest('button[data-repeat]');
    const press = function () {
      repeated = true;
      that.pressKey(button);
      repeatTimer = setTimeout(press, 50);
    };
    clearTimeout(repeatTimer);
    repeated = false;
    if (button !== null) {
      repeatTimer = setTimeout(press, 500);
    }
  });
  ['pointerup', 'pointercancel', 'pointerleave'].forEach(function (type) {
    keys.addEventListener(type, function () { clearTimeout(repeatTimer); });
  });
};

// Bytes sent by the on-screen keys. Other keys send their data-key as text.
OodShell.keySequences = {
  Escape:     '\x1b',
  Tab:        '\t',
  ArrowUp:    '\x1b[A',
  ArrowDown:  '\x1b[B',
  ArrowRight: '\x1b[C',
  ArrowLeft:  '\x1b[D',
  Home:       '\x1b[H',
  End:        '\x1b[F',
  PageUp:     '\x1b[5~',
  PageDown:   '\x1b[6~',
  '^C':       '\x03',
  '^D':       '\x04',
  '^X':       '\x18',
  '^Z':       '\x1a'
};

// Send an on-screen key as if it were typed, so that hterm scrolls to the
// cursor and onVTKeystroke applies any armed Ctrl or Alt.
OodShell.prototype.pressKey = function (button) {
  const modifier = button.dataset.modifier;
  if (modifier) {
    this.setModifier(modifier, !this.modifiers[modifier]);
    return;
  }

  let str = OodShell.keySequences[button.dataset.key] || button.dataset.key;
  // vim, less and the like switch cursor keys to application mode (ESC O A).
  if (this.term.keyboard.applicationCursor) {
    str = str.replace(/^\x1b\[([A-DFH])$/, '\x1bO$1');
  }
  this.term.onVTKeystroke(str);
};

OodShell.prototype.setModifier = function (name, armed) {
  this.modifiers[name] = armed;
  document.querySelector('[data-modifier="' + name + '"]').setAttribute('aria-pressed', armed);
};

// What a keystroke sends with Ctrl and/or Alt held, as hterm and xterm encode
// a physical keyboard.
OodShell.applyModifiers = function (str, ctrl, alt) {
  // Cursor and editing keys take a modifier parameter: ESC [ A -> ESC [ 1 ; 5 A
  const key = /^\x1b[\[O](\d*)([A-Z~])$/.exec(str);
  if (key) {
    return '\x1b[' + (key[1] || '1') + ';' + (1 + (alt ? 2 : 0) + (ctrl ? 4 : 0)) + key[2];
  }
  // Leave text from autocomplete or an input method alone.
  if (str.length !== 1) {
    return str;
  }
  if (ctrl) {
    str = OodShell.ctrlChar(str);
  }
  // Alt sends ESC first, which readline and emacs read as Meta.
  return alt ? '\x1b' + str : str;
};

// Ctrl-A is \x01 and so on through Ctrl-_ (lowercase and shifted forms too),
// plus hterm's Ctrl with Space, digits, / and ?. Others are sent unchanged.
OodShell.ctrlChar = function (ch) {
  const code = ch.charCodeAt(0);
  if (code >= 0x40 && code < 0x7f) {
    return String.fromCharCode(code & 0x1f);
  }
  return {
    ' ': '\x00', '2': '\x00', '3': '\x1b', '4': '\x1c', '5': '\x1d',
    '6': '\x1e', '7': '\x1f', '8': '\x7f', '/': '\x1f', '?': '\x7f'
  }[ch] || ch;
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

  // Nothing left for the on-screen keys to type into
  document.getElementById('terminal_keys').hidden = true;

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
  // Keys typed or tapped by the user. Ctrl or Alt armed on the on-screen
  // keys applies to this one only.
  if (this.modifiers.ctrl || this.modifiers.alt) {
    str = OodShell.applyModifiers(str, this.modifiers.ctrl, this.modifiers.alt);
    this.setModifier('ctrl', false);
    this.setModifier('alt', false);
  }
  this.sendString(str);
};

OodShell.prototype.sendString = function (str) {
  // Just like a keystroke, except str was generated by the terminal itself
  // (pastes, replies to queries), so on-screen modifiers don't apply.
  this.socket.send(JSON.stringify({
    input: str
  }));
};

OodShell.prototype.changeTheme = function (theme) {
  this.term.setProfile(theme);
}

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
