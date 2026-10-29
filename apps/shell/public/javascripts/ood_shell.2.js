// Object that defines a terminal element
function OodShell(element, url, profile, predictiveText) {
  this.element = element;
  this.url     = url;
  this.profile   = profile || "default";
  this.predictiveText = !!predictiveText;
  this.socket  = null;
  this.term    = null;
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
    // Apply the saved predictive text preference to the terminal's input.
    that.setPredictiveText(that.predictiveText);

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
 * Turns the on-screen keyboard's word suggestions on or off. hterm sets
 * autocorrect="off" and autocapitalize="none" on its input element so that the
 * operating system never rewrites shell commands, and mobile keyboards hide
 * their suggestion bar while those are set. This puts them back only when the
 * user opts in. Spellcheck and autocomplete stay off either way.
 */
OodShell.prototype.setPredictiveText = function (enabled) {
  this.predictiveText = enabled;

  // Before the terminal is ready there is no input element yet;
  // onTerminalReady applies the setting once there is.
  const termDocument = this.term && this.term.getDocument();
  const screen = termDocument && termDocument.querySelector('x-screen');
  if (!screen) {
    return;
  }

  const autocorrect = enabled ? 'on' : 'off';
  const autocapitalize = enabled ? 'sentences' : 'none';
  if (screen.getAttribute('autocorrect') === autocorrect &&
      screen.getAttribute('autocapitalize') === autocapitalize) {
    return;
  }

  const wasFocused = termDocument.activeElement === screen;
  screen.setAttribute('autocorrect', autocorrect);
  screen.setAttribute('autocapitalize', autocapitalize);

  // Mobile WebKit only re-reads these attributes on a fresh focus transition,
  // the same constraint installTouchKeyboard works around.
  if (wasFocused) {
    this.term.blur();
    this.term.focus();
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
