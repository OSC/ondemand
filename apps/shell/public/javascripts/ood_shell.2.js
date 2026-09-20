// Object that defines a terminal element
function OodShell(element, url, profile) {
  this.element = element;
  this.url     = url;
  this.profile   = profile || "default";
  this.socket  = null;
  this.term    = null;
}

OodShell.prototype.createTerminal = function () {
  // Viewport sizing is intentionally independent of the WebSocket lifecycle:
  // the shell chrome should fit the visible page even if the connection fails.
  // If this app ever creates/destroys OodShell instances without a page load,
  // add a matching destroy path for the listeners installed below.
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

    // hterm prevents the default action for touch events, which suppresses
    // Safari's normal tap-to-focus behavior. Add back focus for taps while
    // keeping hterm's touch-drag scrolling behavior.
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

/**
 * Restore tap-to-focus for hterm on touch devices without treating a drag or
 * scroll gesture as a tap.
 *
 * This depends on hterm continuing to use a contenteditable x-screen and to
 * install its own touch handlers without capture. If a future hterm update
 * changes either behavior, re-test whether this wrapper is still necessary
 * before carrying the workaround forward. 
 */
OodShell.prototype.installTouchKeyboard = function (term) {
  const screen = term.getDocument().querySelector('x-screen');
  // Track the initial position of the active one-finger tap candidate.
  let touchStart = null;
  // Capture before hterm handles the event; passive listeners preserve its
  // scrolling behavior while this handler only observes the gesture.
  const touchOptions = { passive: true, capture: true };
  // This is a capability heuristic for the Apple/WebKit environment where a
  // dismissed software keyboard can leave contenteditable logically focused.
  // It is intentionally not a browser-name check. The non-standard property,
  // or the underlying focus behavior, may change in future engines/releases;
  // if that happens prefer re-testing the behavior over expanding UA sniffing.
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
      id: touch.identifier,
      x: touch.clientX,
      y: touch.clientY
    };
  }, touchOptions);

  screen.addEventListener('touchmove', function (ev) {
    if (touchStart === null) {
      return;
    }
    for (let i = 0; i < ev.changedTouches.length; ++i) {
      if (ev.changedTouches[i].identifier === touchStart.id) {
        const touch = ev.changedTouches[i];
        const dx = touch.clientX - touchStart.x;
        const dy = touch.clientY - touchStart.y;
        // Once a gesture has moved beyond the 10 CSS-pixel tap radius, do
        // not allow it to become a tap again if the finger returns near its
        // starting point. The threshold is a usability choice rather than a
        // browser invariant and may need tuning for future touch hardware.
        if ((dx * dx + dy * dy) > 100) {
          touchStart = null;
        }
        break;
      }
    }
  }, touchOptions);

  screen.addEventListener('touchend', function (ev) {
    let touch = null;

    if (touchStart === null) {
      return;
    }
    for (let i = 0; i < ev.changedTouches.length; ++i) {
      if (ev.changedTouches[i].identifier === touchStart.id) {
        touch = ev.changedTouches[i];
        break;
      }
    }
    if (touch !== null) {
      const dx = touch.clientX - touchStart.x;
      const dy = touch.clientY - touchStart.y;
      // Treat movement within 10 CSS pixels as a tap rather than scrolling.
      // Keep focus synchronous with the user gesture so iOS/iPadOS Safari can
      // display its software keyboard.
      if ((dx * dx + dy * dy) <= 100) {
        // Apple WebKit can leave a contenteditable element focused after the
        // software keyboard is dismissed with Done. Force a fresh focus
        // transition only for the detected environment; doing this for every
        // touch browser could disrupt IME/composition or accessibility focus.
        if (needsTouchFocusRefresh &&
            term.getDocument().activeElement === screen) {
          term.blur();
        }
        term.focus();
      }
    }

    touchStart = null;
  }, touchOptions);
  screen.addEventListener('touchcancel', function () {
    touchStart = null;
  }, touchOptions);
};

/**
 * Keep the terminal sized to the visible viewport when browser chrome or the
 * software keyboard changes the space available to the page.
 *
 * Only height is overridden here. Width remains under normal page/flex layout
 * so pinch-zoom panning and visualViewport.offsetLeft do not become terminal
 * geometry. If mobile browsers begin resizing layout width for their software
 * keyboards, revisit that assumption before adding visualViewport.width.
 */
OodShell.prototype.installVisualViewportSizing = function () {
  const viewport = window.visualViewport;
  const element = this.element;
  let resizeFrame = null;

  if (!viewport) {
    return;
  }

  const resize = function () {
    if (resizeFrame !== null) {
      return;
    }

    // 100vh style.css is the legacy fallback; 100dvh handles dynamic browser chrome.
    // When VisualViewport is available, ood_shell.2.js may override this with
    // an inline pixel height to account for the software keyboard as well.

    // Use a single animation-frame callback to coalesce bursts of viewport
    // events into one layout update.
    resizeFrame = window.requestAnimationFrame(function () {
      // Convert the visible height back to approximate layout-space CSS
      // pixels so pinch zoom does not intentionally resize the remote PTY.
      // Browsers, notably WebKit, have had small precision/interoperability
      // errors in height * scale. A few pixels are tolerated here; if future
      // reports show row-count jitter at cell boundaries, revisit this math
      // rather than assuming the product exactly equals layout viewport height.
      const height = Math.round(viewport.height * viewport.scale);

      // A VisualViewport belonging to a document that is not fully active can
      // transiently report zero. Preserve the last usable terminal height
      // rather than collapsing the shell until the next viewport event.
      if (height > 0) {
        element.style.height = height + 'px';
      }
      resizeFrame = null;
    });
  };

  // The listeners intentionally live for the page lifetime: current Shell
  // creates one OodShell instance and keeps the disconnected terminal visible.
  // If the app gains in-page terminal replacement, these listeners and any
  // pending animation frame should move behind an explicit destroy lifecycle.
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
