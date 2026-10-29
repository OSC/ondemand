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

    // Show a Copy/Paste toolbar for text selected with a finger.
    that.installMobileSelection(this);

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
  const that = this;
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
      // A tap while text is selected (for example to dismiss the selection
      // toolbar) must not pop the on-screen keyboard open.
      if (that.hasActiveSelection(term)) {
        touchStart = null;
        return;
      }
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

/**
 * Returns true when text inside the terminal is selected. hterm renders into
 * an iframe, so the selection is read from the terminal's own document rather
 * than from the page.
 */
OodShell.prototype.hasActiveSelection = function (term) {
  const termDocument = term.getDocument();
  const screen = termDocument.querySelector('x-screen');
  const selection = termDocument.getSelection();
  if (!screen || !selection || selection.isCollapsed ||
      selection.rangeCount === 0) {
    return false;
  }
  return screen.contains(selection.getRangeAt(0).commonAncestorContainer);
};

/**
 * Shows a Copy/Paste toolbar next to text selected with a finger. hterm calls
 * preventDefault() on touch events, which makes the browser's own selection
 * menu unreliable inside the terminal. The toolbar lives in the page while the
 * selection lives in hterm's iframe, so its position is translated through the
 * iframe's offset. It only appears when the primary pointer is coarse (a touch
 * screen), so selecting text with a mouse behaves as before.
 */
OodShell.prototype.installMobileSelection = function (term) {
  const that = this;
  const termDocument = term.getDocument();
  const coarsePointer = window.matchMedia ?
      window.matchMedia('(pointer: coarse)') : null;
  let pendingFrame = null;
  let selectedText = null;

  const toolbar = document.createElement('div');
  toolbar.className = 'ood-selection-toolbar';
  toolbar.hidden = true;

  const copyButton = document.createElement('button');
  copyButton.type = 'button';
  copyButton.className = 'ood-selection-toolbar-btn';
  copyButton.textContent = 'Copy';

  // Pasting needs the async Clipboard API; don't offer a button that can't work.
  const pasteButton = document.createElement('button');
  pasteButton.type = 'button';
  pasteButton.className = 'ood-selection-toolbar-btn';
  pasteButton.textContent = 'Paste';
  pasteButton.hidden = !(navigator.clipboard && navigator.clipboard.readText);

  toolbar.appendChild(copyButton);
  toolbar.appendChild(pasteButton);
  document.body.appendChild(toolbar);

  /** Hides the toolbar. */
  const hideToolbar = function () {
    toolbar.hidden = true;
  };

  /**
   * Places the toolbar above the selection, or below it when there is no
   * room, and keeps it inside the viewport. Runs in an animation frame
   * because selectionchange fires on every pointer move while dragging.
   */
  const placeToolbar = function () {
    pendingFrame = null;
    // The selection can change while the frame is pending.
    if (!that.hasActiveSelection(term)) {
      hideToolbar();
      return;
    }

    const rect = termDocument.getSelection().getRangeAt(0)
      .getBoundingClientRect();
    const iframe = termDocument.defaultView.frameElement;
    const iframeRect = iframe ?
        iframe.getBoundingClientRect() : { top: 0, left: 0 };

    toolbar.hidden = false;
    const toolbarRect = toolbar.getBoundingClientRect();

    let top = iframeRect.top + rect.top - toolbarRect.height - 8;
    if (top < 0) {
      top = iframeRect.top + rect.bottom + 8;
    }
    const centered = iframeRect.left + rect.left +
        (rect.width / 2) - (toolbarRect.width / 2);
    const left = Math.max(4,
        Math.min(centered, window.innerWidth - toolbarRect.width - 4));

    toolbar.style.top = `${Math.round(top)}px`;
    toolbar.style.left = `${Math.round(left)}px`;

    // Remember the text now: the browser may drop the selection when a
    // button outside the iframe is tapped.
    selectedText = term.getSelectionText();
  };

  /** Queues a single toolbar placement for the next animation frame. */
  const scheduleToolbar = function () {
    if (pendingFrame === null) {
      pendingFrame = window.requestAnimationFrame(placeToolbar);
    }
  };

  termDocument.addEventListener('selectionchange', function () {
    if (coarsePointer && coarsePointer.matches &&
        that.hasActiveSelection(term)) {
      scheduleToolbar();
    } else {
      hideToolbar();
    }
  });

  // Buttons use click rather than touch handlers: preventDefault() on a touch
  // event also suppresses the click that follows it.
  copyButton.addEventListener('click', function () {
    if (selectedText) {
      // hterm tries the async Clipboard API first, then execCommand('copy').
      term.copyStringToClipboard(selectedText);
    }
    const selection = termDocument.getSelection();
    if (selection) {
      selection.collapseToEnd();
    }
    hideToolbar();
  });

  pasteButton.addEventListener('click', function () {
    term.paste();
    hideToolbar();
  });

  // The on-screen keyboard and pinch zoom move the selection on screen.
  if (window.visualViewport) {
    window.visualViewport.addEventListener('resize', function () {
      if (!toolbar.hidden) {
        scheduleToolbar();
      }
    });
  }
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
