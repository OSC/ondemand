// Object that defines a terminal element
function OodShell(element, url, profile) {
  this.element = element;
  this.url     = url;
  this.profile   = profile || "default";
  this.socket  = null;
  this.term    = null;
  this.resizeHeld    = false;
  this.pendingResize = null;
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

    // Pinching with two fingers changes the font size.
    that.installPinchZoom(this);
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

// Pinching with two fingers changes the font size, like ctrl-plus and
// ctrl-minus do on a desktop.
//
// hterm's ScrollPort.onTouch_ scrolls on every touchmove, but returns early for
// events that are already defaultPrevented. These listeners are on the frame's
// document in the capture phase, so they run before hterm's listeners on
// x-screen wherever the touch lands, and claim a move by preventing it.
//
// Two fingers scroll as before until the distance between them changes by
// PINCH_SLOP_PX. From then until every finger has lifted, every move is
// claimed. hterm skips every move after the pinch starts, so its cached
// finger positions are never read while stale and no private hterm state is
// touched. pinch_zoom.test.js checks this against hterm's own handler.
OodShell.prototype.installPinchZoom = function (term) {
  const screen = term.getDocument().querySelector('x-screen');
  if (!screen) {
    return;
  }

  const shell = this;
  const doc = screen.ownerDocument;
  const PINCH_SLOP_PX = 20;
  const MIN_FONT_SIZE = 8;
  const MAX_FONT_SIZE = 40;

  let claimed = false; // A pinch started; claim moves until every finger lifts.
  let pinch = null;    // { distance, size, engaged } for the current two fingers.
  let nextSize = null;
  let pendingFrame = null;

  const distanceBetween = function (touches) {
    return Math.hypot(touches[0].clientX - touches[1].clientX,
                      touches[0].clientY - touches[1].clientY);
  };

  const applySize = function () {
    pendingFrame = null;
    if (nextSize !== term.getFontSize()) {
      term.setFontSize(nextSize);
    }
  };

  // A finger landed, lifted or was cancelled. Apply any pending size, end the
  // gesture once no fingers remain, and start measuring a new pair if any.
  const onTouchesChanged = function (ev) {
    if (pendingFrame !== null) {
      window.cancelAnimationFrame(pendingFrame);
      applySize();
    }

    if (claimed && ev.touches.length === 0) {
      claimed = false;
      shell.releaseResize();
    }

    pinch = null;
    if (ev.touches.length === 2) {
      const distance = distanceBetween(ev.touches);
      if (distance > 0) {
        pinch = { distance: distance, size: term.getFontSize(), engaged: false };
      }
    }
  };

  const onTouchMove = function (ev) {
    if (claimed) {
      ev.preventDefault();
    }
    if (!pinch || ev.touches.length !== 2) {
      return;
    }

    const distance = distanceBetween(ev.touches);
    if (distance <= 0) {
      return;
    }

    if (!pinch.engaged) {
      if (Math.abs(distance - pinch.distance) < PINCH_SLOP_PX) {
        return;
      }
      // Measure from here so the size does not jump by the slop.
      pinch.engaged = true;
      pinch.distance = distance;
      if (!claimed) {
        claimed = true;
        ev.preventDefault();
        // Tell the server the new terminal size once, when the fingers lift.
        shell.holdResize();
      }
      return;
    }

    // A size outside 8-40px (set with ctrl-plus or ctrl-minus) can move toward
    // that range but never jumps into it.
    const min = Math.min(MIN_FONT_SIZE, pinch.size);
    const max = Math.max(MAX_FONT_SIZE, pinch.size);
    nextSize = Math.min(max, Math.max(min,
        Math.round(pinch.size * distance / pinch.distance)));
    if (pendingFrame === null) {
      pendingFrame = window.requestAnimationFrame(applySize);
    }
  };

  ['touchstart', 'touchend', 'touchcancel'].forEach(function (type) {
    doc.addEventListener(type, onTouchesChanged, { capture: true, passive: true });
  });
  // Not passive, because claiming a move means calling preventDefault().
  doc.addEventListener('touchmove', onTouchMove, { capture: true, passive: false });
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

OodShell.prototype.onTerminalResize = function (columns, rows) {
  // React to size changes here.
  // Secure Shell pokes at NaCl, which eventually results in
  // some ioctls on the host.
  this.pendingResize = {
    cols: columns,
    rows: rows
  };
  if (!this.resizeHeld) {
    this.sendPendingResize();
  }
};

// A pinch can change the font size, and with it the column count, on every
// frame. While one is in progress, keep only the latest terminal size so the
// remote program gets one resize (SIGWINCH) per pinch instead of one per step.
OodShell.prototype.holdResize = function () {
  this.resizeHeld = true;
};

// hterm reports size changes to onTerminalResize from a timer, so the report
// for the last step may arrive after this; it is then sent directly. The timer
// sends anything still held.
OodShell.prototype.releaseResize = function () {
  const that = this;
  this.resizeHeld = false;
  window.setTimeout(function () {
    if (!that.resizeHeld) {
      that.sendPendingResize();
    }
  }, 0);
};

OodShell.prototype.sendPendingResize = function () {
  const size = this.pendingResize;
  if (size === null) {
    return;
  }
  this.pendingResize = null;
  this.socket.send(JSON.stringify({ resize: size }));
};
