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

/**
 * Lets a two-finger pinch change the terminal's font size, like ctrl-plus and
 * ctrl-minus do on a desktop. hterm turns every active touch into one scroll
 * movement and calls preventDefault() on it, which also stops the browser's own
 * pinch zoom, so there was no way to resize the text on a phone. hterm's touch
 * handler returns early for events that are already defaultPrevented, so
 * claiming two-finger moves here keeps hterm from scrolling during a pinch
 * without modifying the vendored bundle. One-finger touches are left alone.
 */
OodShell.prototype.installPinchZoom = function (term) {
  const screen = term.getDocument().querySelector('x-screen');
  if (!screen) {
    return;
  }

  const minFontSize = 8;
  const maxFontSize = 40;
  // Not passive, because the pinch has to call preventDefault().
  const touchOptions = { passive: false, capture: true };

  let startDistance = null;
  let startFontSize = null;
  let latestTouches = null;
  let pendingFrame = null;

  /** Pixel distance between two touches. */
  const distanceBetween = function (touchA, touchB) {
    const dx = touchA.clientX - touchB.clientX;
    const dy = touchA.clientY - touchB.clientY;
    return Math.sqrt((dx * dx) + (dy * dy));
  };

  /** Sets the font size from how far the fingers have moved since the start. */
  const applyPinch = function () {
    pendingFrame = null;
    if (startDistance === null || latestTouches === null) {
      return;
    }
    const distance = distanceBetween(latestTouches[0], latestTouches[1]);
    if (distance <= 0) {
      return;
    }
    const size = Math.min(maxFontSize, Math.max(minFontSize,
        Math.round(startFontSize * (distance / startDistance))));
    if (size !== term.getFontSize()) {
      term.setFontSize(size);
    }
  };

  /** Finish the queued resize before clearing the gesture. */
  const finishPendingPinch = function (apply) {
    if (pendingFrame !== null) {
      window.cancelAnimationFrame(pendingFrame);
      pendingFrame = null;
      if (apply) {
        applyPinch();
      }
    }
  };

  /** Synchronize hterm before it resumes processing touch moves. */
  const syncTouches = function (touches) {
    const lastTouch = term.scrollPort_ && term.scrollPort_.lastTouch_;
    if (!lastTouch) {
      return;
    }
    for (let i = 0; i < touches.length; i++) {
      const touch = touches[i];
      lastTouch[touch.identifier] = {
        id: touch.identifier,
        x: touch.clientX,
        y: touch.clientY
      };
    }
  };

  /**
   * Starts a pinch when exactly two fingers are down. The event is not
   * prevented, so hterm still records both fingers' starting positions.
   */
  screen.addEventListener('touchstart', function (ev) {
    if (ev.touches.length !== 2) {
      if (startDistance !== null) {
        finishPendingPinch(true);
        syncTouches(ev.touches);
        startDistance = null;
        latestTouches = null;
      }
      return;
    }
    const distance = distanceBetween(ev.touches[0], ev.touches[1]);
    startDistance = distance > 0 ? distance : null;
    startFontSize = term.getFontSize();
  }, touchOptions);

  screen.addEventListener('touchmove', function (ev) {
    if (startDistance === null || ev.touches.length !== 2) {
      return;
    }
    // Marks the event defaultPrevented so hterm's own handler skips it.
    ev.preventDefault();
    latestTouches = [ev.touches[0], ev.touches[1]];
    if (pendingFrame === null) {
      pendingFrame = window.requestAnimationFrame(applyPinch);
    }
  }, touchOptions);

  /** Ends the pinch when a finger lifts or the touch is cancelled. */
  const endPinch = function (ev) {
    if (startDistance === null) {
      return;
    }
    if (ev.touches.length < 2) {
      // Apply the last move on a normal lift, but discard it on cancellation.
      finishPendingPinch(ev.type === 'touchend');
      // hterm skipped pinch moves, so its cache is stale for any remaining
      // finger. This private field should be re-tested after hterm updates.
      syncTouches(ev.touches);
      startDistance = null;
      latestTouches = null;
    }
  };
  screen.addEventListener('touchend', endPinch, touchOptions);
  screen.addEventListener('touchcancel', endPinch, touchOptions);
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
  this.socket.send(JSON.stringify({
    resize: {
      cols: columns,
      rows: rows
    }
  }));
};
