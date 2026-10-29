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

    // Provide selection and clipboard controls for touch devices.
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
 * Offer an explicit selection mode on touch devices. hterm cancels the
 * default touch gestures used by mobile browsers for selection. In selection
 * mode, stop those events before they reach hterm without cancelling their
 * browser defaults. hterm's normal touch scrolling resumes when mode ends.
 */
OodShell.prototype.installMobileSelection = function (term) {
  const termDocument = term.getDocument();
  const screen = termDocument.querySelector('x-screen');
  const coarse = window.matchMedia && window.matchMedia('(pointer: coarse)').matches;
  if (!screen || !(coarse || navigator.maxTouchPoints > 0)) {
    return;
  }

  const toolbar = document.createElement('div');
  toolbar.className = 'ood-selection-toolbar';
  toolbar.setAttribute('role', 'group');
  toolbar.setAttribute('aria-label', 'Mobile terminal controls');
  const makeButton = function (label) {
    const button = document.createElement('button');
    button.type = 'button';
    button.className = 'ood-selection-toolbar-btn';
    button.textContent = label;
    toolbar.appendChild(button);
    return button;
  };
  const selectButton = makeButton('Select text');
  const copyButton = makeButton('Copy');
  const pasteButton = makeButton('Paste');
  const status = document.createElement('span');
  status.className = 'ood-selection-toolbar-status';
  status.setAttribute('role', 'status');
  toolbar.appendChild(status);
  // Keep the controls in the terminal layout rather than covering the shell
  // menu or terminal text. hterm appends this iframe directly to the element.
  this.element.insertBefore(toolbar, termDocument.defaultView.frameElement);

  const clipboard = navigator.clipboard;
  const canCopy = clipboard && typeof clipboard.writeText === 'function';
  const canPaste = clipboard && typeof clipboard.readText === 'function';
  copyButton.disabled = true;
  pasteButton.disabled = !canPaste;
  if (!canPaste) {
    pasteButton.title = 'Clipboard paste is unavailable in this browser or connection';
  }

  let selecting = false;
  let selectedText = null;
  let buttonTouch = false;
  let releaseTimer = null;
  let previousEditable;
  let previousDefaultCopy;
  let previousOverscrollBehavior;
  let selectionVersion = 0;
  let selectionSession = 0;

  const updateSelection = () => {
    selectionVersion++;
    if (!selecting || !this.hasActiveSelection(term)) {
      // A tap on Copy can move focus and collapse the iframe selection before
      // its click event; keep the snapshot until that gesture finishes.
      if (!buttonTouch) {
        selectedText = null;
        copyButton.disabled = true;
      }
      return;
    }
    selectedText = term.getSelectionText();
    copyButton.disabled = !selectedText || !canCopy;
  };

  const endSelection = () => {
    selecting = false;
    selectionSession++;
    window.clearTimeout(releaseTimer);
    buttonTouch = false;
    screen.style.overscrollBehavior = previousOverscrollBehavior;
    if (previousEditable === null) {
      screen.removeAttribute('contenteditable');
    } else {
      screen.setAttribute('contenteditable', previousEditable);
    }
    term.useDefaultWindowCopy = previousDefaultCopy;
    selectButton.textContent = 'Select text';
    selectButton.setAttribute('aria-pressed', 'false');
    selectedText = null;
    copyButton.disabled = true;
    const selection = termDocument.getSelection();
    if (selection && selection.rangeCount) {
      selection.removeAllRanges();
    }
  };

  selectButton.setAttribute('aria-pressed', 'false');
  selectButton.addEventListener('click', () => {
    if (selecting) {
      endSelection();
      status.textContent = '';
      return;
    }
    selecting = true;
    selectionSession++;
    previousOverscrollBehavior = screen.style.overscrollBehavior;
    screen.style.overscrollBehavior = 'contain';
    previousEditable = screen.getAttribute('contenteditable');
    previousDefaultCopy = term.useDefaultWindowCopy;
    // Avoid opening the keyboard or allowing edits to hterm's rendered rows.
    term.blur();
    screen.setAttribute('contenteditable', 'false');
    // Let the browser's own selection menu copy normally in this mode.
    term.useDefaultWindowCopy = true;
    selectButton.textContent = 'Done';
    selectButton.setAttribute('aria-pressed', 'true');
    status.textContent = 'Touch and hold text to select it. Use the browser Copy menu if Copy is unavailable.';
  });

  // Registered before installTouchKeyboard's capture listeners. Stopping
  // propagation, rather than preventing defaults, permits native selection.
  ['touchstart', 'touchmove', 'touchend', 'touchcancel'].forEach((type) => {
    screen.addEventListener(type, (event) => {
      if (selecting) {
        event.stopImmediatePropagation();
      }
    }, { capture: true, passive: true });
  });
  termDocument.addEventListener('selectionchange', updateSelection);
  copyButton.addEventListener('touchstart', () => {
    window.clearTimeout(releaseTimer);
    buttonTouch = true;
  }, { passive: true });
  copyButton.addEventListener('touchend', () => {
    // A cancelled tap may produce no click. Do not retain a stale snapshot.
    releaseTimer = window.setTimeout(() => {
      buttonTouch = false;
      updateSelection();
    }, 1000);
  }, { passive: true });
  copyButton.addEventListener('touchcancel', () => {
    window.clearTimeout(releaseTimer);
    buttonTouch = false;
    updateSelection();
  }, { passive: true });
  copyButton.addEventListener('click', () => {
    const text = selectedText;
    window.clearTimeout(releaseTimer);
    buttonTouch = false;
    if (!text || !canCopy) {
      updateSelection();
      return;
    }
    // Call writeText directly in the click handler to retain user activation.
    // Do not clear a newer selection while the clipboard request is pending.
    const session = selectionSession;
    const version = selectionVersion;
    const copyFailed = () => {
      status.textContent = 'Copy failed. Select text again and use the browser Copy menu.';
      updateSelection();
    };
    try {
      clipboard.writeText(text).then(() => {
        if (selecting && session === selectionSession && version === selectionVersion) {
          endSelection();
        }
        status.textContent = 'Copied.';
      }).catch(copyFailed);
    } catch (error) {
      copyFailed();
    }
  });
  pasteButton.addEventListener('click', () => {
    if (!canPaste) return;
    // hterm's paste() does not expose or handle readText rejection. Its paste
    // data handler preserves its newline and bracketed-paste processing.
    const pasteFailed = () => {
      status.textContent = 'Paste failed. Check clipboard permission.';
    };
    try {
      clipboard.readText().then((text) => {
        term.onPasteData_(text);
        status.textContent = 'Pasted.';
      }).catch(pasteFailed);
    } catch (error) {
      pasteFailed();
    }
  });
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
