// Object that defines a terminal element
function OodShell(element, url, profile) {
  this.element = element;
  this.url     = url;
  this.profile   = profile || "default";
  this.socket  = null;
  this.term    = null;
  this.keys    = null;
  this.sendingMobileKey = false;
}

OodShell.prototype.createTerminal = function () {
  this.installVisualViewportSizing();
  this.installMobileKeys();
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
    if (that.keys !== null && that.socket.readyState === WebSocket.OPEN) {
      that.keys.setEnabled(true);
    }
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

// On-screen Esc/Ctrl/Alt/arrow keys for soft keyboards (see ood_shell_keys.js).
// Touch devices show the keys by default; the menu can override that choice.
OodShell.prototype.installMobileKeys = function () {
  const toolbar = document.getElementById('mobile_keys');
  const that = this;

  if (!toolbar || typeof OodShellKeys === 'undefined') {
    return;
  }

  let visible = typeof window.matchMedia === 'function' ?
    window.matchMedia('(any-pointer: coarse)').matches : navigator.maxTouchPoints > 0;
  try {
    const saved = window.localStorage.getItem('ood_shell_mobile_keys');
    if (saved === 'true' || saved === 'false') {
      visible = saved === 'true';
    }
  } catch (err) {
    // The keys still work when storage is blocked.
  }

  this.keys = new OodShellKeys(toolbar, {
    enabled: false,
    visible: visible,
    toggle: document.getElementById('mobile_keys_toggle'),
    onVisibilityChange: function (shown) {
      try {
        window.localStorage.setItem('ood_shell_mobile_keys', String(shown));
      } catch (err) {
        // Persistence is optional.
      }
    },
    focus: function () {
      that.term.focus();
    },
    send: function (str) {
      return that.onMobileKeystroke(str);
    },
    applicationCursor: function () {
      // vim, emacs and less switch arrow keys to application mode (ESC O A).
      return !!(that.term && that.term.keyboard && that.term.keyboard.applicationCursor);
    }
  });
};

OodShell.prototype.onMobileKeystroke = function (str) {
  if (this.term === null || this.socket === null || this.socket.readyState !== WebSocket.OPEN) {
    return false;
  }

  // Let hterm scroll to the live cursor, update blinking, and use its current
  // foreground IO. Toolbar bytes are already encoded, so do not modify them
  // again in onVTKeystroke (especially one-tap shortcuts such as ^C).
  const previous = this.sendingMobileKey;
  this.sendingMobileKey = true;
  try {
    this.term.onVTKeystroke(str);
  } finally {
    this.sendingMobileKey = previous;
  }
  return true;
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

  // The on-screen keys have nothing to talk to anymore
  if (this.keys !== null) {
    this.keys.disable();
  }

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

// Send bytes to the remote shell as-is.
OodShell.prototype.sendInput = function (str) {
  if (this.socket === null || this.socket.readyState !== WebSocket.OPEN) {
    return;
  }

  this.socket.send(JSON.stringify({
    input: str
  }));
};

OodShell.prototype.onVTKeystroke = function (str) {
  // Text typed by the user. Apply any Ctrl/Alt armed on the on-screen keys.
  this.sendInput(this.keys === null || this.sendingMobileKey ? str : this.keys.transform(str));
};

OodShell.prototype.sendString = function (str) {
  // Unlike a keystroke, str was generated by the terminal itself (focus
  // reports, device status replies, paste, scroll-to-arrow conversion), so
  // armed modifiers must not apply to it or be used up by it.
  this.sendInput(str);
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
