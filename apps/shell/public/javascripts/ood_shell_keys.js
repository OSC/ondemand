'use strict';

/*
 * On-screen terminal keys for touch devices.
 *
 * Phone and tablet soft keyboards have no Esc, Ctrl or arrow keys, which makes
 * vim, emacs, less and job control (Ctrl-C, Ctrl-Z) unusable. This adds a
 * toolbar with those keys plus sticky Ctrl/Alt modifiers that apply to the next
 * character typed on the soft keyboard.
 *
 * The key encoding is pure (no DOM) so it can be unit tested under Node.
 */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory();
  } else {
    root.OodShellKeys = factory();
  }
}(typeof self !== 'undefined' ? self : this, function () {
  const ESC = '\x1b';

  const REPEAT_DELAY_MS = 400;
  const REPEAT_INTERVAL_MS = 60;
  // Ignore the click that follows a pointer press we've already handled.
  const CLICK_DEDUPE_MS = 1000;

  // Cursor-style keys: final byte of the CSI/SS3 sequence.
  const CURSOR_KEYS = {
    up: 'A',
    down: 'B',
    right: 'C',
    left: 'D',
    home: 'H',
    end: 'F'
  };

  // Keys sent as CSI <n> ~
  const TILDE_KEYS = {
    pageup: 5,
    pagedown: 6
  };

  // Control character for a single typed character, or null if it has none.
  // Follows xterm: Ctrl-A..Z, Ctrl-Space/@ = NUL, Ctrl-[ = ESC, and so on.
  function ctrlChar(ch) {
    if (typeof ch !== 'string' || ch.length !== 1) {
      return null;
    }

    const code = ch.charCodeAt(0);
    if ((code >= 0x41 && code <= 0x5a) || (code >= 0x61 && code <= 0x7a)) {
      return String.fromCharCode(code & 0x1f);
    }

    switch (ch) {
      case ' ':
      case '@':
      case '`':
      case '2':
        return '\x00';
      case '[':
      case '{':
      case '3':
        return '\x1b';
      case '\\':
      case '|':
      case '4':
        return '\x1c';
      case ']':
      case '}':
      case '5':
        return '\x1d';
      case '^':
      case '~':
      case '6':
        return '\x1e';
      case '_':
      case '/':
      case '7':
        return '\x1f';
      case '?':
      case '8':
        return '\x7f';
      default:
        return null;
    }
  }

  // xterm modifier parameter: 1 + alt(2) + ctrl(4). 1 means no modifiers.
  function modifierParam(mods) {
    return 1 + (mods.alt ? 2 : 0) + (mods.ctrl ? 4 : 0);
  }

  // Apply modifiers to text typed on the soft keyboard. Only single characters
  // are transformed; anything longer (autocomplete, paste) passes through.
  function applyModifiers(str, mods) {
    if (!mods || (!mods.ctrl && !mods.alt) || str.length !== 1) {
      return str;
    }

    let out = str;
    if (mods.ctrl) {
      const control = ctrlChar(str);
      if (control !== null) {
        out = control;
      }
    }
    // Alt sends ESC first, which is how readline and emacs read Meta.
    return mods.alt ? ESC + out : out;
  }

  // Bytes for a named key, or null if the name is unknown.
  // appCursor is hterm's DECCKM state, which vim/emacs/less turn on.
  function encodeKey(name, mods, appCursor) {
    mods = mods || {};
    const param = modifierParam(mods);

    if (Object.prototype.hasOwnProperty.call(CURSOR_KEYS, name)) {
      const final = CURSOR_KEYS[name];
      if (param > 1) {
        return ESC + '[1;' + param + final;
      }
      return ESC + (appCursor ? 'O' : '[') + final;
    }

    if (Object.prototype.hasOwnProperty.call(TILDE_KEYS, name)) {
      const code = TILDE_KEYS[name];
      return ESC + '[' + code + (param > 1 ? ';' + param : '') + '~';
    }

    if (name === 'esc') {
      return mods.alt ? ESC + ESC : ESC;
    }

    if (name === 'tab') {
      return mods.alt ? ESC + '\t' : '\t';
    }

    if (name === 'backtab') {
      return ESC + (param > 1 ? '[1;' + (param + 1) : '[') + 'Z';
    }

    return null;
  }

  // Sticky modifier state: off -> once (next key only) -> lock -> off.
  const NEXT_STATE = { off: 'once', once: 'lock', lock: 'off' };

  function ModifierState() {
    this.ctrl = 'off';
    this.alt = 'off';
  }

  ModifierState.prototype.cycle = function (name) {
    if (name === 'ctrl' || name === 'alt') {
      this[name] = NEXT_STATE[this[name]];
    }
  };

  ModifierState.prototype.active = function () {
    return { ctrl: this.ctrl !== 'off', alt: this.alt !== 'off' };
  };

  // One-shot modifiers are used up by a key press; locked ones stay on.
  ModifierState.prototype.consume = function () {
    if (this.ctrl === 'once') {
      this.ctrl = 'off';
    }
    if (this.alt === 'once') {
      this.alt = 'off';
    }
  };

  // Capture releases even when a pressed button's pointer leaves the toolbar.
  function capturePointer(button, pointerId) {
    if (typeof window.PointerEvent === 'function' &&
        typeof button.setPointerCapture === 'function') {
      try {
        button.setPointerCapture(pointerId);
      } catch (err) {
        return false;
      }
    }
    return true;
  }

  // Release capture only while this button still owns it.
  function releasePointer(button, pointerId) {
    if (button && typeof button.hasPointerCapture === 'function' &&
        button.hasPointerCapture(pointerId)) {
      button.releasePointerCapture(pointerId);
    }
  }

  /*
   * toolbar: the element holding the buttons, or null to run without a DOM.
   * options.send(str): sends bytes to the terminal; false rejects the key
   *   without consuming a one-shot modifier.
   * options.applicationCursor(): true when the terminal is in application
   *   cursor key mode.
   * options.focus(): restores terminal focus before a toolbar key.
   * options.enabled / visible: initial readiness and visibility.
   * options.compact: initially hide secondary keys behind More.
   * options.toggle: optional show/hide button.
   * options.onVisibilityChange(visible): saves a user-selected visibility.
   */
  function OodShellKeys(toolbar, options) {
    options = options || {};
    this.toolbar = toolbar || null;
    this.send = options.send || function () {};
    this.applicationCursor = options.applicationCursor || function () { return false; };
    this.focus = options.focus || function () {};
    this.toggle = options.toggle || null;
    this.onVisibilityChange = options.onVisibilityChange || function () {};
    this.enabled = options.enabled !== false;
    this.visible = options.visible !== false;
    this.state = new ModifierState();
    this.repeatDelay = null;
    this.repeatTimer = null;
    this.repeatPointer = null;
    this.repeatButton = null;
    this.lastPresses = new Map();
    this.pendingPresses = new Map();
    this.compact = null;
    this.expanded = false;
    this.extra = this.toolbar && this.toolbar.querySelector('.mobile-keys-extra');
    this.more = this.toolbar && this.toolbar.querySelector('[data-action="more"]');

    if (this.toolbar) {
      this.bind();
      this.setEnabled(this.enabled);
      this.setVisible(this.visible);
      this.setCompact(options.compact === true);
    }
  }

  // Called with text from the keyboard. Applies and then uses up any armed
  // modifiers; returns the string to send.
  OodShellKeys.prototype.transform = function (str) {
    const mods = this.state.active();
    if (!this.enabled || (!mods.ctrl && !mods.alt)) {
      return str;
    }

    const out = applyModifiers(str, mods);
    this.state.consume();
    this.render();
    return out;
  };

  OodShellKeys.prototype.pressKey = function (name) {
    if (!this.enabled) {
      return;
    }
    const seq = encodeKey(name, this.state.active(), this.applicationCursor());
    if (seq === null) {
      return;
    }
    if (this.send(seq) === false) {
      return;
    }
    this.state.consume();
    this.render();
  };

  OodShellKeys.prototype.pressText = function (text) {
    if (!this.enabled || this.send(applyModifiers(text, this.state.active())) === false) {
      return;
    }
    this.state.consume();
    this.render();
  };

  // One-tap control shortcuts such as ^C. Armed modifiers don't apply.
  OodShellKeys.prototype.pressControl = function (letter) {
    if (!this.enabled) {
      return;
    }
    const control = ctrlChar(letter);
    if (control === null) {
      return;
    }
    if (this.send(control) === false) {
      return;
    }
    this.state.consume();
    this.render();
  };

  OodShellKeys.prototype.toggleModifier = function (name) {
    if (!this.enabled) {
      return;
    }
    this.state.cycle(name);
    this.render();
  };

  OodShellKeys.prototype.activate = function (button) {
    if (!this.enabled || button.disabled) {
      return;
    }
    if (button === this.toggle) {
      this.setVisible(!this.visible);
      this.onVisibilityChange(this.visible);
      return;
    }
    if (button === this.more) {
      this.expanded = !this.expanded;
      this.renderLayout();
      return;
    }
    this.focus();
    const data = button.dataset;
    if (data.mod) {
      this.toggleModifier(data.mod);
    } else if (data.key) {
      this.pressKey(data.key);
    } else if (data.ctrl) {
      this.pressControl(data.ctrl);
    } else if (data.text) {
      this.pressText(data.text);
    }
  };

  OodShellKeys.prototype.startRepeat = function (callback, pointerId, button) {
    const that = this;
    this.stopRepeat();
    this.repeatPointer = pointerId;
    this.repeatButton = button;
    if (button && !capturePointer(button, pointerId)) {
      // A focus transition may have ended the pointer before capture.
      this.stopRepeat();
      return;
    }
    this.repeatDelay = setTimeout(function () {
      that.repeatDelay = null;
      that.repeatTimer = setInterval(callback, REPEAT_INTERVAL_MS);
      callback();
    }, REPEAT_DELAY_MS);
  };

  OodShellKeys.prototype.stopRepeat = function () {
    clearTimeout(this.repeatDelay);
    clearInterval(this.repeatTimer);
    this.repeatDelay = null;
    this.repeatTimer = null;
    const button = this.repeatButton;
    const pointerId = this.repeatPointer;
    this.repeatButton = null;
    this.repeatPointer = null;
    releasePointer(button, pointerId);
  };

  // Abandon release-activated keys when the page or controls become inactive.
  OodShellKeys.prototype.cancelPresses = function () {
    const presses = Array.from(this.pendingPresses);
    this.pendingPresses.clear();
    presses.forEach(function (press) { releasePointer(press[1], press[0]); });
  };

  OodShellKeys.prototype.buttonFor = function (target) {
    if (!target || typeof target.closest !== 'function') {
      return null;
    }
    const button = target.closest('button');
    return button && (this.toolbar.contains(button) || button === this.toggle) ? button : null;
  };

  OodShellKeys.prototype.bind = function () {
    const that = this;
    const toolbar = this.toolbar;
    const surfaces = this.toggle ? [toolbar, this.toggle] : [toolbar];
    const listen = function (type, handler, options) {
      surfaces.forEach(function (element) {
        element.addEventListener(type, handler, options);
      });
    };

    // Tapping a key must not take focus from the terminal, or the soft
    // keyboard closes.
    const keepFocus = function (ev) {
      ev.preventDefault();
    };
    listen('mousedown', keepFocus);
    // Holding a key repeats it; don't let a long press open a context menu.
    listen('contextmenu', keepFocus);

    // Act on press rather than release so keys feel immediate and arrows can
    // repeat while held.
    const press = function (ev) {
      if (ev.button !== undefined && ev.button !== 0) {
        return;
      }
      const button = that.buttonFor(ev.target);
      if (!button || !that.enabled || button.disabled) {
        return;
      }

      ev.preventDefault();
      that.lastPresses.set(button, { pointerId: ev.pointerId, time: Date.now() });
      if (button.dataset.mod || button.hasAttribute('data-repeat')) {
        that.activate(button);
        if (that.enabled && button.hasAttribute('data-repeat')) {
          that.startRepeat(function () { that.pressKey(button.dataset.key); }, ev.pointerId, button);
        }
      } else if (capturePointer(button, ev.pointerId)) {
        // In particular, ^C/^Z/^D must allow sliding away to cancel.
        that.pendingPresses.set(ev.pointerId, button);
      }
    };

    const release = function (ev) {
      that.lastPresses.forEach(function (press) {
        if (press.pointerId === ev.pointerId) {
          press.time = Date.now();
        }
      });
      const button = that.pendingPresses.get(ev.pointerId);
      that.pendingPresses.delete(ev.pointerId);
      if (button && !ev.cancelled &&
          that.buttonFor(document.elementFromPoint(ev.clientX, ev.clientY)) === button) {
        that.activate(button);
      }
      releasePointer(button, ev.pointerId);
      if (that.repeatPointer === ev.pointerId) {
        that.stopRepeat();
      }
    };

    if (typeof window.PointerEvent === 'function') {
      listen('touchstart', keepFocus, { passive: false });
      listen('pointerdown', press);
      window.addEventListener('pointerup', release);
      const cancel = function (ev) {
        release({ pointerId: ev.pointerId, cancelled: true });
      };
      window.addEventListener('pointercancel', cancel);
      toolbar.addEventListener('lostpointercapture', cancel);
      if (this.toggle) {
        this.toggle.addEventListener('lostpointercapture', cancel);
      }
    } else {
      // Preventing touchstart suppresses compatibility clicks. Handle the
      // touch itself when Pointer Events are unavailable.
      listen('touchstart', function (ev) {
        ev.preventDefault();
        Array.from(ev.changedTouches).forEach(function (touch) {
          press({ target: touch.target, pointerId: touch.identifier, preventDefault: function () {} });
        });
      }, { passive: false });
      const releaseTouches = function (ev) {
        Array.from(ev.changedTouches).forEach(function (touch) {
          release({
            pointerId: touch.identifier,
            clientX: touch.clientX,
            clientY: touch.clientY,
            cancelled: ev.type === 'touchcancel'
          });
        });
      };
      window.addEventListener('touchend', releaseTouches);
      window.addEventListener('touchcancel', releaseTouches);
      listen('mousedown', function (ev) {
        press({ target: ev.target, button: ev.button, pointerId: 'mouse', preventDefault: function () {} });
      });
      window.addEventListener('mouseup', function (ev) {
        release({ pointerId: 'mouse', clientX: ev.clientX, clientY: ev.clientY });
      });
    }

    window.addEventListener('blur', function () {
      that.stopRepeat();
      that.cancelPresses();
    });
    document.addEventListener('visibilitychange', function () {
      if (document.hidden) {
        that.stopRepeat();
        that.cancelPresses();
        that.resetModifiers();
      }
    });

    // Keyboard and screen reader activation arrive as clicks with no pointer
    // press (detail is 0 for keyboard). Skip clicks that follow a press we
    // already handled.
    listen('click', function (ev) {
      const button = that.buttonFor(ev.target);
      if (!button) {
        return;
      }
      const press = that.lastPresses.get(button);
      if (ev.detail !== 0 && press && Date.now() - press.time < CLICK_DEDUPE_MS) {
        that.lastPresses.delete(button);
        return;
      }
      that.activate(button);
    });
  };

  OodShellKeys.prototype.resetModifiers = function () {
    this.state = new ModifierState();
    this.render();
  };

  OodShellKeys.prototype.setEnabled = function (enabled) {
    this.enabled = enabled;
    if (!enabled) {
      this.stopRepeat();
      this.cancelPresses();
      this.resetModifiers();
    }
    if (this.toolbar) {
      this.toolbar.querySelectorAll('button').forEach(function (button) {
        button.disabled = !enabled;
      });
    }
    if (this.toggle) {
      this.toggle.disabled = !enabled;
    }
    this.render();
  };

  OodShellKeys.prototype.setVisible = function (visible) {
    this.visible = visible;
    if (!visible) {
      this.stopRepeat();
      this.cancelPresses();
      this.resetModifiers();
    }
    if (this.toolbar) {
      this.toolbar.hidden = !visible;
    }
    if (this.toggle) {
      this.toggle.setAttribute('aria-expanded', String(visible));
    }
  };

  // Collapse secondary keys when the available viewport becomes short.
  OodShellKeys.prototype.setCompact = function (compact) {
    if (this.compact === compact) {
      return;
    }
    this.compact = compact;
    this.expanded = false;
    this.cancelPresses();
    this.renderLayout();
  };

  // Keep all keys available without narrowing the primary touch targets.
  OodShellKeys.prototype.renderLayout = function () {
    if (this.extra && this.more) {
      this.extra.hidden = this.compact && !this.expanded;
      this.more.hidden = !this.compact;
      this.more.textContent = this.expanded ? 'Less' : 'More';
      this.more.setAttribute('aria-expanded', String(!this.extra.hidden));
    }
  };

  OodShellKeys.prototype.render = function () {
    if (!this.toolbar) {
      return;
    }

    const that = this;
    ['ctrl', 'alt'].forEach(function (name) {
      const button = that.toolbar.querySelector('[data-mod="' + name + '"]');
      if (!button) {
        return;
      }
      const state = that.state[name];
      const description = that.toolbar.querySelector('#mobile_' + name + '_state');
      const states = { off: 'Off.', once: 'Applies to the next key.', lock: 'Locked on.' };
      button.setAttribute('aria-pressed', state === 'off' ? 'false' : 'true');
      button.setAttribute('data-state', state);
      if (description) {
        description.textContent = states[state];
      }
    });
  };

  // Hide the toolbar, e.g. once the connection is closed.
  OodShellKeys.prototype.disable = function () {
    this.setEnabled(false);
    this.setVisible(false);
  };

  OodShellKeys.ctrlChar = ctrlChar;
  OodShellKeys.applyModifiers = applyModifiers;
  OodShellKeys.encodeKey = encodeKey;
  OodShellKeys.ModifierState = ModifierState;

  return OodShellKeys;
}));
