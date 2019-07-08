'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _logging = require('../core/util/logging.js');

var Log = _interopRequireWildcard(_logging);

var _localization = require('./localization.js');

var _localization2 = _interopRequireDefault(_localization);

var _browser = require('../core/util/browser.js');

var _events = require('../core/util/events.js');

var _keysym = require('../core/input/keysym.js');

var _keysym2 = _interopRequireDefault(_keysym);

var _keysymdef = require('../core/input/keysymdef.js');

var _keysymdef2 = _interopRequireDefault(_keysymdef);

var _keyboard = require('../core/input/keyboard.js');

var _keyboard2 = _interopRequireDefault(_keyboard);

var _rfb = require('../core/rfb.js');

var _rfb2 = _interopRequireDefault(_rfb);

var _display = require('../core/display.js');

var _display2 = _interopRequireDefault(_display);

var _webutil = require('./webutil.js');

var WebUtil = _interopRequireWildcard(_webutil);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

/*
 * noVNC: HTML5 VNC client
 * Copyright (C) 2012 Joel Martin
 * Copyright (C) 2016 Samuel Mannehed for Cendio AB
 * Copyright (C) 2016 Pierre Ossman for Cendio AB
 * Licensed under MPL 2.0 (see LICENSE.txt)
 *
 * See README.md for usage and integration instructions.
 */

