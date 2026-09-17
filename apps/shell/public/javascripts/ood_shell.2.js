// Object that defines a terminal element
function OodShell(element, url, profile) {
  this.element = element;
  this.url     = url;
  this.profile   = profile || "default";
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
  var that = this;

  // Create an instance of hterm.Terminal
  this.term = new hterm.Terminal({ profileId: this.profile });

  // Handler that fires when terminal is initialized and ready for use
  this.term.onTerminalReady = function () {
    // Create a new terminal IO object and give it the foreground.
    // (The default IO object just prints warning messages about unhandled
    // things to the JS console.)
    var io = this.io.push();

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

OodShell.prototype.installTouchKeyboard = function (term) {
  var screen = term.getDocument().querySelector('x-screen');
  var touchStart = null;
  var touchOptions = { passive: true, capture: true };
  var isAppleWebKitTouch = /AppleWebKit/.test(navigator.userAgent) &&
                           !/Android/.test(navigator.userAgent) &&
                           navigator.maxTouchPoints > 0;
  if (!screen) {
    return;
  }

  screen.addEventListener('touchstart', function (ev) {
    var touch;
    if (ev.touches.length !== 1) {
      touchStart = null;
      return;
    }
    touch = ev.touches[0];
    touchStart = {
      id: touch.identifier,
      x: touch.clientX,
      y: touch.clientY
    };
  }, touchOptions);

  screen.addEventListener('touchmove', function (ev) {
    var touch;
    var dx;
    var dy;
    var i;

    if (touchStart === null) {
      return;
    }
    for (i = 0; i < ev.changedTouches.length; ++i) {
      if (ev.changedTouches[i].identifier === touchStart.id) {
        touch = ev.changedTouches[i];
        dx = touch.clientX - touchStart.x;
        dy = touch.clientY - touchStart.y;

        // Once a gesture has moved beyond the tap threshold, do not allow it
        // to become a tap again if the finger returns near its starting point.
        if ((dx * dx + dy * dy) > 100) {
          touchStart = null;
        }
        break;
      }
    }
  }, touchOptions);

  screen.addEventListener('touchend', function (ev) {
    var touch = null;
    var dx;
    var dy;
    var i;

    if (touchStart === null) {
      return;
    }
    for (i = 0; i < ev.changedTouches.length; ++i) {
      if (ev.changedTouches[i].identifier === touchStart.id) {
        touch = ev.changedTouches[i];
        break;
      }
    }

    if (touch !== null) {
      dx = touch.clientX - touchStart.x;
      dy = touch.clientY - touchStart.y;
      // Treat movement within 10 CSS pixels as a tap rather than scrolling.
      // Keep focus synchronous with the user gesture so iOS/iPadOS Safari can
      // display its software keyboard.
      if ((dx * dx + dy * dy) <= 100) {
        // Apple WebKit can leave a contenteditable element focused after the
        // software keyboard is dismissed with Done. Force a fresh focus
        // transition there without changing focus behavior on Chromium,
        // Firefox, or other touch browsers.
        if (isAppleWebKitTouch && term.getDocument().activeElement === screen) {
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

OodShell.prototype.installVisualViewportSizing = function () {
  var viewport = window.visualViewport;
  var element = this.element;
  var resizeFrame = null;
  var resize;

  if (!viewport) {
    return;
  }

  resize = function () {
    if (resizeFrame !== null) {
      return;
    }

    resizeFrame = window.requestAnimationFrame(function () {
      var height = Math.round(viewport.height);

      // A VisualViewport belonging to a document that is not fully active can
      // transiently report zero. Preserve the last usable terminal height
      // rather than collapsing the shell until the next viewport event.
      if (height > 0) {
        element.style.height = height + 'px';
      }
      resizeFrame = null;
    });
  };

  // Safari can update the visual viewport as its browser chrome moves as well
  // as when the software keyboard opens or closes. Measure on the next frame
  // and coalesce repeated events to avoid redundant layout writes.
  resize();
  viewport.addEventListener('resize', resize);
  viewport.addEventListener('scroll', resize);
  window.addEventListener('resize', resize);
};

OodShell.prototype.getMessage = function (ev) {
  this.term.io.print(ev.data);
}

OodShell.prototype.closeTerminal = function (ev) {
  var errorDiv;

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