var UI = {

    connected: false,
    desktopName: "",

    statusTimeout: null,
    hideKeyboardTimeout: null,
    idleControlbarTimeout: null,
    closeControlbarTimeout: null,

    controlbarGrabbed: false,
    controlbarDrag: false,
    controlbarMouseDownClientY: 0,
    controlbarMouseDownOffsetY: 0,

    isSafari: false,
    lastKeyboardinput: null,
    defaultKeyboardinputLen: 100,

    inhibit_reconnect: true,
    reconnect_callback: null,
    reconnect_password: null,

    prime: function (callback) {
        if (document.readyState === "interactive" || document.readyState === "complete") {
            UI.load(callback);
        } else {
            document.addEventListener('DOMContentLoaded', UI.load.bind(UI, callback));
        }
    },

    // Setup rfb object, load settings from browser storage, then call
    // UI.init to setup the UI/menus
    load: function (callback) {
        WebUtil.initSettings(UI.start, callback);
    },

    // Render default UI and initialize settings menu
    start: function (callback) {

        // Setup global variables first
        UI.isSafari = navigator.userAgent.indexOf('Safari') !== -1 && navigator.userAgent.indexOf('Chrome') === -1;

        UI.initSettings();

        // Translate the DOM
        _localization.l10n.translateDOM();

        // Adapt the interface for touch screen devices
        if (_browser.isTouchDevice) {
            document.documentElement.classList.add("noVNC_touch");
            // Remove the address bar
            setTimeout(function () {
                window.scrollTo(0, 1);
            }, 100);
        }

        // Restore control bar position
        if (WebUtil.readSetting('controlbar_pos') === 'right') {
            UI.toggleControlbarSide();
        }

        UI.initFullscreen();

        // Setup event handlers
        UI.addControlbarHandlers();
        UI.addTouchSpecificHandlers();
        UI.addExtraKeysHandlers();
        UI.addMachineHandlers();
        UI.addConnectionControlHandlers();
        UI.addClipboardHandlers();
        UI.addSettingsHandlers();
        document.getElementById("noVNC_status").addEventListener('click', UI.hideStatus);

        // Bootstrap fallback input handler
        UI.keyboardinputReset();

        UI.openControlbar();

        UI.updateVisualState('init');

        document.documentElement.classList.remove("noVNC_loading");

        var autoconnect = WebUtil.getConfigVar('autoconnect', false);
        if (autoconnect === 'true' || autoconnect == '1') {
            autoconnect = true;
            UI.connect();
        } else {
            autoconnect = false;
            // Show the connect panel on first load unless autoconnecting
            UI.openConnectPanel();
        }

        if (typeof callback === "function") {
            callback(UI.rfb);
        }
    },

    initFullscreen: function () {
        // Only show the button if fullscreen is properly supported
        // * Safari doesn't support alphanumerical input while in fullscreen
        if (!UI.isSafari && (document.documentElement.requestFullscreen || document.documentElement.mozRequestFullScreen || document.documentElement.webkitRequestFullscreen || document.body.msRequestFullscreen)) {
            document.getElementById('noVNC_fullscreen_button').classList.remove("noVNC_hidden");
            UI.addFullscreenHandlers();
        }
    },

    initSettings: function () {
        var i;

        // Logging selection dropdown
        var llevels = ['error', 'warn', 'info', 'debug'];
        for (i = 0; i < llevels.length; i += 1) {
            UI.addOption(document.getElementById('noVNC_setting_logging'), llevels[i], llevels[i]);
        }

        // Settings with immediate effects
        UI.initSetting('logging', 'warn');
        UI.updateLogging();

        // if port == 80 (or 443) then it won't be present and should be
        // set manually
        var port = window.location.port;
        if (!port) {
            if (window.location.protocol.substring(0, 5) == 'https') {
                port = 443;
            } else if (window.location.protocol.substring(0, 4) == 'http') {
                port = 80;
            }
        }

        /* Populate the controls if defaults are provided in the URL */
        UI.initSetting('host', window.location.hostname);
        UI.initSetting('port', port);
        UI.initSetting('encrypt', window.location.protocol === "https:");
        UI.initSetting('view_clip', false);
        UI.initSetting('resize', 'off');
        UI.initSetting('shared', true);
        UI.initSetting('view_only', false);
        UI.initSetting('path', 'websockify');
        UI.initSetting('repeaterID', '');
        UI.initSetting('reconnect', false);
        UI.initSetting('reconnect_delay', 5000);

        UI.setupSettingLabels();
    },
    // Adds a link to the label elements on the corresponding input elements
    setupSettingLabels: function () {
        var labels = document.getElementsByTagName('LABEL');
        for (var i = 0; i < labels.length; i++) {
            var htmlFor = labels[i].htmlFor;
            if (htmlFor != '') {
                var elem = document.getElementById(htmlFor);
                if (elem) elem.label = labels[i];
            } else {
                // If 'for' isn't set, use the first input element child
                var children = labels[i].children;
                for (var j = 0; j < children.length; j++) {
                    if (children[j].form !== undefined) {
                        children[j].label = labels[i];
                        break;
                    }
                }
            }
        }
    },

    /* ------^-------
    *     /INIT
    * ==============
    * EVENT HANDLERS
    * ------v------*/

    addControlbarHandlers: function () {
        document.getElementById("noVNC_control_bar").addEventListener('mousemove', UI.activateControlbar);
        document.getElementById("noVNC_control_bar").addEventListener('mouseup', UI.activateControlbar);
        document.getElementById("noVNC_control_bar").addEventListener('mousedown', UI.activateControlbar);
        document.getElementById("noVNC_control_bar").addEventListener('keydown', UI.activateControlbar);

        document.getElementById("noVNC_control_bar").addEventListener('mousedown', UI.keepControlbar);
        document.getElementById("noVNC_control_bar").addEventListener('keydown', UI.keepControlbar);

        document.getElementById("noVNC_view_drag_button").addEventListener('click', UI.toggleViewDrag);

        document.getElementById("noVNC_control_bar_handle").addEventListener('mousedown', UI.controlbarHandleMouseDown);
        document.getElementById("noVNC_control_bar_handle").addEventListener('mouseup', UI.controlbarHandleMouseUp);
        document.getElementById("noVNC_control_bar_handle").addEventListener('mousemove', UI.dragControlbarHandle);
        // resize events aren't available for elements
        window.addEventListener('resize', UI.updateControlbarHandle);

        var exps = document.getElementsByClassName("noVNC_expander");
        for (var i = 0; i < exps.length; i++) {
            exps[i].addEventListener('click', UI.toggleExpander);
        }
    },

    addTouchSpecificHandlers: function () {
        document.getElementById("noVNC_mouse_button0").addEventListener('click', function () {
            UI.setMouseButton(1);
        });
        document.getElementById("noVNC_mouse_button1").addEventListener('click', function () {
            UI.setMouseButton(2);
        });
        document.getElementById("noVNC_mouse_button2").addEventListener('click', function () {
            UI.setMouseButton(4);
        });
        document.getElementById("noVNC_mouse_button4").addEventListener('click', function () {
            UI.setMouseButton(0);
        });
        document.getElementById("noVNC_keyboard_button").addEventListener('click', UI.toggleVirtualKeyboard);

        UI.touchKeyboard = new _keyboard2.default(document.getElementById('noVNC_keyboardinput'));
        UI.touchKeyboard.onkeyevent = UI.keyEvent;
        UI.touchKeyboard.grab();
        document.getElementById("noVNC_keyboardinput").addEventListener('input', UI.keyInput);
        document.getElementById("noVNC_keyboardinput").addEventListener('focus', UI.onfocusVirtualKeyboard);
        document.getElementById("noVNC_keyboardinput").addEventListener('blur', UI.onblurVirtualKeyboard);
        document.getElementById("noVNC_keyboardinput").addEventListener('submit', function () {
            return false;
        });

        document.documentElement.addEventListener('mousedown', UI.keepVirtualKeyboard, true);

        document.getElementById("noVNC_control_bar").addEventListener('touchstart', UI.activateControlbar);
        document.getElementById("noVNC_control_bar").addEventListener('touchmove', UI.activateControlbar);
        document.getElementById("noVNC_control_bar").addEventListener('touchend', UI.activateControlbar);
        document.getElementById("noVNC_control_bar").addEventListener('input', UI.activateControlbar);

        document.getElementById("noVNC_control_bar").addEventListener('touchstart', UI.keepControlbar);
        document.getElementById("noVNC_control_bar").addEventListener('input', UI.keepControlbar);

        document.getElementById("noVNC_control_bar_handle").addEventListener('touchstart', UI.controlbarHandleMouseDown);
        document.getElementById("noVNC_control_bar_handle").addEventListener('touchend', UI.controlbarHandleMouseUp);
        document.getElementById("noVNC_control_bar_handle").addEventListener('touchmove', UI.dragControlbarHandle);
    },

    addExtraKeysHandlers: function () {
        document.getElementById("noVNC_toggle_extra_keys_button").addEventListener('click', UI.toggleExtraKeys);
        document.getElementById("noVNC_toggle_ctrl_button").addEventListener('click', UI.toggleCtrl);
        document.getElementById("noVNC_toggle_alt_button").addEventListener('click', UI.toggleAlt);
        document.getElementById("noVNC_send_tab_button").addEventListener('click', UI.sendTab);
        document.getElementById("noVNC_send_esc_button").addEventListener('click', UI.sendEsc);
        document.getElementById("noVNC_send_ctrl_alt_del_button").addEventListener('click', UI.sendCtrlAltDel);
    },

    addMachineHandlers: function () {
        document.getElementById("noVNC_shutdown_button").addEventListener('click', function () {
            UI.rfb.machineShutdown();
        });
        document.getElementById("noVNC_reboot_button").addEventListener('click', function () {
            UI.rfb.machineReboot();
        });
        document.getElementById("noVNC_reset_button").addEventListener('click', function () {
            UI.rfb.machineReset();
        });
        document.getElementById("noVNC_power_button").addEventListener('click', UI.togglePowerPanel);
    },

    addConnectionControlHandlers: function () {
        document.getElementById("noVNC_disconnect_button").addEventListener('click', UI.disconnect);
        document.getElementById("noVNC_connect_button").addEventListener('click', UI.connect);
        document.getElementById("noVNC_cancel_reconnect_button").addEventListener('click', UI.cancelReconnect);

        document.getElementById("noVNC_password_button").addEventListener('click', UI.setPassword);
    },

    addClipboardHandlers: function () {
        document.getElementById("noVNC_clipboard_button").addEventListener('click', UI.toggleClipboardPanel);
        document.getElementById("noVNC_clipboard_text").addEventListener('change', UI.clipboardSend);
        document.getElementById("noVNC_clipboard_clear_button").addEventListener('click', UI.clipboardClear);
    },

    // Add a call to save settings when the element changes,
    // unless the optional parameter changeFunc is used instead.
    addSettingChangeHandler: function (name, changeFunc) {
        var settingElem = document.getElementById("noVNC_setting_" + name);
        if (changeFunc === undefined) {
            changeFunc = function () {
                UI.saveSetting(name);
            };
        }
        settingElem.addEventListener('change', changeFunc);
    },

    addSettingsHandlers: function () {
        document.getElementById("noVNC_settings_button").addEventListener('click', UI.toggleSettingsPanel);

        UI.addSettingChangeHandler('encrypt');
        UI.addSettingChangeHandler('resize');
        UI.addSettingChangeHandler('resize', UI.enableDisableViewClip);
        UI.addSettingChangeHandler('resize', UI.applyResizeMode);
        UI.addSettingChangeHandler('view_clip');
        UI.addSettingChangeHandler('view_clip', UI.updateViewClip);
        UI.addSettingChangeHandler('shared');
        UI.addSettingChangeHandler('view_only');
        UI.addSettingChangeHandler('view_only', UI.updateViewOnly);
        UI.addSettingChangeHandler('host');
        UI.addSettingChangeHandler('port');
        UI.addSettingChangeHandler('path');
        UI.addSettingChangeHandler('repeaterID');
        UI.addSettingChangeHandler('logging');
        UI.addSettingChangeHandler('logging', UI.updateLogging);
        UI.addSettingChangeHandler('reconnect');
        UI.addSettingChangeHandler('reconnect_delay');
    },

    addFullscreenHandlers: function () {
        document.getElementById("noVNC_fullscreen_button").addEventListener('click', UI.toggleFullscreen);

        window.addEventListener('fullscreenchange', UI.updateFullscreenButton);
        window.addEventListener('mozfullscreenchange', UI.updateFullscreenButton);
        window.addEventListener('webkitfullscreenchange', UI.updateFullscreenButton);
        window.addEventListener('msfullscreenchange', UI.updateFullscreenButton);
    },

    /* ------^-------
     * /EVENT HANDLERS
     * ==============
     *     VISUAL
     * ------v------*/

    // Disable/enable controls depending on connection state
    updateVisualState: function (state) {

        document.documentElement.classList.remove("noVNC_connecting");
        document.documentElement.classList.remove("noVNC_connected");
        document.documentElement.classList.remove("noVNC_disconnecting");
        document.documentElement.classList.remove("noVNC_reconnecting");

        let transition_elem = document.getElementById("noVNC_transition_text");
        switch (state) {
            case 'init':
                break;
            case 'connecting':
                transition_elem.textContent = (0, _localization2.default)("Connecting...");
                document.documentElement.classList.add("noVNC_connecting");
                break;
            case 'connected':
                document.documentElement.classList.add("noVNC_connected");
                break;
            case 'disconnecting':
                transition_elem.textContent = (0, _localization2.default)("Disconnecting...");
                document.documentElement.classList.add("noVNC_disconnecting");
                break;
            case 'disconnected':
                break;
            case 'reconnecting':
                transition_elem.textContent = (0, _localization2.default)("Reconnecting...");
                document.documentElement.classList.add("noVNC_reconnecting");
                break;
            default:
                Log.Error("Invalid visual state: " + state);
                UI.showStatus((0, _localization2.default)("Internal error"), 'error');
                return;
        }

        UI.enableDisableViewClip();

        if (UI.connected) {
            UI.disableSetting('encrypt');
            UI.disableSetting('shared');
            UI.disableSetting('host');
            UI.disableSetting('port');
            UI.disableSetting('path');
            UI.disableSetting('repeaterID');
            UI.setMouseButton(1);

            // Hide the controlbar after 2 seconds
            UI.closeControlbarTimeout = setTimeout(UI.closeControlbar, 2000);
        } else {
            UI.enableSetting('encrypt');
            UI.enableSetting('shared');
            UI.enableSetting('host');
            UI.enableSetting('port');
            UI.enableSetting('path');
            UI.enableSetting('repeaterID');
            UI.updatePowerButton();
            UI.keepControlbar();
        }

        // State change disables viewport dragging.
        // It is enabled (toggled) by direct click on the button
        UI.setViewDrag(false);

        // State change also closes the password dialog
        document.getElementById('noVNC_password_dlg').classList.remove('noVNC_open');
    },

    showStatus: function (text, status_type, time) {
        var statusElem = document.getElementById('noVNC_status');

        clearTimeout(UI.statusTimeout);

        if (typeof status_type === 'undefined') {
            status_type = 'normal';
        }

        // Don't overwrite more severe visible statuses and never
        // errors. Only shows the first error.
        let visible_status_type = 'none';
        if (statusElem.classList.contains("noVNC_open")) {
            if (statusElem.classList.contains("noVNC_status_error")) {
                visible_status_type = 'error';
            } else if (statusElem.classList.contains("noVNC_status_warn")) {
                visible_status_type = 'warn';
            } else {
                visible_status_type = 'normal';
            }
        }
        if (visible_status_type === 'error' || visible_status_type === 'warn' && status_type === 'normal') {
            return;
        }

        switch (status_type) {
            case 'error':
                statusElem.classList.remove("noVNC_status_warn");
                statusElem.classList.remove("noVNC_status_normal");
                statusElem.classList.add("noVNC_status_error");
                break;
            case 'warning':
            case 'warn':
                statusElem.classList.remove("noVNC_status_error");
                statusElem.classList.remove("noVNC_status_normal");
                statusElem.classList.add("noVNC_status_warn");
                break;
            case 'normal':
            case 'info':
            default:
                statusElem.classList.remove("noVNC_status_error");
                statusElem.classList.remove("noVNC_status_warn");
                statusElem.classList.add("noVNC_status_normal");
                break;
        }

        statusElem.textContent = text;
        statusElem.classList.add("noVNC_open");

        // If no time was specified, show the status for 1.5 seconds
        if (typeof time === 'undefined') {
            time = 1500;
        }

        // Error messages do not timeout
        if (status_type !== 'error') {
            UI.statusTimeout = window.setTimeout(UI.hideStatus, time);
        }
    },

    hideStatus: function () {
        clearTimeout(UI.statusTimeout);
        document.getElementById('noVNC_status').classList.remove("noVNC_open");
    },

    activateControlbar: function (event) {
        clearTimeout(UI.idleControlbarTimeout);
        // We manipulate the anchor instead of the actual control
        // bar in order to avoid creating new a stacking group
        document.getElementById('noVNC_control_bar_anchor').classList.remove("noVNC_idle");
        UI.idleControlbarTimeout = window.setTimeout(UI.idleControlbar, 2000);
    },

    idleControlbar: function () {
        document.getElementById('noVNC_control_bar_anchor').classList.add("noVNC_idle");
    },

    keepControlbar: function () {
        clearTimeout(UI.closeControlbarTimeout);
    },

    openControlbar: function () {
        document.getElementById('noVNC_control_bar').classList.add("noVNC_open");
    },

    closeControlbar: function () {
        UI.closeAllPanels();
        document.getElementById('noVNC_control_bar').classList.remove("noVNC_open");
    },

    toggleControlbar: function () {
        if (document.getElementById('noVNC_control_bar').classList.contains("noVNC_open")) {
            UI.closeControlbar();
        } else {
            UI.openControlbar();
        }
    },

    toggleControlbarSide: function () {
        // Temporarily disable animation to avoid weird movement
        var bar = document.getElementById('noVNC_control_bar');
        bar.style.transitionDuration = '0s';
        bar.addEventListener('transitionend', function () {
            this.style.transitionDuration = "";
        });

        var anchor = document.getElementById('noVNC_control_bar_anchor');
        if (anchor.classList.contains("noVNC_right")) {
            WebUtil.writeSetting('controlbar_pos', 'left');
            anchor.classList.remove("noVNC_right");
        } else {
            WebUtil.writeSetting('controlbar_pos', 'right');
            anchor.classList.add("noVNC_right");
        }

        // Consider this a movement of the handle
        UI.controlbarDrag = true;
    },

    showControlbarHint: function (show) {
        var hint = document.getElementById('noVNC_control_bar_hint');
        if (show) {
            hint.classList.add("noVNC_active");
        } else {
            hint.classList.remove("noVNC_active");
        }
    },

    dragControlbarHandle: function (e) {
        if (!UI.controlbarGrabbed) return;

        var ptr = (0, _events.getPointerEvent)(e);

        var anchor = document.getElementById('noVNC_control_bar_anchor');
        if (ptr.clientX < window.innerWidth * 0.1) {
            if (anchor.classList.contains("noVNC_right")) {
                UI.toggleControlbarSide();
            }
        } else if (ptr.clientX > window.innerWidth * 0.9) {
            if (!anchor.classList.contains("noVNC_right")) {
                UI.toggleControlbarSide();
            }
        }

        if (!UI.controlbarDrag) {
            // The goal is to trigger on a certain physical width, the
            // devicePixelRatio brings us a bit closer but is not optimal.
            var dragThreshold = 10 * (window.devicePixelRatio || 1);
            var dragDistance = Math.abs(ptr.clientY - UI.controlbarMouseDownClientY);

            if (dragDistance < dragThreshold) return;

            UI.controlbarDrag = true;
        }

        var eventY = ptr.clientY - UI.controlbarMouseDownOffsetY;

        UI.moveControlbarHandle(eventY);

        e.preventDefault();
        e.stopPropagation();
        UI.keepControlbar();
        UI.activateControlbar();
    },

    // Move the handle but don't allow any position outside the bounds
    moveControlbarHandle: function (viewportRelativeY) {
        var handle = document.getElementById("noVNC_control_bar_handle");
        var handleHeight = handle.getBoundingClientRect().height;
        var controlbarBounds = document.getElementById("noVNC_control_bar").getBoundingClientRect();
        var margin = 10;

        // These heights need to be non-zero for the below logic to work
        if (handleHeight === 0 || controlbarBounds.height === 0) {
            return;
        }

        var newY = viewportRelativeY;

        // Check if the coordinates are outside the control bar
        if (newY < controlbarBounds.top + margin) {
            // Force coordinates to be below the top of the control bar
            newY = controlbarBounds.top + margin;
        } else if (newY > controlbarBounds.top + controlbarBounds.height - handleHeight - margin) {
            // Force coordinates to be above the bottom of the control bar
            newY = controlbarBounds.top + controlbarBounds.height - handleHeight - margin;
        }

        // Corner case: control bar too small for stable position
        if (controlbarBounds.height < handleHeight + margin * 2) {
            newY = controlbarBounds.top + (controlbarBounds.height - handleHeight) / 2;
        }

        // The transform needs coordinates that are relative to the parent
        var parentRelativeY = newY - controlbarBounds.top;
        handle.style.transform = "translateY(" + parentRelativeY + "px)";
    },

    updateControlbarHandle: function () {
        // Since the control bar is fixed on the viewport and not the page,
        // the move function expects coordinates relative the the viewport.
        var handle = document.getElementById("noVNC_control_bar_handle");
        var handleBounds = handle.getBoundingClientRect();
        UI.moveControlbarHandle(handleBounds.top);
    },

    controlbarHandleMouseUp: function (e) {
        if (e.type == "mouseup" && e.button != 0) return;

        // mouseup and mousedown on the same place toggles the controlbar
        if (UI.controlbarGrabbed && !UI.controlbarDrag) {
            UI.toggleControlbar();
            e.preventDefault();
            e.stopPropagation();
            UI.keepControlbar();
            UI.activateControlbar();
        }
        UI.controlbarGrabbed = false;
        UI.showControlbarHint(false);
    },

    controlbarHandleMouseDown: function (e) {
        if (e.type == "mousedown" && e.button != 0) return;

        var ptr = (0, _events.getPointerEvent)(e);

        var handle = document.getElementById("noVNC_control_bar_handle");
        var bounds = handle.getBoundingClientRect();

        // Touch events have implicit capture
        if (e.type === "mousedown") {
            (0, _events.setCapture)(handle);
        }

        UI.controlbarGrabbed = true;
        UI.controlbarDrag = false;

        UI.showControlbarHint(true);

        UI.controlbarMouseDownClientY = ptr.clientY;
        UI.controlbarMouseDownOffsetY = ptr.clientY - bounds.top;
        e.preventDefault();
        e.stopPropagation();
        UI.keepControlbar();
        UI.activateControlbar();
    },

    toggleExpander: function (e) {
        if (this.classList.contains("noVNC_open")) {
            this.classList.remove("noVNC_open");
        } else {
            this.classList.add("noVNC_open");
        }
    },

    /* ------^-------
     *    /VISUAL
     * ==============
     *    SETTINGS
     * ------v------*/

    // Initial page load read/initialization of settings
    initSetting: function (name, defVal) {
        // Check Query string followed by cookie
        var val = WebUtil.getConfigVar(name);
        if (val === null) {
            val = WebUtil.readSetting(name, defVal);
        }
        UI.updateSetting(name, val);
        return val;
    },

    // Update cookie and form control setting. If value is not set, then
    // updates from control to current cookie setting.
    updateSetting: function (name, value) {

        // Save the cookie for this session
        if (typeof value !== 'undefined') {
            WebUtil.writeSetting(name, value);
        }

        // Update the settings control
        value = UI.getSetting(name);

        var ctrl = document.getElementById('noVNC_setting_' + name);
        if (ctrl.type === 'checkbox') {
            ctrl.checked = value;
        } else if (typeof ctrl.options !== 'undefined') {
            for (var i = 0; i < ctrl.options.length; i += 1) {
                if (ctrl.options[i].value === value) {
                    ctrl.selectedIndex = i;
                    break;
                }
            }
        } else {
            /*Weird IE9 error leads to 'null' appearring
            in textboxes instead of ''.*/
            if (value === null) {
                value = "";
            }
            ctrl.value = value;
        }
    },

    // Save control setting to cookie
    saveSetting: function (name) {
        var val,
            ctrl = document.getElementById('noVNC_setting_' + name);
        if (ctrl.type === 'checkbox') {
            val = ctrl.checked;
        } else if (typeof ctrl.options !== 'undefined') {
            val = ctrl.options[ctrl.selectedIndex].value;
        } else {
            val = ctrl.value;
        }
        WebUtil.writeSetting(name, val);
        //Log.Debug("Setting saved '" + name + "=" + val + "'");
        return val;
    },

    // Read form control compatible setting from cookie
    getSetting: function (name) {
        var ctrl = document.getElementById('noVNC_setting_' + name);
        var val = WebUtil.readSetting(name);
        if (typeof val !== 'undefined' && val !== null && ctrl.type === 'checkbox') {
            if (val.toString().toLowerCase() in { '0': 1, 'no': 1, 'false': 1 }) {
                val = false;
            } else {
                val = true;
            }
        }
        return val;
    },

    // These helpers compensate for the lack of parent-selectors and
    // previous-sibling-selectors in CSS which are needed when we want to
    // disable the labels that belong to disabled input elements.
    disableSetting: function (name) {
        var ctrl = document.getElementById('noVNC_setting_' + name);
        ctrl.disabled = true;
        ctrl.label.classList.add('noVNC_disabled');
    },

    enableSetting: function (name) {
        var ctrl = document.getElementById('noVNC_setting_' + name);
        ctrl.disabled = false;
        ctrl.label.classList.remove('noVNC_disabled');
    },

    /* ------^-------
     *   /SETTINGS
     * ==============
     *    PANELS
     * ------v------*/

    closeAllPanels: function () {
        UI.closeSettingsPanel();
        UI.closePowerPanel();
        UI.closeClipboardPanel();
        UI.closeExtraKeys();
    },

    /* ------^-------
     *   /PANELS
     * ==============
     * SETTINGS (panel)
     * ------v------*/

    openSettingsPanel: function () {
        UI.closeAllPanels();
        UI.openControlbar();

        // Refresh UI elements from saved cookies
        UI.updateSetting('encrypt');
        UI.updateSetting('view_clip');
        UI.updateSetting('resize');
        UI.updateSetting('shared');
        UI.updateSetting('view_only');
        UI.updateSetting('path');
        UI.updateSetting('repeaterID');
        UI.updateSetting('logging');
        UI.updateSetting('reconnect');
        UI.updateSetting('reconnect_delay');

        document.getElementById('noVNC_settings').classList.add("noVNC_open");
        document.getElementById('noVNC_settings_button').classList.add("noVNC_selected");
    },

    closeSettingsPanel: function () {
        document.getElementById('noVNC_settings').classList.remove("noVNC_open");
        document.getElementById('noVNC_settings_button').classList.remove("noVNC_selected");
    },

    toggleSettingsPanel: function () {
        if (document.getElementById('noVNC_settings').classList.contains("noVNC_open")) {
            UI.closeSettingsPanel();
        } else {
            UI.openSettingsPanel();
        }
    },

    /* ------^-------
     *   /SETTINGS
     * ==============
     *     POWER
     * ------v------*/

    openPowerPanel: function () {
        UI.closeAllPanels();
        UI.openControlbar();

        document.getElementById('noVNC_power').classList.add("noVNC_open");
        document.getElementById('noVNC_power_button').classList.add("noVNC_selected");
    },

    closePowerPanel: function () {
        document.getElementById('noVNC_power').classList.remove("noVNC_open");
        document.getElementById('noVNC_power_button').classList.remove("noVNC_selected");
    },

    togglePowerPanel: function () {
        if (document.getElementById('noVNC_power').classList.contains("noVNC_open")) {
            UI.closePowerPanel();
        } else {
            UI.openPowerPanel();
        }
    },

    // Disable/enable power button
    updatePowerButton: function () {
        if (UI.connected && UI.rfb.capabilities.power && !UI.rfb.viewOnly) {
            document.getElementById('noVNC_power_button').classList.remove("noVNC_hidden");
        } else {
            document.getElementById('noVNC_power_button').classList.add("noVNC_hidden");
            // Close power panel if open
            UI.closePowerPanel();
        }
    },

    /* ------^-------
     *    /POWER
     * ==============
     *   CLIPBOARD
     * ------v------*/

    openClipboardPanel: function () {
        UI.closeAllPanels();
        UI.openControlbar();

        document.getElementById('noVNC_clipboard').classList.add("noVNC_open");
        document.getElementById('noVNC_clipboard_button').classList.add("noVNC_selected");
    },

    closeClipboardPanel: function () {
        document.getElementById('noVNC_clipboard').classList.remove("noVNC_open");
        document.getElementById('noVNC_clipboard_button').classList.remove("noVNC_selected");
    },

    toggleClipboardPanel: function () {
        if (document.getElementById('noVNC_clipboard').classList.contains("noVNC_open")) {
            UI.closeClipboardPanel();
        } else {
            UI.openClipboardPanel();
        }
    },

    clipboardReceive: function (e) {
        Log.Debug(">> UI.clipboardReceive: " + e.detail.text.substr(0, 40) + "...");
        document.getElementById('noVNC_clipboard_text').value = e.detail.text;
        Log.Debug("<< UI.clipboardReceive");
    },

    clipboardClear: function () {
        document.getElementById('noVNC_clipboard_text').value = "";
        UI.rfb.clipboardPasteFrom("");
    },

    clipboardSend: function () {
        var text = document.getElementById('noVNC_clipboard_text').value;
        Log.Debug(">> UI.clipboardSend: " + text.substr(0, 40) + "...");
        UI.rfb.clipboardPasteFrom(text);
        Log.Debug("<< UI.clipboardSend");
    },

    /* ------^-------
     *  /CLIPBOARD
     * ==============
     *  CONNECTION
     * ------v------*/

    openConnectPanel: function () {
        document.getElementById('noVNC_connect_dlg').classList.add("noVNC_open");
    },

    closeConnectPanel: function () {
        document.getElementById('noVNC_connect_dlg').classList.remove("noVNC_open");
    },

    connect: function (event, password) {

        // Ignore when rfb already exists
        if (typeof UI.rfb !== 'undefined') {
            return;
        }

        var host = UI.getSetting('host');
        var port = UI.getSetting('port');
        var path = UI.getSetting('path');

        if (typeof password === 'undefined') {
            password = WebUtil.getConfigVar('password');
            UI.reconnect_password = password;
        }

        if (password === null) {
            password = undefined;
        }

        UI.hideStatus();

        if (!host) {
            Log.Error("Can't connect when host is: " + host);
            UI.showStatus((0, _localization2.default)("Must set host"), 'error');
            return;
        }

        UI.closeAllPanels();
        UI.closeConnectPanel();

        UI.updateVisualState('connecting');

        var url;

        url = UI.getSetting('encrypt') ? 'wss' : 'ws';

        url += '://' + host;
        if (port) {
            url += ':' + port;
        }
        url += '/' + path;

        UI.rfb = new _rfb2.default(document.getElementById('noVNC_container'), url, { shared: UI.getSetting('shared'),
            repeaterID: UI.getSetting('repeaterID'),
            credentials: { password: password } });
        UI.rfb.addEventListener("connect", UI.connectFinished);
        UI.rfb.addEventListener("disconnect", UI.disconnectFinished);
        UI.rfb.addEventListener("credentialsrequired", UI.credentials);
        UI.rfb.addEventListener("securityfailure", UI.securityFailed);
        UI.rfb.addEventListener("capabilities", function () {
            UI.updatePowerButton();
        });
        UI.rfb.addEventListener("clipboard", UI.clipboardReceive);
        UI.rfb.addEventListener("bell", UI.bell);
        UI.rfb.addEventListener("desktopname", UI.updateDesktopName);
        UI.rfb.clipViewport = UI.getSetting('view_clip');
        UI.rfb.scaleViewport = UI.getSetting('resize') === 'scale';
        UI.rfb.resizeSession = UI.getSetting('resize') === 'remote';

        UI.updateViewOnly(); // requires UI.rfb
    },

    disconnect: function () {
        UI.closeAllPanels();
        UI.rfb.disconnect();

        UI.connected = false;

        // Disable automatic reconnecting
        UI.inhibit_reconnect = true;

        UI.updateVisualState('disconnecting');

        // Don't display the connection settings until we're actually disconnected
    },

    reconnect: function () {
        UI.reconnect_callback = null;

        // if reconnect has been disabled in the meantime, do nothing.
        if (UI.inhibit_reconnect) {
            return;
        }

        UI.connect(null, UI.reconnect_password);
    },

    cancelReconnect: function () {
        if (UI.reconnect_callback !== null) {
            clearTimeout(UI.reconnect_callback);
            UI.reconnect_callback = null;
        }

        UI.updateVisualState('disconnected');

        UI.openControlbar();
        UI.openConnectPanel();
    },

    connectFinished: function (e) {
        UI.connected = true;
        UI.inhibit_reconnect = false;

        let msg;
        if (UI.getSetting('encrypt')) {
            msg = (0, _localization2.default)("Connected (encrypted) to ") + UI.desktopName;
        } else {
            msg = (0, _localization2.default)("Connected (unencrypted) to ") + UI.desktopName;
        }
        UI.showStatus(msg);
        UI.updateVisualState('connected');

        // Do this last because it can only be used on rendered elements
        UI.rfb.focus();
    },

    disconnectFinished: function (e) {
        let wasConnected = UI.connected;

        // This variable is ideally set when disconnection starts, but
        // when the disconnection isn't clean or if it is initiated by
        // the server, we need to do it here as well since
        // UI.disconnect() won't be used in those cases.
        UI.connected = false;

        UI.rfb = undefined;

        if (!e.detail.clean) {
            UI.updateVisualState('disconnected');
            if (wasConnected) {
                UI.showStatus((0, _localization2.default)("Something went wrong, connection is closed"), 'error');
            } else {
                UI.showStatus((0, _localization2.default)("Failed to connect to server"), 'error');
            }
        } else if (UI.getSetting('reconnect', false) === true && !UI.inhibit_reconnect) {
            UI.updateVisualState('reconnecting');

            var delay = parseInt(UI.getSetting('reconnect_delay'));
            UI.reconnect_callback = setTimeout(UI.reconnect, delay);
            return;
        } else {
            UI.updateVisualState('disconnected');
            UI.showStatus((0, _localization2.default)("Disconnected"), 'normal');
        }

        UI.openControlbar();
        UI.openConnectPanel();
    },

    securityFailed: function (e) {
        let msg = "";
        // On security failures we might get a string with a reason
        // directly from the server. Note that we can't control if
        // this string is translated or not.
        if ('reason' in e.detail) {
            msg = (0, _localization2.default)("New connection has been rejected with reason: ") + e.detail.reason;
        } else {
            msg = (0, _localization2.default)("New connection has been rejected");
        }
        UI.showStatus(msg, 'error');
    },

    /* ------^-------
     *  /CONNECTION
     * ==============
     *   PASSWORD
     * ------v------*/

    credentials: function (e) {
        // FIXME: handle more types
        document.getElementById('noVNC_password_dlg').classList.add('noVNC_open');

        setTimeout(function () {
            document.getElementById('noVNC_password_input').focus();
        }, 100);

        Log.Warn("Server asked for a password");
        UI.showStatus((0, _localization2.default)("Password is required"), "warning");
    },

    setPassword: function (e) {
        // Prevent actually submitting the form
        e.preventDefault();

        var inputElem = document.getElementById('noVNC_password_input');
        var password = inputElem.value;
        // Clear the input after reading the password
        inputElem.value = "";
        UI.rfb.sendCredentials({ password: password });
        UI.reconnect_password = password;
        document.getElementById('noVNC_password_dlg').classList.remove('noVNC_open');
    },

    /* ------^-------
     *  /PASSWORD
     * ==============
     *   FULLSCREEN
     * ------v------*/

    toggleFullscreen: function () {
        if (document.fullscreenElement || // alternative standard method
        document.mozFullScreenElement || // currently working methods
        document.webkitFullscreenElement || document.msFullscreenElement) {
            if (document.exitFullscreen) {
                document.exitFullscreen();
            } else if (document.mozCancelFullScreen) {
                document.mozCancelFullScreen();
            } else if (document.webkitExitFullscreen) {
                document.webkitExitFullscreen();
            } else if (document.msExitFullscreen) {
                document.msExitFullscreen();
            }
        } else {
            if (document.documentElement.requestFullscreen) {
                document.documentElement.requestFullscreen();
            } else if (document.documentElement.mozRequestFullScreen) {
                document.documentElement.mozRequestFullScreen();
            } else if (document.documentElement.webkitRequestFullscreen) {
                document.documentElement.webkitRequestFullscreen(Element.ALLOW_KEYBOARD_INPUT);
            } else if (document.body.msRequestFullscreen) {
                document.body.msRequestFullscreen();
            }
        }
        UI.enableDisableViewClip();
        UI.updateFullscreenButton();
    },

    updateFullscreenButton: function () {
        if (document.fullscreenElement || // alternative standard method
        document.mozFullScreenElement || // currently working methods
        document.webkitFullscreenElement || document.msFullscreenElement) {
            document.getElementById('noVNC_fullscreen_button').classList.add("noVNC_selected");
        } else {
            document.getElementById('noVNC_fullscreen_button').classList.remove("noVNC_selected");
        }
    },

    /* ------^-------
     *  /FULLSCREEN
     * ==============
     *     RESIZE
     * ------v------*/

    // Apply remote resizing or local scaling
    applyResizeMode: function () {
        if (!UI.rfb) return;

        UI.rfb.scaleViewport = UI.getSetting('resize') === 'scale';
        UI.rfb.resizeSession = UI.getSetting('resize') === 'remote';
    },

    /* ------^-------
     *    /RESIZE
     * ==============
     * VIEW CLIPPING
     * ------v------*/

    // Update parameters that depend on the viewport clip setting
    updateViewClip: function () {
        if (!UI.rfb) return;

        var cur_clip = UI.rfb.clipViewport;
        var new_clip = UI.getSetting('view_clip');

        if (_browser.isTouchDevice) {
            // Touch devices usually have shit scrollbars
            new_clip = true;
        }

        if (cur_clip !== new_clip) {
            UI.rfb.clipViewport = new_clip;
        }

        // Changing the viewport may change the state of
        // the dragging button
        UI.updateViewDrag();
    },

    // Handle special cases where viewport clipping is forced on/off or locked
    enableDisableViewClip: function () {
        var resizeSetting = UI.getSetting('resize');
        // Disable clipping if we are scaling, connected or on touch
        if (resizeSetting === 'scale' || _browser.isTouchDevice) {
            UI.disableSetting('view_clip');
        } else {
            UI.enableSetting('view_clip');
        }
    },

    /* ------^-------
     * /VIEW CLIPPING
     * ==============
     *    VIEWDRAG
     * ------v------*/

    toggleViewDrag: function () {
        if (!UI.rfb) return;

        var drag = UI.rfb.dragViewport;
        UI.setViewDrag(!drag);
    },

    // Set the view drag mode which moves the viewport on mouse drags
    setViewDrag: function (drag) {
        if (!UI.rfb) return;

        UI.rfb.dragViewport = drag;

        UI.updateViewDrag();
    },

    updateViewDrag: function () {
        if (!UI.connected) return;

        var viewDragButton = document.getElementById('noVNC_view_drag_button');

        if (!UI.rfb.clipViewport && UI.rfb.dragViewport) {
            // We are no longer clipping the viewport. Make sure
            // viewport drag isn't active when it can't be used.
            UI.rfb.dragViewport = false;
        }

        if (UI.rfb.dragViewport) {
            viewDragButton.classList.add("noVNC_selected");
        } else {
            viewDragButton.classList.remove("noVNC_selected");
        }

        // Different behaviour for touch vs non-touch
        // The button is disabled instead of hidden on touch devices
        if (_browser.isTouchDevice) {
            viewDragButton.classList.remove("noVNC_hidden");

            if (UI.rfb.clipViewport) {
                viewDragButton.disabled = false;
            } else {
                viewDragButton.disabled = true;
            }
        } else {
            viewDragButton.disabled = false;

            if (UI.rfb.clipViewport) {
                viewDragButton.classList.remove("noVNC_hidden");
            } else {
                viewDragButton.classList.add("noVNC_hidden");
            }
        }
    },

    /* ------^-------
     *   /VIEWDRAG
     * ==============
     *    KEYBOARD
     * ------v------*/

    showVirtualKeyboard: function () {
        if (!_browser.isTouchDevice) return;

        var input = document.getElementById('noVNC_keyboardinput');

        if (document.activeElement == input) return;

        input.focus();

        try {
            var l = input.value.length;
            // Move the caret to the end
            input.setSelectionRange(l, l);
        } catch (err) {} // setSelectionRange is undefined in Google Chrome
    },

    hideVirtualKeyboard: function () {
        if (!_browser.isTouchDevice) return;

        var input = document.getElementById('noVNC_keyboardinput');

        if (document.activeElement != input) return;

        input.blur();
    },

    toggleVirtualKeyboard: function () {
        if (document.getElementById('noVNC_keyboard_button').classList.contains("noVNC_selected")) {
            UI.hideVirtualKeyboard();
        } else {
            UI.showVirtualKeyboard();
        }
    },

    onfocusVirtualKeyboard: function (event) {
        document.getElementById('noVNC_keyboard_button').classList.add("noVNC_selected");
        if (UI.rfb) {
            UI.rfb.focusOnClick = false;
        }
    },

    onblurVirtualKeyboard: function (event) {
        document.getElementById('noVNC_keyboard_button').classList.remove("noVNC_selected");
        if (UI.rfb) {
            UI.rfb.focusOnClick = true;
        }
    },

    keepVirtualKeyboard: function (event) {
        var input = document.getElementById('noVNC_keyboardinput');

        // Only prevent focus change if the virtual keyboard is active
        if (document.activeElement != input) {
            return;
        }

        // Only allow focus to move to other elements that need
        // focus to function properly
        if (event.target.form !== undefined) {
            switch (event.target.type) {
                case 'text':
                case 'email':
                case 'search':
                case 'password':
                case 'tel':
                case 'url':
                case 'textarea':
                case 'select-one':
                case 'select-multiple':
                    return;
            }
        }

        event.preventDefault();
    },

    keyboardinputReset: function () {
        var kbi = document.getElementById('noVNC_keyboardinput');
        kbi.value = new Array(UI.defaultKeyboardinputLen).join("_");
        UI.lastKeyboardinput = kbi.value;
    },

    keyEvent: function (keysym, code, down) {
        if (!UI.rfb) return;

        UI.rfb.sendKey(keysym, code, down);
    },

    // When normal keyboard events are left uncought, use the input events from
    // the keyboardinput element instead and generate the corresponding key events.
    // This code is required since some browsers on Android are inconsistent in
    // sending keyCodes in the normal keyboard events when using on screen keyboards.
    keyInput: function (event) {

        if (!UI.rfb) return;

        var newValue = event.target.value;

        if (!UI.lastKeyboardinput) {
            UI.keyboardinputReset();
        }
        var oldValue = UI.lastKeyboardinput;

        var newLen;
        try {
            // Try to check caret position since whitespace at the end
            // will not be considered by value.length in some browsers
            newLen = Math.max(event.target.selectionStart, newValue.length);
        } catch (err) {
            // selectionStart is undefined in Google Chrome
            newLen = newValue.length;
        }
        var oldLen = oldValue.length;

        var backspaces;
        var inputs = newLen - oldLen;
        if (inputs < 0) {
            backspaces = -inputs;
        } else {
            backspaces = 0;
        }

        // Compare the old string with the new to account for
        // text-corrections or other input that modify existing text
        var i;
        for (i = 0; i < Math.min(oldLen, newLen); i++) {
            if (newValue.charAt(i) != oldValue.charAt(i)) {
                inputs = newLen - i;
                backspaces = oldLen - i;
                break;
            }
        }

        // Send the key events
        for (i = 0; i < backspaces; i++) {
            UI.rfb.sendKey(_keysym2.default.XK_BackSpace, "Backspace");
        }
        for (i = newLen - inputs; i < newLen; i++) {
            UI.rfb.sendKey(_keysymdef2.default.lookup(newValue.charCodeAt(i)));
        }

        // Control the text content length in the keyboardinput element
        if (newLen > 2 * UI.defaultKeyboardinputLen) {
            UI.keyboardinputReset();
        } else if (newLen < 1) {
            // There always have to be some text in the keyboardinput
            // element with which backspace can interact.
            UI.keyboardinputReset();
            // This sometimes causes the keyboard to disappear for a second
            // but it is required for the android keyboard to recognize that
            // text has been added to the field
            event.target.blur();
            // This has to be ran outside of the input handler in order to work
            setTimeout(event.target.focus.bind(event.target), 0);
        } else {
            UI.lastKeyboardinput = newValue;
        }
    },

    /* ------^-------
     *   /KEYBOARD
     * ==============
     *   EXTRA KEYS
     * ------v------*/

    openExtraKeys: function () {
        UI.closeAllPanels();
        UI.openControlbar();

        document.getElementById('noVNC_modifiers').classList.add("noVNC_open");
        document.getElementById('noVNC_toggle_extra_keys_button').classList.add("noVNC_selected");
    },

    closeExtraKeys: function () {
        document.getElementById('noVNC_modifiers').classList.remove("noVNC_open");
        document.getElementById('noVNC_toggle_extra_keys_button').classList.remove("noVNC_selected");
    },

    toggleExtraKeys: function () {
        if (document.getElementById('noVNC_modifiers').classList.contains("noVNC_open")) {
            UI.closeExtraKeys();
        } else {
            UI.openExtraKeys();
        }
    },

    sendEsc: function () {
        UI.rfb.sendKey(_keysym2.default.XK_Escape, "Escape");
    },

    sendTab: function () {
        UI.rfb.sendKey(_keysym2.default.XK_Tab);
    },

    toggleCtrl: function () {
        var btn = document.getElementById('noVNC_toggle_ctrl_button');
        if (btn.classList.contains("noVNC_selected")) {
            UI.rfb.sendKey(_keysym2.default.XK_Control_L, "ControlLeft", false);
            btn.classList.remove("noVNC_selected");
        } else {
            UI.rfb.sendKey(_keysym2.default.XK_Control_L, "ControlLeft", true);
            btn.classList.add("noVNC_selected");
        }
    },

    toggleAlt: function () {
        var btn = document.getElementById('noVNC_toggle_alt_button');
        if (btn.classList.contains("noVNC_selected")) {
            UI.rfb.sendKey(_keysym2.default.XK_Alt_L, "AltLeft", false);
            btn.classList.remove("noVNC_selected");
        } else {
            UI.rfb.sendKey(_keysym2.default.XK_Alt_L, "AltLeft", true);
            btn.classList.add("noVNC_selected");
        }
    },

    sendCtrlAltDel: function () {
        UI.rfb.sendCtrlAltDel();
    },

    /* ------^-------
     *   /EXTRA KEYS
     * ==============
     *     MISC
     * ------v------*/

    setMouseButton: function (num) {
        var view_only = UI.rfb.viewOnly;
        if (UI.rfb && !view_only) {
            UI.rfb.touchButton = num;
        }

        var blist = [0, 1, 2, 4];
        for (var b = 0; b < blist.length; b++) {
            var button = document.getElementById('noVNC_mouse_button' + blist[b]);
            if (blist[b] === num && !view_only) {
                button.classList.remove("noVNC_hidden");
            } else {
                button.classList.add("noVNC_hidden");
            }
        }
    },

    updateViewOnly: function () {
        if (!UI.rfb) return;
        UI.rfb.viewOnly = UI.getSetting('view_only');

        // Hide input related buttons in view only mode
        if (UI.rfb.viewOnly) {
            document.getElementById('noVNC_keyboard_button').classList.add('noVNC_hidden');
            document.getElementById('noVNC_toggle_extra_keys_button').classList.add('noVNC_hidden');
        } else {
            document.getElementById('noVNC_keyboard_button').classList.remove('noVNC_hidden');
            document.getElementById('noVNC_toggle_extra_keys_button').classList.remove('noVNC_hidden');
        }
        UI.setMouseButton(1); //has it's own logic for hiding/showing
    },

    updateLogging: function () {
        WebUtil.init_logging(UI.getSetting('logging'));
    },

    updateDesktopName: function (e) {
        UI.desktopName = e.detail.name;
        // Display the desktop name in the document title
        document.title = e.detail.name + " - noVNC";
    },

    bell: function (e) {
        if (WebUtil.getConfigVar('bell', 'on') === 'on') {
            var promise = document.getElementById('noVNC_bell').play();
            // The standards disagree on the return value here
            if (promise) {
                promise.catch(function (e) {
                    if (e.name === "NotAllowedError") {
                        // Ignore when the browser doesn't let us play audio.
                        // It is common that the browsers require audio to be
                        // initiated from a user action.
                    } else {
                        Log.Error("Unable to play bell: " + e);
                    }
                });
            }
        }
    },

    //Helper to add options to dropdown.
    addOption: function (selectbox, text, value) {
        var optn = document.createElement("OPTION");
        optn.text = text;
        optn.value = value;
        selectbox.options.add(optn);
    }

    /* ------^-------
     *    /MISC
     * ==============
     */
};

// Set up translations
var LINGUAS = ["de", "el", "es", "nl", "pl", "sv", "tr", "zh"];
_localization.l10n.setup(LINGUAS);
if (_localization.l10n.language !== "en" && _localization.l10n.dictionary === undefined) {
    WebUtil.fetchJSON('app/locale/' + _localization.l10n.language + '.json', function (translations) {
        _localization.l10n.dictionary = translations;

        // wait for translations to load before loading the UI
        UI.prime();
    }, function (err) {
        Log.Error("Failed to load translations: " + err);
        UI.prime();
    });
} else {
    UI.prime();
}

exports.default = UI;