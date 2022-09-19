(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

/*
 * noVNC: HTML5 VNC client
 * Copyright (C) 2018 The noVNC Authors
 * Licensed under MPL 2.0 (see LICENSE.txt)
 *
 * See README.md for usage and integration instructions.
 */

/*
 * Localization Utilities
 */

var Localizer = exports.Localizer = function () {
    function Localizer() {
        _classCallCheck(this, Localizer);

        // Currently configured language
        this.language = 'en';

        // Current dictionary of translations
        this.dictionary = undefined;
    }

    // Configure suitable language based on user preferences


    _createClass(Localizer, [{
        key: 'setup',
        value: function setup(supportedLanguages) {
            this.language = 'en'; // Default: US English

            /*
             * Navigator.languages only available in Chrome (32+) and FireFox (32+)
             * Fall back to navigator.language for other browsers
             */
            var userLanguages = void 0;
            if (_typeof(window.navigator.languages) == 'object') {
                userLanguages = window.navigator.languages;
            } else {
                userLanguages = [navigator.language || navigator.userLanguage];
            }

            for (var i = 0; i < userLanguages.length; i++) {
                var userLang = userLanguages[i].toLowerCase().replace("_", "-").split("-");

                // Built-in default?
                if (userLang[0] === 'en' && (userLang[1] === undefined || userLang[1] === 'us')) {
                    return;
                }

                // First pass: perfect match
                for (var j = 0; j < supportedLanguages.length; j++) {
                    var supLang = supportedLanguages[j].toLowerCase().replace("_", "-").split("-");

                    if (userLang[0] !== supLang[0]) {
                        continue;
                    }
                    if (userLang[1] !== supLang[1]) {
                        continue;
                    }

                    this.language = supportedLanguages[j];
                    return;
                }

                // Second pass: fallback
                for (var _j = 0; _j < supportedLanguages.length; _j++) {
                    var _supLang = supportedLanguages[_j].toLowerCase().replace("_", "-").split("-");

                    if (userLang[0] !== _supLang[0]) {
                        continue;
                    }
                    if (_supLang[1] !== undefined) {
                        continue;
                    }

                    this.language = supportedLanguages[_j];
                    return;
                }
            }
        }

        // Retrieve localised text

    }, {
        key: 'get',
        value: function get(id) {
            if (typeof this.dictionary !== 'undefined' && this.dictionary[id]) {
                return this.dictionary[id];
            } else {
                return id;
            }
        }

        // Traverses the DOM and translates relevant fields
        // See https://html.spec.whatwg.org/multipage/dom.html#attr-translate

    }, {
        key: 'translateDOM',
        value: function translateDOM() {
            var self = this;

            function process(elem, enabled) {
                function isAnyOf(searchElement, items) {
                    return items.indexOf(searchElement) !== -1;
                }

                function translateAttribute(elem, attr) {
                    var str = self.get(elem.getAttribute(attr));
                    elem.setAttribute(attr, str);
                }

                function translateTextNode(node) {
                    var str = self.get(node.data.trim());
                    node.data = str;
                }

                if (elem.hasAttribute("translate")) {
                    if (isAnyOf(elem.getAttribute("translate"), ["", "yes"])) {
                        enabled = true;
                    } else if (isAnyOf(elem.getAttribute("translate"), ["no"])) {
                        enabled = false;
                    }
                }

                if (enabled) {
                    if (elem.hasAttribute("abbr") && elem.tagName === "TH") {
                        translateAttribute(elem, "abbr");
                    }
                    if (elem.hasAttribute("alt") && isAnyOf(elem.tagName, ["AREA", "IMG", "INPUT"])) {
                        translateAttribute(elem, "alt");
                    }
                    if (elem.hasAttribute("download") && isAnyOf(elem.tagName, ["A", "AREA"])) {
                        translateAttribute(elem, "download");
                    }
                    if (elem.hasAttribute("label") && isAnyOf(elem.tagName, ["MENUITEM", "MENU", "OPTGROUP", "OPTION", "TRACK"])) {
                        translateAttribute(elem, "label");
                    }
                    // FIXME: Should update "lang"
                    if (elem.hasAttribute("placeholder") && isAnyOf(elem.tagName, ["INPUT", "TEXTAREA"])) {
                        translateAttribute(elem, "placeholder");
                    }
                    if (elem.hasAttribute("title")) {
                        translateAttribute(elem, "title");
                    }
                    if (elem.hasAttribute("value") && elem.tagName === "INPUT" && isAnyOf(elem.getAttribute("type"), ["reset", "button", "submit"])) {
                        translateAttribute(elem, "value");
                    }
                }

                for (var i = 0; i < elem.childNodes.length; i++) {
                    var node = elem.childNodes[i];
                    if (node.nodeType === node.ELEMENT_NODE) {
                        process(node, enabled);
                    } else if (node.nodeType === node.TEXT_NODE && enabled) {
                        translateTextNode(node);
                    }
                }
            }

            process(document.body, true);
        }
    }]);

    return Localizer;
}();

var l10n = exports.l10n = new Localizer();
exports.default = l10n.get.bind(l10n);
},{}],2:[function(require,module,exports){
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

var _webutil = require('./webutil.js');

var WebUtil = _interopRequireWildcard(_webutil);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

var PAGE_TITLE = "noVNC"; /*
                           * noVNC: HTML5 VNC client
                           * Copyright (C) 2019 The noVNC Authors
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

    lastKeyboardinput: null,
    defaultKeyboardinputLen: 100,

    inhibit_reconnect: true,
    reconnect_callback: null,
    reconnect_password: null,

    prime: function prime() {
        return WebUtil.initSettings().then(function () {
            if (document.readyState === "interactive" || document.readyState === "complete") {
                return UI.start();
            }

            return new Promise(function (resolve, reject) {
                document.addEventListener('DOMContentLoaded', function () {
                    return UI.start().then(resolve).catch(reject);
                });
            });
        });
    },


    // Render default UI and initialize settings menu
    start: function start() {

        UI.initSettings();

        // Translate the DOM
        _localization.l10n.translateDOM();

        WebUtil.fetchJSON('./package.json').then(function (packageInfo) {
            Array.from(document.getElementsByClassName('noVNC_version')).forEach(function (el) {
                return el.innerText = packageInfo.version;
            });
        }).catch(function (err) {
            Log.Error("Couldn't fetch package.json: " + err);
            Array.from(document.getElementsByClassName('noVNC_version_wrapper')).concat(Array.from(document.getElementsByClassName('noVNC_version_separator'))).forEach(function (el) {
                return el.style.display = 'none';
            });
        });

        // Adapt the interface for touch screen devices
        if (_browser.isTouchDevice) {
            document.documentElement.classList.add("noVNC_touch");
            // Remove the address bar
            setTimeout(function () {
                return window.scrollTo(0, 1);
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

        return Promise.resolve(UI.rfb);
    },
    initFullscreen: function initFullscreen() {
        // Only show the button if fullscreen is properly supported
        // * Safari doesn't support alphanumerical input while in fullscreen
        if (!(0, _browser.isSafari)() && (document.documentElement.requestFullscreen || document.documentElement.mozRequestFullScreen || document.documentElement.webkitRequestFullscreen || document.body.msRequestFullscreen)) {
            document.getElementById('noVNC_fullscreen_button').classList.remove("noVNC_hidden");
            UI.addFullscreenHandlers();
        }
    },
    initSettings: function initSettings() {
        // Logging selection dropdown
        var llevels = ['error', 'warn', 'info', 'debug'];
        for (var i = 0; i < llevels.length; i += 1) {
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
        UI.initSetting('show_dot', false);
        UI.initSetting('path', 'websockify');
        UI.initSetting('repeaterID', '');
        UI.initSetting('reconnect', false);
        UI.initSetting('reconnect_delay', 5000);

        UI.setupSettingLabels();
    },

    // Adds a link to the label elements on the corresponding input elements
    setupSettingLabels: function setupSettingLabels() {
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

    addControlbarHandlers: function addControlbarHandlers() {
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
    addTouchSpecificHandlers: function addTouchSpecificHandlers() {
        document.getElementById("noVNC_mouse_button0").addEventListener('click', function () {
            return UI.setMouseButton(1);
        });
        document.getElementById("noVNC_mouse_button1").addEventListener('click', function () {
            return UI.setMouseButton(2);
        });
        document.getElementById("noVNC_mouse_button2").addEventListener('click', function () {
            return UI.setMouseButton(4);
        });
        document.getElementById("noVNC_mouse_button4").addEventListener('click', function () {
            return UI.setMouseButton(0);
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
    addExtraKeysHandlers: function addExtraKeysHandlers() {
        document.getElementById("noVNC_toggle_extra_keys_button").addEventListener('click', UI.toggleExtraKeys);
        document.getElementById("noVNC_toggle_ctrl_button").addEventListener('click', UI.toggleCtrl);
        document.getElementById("noVNC_toggle_windows_button").addEventListener('click', UI.toggleWindows);
        document.getElementById("noVNC_toggle_alt_button").addEventListener('click', UI.toggleAlt);
        document.getElementById("noVNC_send_tab_button").addEventListener('click', UI.sendTab);
        document.getElementById("noVNC_send_esc_button").addEventListener('click', UI.sendEsc);
        document.getElementById("noVNC_send_ctrl_alt_del_button").addEventListener('click', UI.sendCtrlAltDel);
    },
    addMachineHandlers: function addMachineHandlers() {
        document.getElementById("noVNC_shutdown_button").addEventListener('click', function () {
            return UI.rfb.machineShutdown();
        });
        document.getElementById("noVNC_reboot_button").addEventListener('click', function () {
            return UI.rfb.machineReboot();
        });
        document.getElementById("noVNC_reset_button").addEventListener('click', function () {
            return UI.rfb.machineReset();
        });
        document.getElementById("noVNC_power_button").addEventListener('click', UI.togglePowerPanel);
    },
    addConnectionControlHandlers: function addConnectionControlHandlers() {
        document.getElementById("noVNC_disconnect_button").addEventListener('click', UI.disconnect);
        document.getElementById("noVNC_connect_button").addEventListener('click', UI.connect);
        document.getElementById("noVNC_cancel_reconnect_button").addEventListener('click', UI.cancelReconnect);

        document.getElementById("noVNC_credentials_button").addEventListener('click', UI.setCredentials);
    },
    addClipboardHandlers: function addClipboardHandlers() {
        document.getElementById("noVNC_clipboard_button").addEventListener('click', UI.toggleClipboardPanel);
        document.getElementById("noVNC_clipboard_text").addEventListener('change', UI.clipboardSend);
        document.getElementById("noVNC_clipboard_text").addEventListener('input', UI.syncClipboardPanelToLocalClipboard);
        document.getElementById("noVNC_clipboard_clear_button").addEventListener('click', UI.clipboardClear);
    },


    // Add a call to save settings when the element changes,
    // unless the optional parameter changeFunc is used instead.
    addSettingChangeHandler: function addSettingChangeHandler(name, changeFunc) {
        var settingElem = document.getElementById("noVNC_setting_" + name);
        if (changeFunc === undefined) {
            changeFunc = function changeFunc() {
                return UI.saveSetting(name);
            };
        }
        settingElem.addEventListener('change', changeFunc);
    },
    addSettingsHandlers: function addSettingsHandlers() {
        document.getElementById("noVNC_settings_button").addEventListener('click', UI.toggleSettingsPanel);

        UI.addSettingChangeHandler('encrypt');
        UI.addSettingChangeHandler('resize');
        UI.addSettingChangeHandler('resize', UI.applyResizeMode);
        UI.addSettingChangeHandler('resize', UI.updateViewClip);
        UI.addSettingChangeHandler('view_clip');
        UI.addSettingChangeHandler('view_clip', UI.updateViewClip);
        UI.addSettingChangeHandler('shared');
        UI.addSettingChangeHandler('view_only');
        UI.addSettingChangeHandler('view_only', UI.updateViewOnly);
        UI.addSettingChangeHandler('show_dot');
        UI.addSettingChangeHandler('show_dot', UI.updateShowDotCursor);
        UI.addSettingChangeHandler('host');
        UI.addSettingChangeHandler('port');
        UI.addSettingChangeHandler('path');
        UI.addSettingChangeHandler('repeaterID');
        UI.addSettingChangeHandler('logging');
        UI.addSettingChangeHandler('logging', UI.updateLogging);
        UI.addSettingChangeHandler('reconnect');
        UI.addSettingChangeHandler('reconnect_delay');
    },
    addFullscreenHandlers: function addFullscreenHandlers() {
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
    updateVisualState: function updateVisualState(state) {

        document.documentElement.classList.remove("noVNC_connecting");
        document.documentElement.classList.remove("noVNC_connected");
        document.documentElement.classList.remove("noVNC_disconnecting");
        document.documentElement.classList.remove("noVNC_reconnecting");

        var transition_elem = document.getElementById("noVNC_transition_text");
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

        if (UI.connected) {
            UI.updateViewClip();

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

        // State change closes the password dialog
        document.getElementById('noVNC_credentials_dlg').classList.remove('noVNC_open');
    },
    showStatus: function showStatus(text, status_type, time) {
        var statusElem = document.getElementById('noVNC_status');

        if (typeof status_type === 'undefined') {
            status_type = 'normal';
        }

        // Don't overwrite more severe visible statuses and never
        // errors. Only shows the first error.
        if (statusElem.classList.contains("noVNC_open")) {
            if (statusElem.classList.contains("noVNC_status_error")) {
                return;
            }
            if (statusElem.classList.contains("noVNC_status_warn") && status_type === 'normal') {
                return;
            }
        }

        clearTimeout(UI.statusTimeout);

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
    hideStatus: function hideStatus() {
        clearTimeout(UI.statusTimeout);
        document.getElementById('noVNC_status').classList.remove("noVNC_open");
    },
    activateControlbar: function activateControlbar(event) {
        clearTimeout(UI.idleControlbarTimeout);
        // We manipulate the anchor instead of the actual control
        // bar in order to avoid creating new a stacking group
        document.getElementById('noVNC_control_bar_anchor').classList.remove("noVNC_idle");
        UI.idleControlbarTimeout = window.setTimeout(UI.idleControlbar, 2000);
    },
    idleControlbar: function idleControlbar() {
        document.getElementById('noVNC_control_bar_anchor').classList.add("noVNC_idle");
    },
    keepControlbar: function keepControlbar() {
        clearTimeout(UI.closeControlbarTimeout);
    },
    openControlbar: function openControlbar() {
        document.getElementById('noVNC_control_bar').classList.add("noVNC_open");
    },
    closeControlbar: function closeControlbar() {
        UI.closeAllPanels();
        document.getElementById('noVNC_control_bar').classList.remove("noVNC_open");
    },
    toggleControlbar: function toggleControlbar() {
        if (document.getElementById('noVNC_control_bar').classList.contains("noVNC_open")) {
            UI.closeControlbar();
        } else {
            UI.openControlbar();
        }
    },
    toggleControlbarSide: function toggleControlbarSide() {
        // Temporarily disable animation, if bar is displayed, to avoid weird
        // movement. The transitionend-event will not fire when display=none.
        var bar = document.getElementById('noVNC_control_bar');
        var barDisplayStyle = window.getComputedStyle(bar).display;
        if (barDisplayStyle !== 'none') {
            bar.style.transitionDuration = '0s';
            bar.addEventListener('transitionend', function () {
                return bar.style.transitionDuration = '';
            });
        }

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
    showControlbarHint: function showControlbarHint(show) {
        var hint = document.getElementById('noVNC_control_bar_hint');
        if (show) {
            hint.classList.add("noVNC_active");
        } else {
            hint.classList.remove("noVNC_active");
        }
    },
    dragControlbarHandle: function dragControlbarHandle(e) {
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
            var dragDistance = Math.abs(ptr.clientY - UI.controlbarMouseDownClientY);

            if (dragDistance < _browser.dragThreshold) return;

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
    moveControlbarHandle: function moveControlbarHandle(viewportRelativeY) {
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
    updateControlbarHandle: function updateControlbarHandle() {
        // Since the control bar is fixed on the viewport and not the page,
        // the move function expects coordinates relative the the viewport.
        var handle = document.getElementById("noVNC_control_bar_handle");
        var handleBounds = handle.getBoundingClientRect();
        UI.moveControlbarHandle(handleBounds.top);
    },
    controlbarHandleMouseUp: function controlbarHandleMouseUp(e) {
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
    controlbarHandleMouseDown: function controlbarHandleMouseDown(e) {
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
    toggleExpander: function toggleExpander(e) {
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
    initSetting: function initSetting(name, defVal) {
        // Check Query string followed by cookie
        var val = WebUtil.getConfigVar(name);
        if (val === null) {
            val = WebUtil.readSetting(name, defVal);
        }
        WebUtil.setSetting(name, val);
        UI.updateSetting(name);
        return val;
    },


    // Set the new value, update and disable form control setting
    forceSetting: function forceSetting(name, val) {
        WebUtil.setSetting(name, val);
        UI.updateSetting(name);
        UI.disableSetting(name);
    },


    // Update cookie and form control setting. If value is not set, then
    // updates from control to current cookie setting.
    updateSetting: function updateSetting(name) {

        // Update the settings control
        var value = UI.getSetting(name);

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
    saveSetting: function saveSetting(name) {
        var ctrl = document.getElementById('noVNC_setting_' + name);
        var val = void 0;
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
    getSetting: function getSetting(name) {
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
    disableSetting: function disableSetting(name) {
        var ctrl = document.getElementById('noVNC_setting_' + name);
        ctrl.disabled = true;
        ctrl.label.classList.add('noVNC_disabled');
    },
    enableSetting: function enableSetting(name) {
        var ctrl = document.getElementById('noVNC_setting_' + name);
        ctrl.disabled = false;
        ctrl.label.classList.remove('noVNC_disabled');
    },


    /* ------^-------
     *   /SETTINGS
     * ==============
     *    PANELS
     * ------v------*/

    closeAllPanels: function closeAllPanels() {
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

    openSettingsPanel: function openSettingsPanel() {
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
    closeSettingsPanel: function closeSettingsPanel() {
        document.getElementById('noVNC_settings').classList.remove("noVNC_open");
        document.getElementById('noVNC_settings_button').classList.remove("noVNC_selected");
    },
    toggleSettingsPanel: function toggleSettingsPanel() {
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

    openPowerPanel: function openPowerPanel() {
        UI.closeAllPanels();
        UI.openControlbar();

        document.getElementById('noVNC_power').classList.add("noVNC_open");
        document.getElementById('noVNC_power_button').classList.add("noVNC_selected");
    },
    closePowerPanel: function closePowerPanel() {
        document.getElementById('noVNC_power').classList.remove("noVNC_open");
        document.getElementById('noVNC_power_button').classList.remove("noVNC_selected");
    },
    togglePowerPanel: function togglePowerPanel() {
        if (document.getElementById('noVNC_power').classList.contains("noVNC_open")) {
            UI.closePowerPanel();
        } else {
            UI.openPowerPanel();
        }
    },


    // Disable/enable power button
    updatePowerButton: function updatePowerButton() {
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

    // Read and write text to local clipboard is currently only supported in Chrome 66+ and Opera53+
    // further information at https://developer.mozilla.org/en-US/docs/Web/API/Clipboard

    writeLocalClipboard: function writeLocalClipboard(text) {
        if (typeof navigator.clipboard !== "undefined" && typeof navigator.clipboard.writeText !== "undefined" && typeof navigator.permissions !== "undefined" && typeof navigator.permissions.query !== "undefined") {
            navigator.permissions.query({ name: 'clipboard-write' }).then(function () {
                return navigator.clipboard.writeText(text);
            }).then(function () {
                var debugMessage = text.substr(0, 40) + "...";
                Log.Debug('>> UI.setClipboardText: navigator.clipboard.writeText with ' + debugMessage);
            }).catch(function (err) {
                if (err.name !== 'TypeError') {
                    Log.Error(">> UI.setClipboardText: Failed to write system clipboard (trying to copy from NoVNC clipboard)");
                }
            });
        }
    },
    readLocalClipboard: function readLocalClipboard() {
        // navigator.clipboard and navigator.clipbaord.readText is not available in all browsers
        if (typeof navigator.clipboard !== "undefined" && typeof navigator.clipboard.readText !== "undefined" && typeof navigator.permissions !== "undefined" && typeof navigator.permissions.query !== "undefined") {
            navigator.permissions.query({ name: 'clipboard-read' }).then(function () {
                return navigator.clipboard.readText();
            }).then(function (clipboardText) {
                var text = document.getElementById('noVNC_clipboard_text').value;
                if (clipboardText !== text) {
                    document.getElementById('noVNC_clipboard_text').value = clipboardText;
                    UI.clipboardSend();
                }
            }).catch(function (err) {
                if (err.name !== 'TypeError') {
                    Log.Warn("<< UI.readLocalClipboard: Failed to read system clipboard-: " + err);
                }
            });
        }
    },
    openClipboardPanel: function openClipboardPanel() {
        UI.closeAllPanels();
        UI.openControlbar();

        document.getElementById('noVNC_clipboard').classList.add("noVNC_open");
        document.getElementById('noVNC_clipboard_button').classList.add("noVNC_selected");
    },
    closeClipboardPanel: function closeClipboardPanel() {
        document.getElementById('noVNC_clipboard').classList.remove("noVNC_open");
        document.getElementById('noVNC_clipboard_button').classList.remove("noVNC_selected");
    },
    toggleClipboardPanel: function toggleClipboardPanel() {
        if (document.getElementById('noVNC_clipboard').classList.contains("noVNC_open")) {
            UI.closeClipboardPanel();
        } else {
            UI.openClipboardPanel();
        }
    },
    clipboardReceive: function clipboardReceive(e) {
        Log.Debug(">> UI.clipboardReceive: " + e.detail.text.substr(0, 40) + "...");
        document.getElementById('noVNC_clipboard_text').value = e.detail.text;
        UI.writeLocalClipboard(e.detail.text);
        Log.Debug("<< UI.clipboardReceive");
    },
    clipboardClear: function clipboardClear() {
        document.getElementById('noVNC_clipboard_text').value = "";
        UI.writeLocalClipboard("");
        UI.rfb.clipboardPasteFrom("");
    },
    syncClipboardPanelToLocalClipboard: function syncClipboardPanelToLocalClipboard() {
        var text = document.getElementById('noVNC_clipboard_text').value;
        UI.writeLocalClipboard(text);
    },
    clipboardSend: function clipboardSend() {
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

    openConnectPanel: function openConnectPanel() {
        document.getElementById('noVNC_connect_dlg').classList.add("noVNC_open");
    },
    closeConnectPanel: function closeConnectPanel() {
        document.getElementById('noVNC_connect_dlg').classList.remove("noVNC_open");
    },
    connect: function connect(event, password) {

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

        var url = void 0;

        url = UI.getSetting('encrypt') ? 'wss' : 'ws';

        url += '://' + host;
        if (port) {
            url += ':' + port;
        }
        url += '/' + path;

        UI.rfb = new _rfb2.default(document.getElementById('noVNC_container'), url, { shared: UI.getSetting('shared'),
            repeaterID: UI.getSetting('repeaterID'),
            credentials: { password: password },
            wsProtocols: ['binary', 'base64'] });
        UI.rfb.addEventListener("connect", UI.connectFinished);
        UI.rfb.addEventListener("disconnect", UI.disconnectFinished);
        UI.rfb.addEventListener("credentialsrequired", UI.credentials);
        UI.rfb.addEventListener("securityfailure", UI.securityFailed);
        UI.rfb.addEventListener("capabilities", UI.updatePowerButton);
        UI.rfb.addEventListener("clipboard", UI.clipboardReceive);
        UI.rfb.oncanvasfocus = UI.readLocalClipboard;
        UI.rfb.addEventListener("bell", UI.bell);
        UI.rfb.addEventListener("desktopname", UI.updateDesktopName);
        UI.rfb.clipViewport = UI.getSetting('view_clip');
        UI.rfb.scaleViewport = UI.getSetting('resize') === 'scale';
        UI.rfb.resizeSession = UI.getSetting('resize') === 'remote';
        UI.rfb.showDotCursor = UI.getSetting('show_dot');

        UI.updateViewOnly(); // requires UI.rfb
    },
    disconnect: function disconnect() {
        UI.closeAllPanels();
        UI.rfb.disconnect();

        UI.connected = false;

        // Disable automatic reconnecting
        UI.inhibit_reconnect = true;

        UI.updateVisualState('disconnecting');

        // Don't display the connection settings until we're actually disconnected
    },
    reconnect: function reconnect() {
        UI.reconnect_callback = null;

        // if reconnect has been disabled in the meantime, do nothing.
        if (UI.inhibit_reconnect) {
            return;
        }

        UI.connect(null, UI.reconnect_password);
    },
    cancelReconnect: function cancelReconnect() {
        if (UI.reconnect_callback !== null) {
            clearTimeout(UI.reconnect_callback);
            UI.reconnect_callback = null;
        }

        UI.updateVisualState('disconnected');

        UI.openControlbar();
        UI.openConnectPanel();
    },
    connectFinished: function connectFinished(e) {
        UI.connected = true;
        UI.inhibit_reconnect = false;

        var msg = void 0;
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
    disconnectFinished: function disconnectFinished(e) {
        var wasConnected = UI.connected;

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

        document.title = PAGE_TITLE;

        UI.openControlbar();
        UI.openConnectPanel();
    },
    securityFailed: function securityFailed(e) {
        var msg = "";
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

    credentials: function credentials(e) {
        // FIXME: handle more types

        document.getElementById("noVNC_username_block").classList.remove("noVNC_hidden");
        document.getElementById("noVNC_password_block").classList.remove("noVNC_hidden");

        var inputFocus = "none";
        if (e.detail.types.indexOf("username") === -1) {
            document.getElementById("noVNC_username_block").classList.add("noVNC_hidden");
        } else {
            inputFocus = inputFocus === "none" ? "noVNC_username_input" : inputFocus;
        }
        if (e.detail.types.indexOf("password") === -1) {
            document.getElementById("noVNC_password_block").classList.add("noVNC_hidden");
        } else {
            inputFocus = inputFocus === "none" ? "noVNC_password_input" : inputFocus;
        }
        document.getElementById('noVNC_credentials_dlg').classList.add('noVNC_open');

        setTimeout(function () {
            return document.getElementById(inputFocus).focus();
        }, 100);

        Log.Warn("Server asked for credentials");
        UI.showStatus((0, _localization2.default)("Credentials are required"), "warning");
    },
    setCredentials: function setCredentials(e) {
        // Prevent actually submitting the form
        e.preventDefault();

        var inputElemUsername = document.getElementById('noVNC_username_input');
        var username = inputElemUsername.value;

        var inputElemPassword = document.getElementById('noVNC_password_input');
        var password = inputElemPassword.value;
        // Clear the input after reading the password
        inputElemPassword.value = "";

        UI.rfb.sendCredentials({ username: username, password: password });
        UI.reconnect_password = password;
        document.getElementById('noVNC_credentials_dlg').classList.remove('noVNC_open');
    },


    /* ------^-------
     *  /PASSWORD
     * ==============
     *   FULLSCREEN
     * ------v------*/

    toggleFullscreen: function toggleFullscreen() {
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
        UI.updateFullscreenButton();
    },
    updateFullscreenButton: function updateFullscreenButton() {
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
    applyResizeMode: function applyResizeMode() {
        if (!UI.rfb) return;

        UI.rfb.scaleViewport = UI.getSetting('resize') === 'scale';
        UI.rfb.resizeSession = UI.getSetting('resize') === 'remote';
    },


    /* ------^-------
     *    /RESIZE
     * ==============
     * VIEW CLIPPING
     * ------v------*/

    // Update viewport clipping property for the connection. The normal
    // case is to get the value from the setting. There are special cases
    // for when the viewport is scaled or when a touch device is used.
    updateViewClip: function updateViewClip() {
        if (!UI.rfb) return;

        var scaling = UI.getSetting('resize') === 'scale';

        if (scaling) {
            // Can't be clipping if viewport is scaled to fit
            UI.forceSetting('view_clip', false);
            UI.rfb.clipViewport = false;
        } else if (!_browser.hasScrollbarGutter) {
            // Some platforms have scrollbars that are difficult
            // to use in our case, so we always use our own panning
            UI.forceSetting('view_clip', true);
            UI.rfb.clipViewport = true;
        } else {
            UI.enableSetting('view_clip');
            UI.rfb.clipViewport = UI.getSetting('view_clip');
        }

        // Changing the viewport may change the state of
        // the dragging button
        UI.updateViewDrag();
    },


    /* ------^-------
     * /VIEW CLIPPING
     * ==============
     *    VIEWDRAG
     * ------v------*/

    toggleViewDrag: function toggleViewDrag() {
        if (!UI.rfb) return;

        UI.rfb.dragViewport = !UI.rfb.dragViewport;
        UI.updateViewDrag();
    },
    updateViewDrag: function updateViewDrag() {
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

        if (UI.rfb.clipViewport) {
            viewDragButton.classList.remove("noVNC_hidden");
        } else {
            viewDragButton.classList.add("noVNC_hidden");
        }
    },


    /* ------^-------
     *   /VIEWDRAG
     * ==============
     *    KEYBOARD
     * ------v------*/

    showVirtualKeyboard: function showVirtualKeyboard() {
        if (!_browser.isTouchDevice) return;

        var input = document.getElementById('noVNC_keyboardinput');

        if (document.activeElement == input) return;

        input.focus();

        try {
            var l = input.value.length;
            // Move the caret to the end
            input.setSelectionRange(l, l);
        } catch (err) {
            // setSelectionRange is undefined in Google Chrome
        }
    },
    hideVirtualKeyboard: function hideVirtualKeyboard() {
        if (!_browser.isTouchDevice) return;

        var input = document.getElementById('noVNC_keyboardinput');

        if (document.activeElement != input) return;

        input.blur();
    },
    toggleVirtualKeyboard: function toggleVirtualKeyboard() {
        if (document.getElementById('noVNC_keyboard_button').classList.contains("noVNC_selected")) {
            UI.hideVirtualKeyboard();
        } else {
            UI.showVirtualKeyboard();
        }
    },
    onfocusVirtualKeyboard: function onfocusVirtualKeyboard(event) {
        document.getElementById('noVNC_keyboard_button').classList.add("noVNC_selected");
        if (UI.rfb) {
            UI.rfb.focusOnClick = false;
        }
    },
    onblurVirtualKeyboard: function onblurVirtualKeyboard(event) {
        document.getElementById('noVNC_keyboard_button').classList.remove("noVNC_selected");
        if (UI.rfb) {
            UI.rfb.focusOnClick = true;
        }
    },
    keepVirtualKeyboard: function keepVirtualKeyboard(event) {
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
    keyboardinputReset: function keyboardinputReset() {
        var kbi = document.getElementById('noVNC_keyboardinput');
        kbi.value = new Array(UI.defaultKeyboardinputLen).join("_");
        UI.lastKeyboardinput = kbi.value;
    },
    keyEvent: function keyEvent(keysym, code, down) {
        if (!UI.rfb) return;

        UI.rfb.sendKey(keysym, code, down);
    },


    // When normal keyboard events are left uncought, use the input events from
    // the keyboardinput element instead and generate the corresponding key events.
    // This code is required since some browsers on Android are inconsistent in
    // sending keyCodes in the normal keyboard events when using on screen keyboards.
    keyInput: function keyInput(event) {

        if (!UI.rfb) return;

        var newValue = event.target.value;

        if (!UI.lastKeyboardinput) {
            UI.keyboardinputReset();
        }
        var oldValue = UI.lastKeyboardinput;

        var newLen = void 0;
        try {
            // Try to check caret position since whitespace at the end
            // will not be considered by value.length in some browsers
            newLen = Math.max(event.target.selectionStart, newValue.length);
        } catch (err) {
            // selectionStart is undefined in Google Chrome
            newLen = newValue.length;
        }
        var oldLen = oldValue.length;

        var inputs = newLen - oldLen;
        var backspaces = inputs < 0 ? -inputs : 0;

        // Compare the old string with the new to account for
        // text-corrections or other input that modify existing text
        for (var i = 0; i < Math.min(oldLen, newLen); i++) {
            if (newValue.charAt(i) != oldValue.charAt(i)) {
                inputs = newLen - i;
                backspaces = oldLen - i;
                break;
            }
        }

        // Send the key events
        for (var _i = 0; _i < backspaces; _i++) {
            UI.rfb.sendKey(_keysym2.default.XK_BackSpace, "Backspace");
        }
        for (var _i2 = newLen - inputs; _i2 < newLen; _i2++) {
            UI.rfb.sendKey(_keysymdef2.default.lookup(newValue.charCodeAt(_i2)));
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

    openExtraKeys: function openExtraKeys() {
        UI.closeAllPanels();
        UI.openControlbar();

        document.getElementById('noVNC_modifiers').classList.add("noVNC_open");
        document.getElementById('noVNC_toggle_extra_keys_button').classList.add("noVNC_selected");
    },
    closeExtraKeys: function closeExtraKeys() {
        document.getElementById('noVNC_modifiers').classList.remove("noVNC_open");
        document.getElementById('noVNC_toggle_extra_keys_button').classList.remove("noVNC_selected");
    },
    toggleExtraKeys: function toggleExtraKeys() {
        if (document.getElementById('noVNC_modifiers').classList.contains("noVNC_open")) {
            UI.closeExtraKeys();
        } else {
            UI.openExtraKeys();
        }
    },
    sendEsc: function sendEsc() {
        UI.sendKey(_keysym2.default.XK_Escape, "Escape");
    },
    sendTab: function sendTab() {
        UI.sendKey(_keysym2.default.XK_Tab, "Tab");
    },
    toggleCtrl: function toggleCtrl() {
        var btn = document.getElementById('noVNC_toggle_ctrl_button');
        if (btn.classList.contains("noVNC_selected")) {
            UI.sendKey(_keysym2.default.XK_Control_L, "ControlLeft", false);
            btn.classList.remove("noVNC_selected");
        } else {
            UI.sendKey(_keysym2.default.XK_Control_L, "ControlLeft", true);
            btn.classList.add("noVNC_selected");
        }
    },
    toggleWindows: function toggleWindows() {
        var btn = document.getElementById('noVNC_toggle_windows_button');
        if (btn.classList.contains("noVNC_selected")) {
            UI.sendKey(_keysym2.default.XK_Super_L, "MetaLeft", false);
            btn.classList.remove("noVNC_selected");
        } else {
            UI.sendKey(_keysym2.default.XK_Super_L, "MetaLeft", true);
            btn.classList.add("noVNC_selected");
        }
    },
    toggleAlt: function toggleAlt() {
        var btn = document.getElementById('noVNC_toggle_alt_button');
        if (btn.classList.contains("noVNC_selected")) {
            UI.sendKey(_keysym2.default.XK_Alt_L, "AltLeft", false);
            btn.classList.remove("noVNC_selected");
        } else {
            UI.sendKey(_keysym2.default.XK_Alt_L, "AltLeft", true);
            btn.classList.add("noVNC_selected");
        }
    },
    sendCtrlAltDel: function sendCtrlAltDel() {
        UI.rfb.sendCtrlAltDel();
        // See below
        UI.rfb.focus();
        UI.idleControlbar();
    },
    sendKey: function sendKey(keysym, code, down) {
        UI.rfb.sendKey(keysym, code, down);

        // Move focus to the screen in order to be able to use the
        // keyboard right after these extra keys.
        // The exception is when a virtual keyboard is used, because
        // if we focus the screen the virtual keyboard would be closed.
        // In this case we focus our special virtual keyboard input
        // element instead.
        if (document.getElementById('noVNC_keyboard_button').classList.contains("noVNC_selected")) {
            document.getElementById('noVNC_keyboardinput').focus();
        } else {
            UI.rfb.focus();
        }
        // fade out the controlbar to highlight that
        // the focus has been moved to the screen
        UI.idleControlbar();
    },


    /* ------^-------
     *   /EXTRA KEYS
     * ==============
     *     MISC
     * ------v------*/

    setMouseButton: function setMouseButton(num) {
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
    updateViewOnly: function updateViewOnly() {
        if (!UI.rfb) return;
        UI.rfb.viewOnly = UI.getSetting('view_only');

        // Hide input related buttons in view only mode
        if (UI.rfb.viewOnly) {
            document.getElementById('noVNC_keyboard_button').classList.add('noVNC_hidden');
            document.getElementById('noVNC_toggle_extra_keys_button').classList.add('noVNC_hidden');
            document.getElementById('noVNC_mouse_button' + UI.rfb.touchButton).classList.add('noVNC_hidden');
        } else {
            document.getElementById('noVNC_keyboard_button').classList.remove('noVNC_hidden');
            document.getElementById('noVNC_toggle_extra_keys_button').classList.remove('noVNC_hidden');
            document.getElementById('noVNC_mouse_button' + UI.rfb.touchButton).classList.remove('noVNC_hidden');
        }
    },
    updateShowDotCursor: function updateShowDotCursor() {
        if (!UI.rfb) return;
        UI.rfb.showDotCursor = UI.getSetting('show_dot');
    },
    updateLogging: function updateLogging() {
        WebUtil.init_logging(UI.getSetting('logging'));
    },
    updateDesktopName: function updateDesktopName(e) {
        UI.desktopName = e.detail.name;
        // Display the desktop name in the document title
        document.title = e.detail.name + " - " + PAGE_TITLE;
    },
    bell: function bell(e) {
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
    addOption: function addOption(selectbox, text, value) {
        var optn = document.createElement("OPTION");
        optn.text = text;
        optn.value = value;
        selectbox.options.add(optn);
    }
};

// Set up translations
var LINGUAS = ["cs", "de", "el", "es", "ja", "ko", "nl", "pl", "ru", "sv", "tr", "zh_CN", "zh_TW"];
_localization.l10n.setup(LINGUAS);
if (_localization.l10n.language === "en" || _localization.l10n.dictionary !== undefined) {
    UI.prime();
} else {
    WebUtil.fetchJSON('app/locale/' + _localization.l10n.language + '.json').then(function (translations) {
        _localization.l10n.dictionary = translations;
    }).catch(function (err) {
        return Log.Error("Failed to load translations: " + err);
    }).then(UI.prime);
}

exports.default = UI;
},{"../core/input/keyboard.js":18,"../core/input/keysym.js":19,"../core/input/keysymdef.js":20,"../core/rfb.js":25,"../core/util/browser.js":26,"../core/util/events.js":28,"../core/util/logging.js":31,"./localization.js":1,"./webutil.js":3}],3:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.init_logging = init_logging;
exports.getQueryVar = getQueryVar;
exports.getHashVar = getHashVar;
exports.getConfigVar = getConfigVar;
exports.createCookie = createCookie;
exports.readCookie = readCookie;
exports.eraseCookie = eraseCookie;
exports.initSettings = initSettings;
exports.setSetting = setSetting;
exports.writeSetting = writeSetting;
exports.readSetting = readSetting;
exports.eraseSetting = eraseSetting;
exports.injectParamIfMissing = injectParamIfMissing;
exports.fetchJSON = fetchJSON;

var _logging = require("../core/util/logging.js");

// init log level reading the logging HTTP param
function init_logging(level) {
    "use strict";

    if (typeof level !== "undefined") {
        (0, _logging.init_logging)(level);
    } else {
        var param = document.location.href.match(/logging=([A-Za-z0-9._-]*)/);
        (0, _logging.init_logging)(param || undefined);
    }
}

// Read a query string variable
/*
 * noVNC: HTML5 VNC client
 * Copyright (C) 2019 The noVNC Authors
 * Licensed under MPL 2.0 (see LICENSE.txt)
 *
 * See README.md for usage and integration instructions.
 */

function getQueryVar(name, defVal) {
    "use strict";

    var re = new RegExp('.*[?&]' + name + '=([^&#]*)'),
        match = document.location.href.match(re);
    if (typeof defVal === 'undefined') {
        defVal = null;
    }

    if (match) {
        return decodeURIComponent(match[1]);
    }

    return defVal;
}

// Read a hash fragment variable
function getHashVar(name, defVal) {
    "use strict";

    var re = new RegExp('.*[&#]' + name + '=([^&]*)'),
        match = document.location.hash.match(re);
    if (typeof defVal === 'undefined') {
        defVal = null;
    }

    if (match) {
        return decodeURIComponent(match[1]);
    }

    return defVal;
}

// Read a variable from the fragment or the query string
// Fragment takes precedence
function getConfigVar(name, defVal) {
    "use strict";

    var val = getHashVar(name);

    if (val === null) {
        return getQueryVar(name, defVal);
    }

    return val;
}

/*
 * Cookie handling. Dervied from: http://www.quirksmode.org/js/cookies.html
 */

// No days means only for this browser session
function createCookie(name, value, days) {
    "use strict";

    var date = void 0,
        expires = void 0;
    if (days) {
        date = new Date();
        date.setTime(date.getTime() + days * 24 * 60 * 60 * 1000);
        expires = "; expires=" + date.toGMTString();
    } else {
        expires = "";
    }

    var secure = void 0;
    if (document.location.protocol === "https:") {
        secure = "; secure";
    } else {
        secure = "";
    }
    document.cookie = name + "=" + value + expires + "; path=/" + secure;
}

function readCookie(name, defaultValue) {
    "use strict";

    var nameEQ = name + "=";
    var ca = document.cookie.split(';');

    for (var i = 0; i < ca.length; i += 1) {
        var c = ca[i];
        while (c.charAt(0) === ' ') {
            c = c.substring(1, c.length);
        }
        if (c.indexOf(nameEQ) === 0) {
            return c.substring(nameEQ.length, c.length);
        }
    }

    return typeof defaultValue !== 'undefined' ? defaultValue : null;
}

function eraseCookie(name) {
    "use strict";

    createCookie(name, "", -1);
}

/*
 * Setting handling.
 */

var settings = {};

function initSettings() {
    if (!window.chrome || !window.chrome.storage) {
        settings = {};
        return Promise.resolve();
    }

    return new Promise(function (resolve) {
        return window.chrome.storage.sync.get(resolve);
    }).then(function (cfg) {
        settings = cfg;
    });
}

// Update the settings cache, but do not write to permanent storage
function setSetting(name, value) {
    settings[name] = value;
}

// No days means only for this browser session
function writeSetting(name, value) {
    "use strict";

    if (settings[name] === value) return;
    settings[name] = value;
    if (window.chrome && window.chrome.storage) {
        window.chrome.storage.sync.set(settings);
    } else {
        localStorage.setItem(name, value);
    }
}

function readSetting(name, defaultValue) {
    "use strict";

    var value = void 0;
    if (name in settings || window.chrome && window.chrome.storage) {
        value = settings[name];
    } else {
        value = localStorage.getItem(name);
        settings[name] = value;
    }
    if (typeof value === "undefined") {
        value = null;
    }

    if (value === null && typeof defaultValue !== "undefined") {
        return defaultValue;
    }

    return value;
}

function eraseSetting(name) {
    "use strict";
    // Deleting here means that next time the setting is read when using local
    // storage, it will be pulled from local storage again.
    // If the setting in local storage is changed (e.g. in another tab)
    // between this delete and the next read, it could lead to an unexpected
    // value change.

    delete settings[name];
    if (window.chrome && window.chrome.storage) {
        window.chrome.storage.sync.remove(name);
    } else {
        localStorage.removeItem(name);
    }
}

function injectParamIfMissing(path, param, value) {
    // force pretend that we're dealing with a relative path
    // (assume that we wanted an extra if we pass one in)
    path = "/" + path;

    var elem = document.createElement('a');
    elem.href = path;

    var param_eq = encodeURIComponent(param) + "=";
    var query = void 0;
    if (elem.search) {
        query = elem.search.slice(1).split('&');
    } else {
        query = [];
    }

    if (!query.some(function (v) {
        return v.startsWith(param_eq);
    })) {
        query.push(param_eq + encodeURIComponent(value));
        elem.search = "?" + query.join("&");
    }

    // some browsers (e.g. IE11) may occasionally omit the leading slash
    // in the elem.pathname string. Handle that case gracefully.
    if (elem.pathname.charAt(0) == "/") {
        return elem.pathname.slice(1) + elem.search + elem.hash;
    }

    return elem.pathname + elem.search + elem.hash;
}

// sadly, we can't use the Fetch API until we decide to drop
// IE11 support or polyfill promises and fetch in IE11.
// resolve will receive an object on success, while reject
// will receive either an event or an error on failure.
function fetchJSON(path) {
    return new Promise(function (resolve, reject) {
        // NB: IE11 doesn't support JSON as a responseType
        var req = new XMLHttpRequest();
        req.open('GET', path);

        req.onload = function () {
            if (req.status === 200) {
                var resObj = void 0;
                try {
                    resObj = JSON.parse(req.responseText);
                } catch (err) {
                    reject(err);
                }
                resolve(resObj);
            } else {
                reject(new Error("XHR got non-200 status while trying to load '" + path + "': " + req.status));
            }
        };

        req.onerror = function (evt) {
            return reject(new Error("XHR encountered an error while trying to load '" + path + "': " + evt.message));
        };

        req.ontimeout = function (evt) {
            return reject(new Error("XHR timed out while trying to load '" + path + "'"));
        };

        req.send();
    });
}
},{"../core/util/logging.js":31}],4:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _logging = require('./util/logging.js');

var Log = _interopRequireWildcard(_logging);

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

exports.default = {
    /* Convert data (an array of integers) to a Base64 string. */
    toBase64Table: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='.split(''),
    base64Pad: '=',

    encode: function encode(data) {
        "use strict";

        var result = '';
        var length = data.length;
        var lengthpad = length % 3;
        // Convert every three bytes to 4 ascii characters.

        for (var i = 0; i < length - 2; i += 3) {
            result += this.toBase64Table[data[i] >> 2];
            result += this.toBase64Table[((data[i] & 0x03) << 4) + (data[i + 1] >> 4)];
            result += this.toBase64Table[((data[i + 1] & 0x0f) << 2) + (data[i + 2] >> 6)];
            result += this.toBase64Table[data[i + 2] & 0x3f];
        }

        // Convert the remaining 1 or 2 bytes, pad out to 4 characters.
        var j = length - lengthpad;
        if (lengthpad === 2) {
            result += this.toBase64Table[data[j] >> 2];
            result += this.toBase64Table[((data[j] & 0x03) << 4) + (data[j + 1] >> 4)];
            result += this.toBase64Table[(data[j + 1] & 0x0f) << 2];
            result += this.toBase64Table[64];
        } else if (lengthpad === 1) {
            result += this.toBase64Table[data[j] >> 2];
            result += this.toBase64Table[(data[j] & 0x03) << 4];
            result += this.toBase64Table[64];
            result += this.toBase64Table[64];
        }

        return result;
    },


    /* Convert Base64 data to a string */
    /* eslint-disable comma-spacing */
    toBinaryTable: [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, 0, -1, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1, -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1],
    /* eslint-enable comma-spacing */

    decode: function decode(data) {
        var offset = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : 0;

        var data_length = data.indexOf('=') - offset;
        if (data_length < 0) {
            data_length = data.length - offset;
        }

        /* Every four characters is 3 resulting numbers */
        var result_length = (data_length >> 2) * 3 + Math.floor(data_length % 4 / 1.5);
        var result = new Array(result_length);

        // Convert one by one.

        var leftbits = 0; // number of bits decoded, but yet to be appended
        var leftdata = 0; // bits decoded, but yet to be appended
        for (var idx = 0, i = offset; i < data.length; i++) {
            var c = this.toBinaryTable[data.charCodeAt(i) & 0x7f];
            var padding = data.charAt(i) === this.base64Pad;
            // Skip illegal characters and whitespace
            if (c === -1) {
                Log.Error("Illegal character code " + data.charCodeAt(i) + " at position " + i);
                continue;
            }

            // Collect data into leftdata, update bitcount
            leftdata = leftdata << 6 | c;
            leftbits += 6;

            // If we have 8 or more bits, append 8 bits to the result
            if (leftbits >= 8) {
                leftbits -= 8;
                // Append if not padding.
                if (!padding) {
                    result[idx++] = leftdata >> leftbits & 0xff;
                }
                leftdata &= (1 << leftbits) - 1;
            }
        }

        // If there are any bits left, the base64 string was corrupted
        if (leftbits) {
            var err = new Error('Corrupted base64 string');
            err.name = 'Base64-Error';
            throw err;
        }

        return result;
    }
}; /* End of Base64 namespace */
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

// From: http://hg.mozilla.org/mozilla-central/raw-file/ec10630b1a54/js/src/devtools/jint/sunspider/string-base64.js
},{"./util/logging.js":31}],5:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

/*
 * noVNC: HTML5 VNC client
 * Copyright (C) 2019 The noVNC Authors
 * Licensed under MPL 2.0 (see LICENSE.txt)
 *
 * See README.md for usage and integration instructions.
 *
 */

var CopyRectDecoder = function () {
    function CopyRectDecoder() {
        _classCallCheck(this, CopyRectDecoder);
    }

    _createClass(CopyRectDecoder, [{
        key: "decodeRect",
        value: function decodeRect(x, y, width, height, sock, display, depth) {
            if (sock.rQwait("COPYRECT", 4)) {
                return false;
            }

            var deltaX = sock.rQshift16();
            var deltaY = sock.rQshift16();
            display.copyImage(deltaX, deltaY, x, y, width, height);

            return true;
        }
    }]);

    return CopyRectDecoder;
}();

exports.default = CopyRectDecoder;
},{}],6:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }(); /*
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * noVNC: HTML5 VNC client
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Copyright (C) 2019 The noVNC Authors
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Licensed under MPL 2.0 (see LICENSE.txt)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      *
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * See README.md for usage and integration instructions.
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      *
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      */

var _logging = require("../util/logging.js");

var Log = _interopRequireWildcard(_logging);

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var HextileDecoder = function () {
    function HextileDecoder() {
        _classCallCheck(this, HextileDecoder);

        this._tiles = 0;
        this._lastsubencoding = 0;
    }

    _createClass(HextileDecoder, [{
        key: "decodeRect",
        value: function decodeRect(x, y, width, height, sock, display, depth) {
            if (this._tiles === 0) {
                this._tiles_x = Math.ceil(width / 16);
                this._tiles_y = Math.ceil(height / 16);
                this._total_tiles = this._tiles_x * this._tiles_y;
                this._tiles = this._total_tiles;
            }

            while (this._tiles > 0) {
                var bytes = 1;

                if (sock.rQwait("HEXTILE", bytes)) {
                    return false;
                }

                var rQ = sock.rQ;
                var rQi = sock.rQi;

                var subencoding = rQ[rQi]; // Peek
                if (subencoding > 30) {
                    // Raw
                    throw new Error("Illegal hextile subencoding (subencoding: " + subencoding + ")");
                }

                var curr_tile = this._total_tiles - this._tiles;
                var tile_x = curr_tile % this._tiles_x;
                var tile_y = Math.floor(curr_tile / this._tiles_x);
                var tx = x + tile_x * 16;
                var ty = y + tile_y * 16;
                var tw = Math.min(16, x + width - tx);
                var th = Math.min(16, y + height - ty);

                // Figure out how much we are expecting
                if (subencoding & 0x01) {
                    // Raw
                    bytes += tw * th * 4;
                } else {
                    if (subencoding & 0x02) {
                        // Background
                        bytes += 4;
                    }
                    if (subencoding & 0x04) {
                        // Foreground
                        bytes += 4;
                    }
                    if (subencoding & 0x08) {
                        // AnySubrects
                        bytes++; // Since we aren't shifting it off

                        if (sock.rQwait("HEXTILE", bytes)) {
                            return false;
                        }

                        var subrects = rQ[rQi + bytes - 1]; // Peek
                        if (subencoding & 0x10) {
                            // SubrectsColoured
                            bytes += subrects * (4 + 2);
                        } else {
                            bytes += subrects * 2;
                        }
                    }
                }

                if (sock.rQwait("HEXTILE", bytes)) {
                    return false;
                }

                // We know the encoding and have a whole tile
                rQi++;
                if (subencoding === 0) {
                    if (this._lastsubencoding & 0x01) {
                        // Weird: ignore blanks are RAW
                        Log.Debug("     Ignoring blank after RAW");
                    } else {
                        display.fillRect(tx, ty, tw, th, this._background);
                    }
                } else if (subencoding & 0x01) {
                    // Raw
                    display.blitImage(tx, ty, tw, th, rQ, rQi);
                    rQi += bytes - 1;
                } else {
                    if (subencoding & 0x02) {
                        // Background
                        this._background = [rQ[rQi], rQ[rQi + 1], rQ[rQi + 2], rQ[rQi + 3]];
                        rQi += 4;
                    }
                    if (subencoding & 0x04) {
                        // Foreground
                        this._foreground = [rQ[rQi], rQ[rQi + 1], rQ[rQi + 2], rQ[rQi + 3]];
                        rQi += 4;
                    }

                    display.startTile(tx, ty, tw, th, this._background);
                    if (subencoding & 0x08) {
                        // AnySubrects
                        var _subrects = rQ[rQi];
                        rQi++;

                        for (var s = 0; s < _subrects; s++) {
                            var color = void 0;
                            if (subencoding & 0x10) {
                                // SubrectsColoured
                                color = [rQ[rQi], rQ[rQi + 1], rQ[rQi + 2], rQ[rQi + 3]];
                                rQi += 4;
                            } else {
                                color = this._foreground;
                            }
                            var xy = rQ[rQi];
                            rQi++;
                            var sx = xy >> 4;
                            var sy = xy & 0x0f;

                            var wh = rQ[rQi];
                            rQi++;
                            var sw = (wh >> 4) + 1;
                            var sh = (wh & 0x0f) + 1;

                            display.subTile(sx, sy, sw, sh, color);
                        }
                    }
                    display.finishTile();
                }
                sock.rQi = rQi;
                this._lastsubencoding = subencoding;
                this._tiles--;
            }

            return true;
        }
    }]);

    return HextileDecoder;
}();

exports.default = HextileDecoder;
},{"../util/logging.js":31}],7:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

/*
 * noVNC: HTML5 VNC client
 * Copyright (C) 2019 The noVNC Authors
 * Licensed under MPL 2.0 (see LICENSE.txt)
 *
 * See README.md for usage and integration instructions.
 *
 */

var RawDecoder = function () {
    function RawDecoder() {
        _classCallCheck(this, RawDecoder);

        this._lines = 0;
    }

    _createClass(RawDecoder, [{
        key: "decodeRect",
        value: function decodeRect(x, y, width, height, sock, display, depth) {
            if (this._lines === 0) {
                this._lines = height;
            }

            var pixelSize = depth == 8 ? 1 : 4;
            var bytesPerLine = width * pixelSize;

            if (sock.rQwait("RAW", bytesPerLine)) {
                return false;
            }

            var cur_y = y + (height - this._lines);
            var curr_height = Math.min(this._lines, Math.floor(sock.rQlen / bytesPerLine));
            var data = sock.rQ;
            var index = sock.rQi;

            // Convert data if needed
            if (depth == 8) {
                var pixels = width * curr_height;
                var newdata = new Uint8Array(pixels * 4);
                for (var i = 0; i < pixels; i++) {
                    newdata[i * 4 + 0] = (data[index + i] >> 0 & 0x3) * 255 / 3;
                    newdata[i * 4 + 1] = (data[index + i] >> 2 & 0x3) * 255 / 3;
                    newdata[i * 4 + 2] = (data[index + i] >> 4 & 0x3) * 255 / 3;
                    newdata[i * 4 + 4] = 0;
                }
                data = newdata;
                index = 0;
            }

            display.blitImage(x, cur_y, width, curr_height, data, index);
            sock.rQskipBytes(curr_height * bytesPerLine);
            this._lines -= curr_height;
            if (this._lines > 0) {
                return false;
            }

            return true;
        }
    }]);

    return RawDecoder;
}();

exports.default = RawDecoder;
},{}],8:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

/*
 * noVNC: HTML5 VNC client
 * Copyright (C) 2019 The noVNC Authors
 * Licensed under MPL 2.0 (see LICENSE.txt)
 *
 * See README.md for usage and integration instructions.
 *
 */

var RREDecoder = function () {
    function RREDecoder() {
        _classCallCheck(this, RREDecoder);

        this._subrects = 0;
    }

    _createClass(RREDecoder, [{
        key: "decodeRect",
        value: function decodeRect(x, y, width, height, sock, display, depth) {
            if (this._subrects === 0) {
                if (sock.rQwait("RRE", 4 + 4)) {
                    return false;
                }

                this._subrects = sock.rQshift32();

                var color = sock.rQshiftBytes(4); // Background
                display.fillRect(x, y, width, height, color);
            }

            while (this._subrects > 0) {
                if (sock.rQwait("RRE", 4 + 8)) {
                    return false;
                }

                var _color = sock.rQshiftBytes(4);
                var sx = sock.rQshift16();
                var sy = sock.rQshift16();
                var swidth = sock.rQshift16();
                var sheight = sock.rQshift16();
                display.fillRect(x + sx, y + sy, swidth, sheight, _color);

                this._subrects--;
            }

            return true;
        }
    }]);

    return RREDecoder;
}();

exports.default = RREDecoder;
},{}],9:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }(); /*
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * noVNC: HTML5 VNC client
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Copyright (C) 2019 The noVNC Authors
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * (c) 2012 Michael Tinglof, Joe Balaz, Les Piech (Mercuri.ca)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Licensed under MPL 2.0 (see LICENSE.txt)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      *
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * See README.md for usage and integration instructions.
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      *
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      */

var _logging = require("../util/logging.js");

var Log = _interopRequireWildcard(_logging);

var _inflator = require("../inflator.js");

var _inflator2 = _interopRequireDefault(_inflator);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var TightDecoder = function () {
    function TightDecoder() {
        _classCallCheck(this, TightDecoder);

        this._ctl = null;
        this._filter = null;
        this._numColors = 0;
        this._palette = new Uint8Array(1024); // 256 * 4 (max palette size * max bytes-per-pixel)
        this._len = 0;

        this._zlibs = [];
        for (var i = 0; i < 4; i++) {
            this._zlibs[i] = new _inflator2.default();
        }
    }

    _createClass(TightDecoder, [{
        key: "decodeRect",
        value: function decodeRect(x, y, width, height, sock, display, depth) {
            if (this._ctl === null) {
                if (sock.rQwait("TIGHT compression-control", 1)) {
                    return false;
                }

                this._ctl = sock.rQshift8();

                // Reset streams if the server requests it
                for (var i = 0; i < 4; i++) {
                    if (this._ctl >> i & 1) {
                        this._zlibs[i].reset();
                        Log.Info("Reset zlib stream " + i);
                    }
                }

                // Figure out filter
                this._ctl = this._ctl >> 4;
            }

            var ret = void 0;

            if (this._ctl === 0x08) {
                ret = this._fillRect(x, y, width, height, sock, display, depth);
            } else if (this._ctl === 0x09) {
                ret = this._jpegRect(x, y, width, height, sock, display, depth);
            } else if (this._ctl === 0x0A) {
                ret = this._pngRect(x, y, width, height, sock, display, depth);
            } else if ((this._ctl & 0x80) == 0) {
                ret = this._basicRect(this._ctl, x, y, width, height, sock, display, depth);
            } else {
                throw new Error("Illegal tight compression received (ctl: " + this._ctl + ")");
            }

            if (ret) {
                this._ctl = null;
            }

            return ret;
        }
    }, {
        key: "_fillRect",
        value: function _fillRect(x, y, width, height, sock, display, depth) {
            if (sock.rQwait("TIGHT", 3)) {
                return false;
            }

            var rQi = sock.rQi;
            var rQ = sock.rQ;

            display.fillRect(x, y, width, height, [rQ[rQi + 2], rQ[rQi + 1], rQ[rQi]], false);
            sock.rQskipBytes(3);

            return true;
        }
    }, {
        key: "_jpegRect",
        value: function _jpegRect(x, y, width, height, sock, display, depth) {
            var data = this._readData(sock);
            if (data === null) {
                return false;
            }

            display.imageRect(x, y, width, height, "image/jpeg", data);

            return true;
        }
    }, {
        key: "_pngRect",
        value: function _pngRect(x, y, width, height, sock, display, depth) {
            throw new Error("PNG received in standard Tight rect");
        }
    }, {
        key: "_basicRect",
        value: function _basicRect(ctl, x, y, width, height, sock, display, depth) {
            if (this._filter === null) {
                if (ctl & 0x4) {
                    if (sock.rQwait("TIGHT", 1)) {
                        return false;
                    }

                    this._filter = sock.rQshift8();
                } else {
                    // Implicit CopyFilter
                    this._filter = 0;
                }
            }

            var streamId = ctl & 0x3;

            var ret = void 0;

            switch (this._filter) {
                case 0:
                    // CopyFilter
                    ret = this._copyFilter(streamId, x, y, width, height, sock, display, depth);
                    break;
                case 1:
                    // PaletteFilter
                    ret = this._paletteFilter(streamId, x, y, width, height, sock, display, depth);
                    break;
                case 2:
                    // GradientFilter
                    ret = this._gradientFilter(streamId, x, y, width, height, sock, display, depth);
                    break;
                default:
                    throw new Error("Illegal tight filter received (ctl: " + this._filter + ")");
            }

            if (ret) {
                this._filter = null;
            }

            return ret;
        }
    }, {
        key: "_copyFilter",
        value: function _copyFilter(streamId, x, y, width, height, sock, display, depth) {
            var uncompressedSize = width * height * 3;
            var data = void 0;

            if (uncompressedSize < 12) {
                if (sock.rQwait("TIGHT", uncompressedSize)) {
                    return false;
                }

                data = sock.rQshiftBytes(uncompressedSize);
            } else {
                data = this._readData(sock);
                if (data === null) {
                    return false;
                }

                this._zlibs[streamId].setInput(data);
                data = this._zlibs[streamId].inflate(uncompressedSize);
                this._zlibs[streamId].setInput(null);
            }

            display.blitRgbImage(x, y, width, height, data, 0, false);

            return true;
        }
    }, {
        key: "_paletteFilter",
        value: function _paletteFilter(streamId, x, y, width, height, sock, display, depth) {
            if (this._numColors === 0) {
                if (sock.rQwait("TIGHT palette", 1)) {
                    return false;
                }

                var numColors = sock.rQpeek8() + 1;
                var paletteSize = numColors * 3;

                if (sock.rQwait("TIGHT palette", 1 + paletteSize)) {
                    return false;
                }

                this._numColors = numColors;
                sock.rQskipBytes(1);

                sock.rQshiftTo(this._palette, paletteSize);
            }

            var bpp = this._numColors <= 2 ? 1 : 8;
            var rowSize = Math.floor((width * bpp + 7) / 8);
            var uncompressedSize = rowSize * height;

            var data = void 0;

            if (uncompressedSize < 12) {
                if (sock.rQwait("TIGHT", uncompressedSize)) {
                    return false;
                }

                data = sock.rQshiftBytes(uncompressedSize);
            } else {
                data = this._readData(sock);
                if (data === null) {
                    return false;
                }

                this._zlibs[streamId].setInput(data);
                data = this._zlibs[streamId].inflate(uncompressedSize);
                this._zlibs[streamId].setInput(null);
            }

            // Convert indexed (palette based) image data to RGB
            if (this._numColors == 2) {
                this._monoRect(x, y, width, height, data, this._palette, display);
            } else {
                this._paletteRect(x, y, width, height, data, this._palette, display);
            }

            this._numColors = 0;

            return true;
        }
    }, {
        key: "_monoRect",
        value: function _monoRect(x, y, width, height, data, palette, display) {
            // Convert indexed (palette based) image data to RGB
            // TODO: reduce number of calculations inside loop
            var dest = this._getScratchBuffer(width * height * 4);
            var w = Math.floor((width + 7) / 8);
            var w1 = Math.floor(width / 8);

            for (var _y = 0; _y < height; _y++) {
                var dp = void 0,
                    sp = void 0,
                    _x = void 0;
                for (_x = 0; _x < w1; _x++) {
                    for (var b = 7; b >= 0; b--) {
                        dp = (_y * width + _x * 8 + 7 - b) * 4;
                        sp = (data[_y * w + _x] >> b & 1) * 3;
                        dest[dp] = palette[sp];
                        dest[dp + 1] = palette[sp + 1];
                        dest[dp + 2] = palette[sp + 2];
                        dest[dp + 3] = 255;
                    }
                }

                for (var _b = 7; _b >= 8 - width % 8; _b--) {
                    dp = (_y * width + _x * 8 + 7 - _b) * 4;
                    sp = (data[_y * w + _x] >> _b & 1) * 3;
                    dest[dp] = palette[sp];
                    dest[dp + 1] = palette[sp + 1];
                    dest[dp + 2] = palette[sp + 2];
                    dest[dp + 3] = 255;
                }
            }

            display.blitRgbxImage(x, y, width, height, dest, 0, false);
        }
    }, {
        key: "_paletteRect",
        value: function _paletteRect(x, y, width, height, data, palette, display) {
            // Convert indexed (palette based) image data to RGB
            var dest = this._getScratchBuffer(width * height * 4);
            var total = width * height * 4;
            for (var i = 0, j = 0; i < total; i += 4, j++) {
                var sp = data[j] * 3;
                dest[i] = palette[sp];
                dest[i + 1] = palette[sp + 1];
                dest[i + 2] = palette[sp + 2];
                dest[i + 3] = 255;
            }

            display.blitRgbxImage(x, y, width, height, dest, 0, false);
        }
    }, {
        key: "_gradientFilter",
        value: function _gradientFilter(streamId, x, y, width, height, sock, display, depth) {
            throw new Error("Gradient filter not implemented");
        }
    }, {
        key: "_readData",
        value: function _readData(sock) {
            if (this._len === 0) {
                if (sock.rQwait("TIGHT", 3)) {
                    return null;
                }

                var byte = void 0;

                byte = sock.rQshift8();
                this._len = byte & 0x7f;
                if (byte & 0x80) {
                    byte = sock.rQshift8();
                    this._len |= (byte & 0x7f) << 7;
                    if (byte & 0x80) {
                        byte = sock.rQshift8();
                        this._len |= byte << 14;
                    }
                }
            }

            if (sock.rQwait("TIGHT", this._len)) {
                return null;
            }

            var data = sock.rQshiftBytes(this._len);
            this._len = 0;

            return data;
        }
    }, {
        key: "_getScratchBuffer",
        value: function _getScratchBuffer(size) {
            if (!this._scratchBuffer || this._scratchBuffer.length < size) {
                this._scratchBuffer = new Uint8Array(size);
            }
            return this._scratchBuffer;
        }
    }]);

    return TightDecoder;
}();

exports.default = TightDecoder;
},{"../inflator.js":15,"../util/logging.js":31}],10:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _tight = require("./tight.js");

var _tight2 = _interopRequireDefault(_tight);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; } /*
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                * noVNC: HTML5 VNC client
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                * Copyright (C) 2019 The noVNC Authors
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                * Licensed under MPL 2.0 (see LICENSE.txt)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                *
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                * See README.md for usage and integration instructions.
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                *
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                */

var TightPNGDecoder = function (_TightDecoder) {
    _inherits(TightPNGDecoder, _TightDecoder);

    function TightPNGDecoder() {
        _classCallCheck(this, TightPNGDecoder);

        return _possibleConstructorReturn(this, (TightPNGDecoder.__proto__ || Object.getPrototypeOf(TightPNGDecoder)).apply(this, arguments));
    }

    _createClass(TightPNGDecoder, [{
        key: "_pngRect",
        value: function _pngRect(x, y, width, height, sock, display, depth) {
            var data = this._readData(sock);
            if (data === null) {
                return false;
            }

            display.imageRect(x, y, width, height, "image/png", data);

            return true;
        }
    }, {
        key: "_basicRect",
        value: function _basicRect(ctl, x, y, width, height, sock, display, depth) {
            throw new Error("BasicCompression received in TightPNG rect");
        }
    }]);

    return TightPNGDecoder;
}(_tight2.default);

exports.default = TightPNGDecoder;
},{"./tight.js":9}],11:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }(); /*
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * noVNC: HTML5 VNC client
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Copyright (C) 2020 The noVNC Authors
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Licensed under MPL 2.0 (see LICENSE.txt)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      *
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * See README.md for usage and integration instructions.
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      */

var _deflate2 = require("../vendor/pako/lib/zlib/deflate.js");

var _zstream = require("../vendor/pako/lib/zlib/zstream.js");

var _zstream2 = _interopRequireDefault(_zstream);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var Deflator = function () {
    function Deflator() {
        _classCallCheck(this, Deflator);

        this.strm = new _zstream2.default();
        this.chunkSize = 1024 * 10 * 10;
        this.outputBuffer = new Uint8Array(this.chunkSize);
        this.windowBits = 5;

        (0, _deflate2.deflateInit)(this.strm, this.windowBits);
    }

    _createClass(Deflator, [{
        key: "deflate",
        value: function deflate(inData) {
            this.strm.input = inData;
            this.strm.avail_in = this.strm.input.length;
            this.strm.next_in = 0;
            this.strm.output = this.outputBuffer;
            this.strm.avail_out = this.chunkSize;
            this.strm.next_out = 0;

            var lastRet = (0, _deflate2.deflate)(this.strm, _deflate2.Z_FULL_FLUSH);
            var outData = new Uint8Array(this.strm.output.buffer, 0, this.strm.next_out);

            if (lastRet < 0) {
                throw new Error("zlib deflate failed");
            }

            if (this.strm.avail_in > 0) {
                // Read chunks until done

                var chunks = [outData];
                var totalLen = outData.length;
                do {
                    this.strm.output = new Uint8Array(this.chunkSize);
                    this.strm.next_out = 0;
                    this.strm.avail_out = this.chunkSize;

                    lastRet = (0, _deflate2.deflate)(this.strm, _deflate2.Z_FULL_FLUSH);

                    if (lastRet < 0) {
                        throw new Error("zlib deflate failed");
                    }

                    var chunk = new Uint8Array(this.strm.output.buffer, 0, this.strm.next_out);
                    totalLen += chunk.length;
                    chunks.push(chunk);
                } while (this.strm.avail_in > 0);

                // Combine chunks into a single data

                var newData = new Uint8Array(totalLen);
                var offset = 0;

                for (var i = 0; i < chunks.length; i++) {
                    newData.set(chunks[i], offset);
                    offset += chunks[i].length;
                }

                outData = newData;
            }

            this.strm.input = null;
            this.strm.avail_in = 0;
            this.strm.next_in = 0;

            return outData;
        }
    }]);

    return Deflator;
}();

exports.default = Deflator;
},{"../vendor/pako/lib/zlib/deflate.js":38,"../vendor/pako/lib/zlib/zstream.js":44}],12:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

/*
 * Ported from Flashlight VNC ActionScript implementation:
 *     http://www.wizhelp.com/flashlight-vnc/
 *
 * Full attribution follows:
 *
 * -------------------------------------------------------------------------
 *
 * This DES class has been extracted from package Acme.Crypto for use in VNC.
 * The unnecessary odd parity code has been removed.
 *
 * These changes are:
 *  Copyright (C) 1999 AT&T Laboratories Cambridge.  All Rights Reserved.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *

 * DesCipher - the DES encryption method
 *
 * The meat of this code is by Dave Zimmerman <dzimm@widget.com>, and is:
 *
 * Copyright (c) 1996 Widget Workshop, Inc. All Rights Reserved.
 *
 * Permission to use, copy, modify, and distribute this software
 * and its documentation for NON-COMMERCIAL or COMMERCIAL purposes and
 * without fee is hereby granted, provided that this copyright notice is kept
 * intact.
 *
 * WIDGET WORKSHOP MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY
 * OF THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 * TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE, OR NON-INFRINGEMENT. WIDGET WORKSHOP SHALL NOT BE LIABLE
 * FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR
 * DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES.
 *
 * THIS SOFTWARE IS NOT DESIGNED OR INTENDED FOR USE OR RESALE AS ON-LINE
 * CONTROL EQUIPMENT IN HAZARDOUS ENVIRONMENTS REQUIRING FAIL-SAFE
 * PERFORMANCE, SUCH AS IN THE OPERATION OF NUCLEAR FACILITIES, AIRCRAFT
 * NAVIGATION OR COMMUNICATION SYSTEMS, AIR TRAFFIC CONTROL, DIRECT LIFE
 * SUPPORT MACHINES, OR WEAPONS SYSTEMS, IN WHICH THE FAILURE OF THE
 * SOFTWARE COULD LEAD DIRECTLY TO DEATH, PERSONAL INJURY, OR SEVERE
 * PHYSICAL OR ENVIRONMENTAL DAMAGE ("HIGH RISK ACTIVITIES").  WIDGET WORKSHOP
 * SPECIFICALLY DISCLAIMS ANY EXPRESS OR IMPLIED WARRANTY OF FITNESS FOR
 * HIGH RISK ACTIVITIES.
 *
 *
 * The rest is:
 *
 * Copyright (C) 1996 by Jef Poskanzer <jef@acme.com>.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * Visit the ACME Labs Java page for up-to-date versions of this and other
 * fine Java utilities: http://www.acme.com/java/
 */

/* eslint-disable comma-spacing */

// Tables, permutations, S-boxes, etc.
var PC2 = [13, 16, 10, 23, 0, 4, 2, 27, 14, 5, 20, 9, 22, 18, 11, 3, 25, 7, 15, 6, 26, 19, 12, 1, 40, 51, 30, 36, 46, 54, 29, 39, 50, 44, 32, 47, 43, 48, 38, 55, 33, 52, 45, 41, 49, 35, 28, 31],
    totrot = [1, 2, 4, 6, 8, 10, 12, 14, 15, 17, 19, 21, 23, 25, 27, 28];

var z = 0x0;
var a = void 0,
    b = void 0,
    c = void 0,
    d = void 0,
    e = void 0,
    f = void 0;
a = 1 << 16;b = 1 << 24;c = a | b;d = 1 << 2;e = 1 << 10;f = d | e;
var SP1 = [c | e, z | z, a | z, c | f, c | d, a | f, z | d, a | z, z | e, c | e, c | f, z | e, b | f, c | d, b | z, z | d, z | f, b | e, b | e, a | e, a | e, c | z, c | z, b | f, a | d, b | d, b | d, a | d, z | z, z | f, a | f, b | z, a | z, c | f, z | d, c | z, c | e, b | z, b | z, z | e, c | d, a | z, a | e, b | d, z | e, z | d, b | f, a | f, c | f, a | d, c | z, b | f, b | d, z | f, a | f, c | e, z | f, b | e, b | e, z | z, a | d, a | e, z | z, c | d];
a = 1 << 20;b = 1 << 31;c = a | b;d = 1 << 5;e = 1 << 15;f = d | e;
var SP2 = [c | f, b | e, z | e, a | f, a | z, z | d, c | d, b | f, b | d, c | f, c | e, b | z, b | e, a | z, z | d, c | d, a | e, a | d, b | f, z | z, b | z, z | e, a | f, c | z, a | d, b | d, z | z, a | e, z | f, c | e, c | z, z | f, z | z, a | f, c | d, a | z, b | f, c | z, c | e, z | e, c | z, b | e, z | d, c | f, a | f, z | d, z | e, b | z, z | f, c | e, a | z, b | d, a | d, b | f, b | d, a | d, a | e, z | z, b | e, z | f, b | z, c | d, c | f, a | e];
a = 1 << 17;b = 1 << 27;c = a | b;d = 1 << 3;e = 1 << 9;f = d | e;
var SP3 = [z | f, c | e, z | z, c | d, b | e, z | z, a | f, b | e, a | d, b | d, b | d, a | z, c | f, a | d, c | z, z | f, b | z, z | d, c | e, z | e, a | e, c | z, c | d, a | f, b | f, a | e, a | z, b | f, z | d, c | f, z | e, b | z, c | e, b | z, a | d, z | f, a | z, c | e, b | e, z | z, z | e, a | d, c | f, b | e, b | d, z | e, z | z, c | d, b | f, a | z, b | z, c | f, z | d, a | f, a | e, b | d, c | z, b | f, z | f, c | z, a | f, z | d, c | d, a | e];
a = 1 << 13;b = 1 << 23;c = a | b;d = 1 << 0;e = 1 << 7;f = d | e;
var SP4 = [c | d, a | f, a | f, z | e, c | e, b | f, b | d, a | d, z | z, c | z, c | z, c | f, z | f, z | z, b | e, b | d, z | d, a | z, b | z, c | d, z | e, b | z, a | d, a | e, b | f, z | d, a | e, b | e, a | z, c | e, c | f, z | f, b | e, b | d, c | z, c | f, z | f, z | z, z | z, c | z, a | e, b | e, b | f, z | d, c | d, a | f, a | f, z | e, c | f, z | f, z | d, a | z, b | d, a | d, c | e, b | f, a | d, a | e, b | z, c | d, z | e, b | z, a | z, c | e];
a = 1 << 25;b = 1 << 30;c = a | b;d = 1 << 8;e = 1 << 19;f = d | e;
var SP5 = [z | d, a | f, a | e, c | d, z | e, z | d, b | z, a | e, b | f, z | e, a | d, b | f, c | d, c | e, z | f, b | z, a | z, b | e, b | e, z | z, b | d, c | f, c | f, a | d, c | e, b | d, z | z, c | z, a | f, a | z, c | z, z | f, z | e, c | d, z | d, a | z, b | z, a | e, c | d, b | f, a | d, b | z, c | e, a | f, b | f, z | d, a | z, c | e, c | f, z | f, c | z, c | f, a | e, z | z, b | e, c | z, z | f, a | d, b | d, z | e, z | z, b | e, a | f, b | d];
a = 1 << 22;b = 1 << 29;c = a | b;d = 1 << 4;e = 1 << 14;f = d | e;
var SP6 = [b | d, c | z, z | e, c | f, c | z, z | d, c | f, a | z, b | e, a | f, a | z, b | d, a | d, b | e, b | z, z | f, z | z, a | d, b | f, z | e, a | e, b | f, z | d, c | d, c | d, z | z, a | f, c | e, z | f, a | e, c | e, b | z, b | e, z | d, c | d, a | e, c | f, a | z, z | f, b | d, a | z, b | e, b | z, z | f, b | d, c | f, a | e, c | z, a | f, c | e, z | z, c | d, z | d, z | e, c | z, a | f, z | e, a | d, b | f, z | z, c | e, b | z, a | d, b | f];
a = 1 << 21;b = 1 << 26;c = a | b;d = 1 << 1;e = 1 << 11;f = d | e;
var SP7 = [a | z, c | d, b | f, z | z, z | e, b | f, a | f, c | e, c | f, a | z, z | z, b | d, z | d, b | z, c | d, z | f, b | e, a | f, a | d, b | e, b | d, c | z, c | e, a | d, c | z, z | e, z | f, c | f, a | e, z | d, b | z, a | e, b | z, a | e, a | z, b | f, b | f, c | d, c | d, z | d, a | d, b | z, b | e, a | z, c | e, z | f, a | f, c | e, z | f, b | d, c | f, c | z, a | e, z | z, z | d, c | f, z | z, a | f, c | z, z | e, b | d, b | e, z | e, a | d];
a = 1 << 18;b = 1 << 28;c = a | b;d = 1 << 6;e = 1 << 12;f = d | e;
var SP8 = [b | f, z | e, a | z, c | f, b | z, b | f, z | d, b | z, a | d, c | z, c | f, a | e, c | e, a | f, z | e, z | d, c | z, b | d, b | e, z | f, a | e, a | d, c | d, c | e, z | f, z | z, z | z, c | d, b | d, b | e, a | f, a | z, a | f, a | z, c | e, z | e, z | d, c | d, z | e, a | f, b | e, z | d, b | d, c | z, c | d, b | z, a | z, b | f, z | z, c | f, a | d, b | d, c | z, b | e, b | f, z | z, c | f, a | e, a | e, z | f, z | f, a | d, b | z, c | e];

/* eslint-enable comma-spacing */

var DES = function () {
    function DES(password) {
        _classCallCheck(this, DES);

        this.keys = [];

        // Set the key.
        var pc1m = [],
            pcr = [],
            kn = [];

        for (var j = 0, l = 56; j < 56; ++j, l -= 8) {
            l += l < -5 ? 65 : l < -3 ? 31 : l < -1 ? 63 : l === 27 ? 35 : 0; // PC1
            var m = l & 0x7;
            pc1m[j] = (password[l >>> 3] & 1 << m) !== 0 ? 1 : 0;
        }

        for (var i = 0; i < 16; ++i) {
            var _m = i << 1;
            var n = _m + 1;
            kn[_m] = kn[n] = 0;
            for (var o = 28; o < 59; o += 28) {
                for (var _j = o - 28; _j < o; ++_j) {
                    var _l = _j + totrot[i];
                    pcr[_j] = _l < o ? pc1m[_l] : pc1m[_l - 28];
                }
            }
            for (var _j2 = 0; _j2 < 24; ++_j2) {
                if (pcr[PC2[_j2]] !== 0) {
                    kn[_m] |= 1 << 23 - _j2;
                }
                if (pcr[PC2[_j2 + 24]] !== 0) {
                    kn[n] |= 1 << 23 - _j2;
                }
            }
        }

        // cookey
        for (var _i = 0, rawi = 0, KnLi = 0; _i < 16; ++_i) {
            var raw0 = kn[rawi++];
            var raw1 = kn[rawi++];
            this.keys[KnLi] = (raw0 & 0x00fc0000) << 6;
            this.keys[KnLi] |= (raw0 & 0x00000fc0) << 10;
            this.keys[KnLi] |= (raw1 & 0x00fc0000) >>> 10;
            this.keys[KnLi] |= (raw1 & 0x00000fc0) >>> 6;
            ++KnLi;
            this.keys[KnLi] = (raw0 & 0x0003f000) << 12;
            this.keys[KnLi] |= (raw0 & 0x0000003f) << 16;
            this.keys[KnLi] |= (raw1 & 0x0003f000) >>> 4;
            this.keys[KnLi] |= raw1 & 0x0000003f;
            ++KnLi;
        }
    }

    // Encrypt 8 bytes of text


    _createClass(DES, [{
        key: "enc8",
        value: function enc8(text) {
            var b = text.slice();
            var i = 0,
                l = void 0,
                r = void 0,
                x = void 0; // left, right, accumulator

            // Squash 8 bytes to 2 ints
            l = b[i++] << 24 | b[i++] << 16 | b[i++] << 8 | b[i++];
            r = b[i++] << 24 | b[i++] << 16 | b[i++] << 8 | b[i++];

            x = (l >>> 4 ^ r) & 0x0f0f0f0f;
            r ^= x;
            l ^= x << 4;
            x = (l >>> 16 ^ r) & 0x0000ffff;
            r ^= x;
            l ^= x << 16;
            x = (r >>> 2 ^ l) & 0x33333333;
            l ^= x;
            r ^= x << 2;
            x = (r >>> 8 ^ l) & 0x00ff00ff;
            l ^= x;
            r ^= x << 8;
            r = r << 1 | r >>> 31 & 1;
            x = (l ^ r) & 0xaaaaaaaa;
            l ^= x;
            r ^= x;
            l = l << 1 | l >>> 31 & 1;

            for (var _i2 = 0, keysi = 0; _i2 < 8; ++_i2) {
                x = r << 28 | r >>> 4;
                x ^= this.keys[keysi++];
                var fval = SP7[x & 0x3f];
                fval |= SP5[x >>> 8 & 0x3f];
                fval |= SP3[x >>> 16 & 0x3f];
                fval |= SP1[x >>> 24 & 0x3f];
                x = r ^ this.keys[keysi++];
                fval |= SP8[x & 0x3f];
                fval |= SP6[x >>> 8 & 0x3f];
                fval |= SP4[x >>> 16 & 0x3f];
                fval |= SP2[x >>> 24 & 0x3f];
                l ^= fval;
                x = l << 28 | l >>> 4;
                x ^= this.keys[keysi++];
                fval = SP7[x & 0x3f];
                fval |= SP5[x >>> 8 & 0x3f];
                fval |= SP3[x >>> 16 & 0x3f];
                fval |= SP1[x >>> 24 & 0x3f];
                x = l ^ this.keys[keysi++];
                fval |= SP8[x & 0x0000003f];
                fval |= SP6[x >>> 8 & 0x3f];
                fval |= SP4[x >>> 16 & 0x3f];
                fval |= SP2[x >>> 24 & 0x3f];
                r ^= fval;
            }

            r = r << 31 | r >>> 1;
            x = (l ^ r) & 0xaaaaaaaa;
            l ^= x;
            r ^= x;
            l = l << 31 | l >>> 1;
            x = (l >>> 8 ^ r) & 0x00ff00ff;
            r ^= x;
            l ^= x << 8;
            x = (l >>> 2 ^ r) & 0x33333333;
            r ^= x;
            l ^= x << 2;
            x = (r >>> 16 ^ l) & 0x0000ffff;
            l ^= x;
            r ^= x << 16;
            x = (r >>> 4 ^ l) & 0x0f0f0f0f;
            l ^= x;
            r ^= x << 4;

            // Spread ints to bytes
            x = [r, l];
            for (i = 0; i < 8; i++) {
                b[i] = (x[i >>> 2] >>> 8 * (3 - i % 4)) % 256;
                if (b[i] < 0) {
                    b[i] += 256;
                } // unsigned
            }
            return b;
        }

        // Encrypt 16 bytes of text using passwd as key

    }, {
        key: "encrypt",
        value: function encrypt(t) {
            return this.enc8(t.slice(0, 8)).concat(this.enc8(t.slice(8, 16)));
        }
    }]);

    return DES;
}();

exports.default = DES;
},{}],13:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }(); /*
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * noVNC: HTML5 VNC client
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Copyright (C) 2019 The noVNC Authors
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Licensed under MPL 2.0 (see LICENSE.txt)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      *
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * See README.md for usage and integration instructions.
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      */

var _logging = require('./util/logging.js');

var Log = _interopRequireWildcard(_logging);

var _base = require('./base64.js');

var _base2 = _interopRequireDefault(_base);

var _browser = require('./util/browser.js');

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var Display = function () {
    function Display(target) {
        _classCallCheck(this, Display);

        this._drawCtx = null;
        this._c_forceCanvas = false;

        this._renderQ = []; // queue drawing actions for in-oder rendering
        this._flushing = false;

        // the full frame buffer (logical canvas) size
        this._fb_width = 0;
        this._fb_height = 0;

        this._prevDrawStyle = "";
        this._tile = null;
        this._tile16x16 = null;
        this._tile_x = 0;
        this._tile_y = 0;

        Log.Debug(">> Display.constructor");

        // The visible canvas
        this._target = target;

        if (!this._target) {
            throw new Error("Target must be set");
        }

        if (typeof this._target === 'string') {
            throw new Error('target must be a DOM element');
        }

        if (!this._target.getContext) {
            throw new Error("no getContext method");
        }

        this._targetCtx = this._target.getContext('2d');

        // the visible canvas viewport (i.e. what actually gets seen)
        this._viewportLoc = { 'x': 0, 'y': 0, 'w': this._target.width, 'h': this._target.height };

        // The hidden canvas, where we do the actual rendering
        this._backbuffer = document.createElement('canvas');
        this._drawCtx = this._backbuffer.getContext('2d');

        this._damageBounds = { left: 0, top: 0,
            right: this._backbuffer.width,
            bottom: this._backbuffer.height };

        Log.Debug("User Agent: " + navigator.userAgent);

        // Check canvas features
        if (!('createImageData' in this._drawCtx)) {
            throw new Error("Canvas does not support createImageData");
        }

        this._tile16x16 = this._drawCtx.createImageData(16, 16);
        Log.Debug("<< Display.constructor");

        // ===== PROPERTIES =====

        this._scale = 1.0;
        this._clipViewport = false;

        // ===== EVENT HANDLERS =====

        this.onflush = function () {}; // A flush request has finished
    }

    // ===== PROPERTIES =====

    _createClass(Display, [{
        key: 'viewportChangePos',


        // ===== PUBLIC METHODS =====

        value: function viewportChangePos(deltaX, deltaY) {
            var vp = this._viewportLoc;
            deltaX = Math.floor(deltaX);
            deltaY = Math.floor(deltaY);

            if (!this._clipViewport) {
                deltaX = -vp.w; // clamped later of out of bounds
                deltaY = -vp.h;
            }

            var vx2 = vp.x + vp.w - 1;
            var vy2 = vp.y + vp.h - 1;

            // Position change

            if (deltaX < 0 && vp.x + deltaX < 0) {
                deltaX = -vp.x;
            }
            if (vx2 + deltaX >= this._fb_width) {
                deltaX -= vx2 + deltaX - this._fb_width + 1;
            }

            if (vp.y + deltaY < 0) {
                deltaY = -vp.y;
            }
            if (vy2 + deltaY >= this._fb_height) {
                deltaY -= vy2 + deltaY - this._fb_height + 1;
            }

            if (deltaX === 0 && deltaY === 0) {
                return;
            }
            Log.Debug("viewportChange deltaX: " + deltaX + ", deltaY: " + deltaY);

            vp.x += deltaX;
            vp.y += deltaY;

            this._damage(vp.x, vp.y, vp.w, vp.h);

            this.flip();
        }
    }, {
        key: 'viewportChangeSize',
        value: function viewportChangeSize(width, height) {

            if (!this._clipViewport || typeof width === "undefined" || typeof height === "undefined") {

                Log.Debug("Setting viewport to full display region");
                width = this._fb_width;
                height = this._fb_height;
            }

            width = Math.floor(width);
            height = Math.floor(height);

            if (width > this._fb_width) {
                width = this._fb_width;
            }
            if (height > this._fb_height) {
                height = this._fb_height;
            }

            var vp = this._viewportLoc;
            if (vp.w !== width || vp.h !== height) {
                vp.w = width;
                vp.h = height;

                var canvas = this._target;
                canvas.width = width;
                canvas.height = height;

                // The position might need to be updated if we've grown
                this.viewportChangePos(0, 0);

                this._damage(vp.x, vp.y, vp.w, vp.h);
                this.flip();

                // Update the visible size of the target canvas
                this._rescale(this._scale);
            }
        }
    }, {
        key: 'absX',
        value: function absX(x) {
            if (this._scale === 0) {
                return 0;
            }
            return x / this._scale + this._viewportLoc.x;
        }
    }, {
        key: 'absY',
        value: function absY(y) {
            if (this._scale === 0) {
                return 0;
            }
            return y / this._scale + this._viewportLoc.y;
        }
    }, {
        key: 'resize',
        value: function resize(width, height) {
            this._prevDrawStyle = "";

            this._fb_width = width;
            this._fb_height = height;

            var canvas = this._backbuffer;
            if (canvas.width !== width || canvas.height !== height) {

                // We have to save the canvas data since changing the size will clear it
                var saveImg = null;
                if (canvas.width > 0 && canvas.height > 0) {
                    saveImg = this._drawCtx.getImageData(0, 0, canvas.width, canvas.height);
                }

                if (canvas.width !== width) {
                    canvas.width = width;
                }
                if (canvas.height !== height) {
                    canvas.height = height;
                }

                if (saveImg) {
                    this._drawCtx.putImageData(saveImg, 0, 0);
                }
            }

            // Readjust the viewport as it may be incorrectly sized
            // and positioned
            var vp = this._viewportLoc;
            this.viewportChangeSize(vp.w, vp.h);
            this.viewportChangePos(0, 0);
        }

        // Track what parts of the visible canvas that need updating

    }, {
        key: '_damage',
        value: function _damage(x, y, w, h) {
            if (x < this._damageBounds.left) {
                this._damageBounds.left = x;
            }
            if (y < this._damageBounds.top) {
                this._damageBounds.top = y;
            }
            if (x + w > this._damageBounds.right) {
                this._damageBounds.right = x + w;
            }
            if (y + h > this._damageBounds.bottom) {
                this._damageBounds.bottom = y + h;
            }
        }

        // Update the visible canvas with the contents of the
        // rendering canvas

    }, {
        key: 'flip',
        value: function flip(from_queue) {
            if (this._renderQ.length !== 0 && !from_queue) {
                this._renderQ_push({
                    'type': 'flip'
                });
            } else {
                var x = this._damageBounds.left;
                var y = this._damageBounds.top;
                var w = this._damageBounds.right - x;
                var h = this._damageBounds.bottom - y;

                var vx = x - this._viewportLoc.x;
                var vy = y - this._viewportLoc.y;

                if (vx < 0) {
                    w += vx;
                    x -= vx;
                    vx = 0;
                }
                if (vy < 0) {
                    h += vy;
                    y -= vy;
                    vy = 0;
                }

                if (vx + w > this._viewportLoc.w) {
                    w = this._viewportLoc.w - vx;
                }
                if (vy + h > this._viewportLoc.h) {
                    h = this._viewportLoc.h - vy;
                }

                if (w > 0 && h > 0) {
                    // FIXME: We may need to disable image smoothing here
                    //        as well (see copyImage()), but we haven't
                    //        noticed any problem yet.
                    this._targetCtx.drawImage(this._backbuffer, x, y, w, h, vx, vy, w, h);
                }

                this._damageBounds.left = this._damageBounds.top = 65535;
                this._damageBounds.right = this._damageBounds.bottom = 0;
            }
        }
    }, {
        key: 'pending',
        value: function pending() {
            return this._renderQ.length > 0;
        }
    }, {
        key: 'flush',
        value: function flush() {
            if (this._renderQ.length === 0) {
                this.onflush();
            } else {
                this._flushing = true;
            }
        }
    }, {
        key: 'fillRect',
        value: function fillRect(x, y, width, height, color, from_queue) {
            if (this._renderQ.length !== 0 && !from_queue) {
                this._renderQ_push({
                    'type': 'fill',
                    'x': x,
                    'y': y,
                    'width': width,
                    'height': height,
                    'color': color
                });
            } else {
                this._setFillColor(color);
                this._drawCtx.fillRect(x, y, width, height);
                this._damage(x, y, width, height);
            }
        }
    }, {
        key: 'copyImage',
        value: function copyImage(old_x, old_y, new_x, new_y, w, h, from_queue) {
            if (this._renderQ.length !== 0 && !from_queue) {
                this._renderQ_push({
                    'type': 'copy',
                    'old_x': old_x,
                    'old_y': old_y,
                    'x': new_x,
                    'y': new_y,
                    'width': w,
                    'height': h
                });
            } else {
                // Due to this bug among others [1] we need to disable the image-smoothing to
                // avoid getting a blur effect when copying data.
                //
                // 1. https://bugzilla.mozilla.org/show_bug.cgi?id=1194719
                //
                // We need to set these every time since all properties are reset
                // when the the size is changed
                this._drawCtx.mozImageSmoothingEnabled = false;
                this._drawCtx.webkitImageSmoothingEnabled = false;
                this._drawCtx.msImageSmoothingEnabled = false;
                this._drawCtx.imageSmoothingEnabled = false;

                this._drawCtx.drawImage(this._backbuffer, old_x, old_y, w, h, new_x, new_y, w, h);
                this._damage(new_x, new_y, w, h);
            }
        }
    }, {
        key: 'imageRect',
        value: function imageRect(x, y, width, height, mime, arr) {
            /* The internal logic cannot handle empty images, so bail early */
            if (width === 0 || height === 0) {
                return;
            }

            var img = new Image();
            img.src = "data: " + mime + ";base64," + _base2.default.encode(arr);

            this._renderQ_push({
                'type': 'img',
                'img': img,
                'x': x,
                'y': y,
                'width': width,
                'height': height
            });
        }

        // start updating a tile

    }, {
        key: 'startTile',
        value: function startTile(x, y, width, height, color) {
            this._tile_x = x;
            this._tile_y = y;
            if (width === 16 && height === 16) {
                this._tile = this._tile16x16;
            } else {
                this._tile = this._drawCtx.createImageData(width, height);
            }

            var red = color[2];
            var green = color[1];
            var blue = color[0];

            var data = this._tile.data;
            for (var i = 0; i < width * height * 4; i += 4) {
                data[i] = red;
                data[i + 1] = green;
                data[i + 2] = blue;
                data[i + 3] = 255;
            }
        }

        // update sub-rectangle of the current tile

    }, {
        key: 'subTile',
        value: function subTile(x, y, w, h, color) {
            var red = color[2];
            var green = color[1];
            var blue = color[0];
            var xend = x + w;
            var yend = y + h;

            var data = this._tile.data;
            var width = this._tile.width;
            for (var j = y; j < yend; j++) {
                for (var i = x; i < xend; i++) {
                    var p = (i + j * width) * 4;
                    data[p] = red;
                    data[p + 1] = green;
                    data[p + 2] = blue;
                    data[p + 3] = 255;
                }
            }
        }

        // draw the current tile to the screen

    }, {
        key: 'finishTile',
        value: function finishTile() {
            this._drawCtx.putImageData(this._tile, this._tile_x, this._tile_y);
            this._damage(this._tile_x, this._tile_y, this._tile.width, this._tile.height);
        }
    }, {
        key: 'blitImage',
        value: function blitImage(x, y, width, height, arr, offset, from_queue) {
            if (this._renderQ.length !== 0 && !from_queue) {
                // NB(directxman12): it's technically more performant here to use preallocated arrays,
                // but it's a lot of extra work for not a lot of payoff -- if we're using the render queue,
                // this probably isn't getting called *nearly* as much
                var new_arr = new Uint8Array(width * height * 4);
                new_arr.set(new Uint8Array(arr.buffer, 0, new_arr.length));
                this._renderQ_push({
                    'type': 'blit',
                    'data': new_arr,
                    'x': x,
                    'y': y,
                    'width': width,
                    'height': height
                });
            } else {
                this._bgrxImageData(x, y, width, height, arr, offset);
            }
        }
    }, {
        key: 'blitRgbImage',
        value: function blitRgbImage(x, y, width, height, arr, offset, from_queue) {
            if (this._renderQ.length !== 0 && !from_queue) {
                // NB(directxman12): it's technically more performant here to use preallocated arrays,
                // but it's a lot of extra work for not a lot of payoff -- if we're using the render queue,
                // this probably isn't getting called *nearly* as much
                var new_arr = new Uint8Array(width * height * 3);
                new_arr.set(new Uint8Array(arr.buffer, 0, new_arr.length));
                this._renderQ_push({
                    'type': 'blitRgb',
                    'data': new_arr,
                    'x': x,
                    'y': y,
                    'width': width,
                    'height': height
                });
            } else {
                this._rgbImageData(x, y, width, height, arr, offset);
            }
        }
    }, {
        key: 'blitRgbxImage',
        value: function blitRgbxImage(x, y, width, height, arr, offset, from_queue) {
            if (this._renderQ.length !== 0 && !from_queue) {
                // NB(directxman12): it's technically more performant here to use preallocated arrays,
                // but it's a lot of extra work for not a lot of payoff -- if we're using the render queue,
                // this probably isn't getting called *nearly* as much
                var new_arr = new Uint8Array(width * height * 4);
                new_arr.set(new Uint8Array(arr.buffer, 0, new_arr.length));
                this._renderQ_push({
                    'type': 'blitRgbx',
                    'data': new_arr,
                    'x': x,
                    'y': y,
                    'width': width,
                    'height': height
                });
            } else {
                this._rgbxImageData(x, y, width, height, arr, offset);
            }
        }
    }, {
        key: 'drawImage',
        value: function drawImage(img, x, y) {
            this._drawCtx.drawImage(img, x, y);
            this._damage(x, y, img.width, img.height);
        }
    }, {
        key: 'autoscale',
        value: function autoscale(containerWidth, containerHeight) {
            var scaleRatio = void 0;

            if (containerWidth === 0 || containerHeight === 0) {
                scaleRatio = 0;
            } else {

                var vp = this._viewportLoc;
                var targetAspectRatio = containerWidth / containerHeight;
                var fbAspectRatio = vp.w / vp.h;

                if (fbAspectRatio >= targetAspectRatio) {
                    scaleRatio = containerWidth / vp.w;
                } else {
                    scaleRatio = containerHeight / vp.h;
                }
            }

            this._rescale(scaleRatio);
        }

        // ===== PRIVATE METHODS =====

    }, {
        key: '_rescale',
        value: function _rescale(factor) {
            this._scale = factor;
            var vp = this._viewportLoc;

            // NB(directxman12): If you set the width directly, or set the
            //                   style width to a number, the canvas is cleared.
            //                   However, if you set the style width to a string
            //                   ('NNNpx'), the canvas is scaled without clearing.
            var width = factor * vp.w + 'px';
            var height = factor * vp.h + 'px';

            if (this._target.style.width !== width || this._target.style.height !== height) {
                this._target.style.width = width;
                this._target.style.height = height;
            }
        }
    }, {
        key: '_setFillColor',
        value: function _setFillColor(color) {
            var newStyle = 'rgb(' + color[2] + ',' + color[1] + ',' + color[0] + ')';
            if (newStyle !== this._prevDrawStyle) {
                this._drawCtx.fillStyle = newStyle;
                this._prevDrawStyle = newStyle;
            }
        }
    }, {
        key: '_rgbImageData',
        value: function _rgbImageData(x, y, width, height, arr, offset) {
            var img = this._drawCtx.createImageData(width, height);
            var data = img.data;
            for (var i = 0, j = offset; i < width * height * 4; i += 4, j += 3) {
                data[i] = arr[j];
                data[i + 1] = arr[j + 1];
                data[i + 2] = arr[j + 2];
                data[i + 3] = 255; // Alpha
            }
            this._drawCtx.putImageData(img, x, y);
            this._damage(x, y, img.width, img.height);
        }
    }, {
        key: '_bgrxImageData',
        value: function _bgrxImageData(x, y, width, height, arr, offset) {
            var img = this._drawCtx.createImageData(width, height);
            var data = img.data;
            for (var i = 0, j = offset; i < width * height * 4; i += 4, j += 4) {
                data[i] = arr[j + 2];
                data[i + 1] = arr[j + 1];
                data[i + 2] = arr[j];
                data[i + 3] = 255; // Alpha
            }
            this._drawCtx.putImageData(img, x, y);
            this._damage(x, y, img.width, img.height);
        }
    }, {
        key: '_rgbxImageData',
        value: function _rgbxImageData(x, y, width, height, arr, offset) {
            // NB(directxman12): arr must be an Type Array view
            var img = void 0;
            if (_browser.supportsImageMetadata) {
                img = new ImageData(new Uint8ClampedArray(arr.buffer, arr.byteOffset, width * height * 4), width, height);
            } else {
                img = this._drawCtx.createImageData(width, height);
                img.data.set(new Uint8ClampedArray(arr.buffer, arr.byteOffset, width * height * 4));
            }
            this._drawCtx.putImageData(img, x, y);
            this._damage(x, y, img.width, img.height);
        }
    }, {
        key: '_renderQ_push',
        value: function _renderQ_push(action) {
            this._renderQ.push(action);
            if (this._renderQ.length === 1) {
                // If this can be rendered immediately it will be, otherwise
                // the scanner will wait for the relevant event
                this._scan_renderQ();
            }
        }
    }, {
        key: '_resume_renderQ',
        value: function _resume_renderQ() {
            // "this" is the object that is ready, not the
            // display object
            this.removeEventListener('load', this._noVNC_display._resume_renderQ);
            this._noVNC_display._scan_renderQ();
        }
    }, {
        key: '_scan_renderQ',
        value: function _scan_renderQ() {
            var ready = true;
            while (ready && this._renderQ.length > 0) {
                var a = this._renderQ[0];
                switch (a.type) {
                    case 'flip':
                        this.flip(true);
                        break;
                    case 'copy':
                        this.copyImage(a.old_x, a.old_y, a.x, a.y, a.width, a.height, true);
                        break;
                    case 'fill':
                        this.fillRect(a.x, a.y, a.width, a.height, a.color, true);
                        break;
                    case 'blit':
                        this.blitImage(a.x, a.y, a.width, a.height, a.data, 0, true);
                        break;
                    case 'blitRgb':
                        this.blitRgbImage(a.x, a.y, a.width, a.height, a.data, 0, true);
                        break;
                    case 'blitRgbx':
                        this.blitRgbxImage(a.x, a.y, a.width, a.height, a.data, 0, true);
                        break;
                    case 'img':
                        /* IE tends to set "complete" prematurely, so check dimensions */
                        if (a.img.complete && a.img.width !== 0 && a.img.height !== 0) {
                            if (a.img.width !== a.width || a.img.height !== a.height) {
                                Log.Error("Decoded image has incorrect dimensions. Got " + a.img.width + "x" + a.img.height + ". Expected " + a.width + "x" + a.height + ".");
                                return;
                            }
                            this.drawImage(a.img, a.x, a.y);
                        } else {
                            a.img._noVNC_display = this;
                            a.img.addEventListener('load', this._resume_renderQ);
                            // We need to wait for this image to 'load'
                            // to keep things in-order
                            ready = false;
                        }
                        break;
                }

                if (ready) {
                    this._renderQ.shift();
                }
            }

            if (this._renderQ.length === 0 && this._flushing) {
                this._flushing = false;
                this.onflush();
            }
        }
    }, {
        key: 'scale',
        get: function get() {
            return this._scale;
        },
        set: function set(scale) {
            this._rescale(scale);
        }
    }, {
        key: 'clipViewport',
        get: function get() {
            return this._clipViewport;
        },
        set: function set(viewport) {
            this._clipViewport = viewport;
            // May need to readjust the viewport dimensions
            var vp = this._viewportLoc;
            this.viewportChangeSize(vp.w, vp.h);
            this.viewportChangePos(0, 0);
        }
    }, {
        key: 'width',
        get: function get() {
            return this._fb_width;
        }
    }, {
        key: 'height',
        get: function get() {
            return this._fb_height;
        }
    }]);

    return Display;
}();

exports.default = Display;
},{"./base64.js":4,"./util/browser.js":26,"./util/logging.js":31}],14:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.encodingName = encodingName;
/*
 * noVNC: HTML5 VNC client
 * Copyright (C) 2019 The noVNC Authors
 * Licensed under MPL 2.0 (see LICENSE.txt)
 *
 * See README.md for usage and integration instructions.
 */

var encodings = exports.encodings = {
    encodingRaw: 0,
    encodingCopyRect: 1,
    encodingRRE: 2,
    encodingHextile: 5,
    encodingTight: 7,
    encodingTightPNG: -260,

    pseudoEncodingQualityLevel9: -23,
    pseudoEncodingQualityLevel0: -32,
    pseudoEncodingDesktopSize: -223,
    pseudoEncodingLastRect: -224,
    pseudoEncodingCursor: -239,
    pseudoEncodingQEMUExtendedKeyEvent: -258,
    pseudoEncodingDesktopName: -307,
    pseudoEncodingExtendedDesktopSize: -308,
    pseudoEncodingXvp: -309,
    pseudoEncodingFence: -312,
    pseudoEncodingContinuousUpdates: -313,
    pseudoEncodingCompressLevel9: -247,
    pseudoEncodingCompressLevel0: -256,
    pseudoEncodingVMwareCursor: 0x574d5664,
    pseudoEncodingExtendedClipboard: 0xc0a1e5ce
};

function encodingName(num) {
    switch (num) {
        case encodings.encodingRaw:
            return "Raw";
        case encodings.encodingCopyRect:
            return "CopyRect";
        case encodings.encodingRRE:
            return "RRE";
        case encodings.encodingHextile:
            return "Hextile";
        case encodings.encodingTight:
            return "Tight";
        case encodings.encodingTightPNG:
            return "TightPNG";
        default:
            return "[unknown encoding " + num + "]";
    }
}
},{}],15:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }(); /*
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * noVNC: HTML5 VNC client
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Copyright (C) 2020 The noVNC Authors
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Licensed under MPL 2.0 (see LICENSE.txt)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      *
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * See README.md for usage and integration instructions.
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      */

var _inflate2 = require("../vendor/pako/lib/zlib/inflate.js");

var _zstream = require("../vendor/pako/lib/zlib/zstream.js");

var _zstream2 = _interopRequireDefault(_zstream);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var Inflate = function () {
    function Inflate() {
        _classCallCheck(this, Inflate);

        this.strm = new _zstream2.default();
        this.chunkSize = 1024 * 10 * 10;
        this.strm.output = new Uint8Array(this.chunkSize);
        this.windowBits = 5;

        (0, _inflate2.inflateInit)(this.strm, this.windowBits);
    }

    _createClass(Inflate, [{
        key: "setInput",
        value: function setInput(data) {
            if (!data) {
                //FIXME: flush remaining data.
                this.strm.input = null;
                this.strm.avail_in = 0;
                this.strm.next_in = 0;
            } else {
                this.strm.input = data;
                this.strm.avail_in = this.strm.input.length;
                this.strm.next_in = 0;
            }
        }
    }, {
        key: "inflate",
        value: function inflate(expected) {
            // resize our output buffer if it's too small
            // (we could just use multiple chunks, but that would cause an extra
            // allocation each time to flatten the chunks)
            if (expected > this.chunkSize) {
                this.chunkSize = expected;
                this.strm.output = new Uint8Array(this.chunkSize);
            }

            this.strm.next_out = 0;
            this.strm.avail_out = expected;

            var ret = (0, _inflate2.inflate)(this.strm, 0); // Flush argument not used.
            if (ret < 0) {
                throw new Error("zlib inflate failed");
            }

            if (this.strm.next_out != expected) {
                throw new Error("Incomplete zlib block");
            }

            return new Uint8Array(this.strm.output.buffer, 0, this.strm.next_out);
        }
    }, {
        key: "reset",
        value: function reset() {
            (0, _inflate2.inflateReset)(this.strm);
        }
    }]);

    return Inflate;
}();

exports.default = Inflate;
},{"../vendor/pako/lib/zlib/inflate.js":40,"../vendor/pako/lib/zlib/zstream.js":44}],16:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _keysym = require("./keysym.js");

var _keysym2 = _interopRequireDefault(_keysym);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

/*
 * Mapping between HTML key values and VNC/X11 keysyms for "special"
 * keys that cannot be handled via their Unicode codepoint.
 *
 * See https://www.w3.org/TR/uievents-key/ for possible values.
 */

var DOMKeyTable = {}; /*
                       * noVNC: HTML5 VNC client
                       * Copyright (C) 2018 The noVNC Authors
                       * Licensed under MPL 2.0 or any later version (see LICENSE.txt)
                       */

function addStandard(key, standard) {
    if (standard === undefined) throw new Error("Undefined keysym for key \"" + key + "\"");
    if (key in DOMKeyTable) throw new Error("Duplicate entry for key \"" + key + "\"");
    DOMKeyTable[key] = [standard, standard, standard, standard];
}

function addLeftRight(key, left, right) {
    if (left === undefined) throw new Error("Undefined keysym for key \"" + key + "\"");
    if (right === undefined) throw new Error("Undefined keysym for key \"" + key + "\"");
    if (key in DOMKeyTable) throw new Error("Duplicate entry for key \"" + key + "\"");
    DOMKeyTable[key] = [left, left, right, left];
}

function addNumpad(key, standard, numpad) {
    if (standard === undefined) throw new Error("Undefined keysym for key \"" + key + "\"");
    if (numpad === undefined) throw new Error("Undefined keysym for key \"" + key + "\"");
    if (key in DOMKeyTable) throw new Error("Duplicate entry for key \"" + key + "\"");
    DOMKeyTable[key] = [standard, standard, standard, numpad];
}

// 2.2. Modifier Keys

addLeftRight("Alt", _keysym2.default.XK_Alt_L, _keysym2.default.XK_Alt_R);
addStandard("AltGraph", _keysym2.default.XK_ISO_Level3_Shift);
addStandard("CapsLock", _keysym2.default.XK_Caps_Lock);
addLeftRight("Control", _keysym2.default.XK_Control_L, _keysym2.default.XK_Control_R);
// - Fn
// - FnLock
addLeftRight("Meta", _keysym2.default.XK_Super_L, _keysym2.default.XK_Super_R);
addStandard("NumLock", _keysym2.default.XK_Num_Lock);
addStandard("ScrollLock", _keysym2.default.XK_Scroll_Lock);
addLeftRight("Shift", _keysym2.default.XK_Shift_L, _keysym2.default.XK_Shift_R);
// - Symbol
// - SymbolLock

// 2.3. Whitespace Keys

addNumpad("Enter", _keysym2.default.XK_Return, _keysym2.default.XK_KP_Enter);
addStandard("Tab", _keysym2.default.XK_Tab);
addNumpad(" ", _keysym2.default.XK_space, _keysym2.default.XK_KP_Space);

// 2.4. Navigation Keys

addNumpad("ArrowDown", _keysym2.default.XK_Down, _keysym2.default.XK_KP_Down);
addNumpad("ArrowUp", _keysym2.default.XK_Up, _keysym2.default.XK_KP_Up);
addNumpad("ArrowLeft", _keysym2.default.XK_Left, _keysym2.default.XK_KP_Left);
addNumpad("ArrowRight", _keysym2.default.XK_Right, _keysym2.default.XK_KP_Right);
addNumpad("End", _keysym2.default.XK_End, _keysym2.default.XK_KP_End);
addNumpad("Home", _keysym2.default.XK_Home, _keysym2.default.XK_KP_Home);
addNumpad("PageDown", _keysym2.default.XK_Next, _keysym2.default.XK_KP_Next);
addNumpad("PageUp", _keysym2.default.XK_Prior, _keysym2.default.XK_KP_Prior);

// 2.5. Editing Keys

addStandard("Backspace", _keysym2.default.XK_BackSpace);
// Browsers send "Clear" for the numpad 5 without NumLock because
// Windows uses VK_Clear for that key. But Unix expects KP_Begin for
// that scenario.
addNumpad("Clear", _keysym2.default.XK_Clear, _keysym2.default.XK_KP_Begin);
addStandard("Copy", _keysym2.default.XF86XK_Copy);
// - CrSel
addStandard("Cut", _keysym2.default.XF86XK_Cut);
addNumpad("Delete", _keysym2.default.XK_Delete, _keysym2.default.XK_KP_Delete);
// - EraseEof
// - ExSel
addNumpad("Insert", _keysym2.default.XK_Insert, _keysym2.default.XK_KP_Insert);
addStandard("Paste", _keysym2.default.XF86XK_Paste);
addStandard("Redo", _keysym2.default.XK_Redo);
addStandard("Undo", _keysym2.default.XK_Undo);

// 2.6. UI Keys

// - Accept
// - Again (could just be XK_Redo)
// - Attn
addStandard("Cancel", _keysym2.default.XK_Cancel);
addStandard("ContextMenu", _keysym2.default.XK_Menu);
addStandard("Escape", _keysym2.default.XK_Escape);
addStandard("Execute", _keysym2.default.XK_Execute);
addStandard("Find", _keysym2.default.XK_Find);
addStandard("Help", _keysym2.default.XK_Help);
addStandard("Pause", _keysym2.default.XK_Pause);
// - Play
// - Props
addStandard("Select", _keysym2.default.XK_Select);
addStandard("ZoomIn", _keysym2.default.XF86XK_ZoomIn);
addStandard("ZoomOut", _keysym2.default.XF86XK_ZoomOut);

// 2.7. Device Keys

addStandard("BrightnessDown", _keysym2.default.XF86XK_MonBrightnessDown);
addStandard("BrightnessUp", _keysym2.default.XF86XK_MonBrightnessUp);
addStandard("Eject", _keysym2.default.XF86XK_Eject);
addStandard("LogOff", _keysym2.default.XF86XK_LogOff);
addStandard("Power", _keysym2.default.XF86XK_PowerOff);
addStandard("PowerOff", _keysym2.default.XF86XK_PowerDown);
addStandard("PrintScreen", _keysym2.default.XK_Print);
addStandard("Hibernate", _keysym2.default.XF86XK_Hibernate);
addStandard("Standby", _keysym2.default.XF86XK_Standby);
addStandard("WakeUp", _keysym2.default.XF86XK_WakeUp);

// 2.8. IME and Composition Keys

addStandard("AllCandidates", _keysym2.default.XK_MultipleCandidate);
addStandard("Alphanumeric", _keysym2.default.XK_Eisu_Shift); // could also be _Eisu_Toggle
addStandard("CodeInput", _keysym2.default.XK_Codeinput);
addStandard("Compose", _keysym2.default.XK_Multi_key);
addStandard("Convert", _keysym2.default.XK_Henkan);
// - Dead
// - FinalMode
addStandard("GroupFirst", _keysym2.default.XK_ISO_First_Group);
addStandard("GroupLast", _keysym2.default.XK_ISO_Last_Group);
addStandard("GroupNext", _keysym2.default.XK_ISO_Next_Group);
addStandard("GroupPrevious", _keysym2.default.XK_ISO_Prev_Group);
// - ModeChange (XK_Mode_switch is often used for AltGr)
// - NextCandidate
addStandard("NonConvert", _keysym2.default.XK_Muhenkan);
addStandard("PreviousCandidate", _keysym2.default.XK_PreviousCandidate);
// - Process
addStandard("SingleCandidate", _keysym2.default.XK_SingleCandidate);
addStandard("HangulMode", _keysym2.default.XK_Hangul);
addStandard("HanjaMode", _keysym2.default.XK_Hangul_Hanja);
addStandard("JunjuaMode", _keysym2.default.XK_Hangul_Jeonja);
addStandard("Eisu", _keysym2.default.XK_Eisu_toggle);
addStandard("Hankaku", _keysym2.default.XK_Hankaku);
addStandard("Hiragana", _keysym2.default.XK_Hiragana);
addStandard("HiraganaKatakana", _keysym2.default.XK_Hiragana_Katakana);
addStandard("KanaMode", _keysym2.default.XK_Kana_Shift); // could also be _Kana_Lock
addStandard("KanjiMode", _keysym2.default.XK_Kanji);
addStandard("Katakana", _keysym2.default.XK_Katakana);
addStandard("Romaji", _keysym2.default.XK_Romaji);
addStandard("Zenkaku", _keysym2.default.XK_Zenkaku);
addStandard("ZenkakuHanaku", _keysym2.default.XK_Zenkaku_Hankaku);

// 2.9. General-Purpose Function Keys

addStandard("F1", _keysym2.default.XK_F1);
addStandard("F2", _keysym2.default.XK_F2);
addStandard("F3", _keysym2.default.XK_F3);
addStandard("F4", _keysym2.default.XK_F4);
addStandard("F5", _keysym2.default.XK_F5);
addStandard("F6", _keysym2.default.XK_F6);
addStandard("F7", _keysym2.default.XK_F7);
addStandard("F8", _keysym2.default.XK_F8);
addStandard("F9", _keysym2.default.XK_F9);
addStandard("F10", _keysym2.default.XK_F10);
addStandard("F11", _keysym2.default.XK_F11);
addStandard("F12", _keysym2.default.XK_F12);
addStandard("F13", _keysym2.default.XK_F13);
addStandard("F14", _keysym2.default.XK_F14);
addStandard("F15", _keysym2.default.XK_F15);
addStandard("F16", _keysym2.default.XK_F16);
addStandard("F17", _keysym2.default.XK_F17);
addStandard("F18", _keysym2.default.XK_F18);
addStandard("F19", _keysym2.default.XK_F19);
addStandard("F20", _keysym2.default.XK_F20);
addStandard("F21", _keysym2.default.XK_F21);
addStandard("F22", _keysym2.default.XK_F22);
addStandard("F23", _keysym2.default.XK_F23);
addStandard("F24", _keysym2.default.XK_F24);
addStandard("F25", _keysym2.default.XK_F25);
addStandard("F26", _keysym2.default.XK_F26);
addStandard("F27", _keysym2.default.XK_F27);
addStandard("F28", _keysym2.default.XK_F28);
addStandard("F29", _keysym2.default.XK_F29);
addStandard("F30", _keysym2.default.XK_F30);
addStandard("F31", _keysym2.default.XK_F31);
addStandard("F32", _keysym2.default.XK_F32);
addStandard("F33", _keysym2.default.XK_F33);
addStandard("F34", _keysym2.default.XK_F34);
addStandard("F35", _keysym2.default.XK_F35);
// - Soft1...

// 2.10. Multimedia Keys

// - ChannelDown
// - ChannelUp
addStandard("Close", _keysym2.default.XF86XK_Close);
addStandard("MailForward", _keysym2.default.XF86XK_MailForward);
addStandard("MailReply", _keysym2.default.XF86XK_Reply);
addStandard("MailSend", _keysym2.default.XF86XK_Send);
// - MediaClose
addStandard("MediaFastForward", _keysym2.default.XF86XK_AudioForward);
addStandard("MediaPause", _keysym2.default.XF86XK_AudioPause);
addStandard("MediaPlay", _keysym2.default.XF86XK_AudioPlay);
addStandard("MediaRecord", _keysym2.default.XF86XK_AudioRecord);
addStandard("MediaRewind", _keysym2.default.XF86XK_AudioRewind);
addStandard("MediaStop", _keysym2.default.XF86XK_AudioStop);
addStandard("MediaTrackNext", _keysym2.default.XF86XK_AudioNext);
addStandard("MediaTrackPrevious", _keysym2.default.XF86XK_AudioPrev);
addStandard("New", _keysym2.default.XF86XK_New);
addStandard("Open", _keysym2.default.XF86XK_Open);
addStandard("Print", _keysym2.default.XK_Print);
addStandard("Save", _keysym2.default.XF86XK_Save);
addStandard("SpellCheck", _keysym2.default.XF86XK_Spell);

// 2.11. Multimedia Numpad Keys

// - Key11
// - Key12

// 2.12. Audio Keys

// - AudioBalanceLeft
// - AudioBalanceRight
// - AudioBassBoostDown
// - AudioBassBoostToggle
// - AudioBassBoostUp
// - AudioFaderFront
// - AudioFaderRear
// - AudioSurroundModeNext
// - AudioTrebleDown
// - AudioTrebleUp
addStandard("AudioVolumeDown", _keysym2.default.XF86XK_AudioLowerVolume);
addStandard("AudioVolumeUp", _keysym2.default.XF86XK_AudioRaiseVolume);
addStandard("AudioVolumeMute", _keysym2.default.XF86XK_AudioMute);
// - MicrophoneToggle
// - MicrophoneVolumeDown
// - MicrophoneVolumeUp
addStandard("MicrophoneVolumeMute", _keysym2.default.XF86XK_AudioMicMute);

// 2.13. Speech Keys

// - SpeechCorrectionList
// - SpeechInputToggle

// 2.14. Application Keys

addStandard("LaunchApplication1", _keysym2.default.XF86XK_MyComputer);
addStandard("LaunchApplication2", _keysym2.default.XF86XK_Calculator);
addStandard("LaunchCalendar", _keysym2.default.XF86XK_Calendar);
addStandard("LaunchMail", _keysym2.default.XF86XK_Mail);
addStandard("LaunchMediaPlayer", _keysym2.default.XF86XK_AudioMedia);
addStandard("LaunchMusicPlayer", _keysym2.default.XF86XK_Music);
addStandard("LaunchPhone", _keysym2.default.XF86XK_Phone);
addStandard("LaunchScreenSaver", _keysym2.default.XF86XK_ScreenSaver);
addStandard("LaunchSpreadsheet", _keysym2.default.XF86XK_Excel);
addStandard("LaunchWebBrowser", _keysym2.default.XF86XK_WWW);
addStandard("LaunchWebCam", _keysym2.default.XF86XK_WebCam);
addStandard("LaunchWordProcessor", _keysym2.default.XF86XK_Word);

// 2.15. Browser Keys

addStandard("BrowserBack", _keysym2.default.XF86XK_Back);
addStandard("BrowserFavorites", _keysym2.default.XF86XK_Favorites);
addStandard("BrowserForward", _keysym2.default.XF86XK_Forward);
addStandard("BrowserHome", _keysym2.default.XF86XK_HomePage);
addStandard("BrowserRefresh", _keysym2.default.XF86XK_Refresh);
addStandard("BrowserSearch", _keysym2.default.XF86XK_Search);
addStandard("BrowserStop", _keysym2.default.XF86XK_Stop);

// 2.16. Mobile Phone Keys

// - A whole bunch...

// 2.17. TV Keys

// - A whole bunch...

// 2.18. Media Controller Keys

// - A whole bunch...
addStandard("Dimmer", _keysym2.default.XF86XK_BrightnessAdjust);
addStandard("MediaAudioTrack", _keysym2.default.XF86XK_AudioCycleTrack);
addStandard("RandomToggle", _keysym2.default.XF86XK_AudioRandomPlay);
addStandard("SplitScreenToggle", _keysym2.default.XF86XK_SplitScreen);
addStandard("Subtitle", _keysym2.default.XF86XK_Subtitle);
addStandard("VideoModeNext", _keysym2.default.XF86XK_Next_VMode);

// Extra: Numpad

addNumpad("=", _keysym2.default.XK_equal, _keysym2.default.XK_KP_Equal);
addNumpad("+", _keysym2.default.XK_plus, _keysym2.default.XK_KP_Add);
addNumpad("-", _keysym2.default.XK_minus, _keysym2.default.XK_KP_Subtract);
addNumpad("*", _keysym2.default.XK_asterisk, _keysym2.default.XK_KP_Multiply);
addNumpad("/", _keysym2.default.XK_slash, _keysym2.default.XK_KP_Divide);
addNumpad(".", _keysym2.default.XK_period, _keysym2.default.XK_KP_Decimal);
addNumpad(",", _keysym2.default.XK_comma, _keysym2.default.XK_KP_Separator);
addNumpad("0", _keysym2.default.XK_0, _keysym2.default.XK_KP_0);
addNumpad("1", _keysym2.default.XK_1, _keysym2.default.XK_KP_1);
addNumpad("2", _keysym2.default.XK_2, _keysym2.default.XK_KP_2);
addNumpad("3", _keysym2.default.XK_3, _keysym2.default.XK_KP_3);
addNumpad("4", _keysym2.default.XK_4, _keysym2.default.XK_KP_4);
addNumpad("5", _keysym2.default.XK_5, _keysym2.default.XK_KP_5);
addNumpad("6", _keysym2.default.XK_6, _keysym2.default.XK_KP_6);
addNumpad("7", _keysym2.default.XK_7, _keysym2.default.XK_KP_7);
addNumpad("8", _keysym2.default.XK_8, _keysym2.default.XK_KP_8);
addNumpad("9", _keysym2.default.XK_9, _keysym2.default.XK_KP_9);

exports.default = DOMKeyTable;
},{"./keysym.js":19}],17:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});
/*
 * noVNC: HTML5 VNC client
 * Copyright (C) 2018 The noVNC Authors
 * Licensed under MPL 2.0 or any later version (see LICENSE.txt)
 */

/*
 * Fallback mapping between HTML key codes (physical keys) and
 * HTML key values. This only works for keys that don't vary
 * between layouts. We also omit those who manage fine by mapping the
 * Unicode representation.
 *
 * See https://www.w3.org/TR/uievents-code/ for possible codes.
 * See https://www.w3.org/TR/uievents-key/ for possible values.
 */

/* eslint-disable key-spacing */

exports.default = {

    // 3.1.1.1. Writing System Keys

    'Backspace': 'Backspace',

    // 3.1.1.2. Functional Keys

    'AltLeft': 'Alt',
    'AltRight': 'Alt', // This could also be 'AltGraph'
    'CapsLock': 'CapsLock',
    'ContextMenu': 'ContextMenu',
    'ControlLeft': 'Control',
    'ControlRight': 'Control',
    'Enter': 'Enter',
    'MetaLeft': 'Meta',
    'MetaRight': 'Meta',
    'ShiftLeft': 'Shift',
    'ShiftRight': 'Shift',
    'Tab': 'Tab',
    // FIXME: Japanese/Korean keys

    // 3.1.2. Control Pad Section

    'Delete': 'Delete',
    'End': 'End',
    'Help': 'Help',
    'Home': 'Home',
    'Insert': 'Insert',
    'PageDown': 'PageDown',
    'PageUp': 'PageUp',

    // 3.1.3. Arrow Pad Section

    'ArrowDown': 'ArrowDown',
    'ArrowLeft': 'ArrowLeft',
    'ArrowRight': 'ArrowRight',
    'ArrowUp': 'ArrowUp',

    // 3.1.4. Numpad Section

    'NumLock': 'NumLock',
    'NumpadBackspace': 'Backspace',
    'NumpadClear': 'Clear',

    // 3.1.5. Function Section

    'Escape': 'Escape',
    'F1': 'F1',
    'F2': 'F2',
    'F3': 'F3',
    'F4': 'F4',
    'F5': 'F5',
    'F6': 'F6',
    'F7': 'F7',
    'F8': 'F8',
    'F9': 'F9',
    'F10': 'F10',
    'F11': 'F11',
    'F12': 'F12',
    'F13': 'F13',
    'F14': 'F14',
    'F15': 'F15',
    'F16': 'F16',
    'F17': 'F17',
    'F18': 'F18',
    'F19': 'F19',
    'F20': 'F20',
    'F21': 'F21',
    'F22': 'F22',
    'F23': 'F23',
    'F24': 'F24',
    'F25': 'F25',
    'F26': 'F26',
    'F27': 'F27',
    'F28': 'F28',
    'F29': 'F29',
    'F30': 'F30',
    'F31': 'F31',
    'F32': 'F32',
    'F33': 'F33',
    'F34': 'F34',
    'F35': 'F35',
    'PrintScreen': 'PrintScreen',
    'ScrollLock': 'ScrollLock',
    'Pause': 'Pause',

    // 3.1.6. Media Keys

    'BrowserBack': 'BrowserBack',
    'BrowserFavorites': 'BrowserFavorites',
    'BrowserForward': 'BrowserForward',
    'BrowserHome': 'BrowserHome',
    'BrowserRefresh': 'BrowserRefresh',
    'BrowserSearch': 'BrowserSearch',
    'BrowserStop': 'BrowserStop',
    'Eject': 'Eject',
    'LaunchApp1': 'LaunchMyComputer',
    'LaunchApp2': 'LaunchCalendar',
    'LaunchMail': 'LaunchMail',
    'MediaPlayPause': 'MediaPlay',
    'MediaStop': 'MediaStop',
    'MediaTrackNext': 'MediaTrackNext',
    'MediaTrackPrevious': 'MediaTrackPrevious',
    'Power': 'Power',
    'Sleep': 'Sleep',
    'AudioVolumeDown': 'AudioVolumeDown',
    'AudioVolumeMute': 'AudioVolumeMute',
    'AudioVolumeUp': 'AudioVolumeUp',
    'WakeUp': 'WakeUp'
};
},{}],18:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }(); /*
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * noVNC: HTML5 VNC client
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Copyright (C) 2019 The noVNC Authors
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Licensed under MPL 2.0 or any later version (see LICENSE.txt)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      */

var _logging = require('../util/logging.js');

var Log = _interopRequireWildcard(_logging);

var _events = require('../util/events.js');

var _util = require('./util.js');

var KeyboardUtil = _interopRequireWildcard(_util);

var _keysym = require('./keysym.js');

var _keysym2 = _interopRequireDefault(_keysym);

var _browser = require('../util/browser.js');

var browser = _interopRequireWildcard(_browser);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

//
// Keyboard event handler
//

var Keyboard = function () {
    function Keyboard(target) {
        _classCallCheck(this, Keyboard);

        this._target = target || null;

        this._keyDownList = {}; // List of depressed keys
        // (even if they are happy)
        this._pendingKey = null; // Key waiting for keypress
        this._altGrArmed = false; // Windows AltGr detection

        // keep these here so we can refer to them later
        this._eventHandlers = {
            'keyup': this._handleKeyUp.bind(this),
            'keydown': this._handleKeyDown.bind(this),
            'keypress': this._handleKeyPress.bind(this),
            'blur': this._allKeysUp.bind(this),
            'checkalt': this._checkAlt.bind(this)
        };

        // ===== EVENT HANDLERS =====

        this.onkeyevent = function () {}; // Handler for key press/release
    }

    // ===== PRIVATE METHODS =====

    _createClass(Keyboard, [{
        key: '_sendKeyEvent',
        value: function _sendKeyEvent(keysym, code, down) {
            if (down) {
                this._keyDownList[code] = keysym;
            } else {
                // Do we really think this key is down?
                if (!(code in this._keyDownList)) {
                    return;
                }
                delete this._keyDownList[code];
            }

            Log.Debug("onkeyevent " + (down ? "down" : "up") + ", keysym: " + keysym, ", code: " + code);
            this.onkeyevent(keysym, code, down);
        }
    }, {
        key: '_getKeyCode',
        value: function _getKeyCode(e) {
            var code = KeyboardUtil.getKeycode(e);
            if (code !== 'Unidentified') {
                return code;
            }

            // Unstable, but we don't have anything else to go on
            // (don't use it for 'keypress' events thought since
            // WebKit sets it to the same as charCode)
            if (e.keyCode && e.type !== 'keypress') {
                // 229 is used for composition events
                if (e.keyCode !== 229) {
                    return 'Platform' + e.keyCode;
                }
            }

            // A precursor to the final DOM3 standard. Unfortunately it
            // is not layout independent, so it is as bad as using keyCode
            if (e.keyIdentifier) {
                // Non-character key?
                if (e.keyIdentifier.substr(0, 2) !== 'U+') {
                    return e.keyIdentifier;
                }

                var codepoint = parseInt(e.keyIdentifier.substr(2), 16);
                var char = String.fromCharCode(codepoint).toUpperCase();

                return 'Platform' + char.charCodeAt();
            }

            return 'Unidentified';
        }
    }, {
        key: '_handleKeyDown',
        value: function _handleKeyDown(e) {
            var code = this._getKeyCode(e);
            var keysym = KeyboardUtil.getKeysym(e);

            // Windows doesn't have a proper AltGr, but handles it using
            // fake Ctrl+Alt. However the remote end might not be Windows,
            // so we need to merge those in to a single AltGr event. We
            // detect this case by seeing the two key events directly after
            // each other with a very short time between them (<50ms).
            if (this._altGrArmed) {
                this._altGrArmed = false;
                clearTimeout(this._altGrTimeout);

                if (code === "AltRight" && e.timeStamp - this._altGrCtrlTime < 50) {
                    // FIXME: We fail to detect this if either Ctrl key is
                    //        first manually pressed as Windows then no
                    //        longer sends the fake Ctrl down event. It
                    //        does however happily send real Ctrl events
                    //        even when AltGr is already down. Some
                    //        browsers detect this for us though and set the
                    //        key to "AltGraph".
                    keysym = _keysym2.default.XK_ISO_Level3_Shift;
                } else {
                    this._sendKeyEvent(_keysym2.default.XK_Control_L, "ControlLeft", true);
                }
            }

            // We cannot handle keys we cannot track, but we also need
            // to deal with virtual keyboards which omit key info
            if (code === 'Unidentified') {
                if (keysym) {
                    // If it's a virtual keyboard then it should be
                    // sufficient to just send press and release right
                    // after each other
                    this._sendKeyEvent(keysym, code, true);
                    this._sendKeyEvent(keysym, code, false);
                }

                (0, _events.stopEvent)(e);
                return;
            }

            // Alt behaves more like AltGraph on macOS, so shuffle the
            // keys around a bit to make things more sane for the remote
            // server. This method is used by RealVNC and TigerVNC (and
            // possibly others).
            if (browser.isMac() || browser.isIOS()) {
                switch (keysym) {
                    case _keysym2.default.XK_Super_L:
                        keysym = _keysym2.default.XK_Alt_L;
                        break;
                    case _keysym2.default.XK_Super_R:
                        keysym = _keysym2.default.XK_Super_L;
                        break;
                    case _keysym2.default.XK_Alt_L:
                        keysym = _keysym2.default.XK_Mode_switch;
                        break;
                    case _keysym2.default.XK_Alt_R:
                        keysym = _keysym2.default.XK_ISO_Level3_Shift;
                        break;
                }
            }

            // Is this key already pressed? If so, then we must use the
            // same keysym or we'll confuse the server
            if (code in this._keyDownList) {
                keysym = this._keyDownList[code];
            }

            // macOS doesn't send proper key events for modifiers, only
            // state change events. That gets extra confusing for CapsLock
            // which toggles on each press, but not on release. So pretend
            // it was a quick press and release of the button.
            if ((browser.isMac() || browser.isIOS()) && code === 'CapsLock') {
                this._sendKeyEvent(_keysym2.default.XK_Caps_Lock, 'CapsLock', true);
                this._sendKeyEvent(_keysym2.default.XK_Caps_Lock, 'CapsLock', false);
                (0, _events.stopEvent)(e);
                return;
            }

            // If this is a legacy browser then we'll need to wait for
            // a keypress event as well
            // (IE and Edge has a broken KeyboardEvent.key, so we can't
            // just check for the presence of that field)
            if (!keysym && (!e.key || browser.isIE() || browser.isEdge())) {
                this._pendingKey = code;
                // However we might not get a keypress event if the key
                // is non-printable, which needs some special fallback
                // handling
                setTimeout(this._handleKeyPressTimeout.bind(this), 10, e);
                return;
            }

            this._pendingKey = null;
            (0, _events.stopEvent)(e);

            // Possible start of AltGr sequence? (see above)
            if (code === "ControlLeft" && browser.isWindows() && !("ControlLeft" in this._keyDownList)) {
                this._altGrArmed = true;
                this._altGrTimeout = setTimeout(this._handleAltGrTimeout.bind(this), 100);
                this._altGrCtrlTime = e.timeStamp;
                return;
            }

            this._sendKeyEvent(keysym, code, true);
        }

        // Legacy event for browsers without code/key

    }, {
        key: '_handleKeyPress',
        value: function _handleKeyPress(e) {
            (0, _events.stopEvent)(e);

            // Are we expecting a keypress?
            if (this._pendingKey === null) {
                return;
            }

            var code = this._getKeyCode(e);
            var keysym = KeyboardUtil.getKeysym(e);

            // The key we were waiting for?
            if (code !== 'Unidentified' && code != this._pendingKey) {
                return;
            }

            code = this._pendingKey;
            this._pendingKey = null;

            if (!keysym) {
                Log.Info('keypress with no keysym:', e);
                return;
            }

            this._sendKeyEvent(keysym, code, true);
        }
    }, {
        key: '_handleKeyPressTimeout',
        value: function _handleKeyPressTimeout(e) {
            // Did someone manage to sort out the key already?
            if (this._pendingKey === null) {
                return;
            }

            var keysym = void 0;

            var code = this._pendingKey;
            this._pendingKey = null;

            // We have no way of knowing the proper keysym with the
            // information given, but the following are true for most
            // layouts
            if (e.keyCode >= 0x30 && e.keyCode <= 0x39) {
                // Digit
                keysym = e.keyCode;
            } else if (e.keyCode >= 0x41 && e.keyCode <= 0x5a) {
                // Character (A-Z)
                var char = String.fromCharCode(e.keyCode);
                // A feeble attempt at the correct case
                if (e.shiftKey) {
                    char = char.toUpperCase();
                } else {
                    char = char.toLowerCase();
                }
                keysym = char.charCodeAt();
            } else {
                // Unknown, give up
                keysym = 0;
            }

            this._sendKeyEvent(keysym, code, true);
        }
    }, {
        key: '_handleKeyUp',
        value: function _handleKeyUp(e) {
            (0, _events.stopEvent)(e);

            var code = this._getKeyCode(e);

            // We can't get a release in the middle of an AltGr sequence, so
            // abort that detection
            if (this._altGrArmed) {
                this._altGrArmed = false;
                clearTimeout(this._altGrTimeout);
                this._sendKeyEvent(_keysym2.default.XK_Control_L, "ControlLeft", true);
            }

            // See comment in _handleKeyDown()
            if ((browser.isMac() || browser.isIOS()) && code === 'CapsLock') {
                this._sendKeyEvent(_keysym2.default.XK_Caps_Lock, 'CapsLock', true);
                this._sendKeyEvent(_keysym2.default.XK_Caps_Lock, 'CapsLock', false);
                return;
            }

            this._sendKeyEvent(this._keyDownList[code], code, false);

            // Windows has a rather nasty bug where it won't send key
            // release events for a Shift button if the other Shift is still
            // pressed
            if (browser.isWindows() && (code === 'ShiftLeft' || code === 'ShiftRight')) {
                if ('ShiftRight' in this._keyDownList) {
                    this._sendKeyEvent(this._keyDownList['ShiftRight'], 'ShiftRight', false);
                }
                if ('ShiftLeft' in this._keyDownList) {
                    this._sendKeyEvent(this._keyDownList['ShiftLeft'], 'ShiftLeft', false);
                }
            }
        }
    }, {
        key: '_handleAltGrTimeout',
        value: function _handleAltGrTimeout() {
            this._altGrArmed = false;
            clearTimeout(this._altGrTimeout);
            this._sendKeyEvent(_keysym2.default.XK_Control_L, "ControlLeft", true);
        }
    }, {
        key: '_allKeysUp',
        value: function _allKeysUp() {
            Log.Debug(">> Keyboard.allKeysUp");
            for (var code in this._keyDownList) {
                this._sendKeyEvent(this._keyDownList[code], code, false);
            }
            Log.Debug("<< Keyboard.allKeysUp");
        }

        // Alt workaround for Firefox on Windows, see below

    }, {
        key: '_checkAlt',
        value: function _checkAlt(e) {
            if (e.skipCheckAlt) {
                return;
            }
            if (e.altKey) {
                return;
            }

            var target = this._target;
            var downList = this._keyDownList;
            ['AltLeft', 'AltRight'].forEach(function (code) {
                if (!(code in downList)) {
                    return;
                }

                var event = new KeyboardEvent('keyup', { key: downList[code],
                    code: code });
                event.skipCheckAlt = true;
                target.dispatchEvent(event);
            });
        }

        // ===== PUBLIC METHODS =====

    }, {
        key: 'grab',
        value: function grab() {
            //Log.Debug(">> Keyboard.grab");

            this._target.addEventListener('keydown', this._eventHandlers.keydown);
            this._target.addEventListener('keyup', this._eventHandlers.keyup);
            this._target.addEventListener('keypress', this._eventHandlers.keypress);

            // Release (key up) if window loses focus
            window.addEventListener('blur', this._eventHandlers.blur);

            // Firefox on Windows has broken handling of Alt, so we need to
            // poll as best we can for releases (still doesn't prevent the
            // menu from popping up though as we can't call
            // preventDefault())
            if (browser.isWindows() && browser.isFirefox()) {
                var handler = this._eventHandlers.checkalt;
                ['mousedown', 'mouseup', 'mousemove', 'wheel', 'touchstart', 'touchend', 'touchmove', 'keydown', 'keyup'].forEach(function (type) {
                    return document.addEventListener(type, handler, { capture: true,
                        passive: true });
                });
            }

            //Log.Debug("<< Keyboard.grab");
        }
    }, {
        key: 'ungrab',
        value: function ungrab() {
            //Log.Debug(">> Keyboard.ungrab");

            if (browser.isWindows() && browser.isFirefox()) {
                var handler = this._eventHandlers.checkalt;
                ['mousedown', 'mouseup', 'mousemove', 'wheel', 'touchstart', 'touchend', 'touchmove', 'keydown', 'keyup'].forEach(function (type) {
                    return document.removeEventListener(type, handler);
                });
            }

            this._target.removeEventListener('keydown', this._eventHandlers.keydown);
            this._target.removeEventListener('keyup', this._eventHandlers.keyup);
            this._target.removeEventListener('keypress', this._eventHandlers.keypress);
            window.removeEventListener('blur', this._eventHandlers.blur);

            // Release (key up) all keys that are in a down state
            this._allKeysUp();

            //Log.Debug(">> Keyboard.ungrab");
        }
    }]);

    return Keyboard;
}();

exports.default = Keyboard;
},{"../util/browser.js":26,"../util/events.js":28,"../util/logging.js":31,"./keysym.js":19,"./util.js":22}],19:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
/* eslint-disable key-spacing */

exports.default = {
  XK_VoidSymbol: 0xffffff, /* Void symbol */

  XK_BackSpace: 0xff08, /* Back space, back char */
  XK_Tab: 0xff09,
  XK_Linefeed: 0xff0a, /* Linefeed, LF */
  XK_Clear: 0xff0b,
  XK_Return: 0xff0d, /* Return, enter */
  XK_Pause: 0xff13, /* Pause, hold */
  XK_Scroll_Lock: 0xff14,
  XK_Sys_Req: 0xff15,
  XK_Escape: 0xff1b,
  XK_Delete: 0xffff, /* Delete, rubout */

  /* International & multi-key character composition */

  XK_Multi_key: 0xff20, /* Multi-key character compose */
  XK_Codeinput: 0xff37,
  XK_SingleCandidate: 0xff3c,
  XK_MultipleCandidate: 0xff3d,
  XK_PreviousCandidate: 0xff3e,

  /* Japanese keyboard support */

  XK_Kanji: 0xff21, /* Kanji, Kanji convert */
  XK_Muhenkan: 0xff22, /* Cancel Conversion */
  XK_Henkan_Mode: 0xff23, /* Start/Stop Conversion */
  XK_Henkan: 0xff23, /* Alias for Henkan_Mode */
  XK_Romaji: 0xff24, /* to Romaji */
  XK_Hiragana: 0xff25, /* to Hiragana */
  XK_Katakana: 0xff26, /* to Katakana */
  XK_Hiragana_Katakana: 0xff27, /* Hiragana/Katakana toggle */
  XK_Zenkaku: 0xff28, /* to Zenkaku */
  XK_Hankaku: 0xff29, /* to Hankaku */
  XK_Zenkaku_Hankaku: 0xff2a, /* Zenkaku/Hankaku toggle */
  XK_Touroku: 0xff2b, /* Add to Dictionary */
  XK_Massyo: 0xff2c, /* Delete from Dictionary */
  XK_Kana_Lock: 0xff2d, /* Kana Lock */
  XK_Kana_Shift: 0xff2e, /* Kana Shift */
  XK_Eisu_Shift: 0xff2f, /* Alphanumeric Shift */
  XK_Eisu_toggle: 0xff30, /* Alphanumeric toggle */
  XK_Kanji_Bangou: 0xff37, /* Codeinput */
  XK_Zen_Koho: 0xff3d, /* Multiple/All Candidate(s) */
  XK_Mae_Koho: 0xff3e, /* Previous Candidate */

  /* Cursor control & motion */

  XK_Home: 0xff50,
  XK_Left: 0xff51, /* Move left, left arrow */
  XK_Up: 0xff52, /* Move up, up arrow */
  XK_Right: 0xff53, /* Move right, right arrow */
  XK_Down: 0xff54, /* Move down, down arrow */
  XK_Prior: 0xff55, /* Prior, previous */
  XK_Page_Up: 0xff55,
  XK_Next: 0xff56, /* Next */
  XK_Page_Down: 0xff56,
  XK_End: 0xff57, /* EOL */
  XK_Begin: 0xff58, /* BOL */

  /* Misc functions */

  XK_Select: 0xff60, /* Select, mark */
  XK_Print: 0xff61,
  XK_Execute: 0xff62, /* Execute, run, do */
  XK_Insert: 0xff63, /* Insert, insert here */
  XK_Undo: 0xff65,
  XK_Redo: 0xff66, /* Redo, again */
  XK_Menu: 0xff67,
  XK_Find: 0xff68, /* Find, search */
  XK_Cancel: 0xff69, /* Cancel, stop, abort, exit */
  XK_Help: 0xff6a, /* Help */
  XK_Break: 0xff6b,
  XK_Mode_switch: 0xff7e, /* Character set switch */
  XK_script_switch: 0xff7e, /* Alias for mode_switch */
  XK_Num_Lock: 0xff7f,

  /* Keypad functions, keypad numbers cleverly chosen to map to ASCII */

  XK_KP_Space: 0xff80, /* Space */
  XK_KP_Tab: 0xff89,
  XK_KP_Enter: 0xff8d, /* Enter */
  XK_KP_F1: 0xff91, /* PF1, KP_A, ... */
  XK_KP_F2: 0xff92,
  XK_KP_F3: 0xff93,
  XK_KP_F4: 0xff94,
  XK_KP_Home: 0xff95,
  XK_KP_Left: 0xff96,
  XK_KP_Up: 0xff97,
  XK_KP_Right: 0xff98,
  XK_KP_Down: 0xff99,
  XK_KP_Prior: 0xff9a,
  XK_KP_Page_Up: 0xff9a,
  XK_KP_Next: 0xff9b,
  XK_KP_Page_Down: 0xff9b,
  XK_KP_End: 0xff9c,
  XK_KP_Begin: 0xff9d,
  XK_KP_Insert: 0xff9e,
  XK_KP_Delete: 0xff9f,
  XK_KP_Equal: 0xffbd, /* Equals */
  XK_KP_Multiply: 0xffaa,
  XK_KP_Add: 0xffab,
  XK_KP_Separator: 0xffac, /* Separator, often comma */
  XK_KP_Subtract: 0xffad,
  XK_KP_Decimal: 0xffae,
  XK_KP_Divide: 0xffaf,

  XK_KP_0: 0xffb0,
  XK_KP_1: 0xffb1,
  XK_KP_2: 0xffb2,
  XK_KP_3: 0xffb3,
  XK_KP_4: 0xffb4,
  XK_KP_5: 0xffb5,
  XK_KP_6: 0xffb6,
  XK_KP_7: 0xffb7,
  XK_KP_8: 0xffb8,
  XK_KP_9: 0xffb9,

  /*
   * Auxiliary functions; note the duplicate definitions for left and right
   * function keys;  Sun keyboards and a few other manufacturers have such
   * function key groups on the left and/or right sides of the keyboard.
   * We've not found a keyboard with more than 35 function keys total.
   */

  XK_F1: 0xffbe,
  XK_F2: 0xffbf,
  XK_F3: 0xffc0,
  XK_F4: 0xffc1,
  XK_F5: 0xffc2,
  XK_F6: 0xffc3,
  XK_F7: 0xffc4,
  XK_F8: 0xffc5,
  XK_F9: 0xffc6,
  XK_F10: 0xffc7,
  XK_F11: 0xffc8,
  XK_L1: 0xffc8,
  XK_F12: 0xffc9,
  XK_L2: 0xffc9,
  XK_F13: 0xffca,
  XK_L3: 0xffca,
  XK_F14: 0xffcb,
  XK_L4: 0xffcb,
  XK_F15: 0xffcc,
  XK_L5: 0xffcc,
  XK_F16: 0xffcd,
  XK_L6: 0xffcd,
  XK_F17: 0xffce,
  XK_L7: 0xffce,
  XK_F18: 0xffcf,
  XK_L8: 0xffcf,
  XK_F19: 0xffd0,
  XK_L9: 0xffd0,
  XK_F20: 0xffd1,
  XK_L10: 0xffd1,
  XK_F21: 0xffd2,
  XK_R1: 0xffd2,
  XK_F22: 0xffd3,
  XK_R2: 0xffd3,
  XK_F23: 0xffd4,
  XK_R3: 0xffd4,
  XK_F24: 0xffd5,
  XK_R4: 0xffd5,
  XK_F25: 0xffd6,
  XK_R5: 0xffd6,
  XK_F26: 0xffd7,
  XK_R6: 0xffd7,
  XK_F27: 0xffd8,
  XK_R7: 0xffd8,
  XK_F28: 0xffd9,
  XK_R8: 0xffd9,
  XK_F29: 0xffda,
  XK_R9: 0xffda,
  XK_F30: 0xffdb,
  XK_R10: 0xffdb,
  XK_F31: 0xffdc,
  XK_R11: 0xffdc,
  XK_F32: 0xffdd,
  XK_R12: 0xffdd,
  XK_F33: 0xffde,
  XK_R13: 0xffde,
  XK_F34: 0xffdf,
  XK_R14: 0xffdf,
  XK_F35: 0xffe0,
  XK_R15: 0xffe0,

  /* Modifiers */

  XK_Shift_L: 0xffe1, /* Left shift */
  XK_Shift_R: 0xffe2, /* Right shift */
  XK_Control_L: 0xffe3, /* Left control */
  XK_Control_R: 0xffe4, /* Right control */
  XK_Caps_Lock: 0xffe5, /* Caps lock */
  XK_Shift_Lock: 0xffe6, /* Shift lock */

  XK_Meta_L: 0xffe7, /* Left meta */
  XK_Meta_R: 0xffe8, /* Right meta */
  XK_Alt_L: 0xffe9, /* Left alt */
  XK_Alt_R: 0xffea, /* Right alt */
  XK_Super_L: 0xffeb, /* Left super */
  XK_Super_R: 0xffec, /* Right super */
  XK_Hyper_L: 0xffed, /* Left hyper */
  XK_Hyper_R: 0xffee, /* Right hyper */

  /*
   * Keyboard (XKB) Extension function and modifier keys
   * (from Appendix C of "The X Keyboard Extension: Protocol Specification")
   * Byte 3 = 0xfe
   */

  XK_ISO_Level3_Shift: 0xfe03, /* AltGr */
  XK_ISO_Next_Group: 0xfe08,
  XK_ISO_Prev_Group: 0xfe0a,
  XK_ISO_First_Group: 0xfe0c,
  XK_ISO_Last_Group: 0xfe0e,

  /*
   * Latin 1
   * (ISO/IEC 8859-1: Unicode U+0020..U+00FF)
   * Byte 3: 0
   */

  XK_space: 0x0020, /* U+0020 SPACE */
  XK_exclam: 0x0021, /* U+0021 EXCLAMATION MARK */
  XK_quotedbl: 0x0022, /* U+0022 QUOTATION MARK */
  XK_numbersign: 0x0023, /* U+0023 NUMBER SIGN */
  XK_dollar: 0x0024, /* U+0024 DOLLAR SIGN */
  XK_percent: 0x0025, /* U+0025 PERCENT SIGN */
  XK_ampersand: 0x0026, /* U+0026 AMPERSAND */
  XK_apostrophe: 0x0027, /* U+0027 APOSTROPHE */
  XK_quoteright: 0x0027, /* deprecated */
  XK_parenleft: 0x0028, /* U+0028 LEFT PARENTHESIS */
  XK_parenright: 0x0029, /* U+0029 RIGHT PARENTHESIS */
  XK_asterisk: 0x002a, /* U+002A ASTERISK */
  XK_plus: 0x002b, /* U+002B PLUS SIGN */
  XK_comma: 0x002c, /* U+002C COMMA */
  XK_minus: 0x002d, /* U+002D HYPHEN-MINUS */
  XK_period: 0x002e, /* U+002E FULL STOP */
  XK_slash: 0x002f, /* U+002F SOLIDUS */
  XK_0: 0x0030, /* U+0030 DIGIT ZERO */
  XK_1: 0x0031, /* U+0031 DIGIT ONE */
  XK_2: 0x0032, /* U+0032 DIGIT TWO */
  XK_3: 0x0033, /* U+0033 DIGIT THREE */
  XK_4: 0x0034, /* U+0034 DIGIT FOUR */
  XK_5: 0x0035, /* U+0035 DIGIT FIVE */
  XK_6: 0x0036, /* U+0036 DIGIT SIX */
  XK_7: 0x0037, /* U+0037 DIGIT SEVEN */
  XK_8: 0x0038, /* U+0038 DIGIT EIGHT */
  XK_9: 0x0039, /* U+0039 DIGIT NINE */
  XK_colon: 0x003a, /* U+003A COLON */
  XK_semicolon: 0x003b, /* U+003B SEMICOLON */
  XK_less: 0x003c, /* U+003C LESS-THAN SIGN */
  XK_equal: 0x003d, /* U+003D EQUALS SIGN */
  XK_greater: 0x003e, /* U+003E GREATER-THAN SIGN */
  XK_question: 0x003f, /* U+003F QUESTION MARK */
  XK_at: 0x0040, /* U+0040 COMMERCIAL AT */
  XK_A: 0x0041, /* U+0041 LATIN CAPITAL LETTER A */
  XK_B: 0x0042, /* U+0042 LATIN CAPITAL LETTER B */
  XK_C: 0x0043, /* U+0043 LATIN CAPITAL LETTER C */
  XK_D: 0x0044, /* U+0044 LATIN CAPITAL LETTER D */
  XK_E: 0x0045, /* U+0045 LATIN CAPITAL LETTER E */
  XK_F: 0x0046, /* U+0046 LATIN CAPITAL LETTER F */
  XK_G: 0x0047, /* U+0047 LATIN CAPITAL LETTER G */
  XK_H: 0x0048, /* U+0048 LATIN CAPITAL LETTER H */
  XK_I: 0x0049, /* U+0049 LATIN CAPITAL LETTER I */
  XK_J: 0x004a, /* U+004A LATIN CAPITAL LETTER J */
  XK_K: 0x004b, /* U+004B LATIN CAPITAL LETTER K */
  XK_L: 0x004c, /* U+004C LATIN CAPITAL LETTER L */
  XK_M: 0x004d, /* U+004D LATIN CAPITAL LETTER M */
  XK_N: 0x004e, /* U+004E LATIN CAPITAL LETTER N */
  XK_O: 0x004f, /* U+004F LATIN CAPITAL LETTER O */
  XK_P: 0x0050, /* U+0050 LATIN CAPITAL LETTER P */
  XK_Q: 0x0051, /* U+0051 LATIN CAPITAL LETTER Q */
  XK_R: 0x0052, /* U+0052 LATIN CAPITAL LETTER R */
  XK_S: 0x0053, /* U+0053 LATIN CAPITAL LETTER S */
  XK_T: 0x0054, /* U+0054 LATIN CAPITAL LETTER T */
  XK_U: 0x0055, /* U+0055 LATIN CAPITAL LETTER U */
  XK_V: 0x0056, /* U+0056 LATIN CAPITAL LETTER V */
  XK_W: 0x0057, /* U+0057 LATIN CAPITAL LETTER W */
  XK_X: 0x0058, /* U+0058 LATIN CAPITAL LETTER X */
  XK_Y: 0x0059, /* U+0059 LATIN CAPITAL LETTER Y */
  XK_Z: 0x005a, /* U+005A LATIN CAPITAL LETTER Z */
  XK_bracketleft: 0x005b, /* U+005B LEFT SQUARE BRACKET */
  XK_backslash: 0x005c, /* U+005C REVERSE SOLIDUS */
  XK_bracketright: 0x005d, /* U+005D RIGHT SQUARE BRACKET */
  XK_asciicircum: 0x005e, /* U+005E CIRCUMFLEX ACCENT */
  XK_underscore: 0x005f, /* U+005F LOW LINE */
  XK_grave: 0x0060, /* U+0060 GRAVE ACCENT */
  XK_quoteleft: 0x0060, /* deprecated */
  XK_a: 0x0061, /* U+0061 LATIN SMALL LETTER A */
  XK_b: 0x0062, /* U+0062 LATIN SMALL LETTER B */
  XK_c: 0x0063, /* U+0063 LATIN SMALL LETTER C */
  XK_d: 0x0064, /* U+0064 LATIN SMALL LETTER D */
  XK_e: 0x0065, /* U+0065 LATIN SMALL LETTER E */
  XK_f: 0x0066, /* U+0066 LATIN SMALL LETTER F */
  XK_g: 0x0067, /* U+0067 LATIN SMALL LETTER G */
  XK_h: 0x0068, /* U+0068 LATIN SMALL LETTER H */
  XK_i: 0x0069, /* U+0069 LATIN SMALL LETTER I */
  XK_j: 0x006a, /* U+006A LATIN SMALL LETTER J */
  XK_k: 0x006b, /* U+006B LATIN SMALL LETTER K */
  XK_l: 0x006c, /* U+006C LATIN SMALL LETTER L */
  XK_m: 0x006d, /* U+006D LATIN SMALL LETTER M */
  XK_n: 0x006e, /* U+006E LATIN SMALL LETTER N */
  XK_o: 0x006f, /* U+006F LATIN SMALL LETTER O */
  XK_p: 0x0070, /* U+0070 LATIN SMALL LETTER P */
  XK_q: 0x0071, /* U+0071 LATIN SMALL LETTER Q */
  XK_r: 0x0072, /* U+0072 LATIN SMALL LETTER R */
  XK_s: 0x0073, /* U+0073 LATIN SMALL LETTER S */
  XK_t: 0x0074, /* U+0074 LATIN SMALL LETTER T */
  XK_u: 0x0075, /* U+0075 LATIN SMALL LETTER U */
  XK_v: 0x0076, /* U+0076 LATIN SMALL LETTER V */
  XK_w: 0x0077, /* U+0077 LATIN SMALL LETTER W */
  XK_x: 0x0078, /* U+0078 LATIN SMALL LETTER X */
  XK_y: 0x0079, /* U+0079 LATIN SMALL LETTER Y */
  XK_z: 0x007a, /* U+007A LATIN SMALL LETTER Z */
  XK_braceleft: 0x007b, /* U+007B LEFT CURLY BRACKET */
  XK_bar: 0x007c, /* U+007C VERTICAL LINE */
  XK_braceright: 0x007d, /* U+007D RIGHT CURLY BRACKET */
  XK_asciitilde: 0x007e, /* U+007E TILDE */

  XK_nobreakspace: 0x00a0, /* U+00A0 NO-BREAK SPACE */
  XK_exclamdown: 0x00a1, /* U+00A1 INVERTED EXCLAMATION MARK */
  XK_cent: 0x00a2, /* U+00A2 CENT SIGN */
  XK_sterling: 0x00a3, /* U+00A3 POUND SIGN */
  XK_currency: 0x00a4, /* U+00A4 CURRENCY SIGN */
  XK_yen: 0x00a5, /* U+00A5 YEN SIGN */
  XK_brokenbar: 0x00a6, /* U+00A6 BROKEN BAR */
  XK_section: 0x00a7, /* U+00A7 SECTION SIGN */
  XK_diaeresis: 0x00a8, /* U+00A8 DIAERESIS */
  XK_copyright: 0x00a9, /* U+00A9 COPYRIGHT SIGN */
  XK_ordfeminine: 0x00aa, /* U+00AA FEMININE ORDINAL INDICATOR */
  XK_guillemotleft: 0x00ab, /* U+00AB LEFT-POINTING DOUBLE ANGLE QUOTATION MARK */
  XK_notsign: 0x00ac, /* U+00AC NOT SIGN */
  XK_hyphen: 0x00ad, /* U+00AD SOFT HYPHEN */
  XK_registered: 0x00ae, /* U+00AE REGISTERED SIGN */
  XK_macron: 0x00af, /* U+00AF MACRON */
  XK_degree: 0x00b0, /* U+00B0 DEGREE SIGN */
  XK_plusminus: 0x00b1, /* U+00B1 PLUS-MINUS SIGN */
  XK_twosuperior: 0x00b2, /* U+00B2 SUPERSCRIPT TWO */
  XK_threesuperior: 0x00b3, /* U+00B3 SUPERSCRIPT THREE */
  XK_acute: 0x00b4, /* U+00B4 ACUTE ACCENT */
  XK_mu: 0x00b5, /* U+00B5 MICRO SIGN */
  XK_paragraph: 0x00b6, /* U+00B6 PILCROW SIGN */
  XK_periodcentered: 0x00b7, /* U+00B7 MIDDLE DOT */
  XK_cedilla: 0x00b8, /* U+00B8 CEDILLA */
  XK_onesuperior: 0x00b9, /* U+00B9 SUPERSCRIPT ONE */
  XK_masculine: 0x00ba, /* U+00BA MASCULINE ORDINAL INDICATOR */
  XK_guillemotright: 0x00bb, /* U+00BB RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK */
  XK_onequarter: 0x00bc, /* U+00BC VULGAR FRACTION ONE QUARTER */
  XK_onehalf: 0x00bd, /* U+00BD VULGAR FRACTION ONE HALF */
  XK_threequarters: 0x00be, /* U+00BE VULGAR FRACTION THREE QUARTERS */
  XK_questiondown: 0x00bf, /* U+00BF INVERTED QUESTION MARK */
  XK_Agrave: 0x00c0, /* U+00C0 LATIN CAPITAL LETTER A WITH GRAVE */
  XK_Aacute: 0x00c1, /* U+00C1 LATIN CAPITAL LETTER A WITH ACUTE */
  XK_Acircumflex: 0x00c2, /* U+00C2 LATIN CAPITAL LETTER A WITH CIRCUMFLEX */
  XK_Atilde: 0x00c3, /* U+00C3 LATIN CAPITAL LETTER A WITH TILDE */
  XK_Adiaeresis: 0x00c4, /* U+00C4 LATIN CAPITAL LETTER A WITH DIAERESIS */
  XK_Aring: 0x00c5, /* U+00C5 LATIN CAPITAL LETTER A WITH RING ABOVE */
  XK_AE: 0x00c6, /* U+00C6 LATIN CAPITAL LETTER AE */
  XK_Ccedilla: 0x00c7, /* U+00C7 LATIN CAPITAL LETTER C WITH CEDILLA */
  XK_Egrave: 0x00c8, /* U+00C8 LATIN CAPITAL LETTER E WITH GRAVE */
  XK_Eacute: 0x00c9, /* U+00C9 LATIN CAPITAL LETTER E WITH ACUTE */
  XK_Ecircumflex: 0x00ca, /* U+00CA LATIN CAPITAL LETTER E WITH CIRCUMFLEX */
  XK_Ediaeresis: 0x00cb, /* U+00CB LATIN CAPITAL LETTER E WITH DIAERESIS */
  XK_Igrave: 0x00cc, /* U+00CC LATIN CAPITAL LETTER I WITH GRAVE */
  XK_Iacute: 0x00cd, /* U+00CD LATIN CAPITAL LETTER I WITH ACUTE */
  XK_Icircumflex: 0x00ce, /* U+00CE LATIN CAPITAL LETTER I WITH CIRCUMFLEX */
  XK_Idiaeresis: 0x00cf, /* U+00CF LATIN CAPITAL LETTER I WITH DIAERESIS */
  XK_ETH: 0x00d0, /* U+00D0 LATIN CAPITAL LETTER ETH */
  XK_Eth: 0x00d0, /* deprecated */
  XK_Ntilde: 0x00d1, /* U+00D1 LATIN CAPITAL LETTER N WITH TILDE */
  XK_Ograve: 0x00d2, /* U+00D2 LATIN CAPITAL LETTER O WITH GRAVE */
  XK_Oacute: 0x00d3, /* U+00D3 LATIN CAPITAL LETTER O WITH ACUTE */
  XK_Ocircumflex: 0x00d4, /* U+00D4 LATIN CAPITAL LETTER O WITH CIRCUMFLEX */
  XK_Otilde: 0x00d5, /* U+00D5 LATIN CAPITAL LETTER O WITH TILDE */
  XK_Odiaeresis: 0x00d6, /* U+00D6 LATIN CAPITAL LETTER O WITH DIAERESIS */
  XK_multiply: 0x00d7, /* U+00D7 MULTIPLICATION SIGN */
  XK_Oslash: 0x00d8, /* U+00D8 LATIN CAPITAL LETTER O WITH STROKE */
  XK_Ooblique: 0x00d8, /* U+00D8 LATIN CAPITAL LETTER O WITH STROKE */
  XK_Ugrave: 0x00d9, /* U+00D9 LATIN CAPITAL LETTER U WITH GRAVE */
  XK_Uacute: 0x00da, /* U+00DA LATIN CAPITAL LETTER U WITH ACUTE */
  XK_Ucircumflex: 0x00db, /* U+00DB LATIN CAPITAL LETTER U WITH CIRCUMFLEX */
  XK_Udiaeresis: 0x00dc, /* U+00DC LATIN CAPITAL LETTER U WITH DIAERESIS */
  XK_Yacute: 0x00dd, /* U+00DD LATIN CAPITAL LETTER Y WITH ACUTE */
  XK_THORN: 0x00de, /* U+00DE LATIN CAPITAL LETTER THORN */
  XK_Thorn: 0x00de, /* deprecated */
  XK_ssharp: 0x00df, /* U+00DF LATIN SMALL LETTER SHARP S */
  XK_agrave: 0x00e0, /* U+00E0 LATIN SMALL LETTER A WITH GRAVE */
  XK_aacute: 0x00e1, /* U+00E1 LATIN SMALL LETTER A WITH ACUTE */
  XK_acircumflex: 0x00e2, /* U+00E2 LATIN SMALL LETTER A WITH CIRCUMFLEX */
  XK_atilde: 0x00e3, /* U+00E3 LATIN SMALL LETTER A WITH TILDE */
  XK_adiaeresis: 0x00e4, /* U+00E4 LATIN SMALL LETTER A WITH DIAERESIS */
  XK_aring: 0x00e5, /* U+00E5 LATIN SMALL LETTER A WITH RING ABOVE */
  XK_ae: 0x00e6, /* U+00E6 LATIN SMALL LETTER AE */
  XK_ccedilla: 0x00e7, /* U+00E7 LATIN SMALL LETTER C WITH CEDILLA */
  XK_egrave: 0x00e8, /* U+00E8 LATIN SMALL LETTER E WITH GRAVE */
  XK_eacute: 0x00e9, /* U+00E9 LATIN SMALL LETTER E WITH ACUTE */
  XK_ecircumflex: 0x00ea, /* U+00EA LATIN SMALL LETTER E WITH CIRCUMFLEX */
  XK_ediaeresis: 0x00eb, /* U+00EB LATIN SMALL LETTER E WITH DIAERESIS */
  XK_igrave: 0x00ec, /* U+00EC LATIN SMALL LETTER I WITH GRAVE */
  XK_iacute: 0x00ed, /* U+00ED LATIN SMALL LETTER I WITH ACUTE */
  XK_icircumflex: 0x00ee, /* U+00EE LATIN SMALL LETTER I WITH CIRCUMFLEX */
  XK_idiaeresis: 0x00ef, /* U+00EF LATIN SMALL LETTER I WITH DIAERESIS */
  XK_eth: 0x00f0, /* U+00F0 LATIN SMALL LETTER ETH */
  XK_ntilde: 0x00f1, /* U+00F1 LATIN SMALL LETTER N WITH TILDE */
  XK_ograve: 0x00f2, /* U+00F2 LATIN SMALL LETTER O WITH GRAVE */
  XK_oacute: 0x00f3, /* U+00F3 LATIN SMALL LETTER O WITH ACUTE */
  XK_ocircumflex: 0x00f4, /* U+00F4 LATIN SMALL LETTER O WITH CIRCUMFLEX */
  XK_otilde: 0x00f5, /* U+00F5 LATIN SMALL LETTER O WITH TILDE */
  XK_odiaeresis: 0x00f6, /* U+00F6 LATIN SMALL LETTER O WITH DIAERESIS */
  XK_division: 0x00f7, /* U+00F7 DIVISION SIGN */
  XK_oslash: 0x00f8, /* U+00F8 LATIN SMALL LETTER O WITH STROKE */
  XK_ooblique: 0x00f8, /* U+00F8 LATIN SMALL LETTER O WITH STROKE */
  XK_ugrave: 0x00f9, /* U+00F9 LATIN SMALL LETTER U WITH GRAVE */
  XK_uacute: 0x00fa, /* U+00FA LATIN SMALL LETTER U WITH ACUTE */
  XK_ucircumflex: 0x00fb, /* U+00FB LATIN SMALL LETTER U WITH CIRCUMFLEX */
  XK_udiaeresis: 0x00fc, /* U+00FC LATIN SMALL LETTER U WITH DIAERESIS */
  XK_yacute: 0x00fd, /* U+00FD LATIN SMALL LETTER Y WITH ACUTE */
  XK_thorn: 0x00fe, /* U+00FE LATIN SMALL LETTER THORN */
  XK_ydiaeresis: 0x00ff, /* U+00FF LATIN SMALL LETTER Y WITH DIAERESIS */

  /*
   * Korean
   * Byte 3 = 0x0e
   */

  XK_Hangul: 0xff31, /* Hangul start/stop(toggle) */
  XK_Hangul_Hanja: 0xff34, /* Start Hangul->Hanja Conversion */
  XK_Hangul_Jeonja: 0xff38, /* Jeonja mode */

  /*
   * XFree86 vendor specific keysyms.
   *
   * The XFree86 keysym range is 0x10080001 - 0x1008FFFF.
   */

  XF86XK_ModeLock: 0x1008FF01,
  XF86XK_MonBrightnessUp: 0x1008FF02,
  XF86XK_MonBrightnessDown: 0x1008FF03,
  XF86XK_KbdLightOnOff: 0x1008FF04,
  XF86XK_KbdBrightnessUp: 0x1008FF05,
  XF86XK_KbdBrightnessDown: 0x1008FF06,
  XF86XK_Standby: 0x1008FF10,
  XF86XK_AudioLowerVolume: 0x1008FF11,
  XF86XK_AudioMute: 0x1008FF12,
  XF86XK_AudioRaiseVolume: 0x1008FF13,
  XF86XK_AudioPlay: 0x1008FF14,
  XF86XK_AudioStop: 0x1008FF15,
  XF86XK_AudioPrev: 0x1008FF16,
  XF86XK_AudioNext: 0x1008FF17,
  XF86XK_HomePage: 0x1008FF18,
  XF86XK_Mail: 0x1008FF19,
  XF86XK_Start: 0x1008FF1A,
  XF86XK_Search: 0x1008FF1B,
  XF86XK_AudioRecord: 0x1008FF1C,
  XF86XK_Calculator: 0x1008FF1D,
  XF86XK_Memo: 0x1008FF1E,
  XF86XK_ToDoList: 0x1008FF1F,
  XF86XK_Calendar: 0x1008FF20,
  XF86XK_PowerDown: 0x1008FF21,
  XF86XK_ContrastAdjust: 0x1008FF22,
  XF86XK_RockerUp: 0x1008FF23,
  XF86XK_RockerDown: 0x1008FF24,
  XF86XK_RockerEnter: 0x1008FF25,
  XF86XK_Back: 0x1008FF26,
  XF86XK_Forward: 0x1008FF27,
  XF86XK_Stop: 0x1008FF28,
  XF86XK_Refresh: 0x1008FF29,
  XF86XK_PowerOff: 0x1008FF2A,
  XF86XK_WakeUp: 0x1008FF2B,
  XF86XK_Eject: 0x1008FF2C,
  XF86XK_ScreenSaver: 0x1008FF2D,
  XF86XK_WWW: 0x1008FF2E,
  XF86XK_Sleep: 0x1008FF2F,
  XF86XK_Favorites: 0x1008FF30,
  XF86XK_AudioPause: 0x1008FF31,
  XF86XK_AudioMedia: 0x1008FF32,
  XF86XK_MyComputer: 0x1008FF33,
  XF86XK_VendorHome: 0x1008FF34,
  XF86XK_LightBulb: 0x1008FF35,
  XF86XK_Shop: 0x1008FF36,
  XF86XK_History: 0x1008FF37,
  XF86XK_OpenURL: 0x1008FF38,
  XF86XK_AddFavorite: 0x1008FF39,
  XF86XK_HotLinks: 0x1008FF3A,
  XF86XK_BrightnessAdjust: 0x1008FF3B,
  XF86XK_Finance: 0x1008FF3C,
  XF86XK_Community: 0x1008FF3D,
  XF86XK_AudioRewind: 0x1008FF3E,
  XF86XK_BackForward: 0x1008FF3F,
  XF86XK_Launch0: 0x1008FF40,
  XF86XK_Launch1: 0x1008FF41,
  XF86XK_Launch2: 0x1008FF42,
  XF86XK_Launch3: 0x1008FF43,
  XF86XK_Launch4: 0x1008FF44,
  XF86XK_Launch5: 0x1008FF45,
  XF86XK_Launch6: 0x1008FF46,
  XF86XK_Launch7: 0x1008FF47,
  XF86XK_Launch8: 0x1008FF48,
  XF86XK_Launch9: 0x1008FF49,
  XF86XK_LaunchA: 0x1008FF4A,
  XF86XK_LaunchB: 0x1008FF4B,
  XF86XK_LaunchC: 0x1008FF4C,
  XF86XK_LaunchD: 0x1008FF4D,
  XF86XK_LaunchE: 0x1008FF4E,
  XF86XK_LaunchF: 0x1008FF4F,
  XF86XK_ApplicationLeft: 0x1008FF50,
  XF86XK_ApplicationRight: 0x1008FF51,
  XF86XK_Book: 0x1008FF52,
  XF86XK_CD: 0x1008FF53,
  XF86XK_Calculater: 0x1008FF54,
  XF86XK_Clear: 0x1008FF55,
  XF86XK_Close: 0x1008FF56,
  XF86XK_Copy: 0x1008FF57,
  XF86XK_Cut: 0x1008FF58,
  XF86XK_Display: 0x1008FF59,
  XF86XK_DOS: 0x1008FF5A,
  XF86XK_Documents: 0x1008FF5B,
  XF86XK_Excel: 0x1008FF5C,
  XF86XK_Explorer: 0x1008FF5D,
  XF86XK_Game: 0x1008FF5E,
  XF86XK_Go: 0x1008FF5F,
  XF86XK_iTouch: 0x1008FF60,
  XF86XK_LogOff: 0x1008FF61,
  XF86XK_Market: 0x1008FF62,
  XF86XK_Meeting: 0x1008FF63,
  XF86XK_MenuKB: 0x1008FF65,
  XF86XK_MenuPB: 0x1008FF66,
  XF86XK_MySites: 0x1008FF67,
  XF86XK_New: 0x1008FF68,
  XF86XK_News: 0x1008FF69,
  XF86XK_OfficeHome: 0x1008FF6A,
  XF86XK_Open: 0x1008FF6B,
  XF86XK_Option: 0x1008FF6C,
  XF86XK_Paste: 0x1008FF6D,
  XF86XK_Phone: 0x1008FF6E,
  XF86XK_Q: 0x1008FF70,
  XF86XK_Reply: 0x1008FF72,
  XF86XK_Reload: 0x1008FF73,
  XF86XK_RotateWindows: 0x1008FF74,
  XF86XK_RotationPB: 0x1008FF75,
  XF86XK_RotationKB: 0x1008FF76,
  XF86XK_Save: 0x1008FF77,
  XF86XK_ScrollUp: 0x1008FF78,
  XF86XK_ScrollDown: 0x1008FF79,
  XF86XK_ScrollClick: 0x1008FF7A,
  XF86XK_Send: 0x1008FF7B,
  XF86XK_Spell: 0x1008FF7C,
  XF86XK_SplitScreen: 0x1008FF7D,
  XF86XK_Support: 0x1008FF7E,
  XF86XK_TaskPane: 0x1008FF7F,
  XF86XK_Terminal: 0x1008FF80,
  XF86XK_Tools: 0x1008FF81,
  XF86XK_Travel: 0x1008FF82,
  XF86XK_UserPB: 0x1008FF84,
  XF86XK_User1KB: 0x1008FF85,
  XF86XK_User2KB: 0x1008FF86,
  XF86XK_Video: 0x1008FF87,
  XF86XK_WheelButton: 0x1008FF88,
  XF86XK_Word: 0x1008FF89,
  XF86XK_Xfer: 0x1008FF8A,
  XF86XK_ZoomIn: 0x1008FF8B,
  XF86XK_ZoomOut: 0x1008FF8C,
  XF86XK_Away: 0x1008FF8D,
  XF86XK_Messenger: 0x1008FF8E,
  XF86XK_WebCam: 0x1008FF8F,
  XF86XK_MailForward: 0x1008FF90,
  XF86XK_Pictures: 0x1008FF91,
  XF86XK_Music: 0x1008FF92,
  XF86XK_Battery: 0x1008FF93,
  XF86XK_Bluetooth: 0x1008FF94,
  XF86XK_WLAN: 0x1008FF95,
  XF86XK_UWB: 0x1008FF96,
  XF86XK_AudioForward: 0x1008FF97,
  XF86XK_AudioRepeat: 0x1008FF98,
  XF86XK_AudioRandomPlay: 0x1008FF99,
  XF86XK_Subtitle: 0x1008FF9A,
  XF86XK_AudioCycleTrack: 0x1008FF9B,
  XF86XK_CycleAngle: 0x1008FF9C,
  XF86XK_FrameBack: 0x1008FF9D,
  XF86XK_FrameForward: 0x1008FF9E,
  XF86XK_Time: 0x1008FF9F,
  XF86XK_Select: 0x1008FFA0,
  XF86XK_View: 0x1008FFA1,
  XF86XK_TopMenu: 0x1008FFA2,
  XF86XK_Red: 0x1008FFA3,
  XF86XK_Green: 0x1008FFA4,
  XF86XK_Yellow: 0x1008FFA5,
  XF86XK_Blue: 0x1008FFA6,
  XF86XK_Suspend: 0x1008FFA7,
  XF86XK_Hibernate: 0x1008FFA8,
  XF86XK_TouchpadToggle: 0x1008FFA9,
  XF86XK_TouchpadOn: 0x1008FFB0,
  XF86XK_TouchpadOff: 0x1008FFB1,
  XF86XK_AudioMicMute: 0x1008FFB2,
  XF86XK_Switch_VT_1: 0x1008FE01,
  XF86XK_Switch_VT_2: 0x1008FE02,
  XF86XK_Switch_VT_3: 0x1008FE03,
  XF86XK_Switch_VT_4: 0x1008FE04,
  XF86XK_Switch_VT_5: 0x1008FE05,
  XF86XK_Switch_VT_6: 0x1008FE06,
  XF86XK_Switch_VT_7: 0x1008FE07,
  XF86XK_Switch_VT_8: 0x1008FE08,
  XF86XK_Switch_VT_9: 0x1008FE09,
  XF86XK_Switch_VT_10: 0x1008FE0A,
  XF86XK_Switch_VT_11: 0x1008FE0B,
  XF86XK_Switch_VT_12: 0x1008FE0C,
  XF86XK_Ungrab: 0x1008FE20,
  XF86XK_ClearGrab: 0x1008FE21,
  XF86XK_Next_VMode: 0x1008FE22,
  XF86XK_Prev_VMode: 0x1008FE23,
  XF86XK_LogWindowTree: 0x1008FE24,
  XF86XK_LogGrabInfo: 0x1008FE25
};
},{}],20:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});
/*
 * Mapping from Unicode codepoints to X11/RFB keysyms
 *
 * This file was automatically generated from keysymdef.h
 * DO NOT EDIT!
 */

/* Functions at the bottom */

var codepoints = {
    0x0100: 0x03c0, // XK_Amacron
    0x0101: 0x03e0, // XK_amacron
    0x0102: 0x01c3, // XK_Abreve
    0x0103: 0x01e3, // XK_abreve
    0x0104: 0x01a1, // XK_Aogonek
    0x0105: 0x01b1, // XK_aogonek
    0x0106: 0x01c6, // XK_Cacute
    0x0107: 0x01e6, // XK_cacute
    0x0108: 0x02c6, // XK_Ccircumflex
    0x0109: 0x02e6, // XK_ccircumflex
    0x010a: 0x02c5, // XK_Cabovedot
    0x010b: 0x02e5, // XK_cabovedot
    0x010c: 0x01c8, // XK_Ccaron
    0x010d: 0x01e8, // XK_ccaron
    0x010e: 0x01cf, // XK_Dcaron
    0x010f: 0x01ef, // XK_dcaron
    0x0110: 0x01d0, // XK_Dstroke
    0x0111: 0x01f0, // XK_dstroke
    0x0112: 0x03aa, // XK_Emacron
    0x0113: 0x03ba, // XK_emacron
    0x0116: 0x03cc, // XK_Eabovedot
    0x0117: 0x03ec, // XK_eabovedot
    0x0118: 0x01ca, // XK_Eogonek
    0x0119: 0x01ea, // XK_eogonek
    0x011a: 0x01cc, // XK_Ecaron
    0x011b: 0x01ec, // XK_ecaron
    0x011c: 0x02d8, // XK_Gcircumflex
    0x011d: 0x02f8, // XK_gcircumflex
    0x011e: 0x02ab, // XK_Gbreve
    0x011f: 0x02bb, // XK_gbreve
    0x0120: 0x02d5, // XK_Gabovedot
    0x0121: 0x02f5, // XK_gabovedot
    0x0122: 0x03ab, // XK_Gcedilla
    0x0123: 0x03bb, // XK_gcedilla
    0x0124: 0x02a6, // XK_Hcircumflex
    0x0125: 0x02b6, // XK_hcircumflex
    0x0126: 0x02a1, // XK_Hstroke
    0x0127: 0x02b1, // XK_hstroke
    0x0128: 0x03a5, // XK_Itilde
    0x0129: 0x03b5, // XK_itilde
    0x012a: 0x03cf, // XK_Imacron
    0x012b: 0x03ef, // XK_imacron
    0x012e: 0x03c7, // XK_Iogonek
    0x012f: 0x03e7, // XK_iogonek
    0x0130: 0x02a9, // XK_Iabovedot
    0x0131: 0x02b9, // XK_idotless
    0x0134: 0x02ac, // XK_Jcircumflex
    0x0135: 0x02bc, // XK_jcircumflex
    0x0136: 0x03d3, // XK_Kcedilla
    0x0137: 0x03f3, // XK_kcedilla
    0x0138: 0x03a2, // XK_kra
    0x0139: 0x01c5, // XK_Lacute
    0x013a: 0x01e5, // XK_lacute
    0x013b: 0x03a6, // XK_Lcedilla
    0x013c: 0x03b6, // XK_lcedilla
    0x013d: 0x01a5, // XK_Lcaron
    0x013e: 0x01b5, // XK_lcaron
    0x0141: 0x01a3, // XK_Lstroke
    0x0142: 0x01b3, // XK_lstroke
    0x0143: 0x01d1, // XK_Nacute
    0x0144: 0x01f1, // XK_nacute
    0x0145: 0x03d1, // XK_Ncedilla
    0x0146: 0x03f1, // XK_ncedilla
    0x0147: 0x01d2, // XK_Ncaron
    0x0148: 0x01f2, // XK_ncaron
    0x014a: 0x03bd, // XK_ENG
    0x014b: 0x03bf, // XK_eng
    0x014c: 0x03d2, // XK_Omacron
    0x014d: 0x03f2, // XK_omacron
    0x0150: 0x01d5, // XK_Odoubleacute
    0x0151: 0x01f5, // XK_odoubleacute
    0x0152: 0x13bc, // XK_OE
    0x0153: 0x13bd, // XK_oe
    0x0154: 0x01c0, // XK_Racute
    0x0155: 0x01e0, // XK_racute
    0x0156: 0x03a3, // XK_Rcedilla
    0x0157: 0x03b3, // XK_rcedilla
    0x0158: 0x01d8, // XK_Rcaron
    0x0159: 0x01f8, // XK_rcaron
    0x015a: 0x01a6, // XK_Sacute
    0x015b: 0x01b6, // XK_sacute
    0x015c: 0x02de, // XK_Scircumflex
    0x015d: 0x02fe, // XK_scircumflex
    0x015e: 0x01aa, // XK_Scedilla
    0x015f: 0x01ba, // XK_scedilla
    0x0160: 0x01a9, // XK_Scaron
    0x0161: 0x01b9, // XK_scaron
    0x0162: 0x01de, // XK_Tcedilla
    0x0163: 0x01fe, // XK_tcedilla
    0x0164: 0x01ab, // XK_Tcaron
    0x0165: 0x01bb, // XK_tcaron
    0x0166: 0x03ac, // XK_Tslash
    0x0167: 0x03bc, // XK_tslash
    0x0168: 0x03dd, // XK_Utilde
    0x0169: 0x03fd, // XK_utilde
    0x016a: 0x03de, // XK_Umacron
    0x016b: 0x03fe, // XK_umacron
    0x016c: 0x02dd, // XK_Ubreve
    0x016d: 0x02fd, // XK_ubreve
    0x016e: 0x01d9, // XK_Uring
    0x016f: 0x01f9, // XK_uring
    0x0170: 0x01db, // XK_Udoubleacute
    0x0171: 0x01fb, // XK_udoubleacute
    0x0172: 0x03d9, // XK_Uogonek
    0x0173: 0x03f9, // XK_uogonek
    0x0178: 0x13be, // XK_Ydiaeresis
    0x0179: 0x01ac, // XK_Zacute
    0x017a: 0x01bc, // XK_zacute
    0x017b: 0x01af, // XK_Zabovedot
    0x017c: 0x01bf, // XK_zabovedot
    0x017d: 0x01ae, // XK_Zcaron
    0x017e: 0x01be, // XK_zcaron
    0x0192: 0x08f6, // XK_function
    0x01d2: 0x10001d1, // XK_Ocaron
    0x02c7: 0x01b7, // XK_caron
    0x02d8: 0x01a2, // XK_breve
    0x02d9: 0x01ff, // XK_abovedot
    0x02db: 0x01b2, // XK_ogonek
    0x02dd: 0x01bd, // XK_doubleacute
    0x0385: 0x07ae, // XK_Greek_accentdieresis
    0x0386: 0x07a1, // XK_Greek_ALPHAaccent
    0x0388: 0x07a2, // XK_Greek_EPSILONaccent
    0x0389: 0x07a3, // XK_Greek_ETAaccent
    0x038a: 0x07a4, // XK_Greek_IOTAaccent
    0x038c: 0x07a7, // XK_Greek_OMICRONaccent
    0x038e: 0x07a8, // XK_Greek_UPSILONaccent
    0x038f: 0x07ab, // XK_Greek_OMEGAaccent
    0x0390: 0x07b6, // XK_Greek_iotaaccentdieresis
    0x0391: 0x07c1, // XK_Greek_ALPHA
    0x0392: 0x07c2, // XK_Greek_BETA
    0x0393: 0x07c3, // XK_Greek_GAMMA
    0x0394: 0x07c4, // XK_Greek_DELTA
    0x0395: 0x07c5, // XK_Greek_EPSILON
    0x0396: 0x07c6, // XK_Greek_ZETA
    0x0397: 0x07c7, // XK_Greek_ETA
    0x0398: 0x07c8, // XK_Greek_THETA
    0x0399: 0x07c9, // XK_Greek_IOTA
    0x039a: 0x07ca, // XK_Greek_KAPPA
    0x039b: 0x07cb, // XK_Greek_LAMDA
    0x039c: 0x07cc, // XK_Greek_MU
    0x039d: 0x07cd, // XK_Greek_NU
    0x039e: 0x07ce, // XK_Greek_XI
    0x039f: 0x07cf, // XK_Greek_OMICRON
    0x03a0: 0x07d0, // XK_Greek_PI
    0x03a1: 0x07d1, // XK_Greek_RHO
    0x03a3: 0x07d2, // XK_Greek_SIGMA
    0x03a4: 0x07d4, // XK_Greek_TAU
    0x03a5: 0x07d5, // XK_Greek_UPSILON
    0x03a6: 0x07d6, // XK_Greek_PHI
    0x03a7: 0x07d7, // XK_Greek_CHI
    0x03a8: 0x07d8, // XK_Greek_PSI
    0x03a9: 0x07d9, // XK_Greek_OMEGA
    0x03aa: 0x07a5, // XK_Greek_IOTAdieresis
    0x03ab: 0x07a9, // XK_Greek_UPSILONdieresis
    0x03ac: 0x07b1, // XK_Greek_alphaaccent
    0x03ad: 0x07b2, // XK_Greek_epsilonaccent
    0x03ae: 0x07b3, // XK_Greek_etaaccent
    0x03af: 0x07b4, // XK_Greek_iotaaccent
    0x03b0: 0x07ba, // XK_Greek_upsilonaccentdieresis
    0x03b1: 0x07e1, // XK_Greek_alpha
    0x03b2: 0x07e2, // XK_Greek_beta
    0x03b3: 0x07e3, // XK_Greek_gamma
    0x03b4: 0x07e4, // XK_Greek_delta
    0x03b5: 0x07e5, // XK_Greek_epsilon
    0x03b6: 0x07e6, // XK_Greek_zeta
    0x03b7: 0x07e7, // XK_Greek_eta
    0x03b8: 0x07e8, // XK_Greek_theta
    0x03b9: 0x07e9, // XK_Greek_iota
    0x03ba: 0x07ea, // XK_Greek_kappa
    0x03bb: 0x07eb, // XK_Greek_lamda
    0x03bc: 0x07ec, // XK_Greek_mu
    0x03bd: 0x07ed, // XK_Greek_nu
    0x03be: 0x07ee, // XK_Greek_xi
    0x03bf: 0x07ef, // XK_Greek_omicron
    0x03c0: 0x07f0, // XK_Greek_pi
    0x03c1: 0x07f1, // XK_Greek_rho
    0x03c2: 0x07f3, // XK_Greek_finalsmallsigma
    0x03c3: 0x07f2, // XK_Greek_sigma
    0x03c4: 0x07f4, // XK_Greek_tau
    0x03c5: 0x07f5, // XK_Greek_upsilon
    0x03c6: 0x07f6, // XK_Greek_phi
    0x03c7: 0x07f7, // XK_Greek_chi
    0x03c8: 0x07f8, // XK_Greek_psi
    0x03c9: 0x07f9, // XK_Greek_omega
    0x03ca: 0x07b5, // XK_Greek_iotadieresis
    0x03cb: 0x07b9, // XK_Greek_upsilondieresis
    0x03cc: 0x07b7, // XK_Greek_omicronaccent
    0x03cd: 0x07b8, // XK_Greek_upsilonaccent
    0x03ce: 0x07bb, // XK_Greek_omegaaccent
    0x0401: 0x06b3, // XK_Cyrillic_IO
    0x0402: 0x06b1, // XK_Serbian_DJE
    0x0403: 0x06b2, // XK_Macedonia_GJE
    0x0404: 0x06b4, // XK_Ukrainian_IE
    0x0405: 0x06b5, // XK_Macedonia_DSE
    0x0406: 0x06b6, // XK_Ukrainian_I
    0x0407: 0x06b7, // XK_Ukrainian_YI
    0x0408: 0x06b8, // XK_Cyrillic_JE
    0x0409: 0x06b9, // XK_Cyrillic_LJE
    0x040a: 0x06ba, // XK_Cyrillic_NJE
    0x040b: 0x06bb, // XK_Serbian_TSHE
    0x040c: 0x06bc, // XK_Macedonia_KJE
    0x040e: 0x06be, // XK_Byelorussian_SHORTU
    0x040f: 0x06bf, // XK_Cyrillic_DZHE
    0x0410: 0x06e1, // XK_Cyrillic_A
    0x0411: 0x06e2, // XK_Cyrillic_BE
    0x0412: 0x06f7, // XK_Cyrillic_VE
    0x0413: 0x06e7, // XK_Cyrillic_GHE
    0x0414: 0x06e4, // XK_Cyrillic_DE
    0x0415: 0x06e5, // XK_Cyrillic_IE
    0x0416: 0x06f6, // XK_Cyrillic_ZHE
    0x0417: 0x06fa, // XK_Cyrillic_ZE
    0x0418: 0x06e9, // XK_Cyrillic_I
    0x0419: 0x06ea, // XK_Cyrillic_SHORTI
    0x041a: 0x06eb, // XK_Cyrillic_KA
    0x041b: 0x06ec, // XK_Cyrillic_EL
    0x041c: 0x06ed, // XK_Cyrillic_EM
    0x041d: 0x06ee, // XK_Cyrillic_EN
    0x041e: 0x06ef, // XK_Cyrillic_O
    0x041f: 0x06f0, // XK_Cyrillic_PE
    0x0420: 0x06f2, // XK_Cyrillic_ER
    0x0421: 0x06f3, // XK_Cyrillic_ES
    0x0422: 0x06f4, // XK_Cyrillic_TE
    0x0423: 0x06f5, // XK_Cyrillic_U
    0x0424: 0x06e6, // XK_Cyrillic_EF
    0x0425: 0x06e8, // XK_Cyrillic_HA
    0x0426: 0x06e3, // XK_Cyrillic_TSE
    0x0427: 0x06fe, // XK_Cyrillic_CHE
    0x0428: 0x06fb, // XK_Cyrillic_SHA
    0x0429: 0x06fd, // XK_Cyrillic_SHCHA
    0x042a: 0x06ff, // XK_Cyrillic_HARDSIGN
    0x042b: 0x06f9, // XK_Cyrillic_YERU
    0x042c: 0x06f8, // XK_Cyrillic_SOFTSIGN
    0x042d: 0x06fc, // XK_Cyrillic_E
    0x042e: 0x06e0, // XK_Cyrillic_YU
    0x042f: 0x06f1, // XK_Cyrillic_YA
    0x0430: 0x06c1, // XK_Cyrillic_a
    0x0431: 0x06c2, // XK_Cyrillic_be
    0x0432: 0x06d7, // XK_Cyrillic_ve
    0x0433: 0x06c7, // XK_Cyrillic_ghe
    0x0434: 0x06c4, // XK_Cyrillic_de
    0x0435: 0x06c5, // XK_Cyrillic_ie
    0x0436: 0x06d6, // XK_Cyrillic_zhe
    0x0437: 0x06da, // XK_Cyrillic_ze
    0x0438: 0x06c9, // XK_Cyrillic_i
    0x0439: 0x06ca, // XK_Cyrillic_shorti
    0x043a: 0x06cb, // XK_Cyrillic_ka
    0x043b: 0x06cc, // XK_Cyrillic_el
    0x043c: 0x06cd, // XK_Cyrillic_em
    0x043d: 0x06ce, // XK_Cyrillic_en
    0x043e: 0x06cf, // XK_Cyrillic_o
    0x043f: 0x06d0, // XK_Cyrillic_pe
    0x0440: 0x06d2, // XK_Cyrillic_er
    0x0441: 0x06d3, // XK_Cyrillic_es
    0x0442: 0x06d4, // XK_Cyrillic_te
    0x0443: 0x06d5, // XK_Cyrillic_u
    0x0444: 0x06c6, // XK_Cyrillic_ef
    0x0445: 0x06c8, // XK_Cyrillic_ha
    0x0446: 0x06c3, // XK_Cyrillic_tse
    0x0447: 0x06de, // XK_Cyrillic_che
    0x0448: 0x06db, // XK_Cyrillic_sha
    0x0449: 0x06dd, // XK_Cyrillic_shcha
    0x044a: 0x06df, // XK_Cyrillic_hardsign
    0x044b: 0x06d9, // XK_Cyrillic_yeru
    0x044c: 0x06d8, // XK_Cyrillic_softsign
    0x044d: 0x06dc, // XK_Cyrillic_e
    0x044e: 0x06c0, // XK_Cyrillic_yu
    0x044f: 0x06d1, // XK_Cyrillic_ya
    0x0451: 0x06a3, // XK_Cyrillic_io
    0x0452: 0x06a1, // XK_Serbian_dje
    0x0453: 0x06a2, // XK_Macedonia_gje
    0x0454: 0x06a4, // XK_Ukrainian_ie
    0x0455: 0x06a5, // XK_Macedonia_dse
    0x0456: 0x06a6, // XK_Ukrainian_i
    0x0457: 0x06a7, // XK_Ukrainian_yi
    0x0458: 0x06a8, // XK_Cyrillic_je
    0x0459: 0x06a9, // XK_Cyrillic_lje
    0x045a: 0x06aa, // XK_Cyrillic_nje
    0x045b: 0x06ab, // XK_Serbian_tshe
    0x045c: 0x06ac, // XK_Macedonia_kje
    0x045e: 0x06ae, // XK_Byelorussian_shortu
    0x045f: 0x06af, // XK_Cyrillic_dzhe
    0x0490: 0x06bd, // XK_Ukrainian_GHE_WITH_UPTURN
    0x0491: 0x06ad, // XK_Ukrainian_ghe_with_upturn
    0x05d0: 0x0ce0, // XK_hebrew_aleph
    0x05d1: 0x0ce1, // XK_hebrew_bet
    0x05d2: 0x0ce2, // XK_hebrew_gimel
    0x05d3: 0x0ce3, // XK_hebrew_dalet
    0x05d4: 0x0ce4, // XK_hebrew_he
    0x05d5: 0x0ce5, // XK_hebrew_waw
    0x05d6: 0x0ce6, // XK_hebrew_zain
    0x05d7: 0x0ce7, // XK_hebrew_chet
    0x05d8: 0x0ce8, // XK_hebrew_tet
    0x05d9: 0x0ce9, // XK_hebrew_yod
    0x05da: 0x0cea, // XK_hebrew_finalkaph
    0x05db: 0x0ceb, // XK_hebrew_kaph
    0x05dc: 0x0cec, // XK_hebrew_lamed
    0x05dd: 0x0ced, // XK_hebrew_finalmem
    0x05de: 0x0cee, // XK_hebrew_mem
    0x05df: 0x0cef, // XK_hebrew_finalnun
    0x05e0: 0x0cf0, // XK_hebrew_nun
    0x05e1: 0x0cf1, // XK_hebrew_samech
    0x05e2: 0x0cf2, // XK_hebrew_ayin
    0x05e3: 0x0cf3, // XK_hebrew_finalpe
    0x05e4: 0x0cf4, // XK_hebrew_pe
    0x05e5: 0x0cf5, // XK_hebrew_finalzade
    0x05e6: 0x0cf6, // XK_hebrew_zade
    0x05e7: 0x0cf7, // XK_hebrew_qoph
    0x05e8: 0x0cf8, // XK_hebrew_resh
    0x05e9: 0x0cf9, // XK_hebrew_shin
    0x05ea: 0x0cfa, // XK_hebrew_taw
    0x060c: 0x05ac, // XK_Arabic_comma
    0x061b: 0x05bb, // XK_Arabic_semicolon
    0x061f: 0x05bf, // XK_Arabic_question_mark
    0x0621: 0x05c1, // XK_Arabic_hamza
    0x0622: 0x05c2, // XK_Arabic_maddaonalef
    0x0623: 0x05c3, // XK_Arabic_hamzaonalef
    0x0624: 0x05c4, // XK_Arabic_hamzaonwaw
    0x0625: 0x05c5, // XK_Arabic_hamzaunderalef
    0x0626: 0x05c6, // XK_Arabic_hamzaonyeh
    0x0627: 0x05c7, // XK_Arabic_alef
    0x0628: 0x05c8, // XK_Arabic_beh
    0x0629: 0x05c9, // XK_Arabic_tehmarbuta
    0x062a: 0x05ca, // XK_Arabic_teh
    0x062b: 0x05cb, // XK_Arabic_theh
    0x062c: 0x05cc, // XK_Arabic_jeem
    0x062d: 0x05cd, // XK_Arabic_hah
    0x062e: 0x05ce, // XK_Arabic_khah
    0x062f: 0x05cf, // XK_Arabic_dal
    0x0630: 0x05d0, // XK_Arabic_thal
    0x0631: 0x05d1, // XK_Arabic_ra
    0x0632: 0x05d2, // XK_Arabic_zain
    0x0633: 0x05d3, // XK_Arabic_seen
    0x0634: 0x05d4, // XK_Arabic_sheen
    0x0635: 0x05d5, // XK_Arabic_sad
    0x0636: 0x05d6, // XK_Arabic_dad
    0x0637: 0x05d7, // XK_Arabic_tah
    0x0638: 0x05d8, // XK_Arabic_zah
    0x0639: 0x05d9, // XK_Arabic_ain
    0x063a: 0x05da, // XK_Arabic_ghain
    0x0640: 0x05e0, // XK_Arabic_tatweel
    0x0641: 0x05e1, // XK_Arabic_feh
    0x0642: 0x05e2, // XK_Arabic_qaf
    0x0643: 0x05e3, // XK_Arabic_kaf
    0x0644: 0x05e4, // XK_Arabic_lam
    0x0645: 0x05e5, // XK_Arabic_meem
    0x0646: 0x05e6, // XK_Arabic_noon
    0x0647: 0x05e7, // XK_Arabic_ha
    0x0648: 0x05e8, // XK_Arabic_waw
    0x0649: 0x05e9, // XK_Arabic_alefmaksura
    0x064a: 0x05ea, // XK_Arabic_yeh
    0x064b: 0x05eb, // XK_Arabic_fathatan
    0x064c: 0x05ec, // XK_Arabic_dammatan
    0x064d: 0x05ed, // XK_Arabic_kasratan
    0x064e: 0x05ee, // XK_Arabic_fatha
    0x064f: 0x05ef, // XK_Arabic_damma
    0x0650: 0x05f0, // XK_Arabic_kasra
    0x0651: 0x05f1, // XK_Arabic_shadda
    0x0652: 0x05f2, // XK_Arabic_sukun
    0x0e01: 0x0da1, // XK_Thai_kokai
    0x0e02: 0x0da2, // XK_Thai_khokhai
    0x0e03: 0x0da3, // XK_Thai_khokhuat
    0x0e04: 0x0da4, // XK_Thai_khokhwai
    0x0e05: 0x0da5, // XK_Thai_khokhon
    0x0e06: 0x0da6, // XK_Thai_khorakhang
    0x0e07: 0x0da7, // XK_Thai_ngongu
    0x0e08: 0x0da8, // XK_Thai_chochan
    0x0e09: 0x0da9, // XK_Thai_choching
    0x0e0a: 0x0daa, // XK_Thai_chochang
    0x0e0b: 0x0dab, // XK_Thai_soso
    0x0e0c: 0x0dac, // XK_Thai_chochoe
    0x0e0d: 0x0dad, // XK_Thai_yoying
    0x0e0e: 0x0dae, // XK_Thai_dochada
    0x0e0f: 0x0daf, // XK_Thai_topatak
    0x0e10: 0x0db0, // XK_Thai_thothan
    0x0e11: 0x0db1, // XK_Thai_thonangmontho
    0x0e12: 0x0db2, // XK_Thai_thophuthao
    0x0e13: 0x0db3, // XK_Thai_nonen
    0x0e14: 0x0db4, // XK_Thai_dodek
    0x0e15: 0x0db5, // XK_Thai_totao
    0x0e16: 0x0db6, // XK_Thai_thothung
    0x0e17: 0x0db7, // XK_Thai_thothahan
    0x0e18: 0x0db8, // XK_Thai_thothong
    0x0e19: 0x0db9, // XK_Thai_nonu
    0x0e1a: 0x0dba, // XK_Thai_bobaimai
    0x0e1b: 0x0dbb, // XK_Thai_popla
    0x0e1c: 0x0dbc, // XK_Thai_phophung
    0x0e1d: 0x0dbd, // XK_Thai_fofa
    0x0e1e: 0x0dbe, // XK_Thai_phophan
    0x0e1f: 0x0dbf, // XK_Thai_fofan
    0x0e20: 0x0dc0, // XK_Thai_phosamphao
    0x0e21: 0x0dc1, // XK_Thai_moma
    0x0e22: 0x0dc2, // XK_Thai_yoyak
    0x0e23: 0x0dc3, // XK_Thai_rorua
    0x0e24: 0x0dc4, // XK_Thai_ru
    0x0e25: 0x0dc5, // XK_Thai_loling
    0x0e26: 0x0dc6, // XK_Thai_lu
    0x0e27: 0x0dc7, // XK_Thai_wowaen
    0x0e28: 0x0dc8, // XK_Thai_sosala
    0x0e29: 0x0dc9, // XK_Thai_sorusi
    0x0e2a: 0x0dca, // XK_Thai_sosua
    0x0e2b: 0x0dcb, // XK_Thai_hohip
    0x0e2c: 0x0dcc, // XK_Thai_lochula
    0x0e2d: 0x0dcd, // XK_Thai_oang
    0x0e2e: 0x0dce, // XK_Thai_honokhuk
    0x0e2f: 0x0dcf, // XK_Thai_paiyannoi
    0x0e30: 0x0dd0, // XK_Thai_saraa
    0x0e31: 0x0dd1, // XK_Thai_maihanakat
    0x0e32: 0x0dd2, // XK_Thai_saraaa
    0x0e33: 0x0dd3, // XK_Thai_saraam
    0x0e34: 0x0dd4, // XK_Thai_sarai
    0x0e35: 0x0dd5, // XK_Thai_saraii
    0x0e36: 0x0dd6, // XK_Thai_saraue
    0x0e37: 0x0dd7, // XK_Thai_sarauee
    0x0e38: 0x0dd8, // XK_Thai_sarau
    0x0e39: 0x0dd9, // XK_Thai_sarauu
    0x0e3a: 0x0dda, // XK_Thai_phinthu
    0x0e3f: 0x0ddf, // XK_Thai_baht
    0x0e40: 0x0de0, // XK_Thai_sarae
    0x0e41: 0x0de1, // XK_Thai_saraae
    0x0e42: 0x0de2, // XK_Thai_sarao
    0x0e43: 0x0de3, // XK_Thai_saraaimaimuan
    0x0e44: 0x0de4, // XK_Thai_saraaimaimalai
    0x0e45: 0x0de5, // XK_Thai_lakkhangyao
    0x0e46: 0x0de6, // XK_Thai_maiyamok
    0x0e47: 0x0de7, // XK_Thai_maitaikhu
    0x0e48: 0x0de8, // XK_Thai_maiek
    0x0e49: 0x0de9, // XK_Thai_maitho
    0x0e4a: 0x0dea, // XK_Thai_maitri
    0x0e4b: 0x0deb, // XK_Thai_maichattawa
    0x0e4c: 0x0dec, // XK_Thai_thanthakhat
    0x0e4d: 0x0ded, // XK_Thai_nikhahit
    0x0e50: 0x0df0, // XK_Thai_leksun
    0x0e51: 0x0df1, // XK_Thai_leknung
    0x0e52: 0x0df2, // XK_Thai_leksong
    0x0e53: 0x0df3, // XK_Thai_leksam
    0x0e54: 0x0df4, // XK_Thai_leksi
    0x0e55: 0x0df5, // XK_Thai_lekha
    0x0e56: 0x0df6, // XK_Thai_lekhok
    0x0e57: 0x0df7, // XK_Thai_lekchet
    0x0e58: 0x0df8, // XK_Thai_lekpaet
    0x0e59: 0x0df9, // XK_Thai_lekkao
    0x2002: 0x0aa2, // XK_enspace
    0x2003: 0x0aa1, // XK_emspace
    0x2004: 0x0aa3, // XK_em3space
    0x2005: 0x0aa4, // XK_em4space
    0x2007: 0x0aa5, // XK_digitspace
    0x2008: 0x0aa6, // XK_punctspace
    0x2009: 0x0aa7, // XK_thinspace
    0x200a: 0x0aa8, // XK_hairspace
    0x2012: 0x0abb, // XK_figdash
    0x2013: 0x0aaa, // XK_endash
    0x2014: 0x0aa9, // XK_emdash
    0x2015: 0x07af, // XK_Greek_horizbar
    0x2017: 0x0cdf, // XK_hebrew_doublelowline
    0x2018: 0x0ad0, // XK_leftsinglequotemark
    0x2019: 0x0ad1, // XK_rightsinglequotemark
    0x201a: 0x0afd, // XK_singlelowquotemark
    0x201c: 0x0ad2, // XK_leftdoublequotemark
    0x201d: 0x0ad3, // XK_rightdoublequotemark
    0x201e: 0x0afe, // XK_doublelowquotemark
    0x2020: 0x0af1, // XK_dagger
    0x2021: 0x0af2, // XK_doubledagger
    0x2022: 0x0ae6, // XK_enfilledcircbullet
    0x2025: 0x0aaf, // XK_doubbaselinedot
    0x2026: 0x0aae, // XK_ellipsis
    0x2030: 0x0ad5, // XK_permille
    0x2032: 0x0ad6, // XK_minutes
    0x2033: 0x0ad7, // XK_seconds
    0x2038: 0x0afc, // XK_caret
    0x203e: 0x047e, // XK_overline
    0x20a9: 0x0eff, // XK_Korean_Won
    0x20ac: 0x20ac, // XK_EuroSign
    0x2105: 0x0ab8, // XK_careof
    0x2116: 0x06b0, // XK_numerosign
    0x2117: 0x0afb, // XK_phonographcopyright
    0x211e: 0x0ad4, // XK_prescription
    0x2122: 0x0ac9, // XK_trademark
    0x2153: 0x0ab0, // XK_onethird
    0x2154: 0x0ab1, // XK_twothirds
    0x2155: 0x0ab2, // XK_onefifth
    0x2156: 0x0ab3, // XK_twofifths
    0x2157: 0x0ab4, // XK_threefifths
    0x2158: 0x0ab5, // XK_fourfifths
    0x2159: 0x0ab6, // XK_onesixth
    0x215a: 0x0ab7, // XK_fivesixths
    0x215b: 0x0ac3, // XK_oneeighth
    0x215c: 0x0ac4, // XK_threeeighths
    0x215d: 0x0ac5, // XK_fiveeighths
    0x215e: 0x0ac6, // XK_seveneighths
    0x2190: 0x08fb, // XK_leftarrow
    0x2191: 0x08fc, // XK_uparrow
    0x2192: 0x08fd, // XK_rightarrow
    0x2193: 0x08fe, // XK_downarrow
    0x21d2: 0x08ce, // XK_implies
    0x21d4: 0x08cd, // XK_ifonlyif
    0x2202: 0x08ef, // XK_partialderivative
    0x2207: 0x08c5, // XK_nabla
    0x2218: 0x0bca, // XK_jot
    0x221a: 0x08d6, // XK_radical
    0x221d: 0x08c1, // XK_variation
    0x221e: 0x08c2, // XK_infinity
    0x2227: 0x08de, // XK_logicaland
    0x2228: 0x08df, // XK_logicalor
    0x2229: 0x08dc, // XK_intersection
    0x222a: 0x08dd, // XK_union
    0x222b: 0x08bf, // XK_integral
    0x2234: 0x08c0, // XK_therefore
    0x223c: 0x08c8, // XK_approximate
    0x2243: 0x08c9, // XK_similarequal
    0x2245: 0x1002248, // XK_approxeq
    0x2260: 0x08bd, // XK_notequal
    0x2261: 0x08cf, // XK_identical
    0x2264: 0x08bc, // XK_lessthanequal
    0x2265: 0x08be, // XK_greaterthanequal
    0x2282: 0x08da, // XK_includedin
    0x2283: 0x08db, // XK_includes
    0x22a2: 0x0bfc, // XK_righttack
    0x22a3: 0x0bdc, // XK_lefttack
    0x22a4: 0x0bc2, // XK_downtack
    0x22a5: 0x0bce, // XK_uptack
    0x2308: 0x0bd3, // XK_upstile
    0x230a: 0x0bc4, // XK_downstile
    0x2315: 0x0afa, // XK_telephonerecorder
    0x2320: 0x08a4, // XK_topintegral
    0x2321: 0x08a5, // XK_botintegral
    0x2395: 0x0bcc, // XK_quad
    0x239b: 0x08ab, // XK_topleftparens
    0x239d: 0x08ac, // XK_botleftparens
    0x239e: 0x08ad, // XK_toprightparens
    0x23a0: 0x08ae, // XK_botrightparens
    0x23a1: 0x08a7, // XK_topleftsqbracket
    0x23a3: 0x08a8, // XK_botleftsqbracket
    0x23a4: 0x08a9, // XK_toprightsqbracket
    0x23a6: 0x08aa, // XK_botrightsqbracket
    0x23a8: 0x08af, // XK_leftmiddlecurlybrace
    0x23ac: 0x08b0, // XK_rightmiddlecurlybrace
    0x23b7: 0x08a1, // XK_leftradical
    0x23ba: 0x09ef, // XK_horizlinescan1
    0x23bb: 0x09f0, // XK_horizlinescan3
    0x23bc: 0x09f2, // XK_horizlinescan7
    0x23bd: 0x09f3, // XK_horizlinescan9
    0x2409: 0x09e2, // XK_ht
    0x240a: 0x09e5, // XK_lf
    0x240b: 0x09e9, // XK_vt
    0x240c: 0x09e3, // XK_ff
    0x240d: 0x09e4, // XK_cr
    0x2423: 0x0aac, // XK_signifblank
    0x2424: 0x09e8, // XK_nl
    0x2500: 0x08a3, // XK_horizconnector
    0x2502: 0x08a6, // XK_vertconnector
    0x250c: 0x08a2, // XK_topleftradical
    0x2510: 0x09eb, // XK_uprightcorner
    0x2514: 0x09ed, // XK_lowleftcorner
    0x2518: 0x09ea, // XK_lowrightcorner
    0x251c: 0x09f4, // XK_leftt
    0x2524: 0x09f5, // XK_rightt
    0x252c: 0x09f7, // XK_topt
    0x2534: 0x09f6, // XK_bott
    0x253c: 0x09ee, // XK_crossinglines
    0x2592: 0x09e1, // XK_checkerboard
    0x25aa: 0x0ae7, // XK_enfilledsqbullet
    0x25ab: 0x0ae1, // XK_enopensquarebullet
    0x25ac: 0x0adb, // XK_filledrectbullet
    0x25ad: 0x0ae2, // XK_openrectbullet
    0x25ae: 0x0adf, // XK_emfilledrect
    0x25af: 0x0acf, // XK_emopenrectangle
    0x25b2: 0x0ae8, // XK_filledtribulletup
    0x25b3: 0x0ae3, // XK_opentribulletup
    0x25b6: 0x0add, // XK_filledrighttribullet
    0x25b7: 0x0acd, // XK_rightopentriangle
    0x25bc: 0x0ae9, // XK_filledtribulletdown
    0x25bd: 0x0ae4, // XK_opentribulletdown
    0x25c0: 0x0adc, // XK_filledlefttribullet
    0x25c1: 0x0acc, // XK_leftopentriangle
    0x25c6: 0x09e0, // XK_soliddiamond
    0x25cb: 0x0ace, // XK_emopencircle
    0x25cf: 0x0ade, // XK_emfilledcircle
    0x25e6: 0x0ae0, // XK_enopencircbullet
    0x2606: 0x0ae5, // XK_openstar
    0x260e: 0x0af9, // XK_telephone
    0x2613: 0x0aca, // XK_signaturemark
    0x261c: 0x0aea, // XK_leftpointer
    0x261e: 0x0aeb, // XK_rightpointer
    0x2640: 0x0af8, // XK_femalesymbol
    0x2642: 0x0af7, // XK_malesymbol
    0x2663: 0x0aec, // XK_club
    0x2665: 0x0aee, // XK_heart
    0x2666: 0x0aed, // XK_diamond
    0x266d: 0x0af6, // XK_musicalflat
    0x266f: 0x0af5, // XK_musicalsharp
    0x2713: 0x0af3, // XK_checkmark
    0x2717: 0x0af4, // XK_ballotcross
    0x271d: 0x0ad9, // XK_latincross
    0x2720: 0x0af0, // XK_maltesecross
    0x27e8: 0x0abc, // XK_leftanglebracket
    0x27e9: 0x0abe, // XK_rightanglebracket
    0x3001: 0x04a4, // XK_kana_comma
    0x3002: 0x04a1, // XK_kana_fullstop
    0x300c: 0x04a2, // XK_kana_openingbracket
    0x300d: 0x04a3, // XK_kana_closingbracket
    0x309b: 0x04de, // XK_voicedsound
    0x309c: 0x04df, // XK_semivoicedsound
    0x30a1: 0x04a7, // XK_kana_a
    0x30a2: 0x04b1, // XK_kana_A
    0x30a3: 0x04a8, // XK_kana_i
    0x30a4: 0x04b2, // XK_kana_I
    0x30a5: 0x04a9, // XK_kana_u
    0x30a6: 0x04b3, // XK_kana_U
    0x30a7: 0x04aa, // XK_kana_e
    0x30a8: 0x04b4, // XK_kana_E
    0x30a9: 0x04ab, // XK_kana_o
    0x30aa: 0x04b5, // XK_kana_O
    0x30ab: 0x04b6, // XK_kana_KA
    0x30ad: 0x04b7, // XK_kana_KI
    0x30af: 0x04b8, // XK_kana_KU
    0x30b1: 0x04b9, // XK_kana_KE
    0x30b3: 0x04ba, // XK_kana_KO
    0x30b5: 0x04bb, // XK_kana_SA
    0x30b7: 0x04bc, // XK_kana_SHI
    0x30b9: 0x04bd, // XK_kana_SU
    0x30bb: 0x04be, // XK_kana_SE
    0x30bd: 0x04bf, // XK_kana_SO
    0x30bf: 0x04c0, // XK_kana_TA
    0x30c1: 0x04c1, // XK_kana_CHI
    0x30c3: 0x04af, // XK_kana_tsu
    0x30c4: 0x04c2, // XK_kana_TSU
    0x30c6: 0x04c3, // XK_kana_TE
    0x30c8: 0x04c4, // XK_kana_TO
    0x30ca: 0x04c5, // XK_kana_NA
    0x30cb: 0x04c6, // XK_kana_NI
    0x30cc: 0x04c7, // XK_kana_NU
    0x30cd: 0x04c8, // XK_kana_NE
    0x30ce: 0x04c9, // XK_kana_NO
    0x30cf: 0x04ca, // XK_kana_HA
    0x30d2: 0x04cb, // XK_kana_HI
    0x30d5: 0x04cc, // XK_kana_FU
    0x30d8: 0x04cd, // XK_kana_HE
    0x30db: 0x04ce, // XK_kana_HO
    0x30de: 0x04cf, // XK_kana_MA
    0x30df: 0x04d0, // XK_kana_MI
    0x30e0: 0x04d1, // XK_kana_MU
    0x30e1: 0x04d2, // XK_kana_ME
    0x30e2: 0x04d3, // XK_kana_MO
    0x30e3: 0x04ac, // XK_kana_ya
    0x30e4: 0x04d4, // XK_kana_YA
    0x30e5: 0x04ad, // XK_kana_yu
    0x30e6: 0x04d5, // XK_kana_YU
    0x30e7: 0x04ae, // XK_kana_yo
    0x30e8: 0x04d6, // XK_kana_YO
    0x30e9: 0x04d7, // XK_kana_RA
    0x30ea: 0x04d8, // XK_kana_RI
    0x30eb: 0x04d9, // XK_kana_RU
    0x30ec: 0x04da, // XK_kana_RE
    0x30ed: 0x04db, // XK_kana_RO
    0x30ef: 0x04dc, // XK_kana_WA
    0x30f2: 0x04a6, // XK_kana_WO
    0x30f3: 0x04dd, // XK_kana_N
    0x30fb: 0x04a5, // XK_kana_conjunctive
    0x30fc: 0x04b0 // XK_prolongedsound
};

exports.default = {
    lookup: function lookup(u) {
        // Latin-1 is one-to-one mapping
        if (u >= 0x20 && u <= 0xff) {
            return u;
        }

        // Lookup table (fairly random)
        var keysym = codepoints[u];
        if (keysym !== undefined) {
            return keysym;
        }

        // General mapping as final fallback
        return 0x01000000 | u;
    }
};
},{}],21:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }(); /*
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * noVNC: HTML5 VNC client
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Copyright (C) 2019 The noVNC Authors
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Licensed under MPL 2.0 or any later version (see LICENSE.txt)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      */

var _logging = require('../util/logging.js');

var Log = _interopRequireWildcard(_logging);

var _browser = require('../util/browser.js');

var _events = require('../util/events.js');

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var WHEEL_STEP = 10; // Delta threshold for a mouse wheel step
var WHEEL_STEP_TIMEOUT = 50; // ms
var WHEEL_LINE_HEIGHT = 19;

var Mouse = function () {
    function Mouse(target) {
        _classCallCheck(this, Mouse);

        this._target = target || document;

        this._doubleClickTimer = null;
        this._lastTouchPos = null;

        this._pos = null;
        this._wheelStepXTimer = null;
        this._wheelStepYTimer = null;
        this._accumulatedWheelDeltaX = 0;
        this._accumulatedWheelDeltaY = 0;

        this._eventHandlers = {
            'mousedown': this._handleMouseDown.bind(this),
            'mouseup': this._handleMouseUp.bind(this),
            'mousemove': this._handleMouseMove.bind(this),
            'mousewheel': this._handleMouseWheel.bind(this),
            'mousedisable': this._handleMouseDisable.bind(this)
        };

        // ===== PROPERTIES =====

        this.touchButton = 1; // Button mask (1, 2, 4) for touch devices (0 means ignore clicks)

        // ===== EVENT HANDLERS =====

        this.onmousebutton = function () {}; // Handler for mouse button click/release
        this.onmousemove = function () {}; // Handler for mouse movement
    }

    // ===== PRIVATE METHODS =====

    _createClass(Mouse, [{
        key: '_resetDoubleClickTimer',
        value: function _resetDoubleClickTimer() {
            this._doubleClickTimer = null;
        }
    }, {
        key: '_handleMouseButton',
        value: function _handleMouseButton(e, down) {
            this._updateMousePosition(e);
            var pos = this._pos;

            var bmask = void 0;
            if (e.touches || e.changedTouches) {
                // Touch device

                // When two touches occur within 500 ms of each other and are
                // close enough together a double click is triggered.
                if (down == 1) {
                    if (this._doubleClickTimer === null) {
                        this._lastTouchPos = pos;
                    } else {
                        clearTimeout(this._doubleClickTimer);

                        // When the distance between the two touches is small enough
                        // force the position of the latter touch to the position of
                        // the first.

                        var xs = this._lastTouchPos.x - pos.x;
                        var ys = this._lastTouchPos.y - pos.y;
                        var d = Math.sqrt(xs * xs + ys * ys);

                        // The goal is to trigger on a certain physical width, the
                        // devicePixelRatio brings us a bit closer but is not optimal.
                        var threshold = 20 * (window.devicePixelRatio || 1);
                        if (d < threshold) {
                            pos = this._lastTouchPos;
                        }
                    }
                    this._doubleClickTimer = setTimeout(this._resetDoubleClickTimer.bind(this), 500);
                }
                bmask = this.touchButton;
                // If bmask is set
            } else if (e.which) {
                /* everything except IE */
                bmask = 1 << e.button;
            } else {
                /* IE including 9 */
                bmask = (e.button & 0x1) + // Left
                (e.button & 0x2) * 2 + // Right
                (e.button & 0x4) / 2; // Middle
            }

            Log.Debug("onmousebutton " + (down ? "down" : "up") + ", x: " + pos.x + ", y: " + pos.y + ", bmask: " + bmask);
            this.onmousebutton(pos.x, pos.y, down, bmask);

            (0, _events.stopEvent)(e);
        }
    }, {
        key: '_handleMouseDown',
        value: function _handleMouseDown(e) {
            // Touch events have implicit capture
            if (e.type === "mousedown") {
                (0, _events.setCapture)(this._target);
            }

            this._handleMouseButton(e, 1);
        }
    }, {
        key: '_handleMouseUp',
        value: function _handleMouseUp(e) {
            this._handleMouseButton(e, 0);
        }

        // Mouse wheel events are sent in steps over VNC. This means that the VNC
        // protocol can't handle a wheel event with specific distance or speed.
        // Therefor, if we get a lot of small mouse wheel events we combine them.

    }, {
        key: '_generateWheelStepX',
        value: function _generateWheelStepX() {

            if (this._accumulatedWheelDeltaX < 0) {
                this.onmousebutton(this._pos.x, this._pos.y, 1, 1 << 5);
                this.onmousebutton(this._pos.x, this._pos.y, 0, 1 << 5);
            } else if (this._accumulatedWheelDeltaX > 0) {
                this.onmousebutton(this._pos.x, this._pos.y, 1, 1 << 6);
                this.onmousebutton(this._pos.x, this._pos.y, 0, 1 << 6);
            }

            this._accumulatedWheelDeltaX = 0;
        }
    }, {
        key: '_generateWheelStepY',
        value: function _generateWheelStepY() {

            if (this._accumulatedWheelDeltaY < 0) {
                this.onmousebutton(this._pos.x, this._pos.y, 1, 1 << 3);
                this.onmousebutton(this._pos.x, this._pos.y, 0, 1 << 3);
            } else if (this._accumulatedWheelDeltaY > 0) {
                this.onmousebutton(this._pos.x, this._pos.y, 1, 1 << 4);
                this.onmousebutton(this._pos.x, this._pos.y, 0, 1 << 4);
            }

            this._accumulatedWheelDeltaY = 0;
        }
    }, {
        key: '_resetWheelStepTimers',
        value: function _resetWheelStepTimers() {
            window.clearTimeout(this._wheelStepXTimer);
            window.clearTimeout(this._wheelStepYTimer);
            this._wheelStepXTimer = null;
            this._wheelStepYTimer = null;
        }
    }, {
        key: '_handleMouseWheel',
        value: function _handleMouseWheel(e) {
            this._resetWheelStepTimers();

            this._updateMousePosition(e);

            var dX = e.deltaX;
            var dY = e.deltaY;

            // Pixel units unless it's non-zero.
            // Note that if deltamode is line or page won't matter since we aren't
            // sending the mouse wheel delta to the server anyway.
            // The difference between pixel and line can be important however since
            // we have a threshold that can be smaller than the line height.
            if (e.deltaMode !== 0) {
                dX *= WHEEL_LINE_HEIGHT;
                dY *= WHEEL_LINE_HEIGHT;
            }

            this._accumulatedWheelDeltaX += dX;
            this._accumulatedWheelDeltaY += dY;

            // Generate a mouse wheel step event when the accumulated delta
            // for one of the axes is large enough.
            // Small delta events that do not pass the threshold get sent
            // after a timeout.
            if (Math.abs(this._accumulatedWheelDeltaX) > WHEEL_STEP) {
                this._generateWheelStepX();
            } else {
                this._wheelStepXTimer = window.setTimeout(this._generateWheelStepX.bind(this), WHEEL_STEP_TIMEOUT);
            }
            if (Math.abs(this._accumulatedWheelDeltaY) > WHEEL_STEP) {
                this._generateWheelStepY();
            } else {
                this._wheelStepYTimer = window.setTimeout(this._generateWheelStepY.bind(this), WHEEL_STEP_TIMEOUT);
            }

            (0, _events.stopEvent)(e);
        }
    }, {
        key: '_handleMouseMove',
        value: function _handleMouseMove(e) {
            this._updateMousePosition(e);
            this.onmousemove(this._pos.x, this._pos.y);
            (0, _events.stopEvent)(e);
        }
    }, {
        key: '_handleMouseDisable',
        value: function _handleMouseDisable(e) {
            /*
             * Stop propagation if inside canvas area
             * Note: This is only needed for the 'click' event as it fails
             *       to fire properly for the target element so we have
             *       to listen on the document element instead.
             */
            if (e.target == this._target) {
                (0, _events.stopEvent)(e);
            }
        }

        // Update coordinates relative to target

    }, {
        key: '_updateMousePosition',
        value: function _updateMousePosition(e) {
            e = (0, _events.getPointerEvent)(e);
            var bounds = this._target.getBoundingClientRect();
            var x = void 0;
            var y = void 0;
            // Clip to target bounds
            if (e.clientX < bounds.left) {
                x = 0;
            } else if (e.clientX >= bounds.right) {
                x = bounds.width - 1;
            } else {
                x = e.clientX - bounds.left;
            }
            if (e.clientY < bounds.top) {
                y = 0;
            } else if (e.clientY >= bounds.bottom) {
                y = bounds.height - 1;
            } else {
                y = e.clientY - bounds.top;
            }
            this._pos = { x: x, y: y };
        }

        // ===== PUBLIC METHODS =====

    }, {
        key: 'grab',
        value: function grab() {
            if (_browser.isTouchDevice) {
                this._target.addEventListener('touchstart', this._eventHandlers.mousedown);
                this._target.addEventListener('touchend', this._eventHandlers.mouseup);
                this._target.addEventListener('touchmove', this._eventHandlers.mousemove);
            }
            this._target.addEventListener('mousedown', this._eventHandlers.mousedown);
            this._target.addEventListener('mouseup', this._eventHandlers.mouseup);
            this._target.addEventListener('mousemove', this._eventHandlers.mousemove);
            this._target.addEventListener('wheel', this._eventHandlers.mousewheel);

            /* Prevent middle-click pasting (see above for why we bind to document) */
            document.addEventListener('click', this._eventHandlers.mousedisable);

            /* preventDefault() on mousedown doesn't stop this event for some
               reason so we have to explicitly block it */
            this._target.addEventListener('contextmenu', this._eventHandlers.mousedisable);
        }
    }, {
        key: 'ungrab',
        value: function ungrab() {
            this._resetWheelStepTimers();

            if (_browser.isTouchDevice) {
                this._target.removeEventListener('touchstart', this._eventHandlers.mousedown);
                this._target.removeEventListener('touchend', this._eventHandlers.mouseup);
                this._target.removeEventListener('touchmove', this._eventHandlers.mousemove);
            }
            this._target.removeEventListener('mousedown', this._eventHandlers.mousedown);
            this._target.removeEventListener('mouseup', this._eventHandlers.mouseup);
            this._target.removeEventListener('mousemove', this._eventHandlers.mousemove);
            this._target.removeEventListener('wheel', this._eventHandlers.mousewheel);

            document.removeEventListener('click', this._eventHandlers.mousedisable);

            this._target.removeEventListener('contextmenu', this._eventHandlers.mousedisable);
        }
    }]);

    return Mouse;
}();

exports.default = Mouse;
},{"../util/browser.js":26,"../util/events.js":28,"../util/logging.js":31}],22:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.getKeycode = getKeycode;
exports.getKey = getKey;
exports.getKeysym = getKeysym;

var _keysym = require("./keysym.js");

var _keysym2 = _interopRequireDefault(_keysym);

var _keysymdef = require("./keysymdef.js");

var _keysymdef2 = _interopRequireDefault(_keysymdef);

var _vkeys = require("./vkeys.js");

var _vkeys2 = _interopRequireDefault(_vkeys);

var _fixedkeys = require("./fixedkeys.js");

var _fixedkeys2 = _interopRequireDefault(_fixedkeys);

var _domkeytable = require("./domkeytable.js");

var _domkeytable2 = _interopRequireDefault(_domkeytable);

var _browser = require("../util/browser.js");

var browser = _interopRequireWildcard(_browser);

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

// Get 'KeyboardEvent.code', handling legacy browsers
function getKeycode(evt) {
    // Are we getting proper key identifiers?
    // (unfortunately Firefox and Chrome are crappy here and gives
    // us an empty string on some platforms, rather than leaving it
    // undefined)
    if (evt.code) {
        // Mozilla isn't fully in sync with the spec yet
        switch (evt.code) {
            case 'OSLeft':
                return 'MetaLeft';
            case 'OSRight':
                return 'MetaRight';
        }

        return evt.code;
    }

    // The de-facto standard is to use Windows Virtual-Key codes
    // in the 'keyCode' field for non-printable characters. However
    // Webkit sets it to the same as charCode in 'keypress' events.
    if (evt.type !== 'keypress' && evt.keyCode in _vkeys2.default) {
        var code = _vkeys2.default[evt.keyCode];

        // macOS has messed up this code for some reason
        if (browser.isMac() && code === 'ContextMenu') {
            code = 'MetaRight';
        }

        // The keyCode doesn't distinguish between left and right
        // for the standard modifiers
        if (evt.location === 2) {
            switch (code) {
                case 'ShiftLeft':
                    return 'ShiftRight';
                case 'ControlLeft':
                    return 'ControlRight';
                case 'AltLeft':
                    return 'AltRight';
            }
        }

        // Nor a bunch of the numpad keys
        if (evt.location === 3) {
            switch (code) {
                case 'Delete':
                    return 'NumpadDecimal';
                case 'Insert':
                    return 'Numpad0';
                case 'End':
                    return 'Numpad1';
                case 'ArrowDown':
                    return 'Numpad2';
                case 'PageDown':
                    return 'Numpad3';
                case 'ArrowLeft':
                    return 'Numpad4';
                case 'ArrowRight':
                    return 'Numpad6';
                case 'Home':
                    return 'Numpad7';
                case 'ArrowUp':
                    return 'Numpad8';
                case 'PageUp':
                    return 'Numpad9';
                case 'Enter':
                    return 'NumpadEnter';
            }
        }

        return code;
    }

    return 'Unidentified';
}

// Get 'KeyboardEvent.key', handling legacy browsers
function getKey(evt) {
    // Are we getting a proper key value?
    if (evt.key !== undefined) {
        // IE and Edge use some ancient version of the spec
        // https://developer.microsoft.com/en-us/microsoft-edge/platform/issues/8860571/
        switch (evt.key) {
            case 'Spacebar':
                return ' ';
            case 'Esc':
                return 'Escape';
            case 'Scroll':
                return 'ScrollLock';
            case 'Win':
                return 'Meta';
            case 'Apps':
                return 'ContextMenu';
            case 'Up':
                return 'ArrowUp';
            case 'Left':
                return 'ArrowLeft';
            case 'Right':
                return 'ArrowRight';
            case 'Down':
                return 'ArrowDown';
            case 'Del':
                return 'Delete';
            case 'Divide':
                return '/';
            case 'Multiply':
                return '*';
            case 'Subtract':
                return '-';
            case 'Add':
                return '+';
            case 'Decimal':
                return evt.char;
        }

        // Mozilla isn't fully in sync with the spec yet
        switch (evt.key) {
            case 'OS':
                return 'Meta';
            case 'LaunchMyComputer':
                return 'LaunchApplication1';
            case 'LaunchCalculator':
                return 'LaunchApplication2';
        }

        // iOS leaks some OS names
        switch (evt.key) {
            case 'UIKeyInputUpArrow':
                return 'ArrowUp';
            case 'UIKeyInputDownArrow':
                return 'ArrowDown';
            case 'UIKeyInputLeftArrow':
                return 'ArrowLeft';
            case 'UIKeyInputRightArrow':
                return 'ArrowRight';
            case 'UIKeyInputEscape':
                return 'Escape';
        }

        // Broken behaviour in Chrome
        if (evt.key === '\x00' && evt.code === 'NumpadDecimal') {
            return 'Delete';
        }

        // IE and Edge need special handling, but for everyone else we
        // can trust the value provided
        if (!browser.isIE() && !browser.isEdge()) {
            return evt.key;
        }

        // IE and Edge have broken handling of AltGraph so we can only
        // trust them for non-printable characters (and unfortunately
        // they also specify 'Unidentified' for some problem keys)
        if (evt.key.length !== 1 && evt.key !== 'Unidentified') {
            return evt.key;
        }
    }

    // Try to deduce it based on the physical key
    var code = getKeycode(evt);
    if (code in _fixedkeys2.default) {
        return _fixedkeys2.default[code];
    }

    // If that failed, then see if we have a printable character
    if (evt.charCode) {
        return String.fromCharCode(evt.charCode);
    }

    // At this point we have nothing left to go on
    return 'Unidentified';
}

// Get the most reliable keysym value we can get from a key event
function getKeysym(evt) {
    var key = getKey(evt);

    if (key === 'Unidentified') {
        return null;
    }

    // First look up special keys
    if (key in _domkeytable2.default) {
        var location = evt.location;

        // Safari screws up location for the right cmd key
        if (key === 'Meta' && location === 0) {
            location = 2;
        }

        // And for Clear
        if (key === 'Clear' && location === 3) {
            var code = getKeycode(evt);
            if (code === 'NumLock') {
                location = 0;
            }
        }

        if (location === undefined || location > 3) {
            location = 0;
        }

        // The original Meta key now gets confused with the Windows key
        // https://bugs.chromium.org/p/chromium/issues/detail?id=1020141
        // https://bugzilla.mozilla.org/show_bug.cgi?id=1232918
        if (key === 'Meta') {
            var _code = getKeycode(evt);
            if (_code === 'AltLeft') {
                return _keysym2.default.XK_Meta_L;
            } else if (_code === 'AltRight') {
                return _keysym2.default.XK_Meta_R;
            }
        }

        // macOS has Clear instead of NumLock, but the remote system is
        // probably not macOS, so lying here is probably best...
        if (key === 'Clear') {
            var _code2 = getKeycode(evt);
            if (_code2 === 'NumLock') {
                return _keysym2.default.XK_Num_Lock;
            }
        }

        return _domkeytable2.default[key][location];
    }

    // Now we need to look at the Unicode symbol instead

    // Special key? (FIXME: Should have been caught earlier)
    if (key.length !== 1) {
        return null;
    }

    var codepoint = key.charCodeAt();
    if (codepoint) {
        return _keysymdef2.default.lookup(codepoint);
    }

    return null;
}
},{"../util/browser.js":26,"./domkeytable.js":16,"./fixedkeys.js":17,"./keysym.js":19,"./keysymdef.js":20,"./vkeys.js":23}],23:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});
/*
 * noVNC: HTML5 VNC client
 * Copyright (C) 2018 The noVNC Authors
 * Licensed under MPL 2.0 or any later version (see LICENSE.txt)
 */

/*
 * Mapping between Microsoft® Windows® Virtual-Key codes and
 * HTML key codes.
 */

exports.default = {
  0x08: 'Backspace',
  0x09: 'Tab',
  0x0a: 'NumpadClear',
  0x0c: 'Numpad5', // IE11 sends evt.keyCode: 12 when numlock is off
  0x0d: 'Enter',
  0x10: 'ShiftLeft',
  0x11: 'ControlLeft',
  0x12: 'AltLeft',
  0x13: 'Pause',
  0x14: 'CapsLock',
  0x15: 'Lang1',
  0x19: 'Lang2',
  0x1b: 'Escape',
  0x1c: 'Convert',
  0x1d: 'NonConvert',
  0x20: 'Space',
  0x21: 'PageUp',
  0x22: 'PageDown',
  0x23: 'End',
  0x24: 'Home',
  0x25: 'ArrowLeft',
  0x26: 'ArrowUp',
  0x27: 'ArrowRight',
  0x28: 'ArrowDown',
  0x29: 'Select',
  0x2c: 'PrintScreen',
  0x2d: 'Insert',
  0x2e: 'Delete',
  0x2f: 'Help',
  0x30: 'Digit0',
  0x31: 'Digit1',
  0x32: 'Digit2',
  0x33: 'Digit3',
  0x34: 'Digit4',
  0x35: 'Digit5',
  0x36: 'Digit6',
  0x37: 'Digit7',
  0x38: 'Digit8',
  0x39: 'Digit9',
  0x5b: 'MetaLeft',
  0x5c: 'MetaRight',
  0x5d: 'ContextMenu',
  0x5f: 'Sleep',
  0x60: 'Numpad0',
  0x61: 'Numpad1',
  0x62: 'Numpad2',
  0x63: 'Numpad3',
  0x64: 'Numpad4',
  0x65: 'Numpad5',
  0x66: 'Numpad6',
  0x67: 'Numpad7',
  0x68: 'Numpad8',
  0x69: 'Numpad9',
  0x6a: 'NumpadMultiply',
  0x6b: 'NumpadAdd',
  0x6c: 'NumpadDecimal',
  0x6d: 'NumpadSubtract',
  0x6e: 'NumpadDecimal', // Duplicate, because buggy on Windows
  0x6f: 'NumpadDivide',
  0x70: 'F1',
  0x71: 'F2',
  0x72: 'F3',
  0x73: 'F4',
  0x74: 'F5',
  0x75: 'F6',
  0x76: 'F7',
  0x77: 'F8',
  0x78: 'F9',
  0x79: 'F10',
  0x7a: 'F11',
  0x7b: 'F12',
  0x7c: 'F13',
  0x7d: 'F14',
  0x7e: 'F15',
  0x7f: 'F16',
  0x80: 'F17',
  0x81: 'F18',
  0x82: 'F19',
  0x83: 'F20',
  0x84: 'F21',
  0x85: 'F22',
  0x86: 'F23',
  0x87: 'F24',
  0x90: 'NumLock',
  0x91: 'ScrollLock',
  0xa6: 'BrowserBack',
  0xa7: 'BrowserForward',
  0xa8: 'BrowserRefresh',
  0xa9: 'BrowserStop',
  0xaa: 'BrowserSearch',
  0xab: 'BrowserFavorites',
  0xac: 'BrowserHome',
  0xad: 'AudioVolumeMute',
  0xae: 'AudioVolumeDown',
  0xaf: 'AudioVolumeUp',
  0xb0: 'MediaTrackNext',
  0xb1: 'MediaTrackPrevious',
  0xb2: 'MediaStop',
  0xb3: 'MediaPlayPause',
  0xb4: 'LaunchMail',
  0xb5: 'MediaSelect',
  0xb6: 'LaunchApp1',
  0xb7: 'LaunchApp2',
  0xe1: 'AltRight' // Only when it is AltGraph
};
},{}],24:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
/*
 * This file is auto-generated from keymaps.csv on 2017-05-31 16:20
 * Database checksum sha256(92fd165507f2a3b8c5b3fa56e425d45788dbcb98cf067a307527d91ce22cab94)
 * To re-generate, run:
 *   keymap-gen --lang=js code-map keymaps.csv html atset1
*/
exports.default = {
  "Again": 0xe005, /* html:Again (Again) -> linux:129 (KEY_AGAIN) -> atset1:57349 */
  "AltLeft": 0x38, /* html:AltLeft (AltLeft) -> linux:56 (KEY_LEFTALT) -> atset1:56 */
  "AltRight": 0xe038, /* html:AltRight (AltRight) -> linux:100 (KEY_RIGHTALT) -> atset1:57400 */
  "ArrowDown": 0xe050, /* html:ArrowDown (ArrowDown) -> linux:108 (KEY_DOWN) -> atset1:57424 */
  "ArrowLeft": 0xe04b, /* html:ArrowLeft (ArrowLeft) -> linux:105 (KEY_LEFT) -> atset1:57419 */
  "ArrowRight": 0xe04d, /* html:ArrowRight (ArrowRight) -> linux:106 (KEY_RIGHT) -> atset1:57421 */
  "ArrowUp": 0xe048, /* html:ArrowUp (ArrowUp) -> linux:103 (KEY_UP) -> atset1:57416 */
  "AudioVolumeDown": 0xe02e, /* html:AudioVolumeDown (AudioVolumeDown) -> linux:114 (KEY_VOLUMEDOWN) -> atset1:57390 */
  "AudioVolumeMute": 0xe020, /* html:AudioVolumeMute (AudioVolumeMute) -> linux:113 (KEY_MUTE) -> atset1:57376 */
  "AudioVolumeUp": 0xe030, /* html:AudioVolumeUp (AudioVolumeUp) -> linux:115 (KEY_VOLUMEUP) -> atset1:57392 */
  "Backquote": 0x29, /* html:Backquote (Backquote) -> linux:41 (KEY_GRAVE) -> atset1:41 */
  "Backslash": 0x2b, /* html:Backslash (Backslash) -> linux:43 (KEY_BACKSLASH) -> atset1:43 */
  "Backspace": 0xe, /* html:Backspace (Backspace) -> linux:14 (KEY_BACKSPACE) -> atset1:14 */
  "BracketLeft": 0x1a, /* html:BracketLeft (BracketLeft) -> linux:26 (KEY_LEFTBRACE) -> atset1:26 */
  "BracketRight": 0x1b, /* html:BracketRight (BracketRight) -> linux:27 (KEY_RIGHTBRACE) -> atset1:27 */
  "BrowserBack": 0xe06a, /* html:BrowserBack (BrowserBack) -> linux:158 (KEY_BACK) -> atset1:57450 */
  "BrowserFavorites": 0xe066, /* html:BrowserFavorites (BrowserFavorites) -> linux:156 (KEY_BOOKMARKS) -> atset1:57446 */
  "BrowserForward": 0xe069, /* html:BrowserForward (BrowserForward) -> linux:159 (KEY_FORWARD) -> atset1:57449 */
  "BrowserHome": 0xe032, /* html:BrowserHome (BrowserHome) -> linux:172 (KEY_HOMEPAGE) -> atset1:57394 */
  "BrowserRefresh": 0xe067, /* html:BrowserRefresh (BrowserRefresh) -> linux:173 (KEY_REFRESH) -> atset1:57447 */
  "BrowserSearch": 0xe065, /* html:BrowserSearch (BrowserSearch) -> linux:217 (KEY_SEARCH) -> atset1:57445 */
  "BrowserStop": 0xe068, /* html:BrowserStop (BrowserStop) -> linux:128 (KEY_STOP) -> atset1:57448 */
  "CapsLock": 0x3a, /* html:CapsLock (CapsLock) -> linux:58 (KEY_CAPSLOCK) -> atset1:58 */
  "Comma": 0x33, /* html:Comma (Comma) -> linux:51 (KEY_COMMA) -> atset1:51 */
  "ContextMenu": 0xe05d, /* html:ContextMenu (ContextMenu) -> linux:127 (KEY_COMPOSE) -> atset1:57437 */
  "ControlLeft": 0x1d, /* html:ControlLeft (ControlLeft) -> linux:29 (KEY_LEFTCTRL) -> atset1:29 */
  "ControlRight": 0xe01d, /* html:ControlRight (ControlRight) -> linux:97 (KEY_RIGHTCTRL) -> atset1:57373 */
  "Convert": 0x79, /* html:Convert (Convert) -> linux:92 (KEY_HENKAN) -> atset1:121 */
  "Copy": 0xe078, /* html:Copy (Copy) -> linux:133 (KEY_COPY) -> atset1:57464 */
  "Cut": 0xe03c, /* html:Cut (Cut) -> linux:137 (KEY_CUT) -> atset1:57404 */
  "Delete": 0xe053, /* html:Delete (Delete) -> linux:111 (KEY_DELETE) -> atset1:57427 */
  "Digit0": 0xb, /* html:Digit0 (Digit0) -> linux:11 (KEY_0) -> atset1:11 */
  "Digit1": 0x2, /* html:Digit1 (Digit1) -> linux:2 (KEY_1) -> atset1:2 */
  "Digit2": 0x3, /* html:Digit2 (Digit2) -> linux:3 (KEY_2) -> atset1:3 */
  "Digit3": 0x4, /* html:Digit3 (Digit3) -> linux:4 (KEY_3) -> atset1:4 */
  "Digit4": 0x5, /* html:Digit4 (Digit4) -> linux:5 (KEY_4) -> atset1:5 */
  "Digit5": 0x6, /* html:Digit5 (Digit5) -> linux:6 (KEY_5) -> atset1:6 */
  "Digit6": 0x7, /* html:Digit6 (Digit6) -> linux:7 (KEY_6) -> atset1:7 */
  "Digit7": 0x8, /* html:Digit7 (Digit7) -> linux:8 (KEY_7) -> atset1:8 */
  "Digit8": 0x9, /* html:Digit8 (Digit8) -> linux:9 (KEY_8) -> atset1:9 */
  "Digit9": 0xa, /* html:Digit9 (Digit9) -> linux:10 (KEY_9) -> atset1:10 */
  "Eject": 0xe07d, /* html:Eject (Eject) -> linux:162 (KEY_EJECTCLOSECD) -> atset1:57469 */
  "End": 0xe04f, /* html:End (End) -> linux:107 (KEY_END) -> atset1:57423 */
  "Enter": 0x1c, /* html:Enter (Enter) -> linux:28 (KEY_ENTER) -> atset1:28 */
  "Equal": 0xd, /* html:Equal (Equal) -> linux:13 (KEY_EQUAL) -> atset1:13 */
  "Escape": 0x1, /* html:Escape (Escape) -> linux:1 (KEY_ESC) -> atset1:1 */
  "F1": 0x3b, /* html:F1 (F1) -> linux:59 (KEY_F1) -> atset1:59 */
  "F10": 0x44, /* html:F10 (F10) -> linux:68 (KEY_F10) -> atset1:68 */
  "F11": 0x57, /* html:F11 (F11) -> linux:87 (KEY_F11) -> atset1:87 */
  "F12": 0x58, /* html:F12 (F12) -> linux:88 (KEY_F12) -> atset1:88 */
  "F13": 0x5d, /* html:F13 (F13) -> linux:183 (KEY_F13) -> atset1:93 */
  "F14": 0x5e, /* html:F14 (F14) -> linux:184 (KEY_F14) -> atset1:94 */
  "F15": 0x5f, /* html:F15 (F15) -> linux:185 (KEY_F15) -> atset1:95 */
  "F16": 0x55, /* html:F16 (F16) -> linux:186 (KEY_F16) -> atset1:85 */
  "F17": 0xe003, /* html:F17 (F17) -> linux:187 (KEY_F17) -> atset1:57347 */
  "F18": 0xe077, /* html:F18 (F18) -> linux:188 (KEY_F18) -> atset1:57463 */
  "F19": 0xe004, /* html:F19 (F19) -> linux:189 (KEY_F19) -> atset1:57348 */
  "F2": 0x3c, /* html:F2 (F2) -> linux:60 (KEY_F2) -> atset1:60 */
  "F20": 0x5a, /* html:F20 (F20) -> linux:190 (KEY_F20) -> atset1:90 */
  "F21": 0x74, /* html:F21 (F21) -> linux:191 (KEY_F21) -> atset1:116 */
  "F22": 0xe079, /* html:F22 (F22) -> linux:192 (KEY_F22) -> atset1:57465 */
  "F23": 0x6d, /* html:F23 (F23) -> linux:193 (KEY_F23) -> atset1:109 */
  "F24": 0x6f, /* html:F24 (F24) -> linux:194 (KEY_F24) -> atset1:111 */
  "F3": 0x3d, /* html:F3 (F3) -> linux:61 (KEY_F3) -> atset1:61 */
  "F4": 0x3e, /* html:F4 (F4) -> linux:62 (KEY_F4) -> atset1:62 */
  "F5": 0x3f, /* html:F5 (F5) -> linux:63 (KEY_F5) -> atset1:63 */
  "F6": 0x40, /* html:F6 (F6) -> linux:64 (KEY_F6) -> atset1:64 */
  "F7": 0x41, /* html:F7 (F7) -> linux:65 (KEY_F7) -> atset1:65 */
  "F8": 0x42, /* html:F8 (F8) -> linux:66 (KEY_F8) -> atset1:66 */
  "F9": 0x43, /* html:F9 (F9) -> linux:67 (KEY_F9) -> atset1:67 */
  "Find": 0xe041, /* html:Find (Find) -> linux:136 (KEY_FIND) -> atset1:57409 */
  "Help": 0xe075, /* html:Help (Help) -> linux:138 (KEY_HELP) -> atset1:57461 */
  "Hiragana": 0x77, /* html:Hiragana (Lang4) -> linux:91 (KEY_HIRAGANA) -> atset1:119 */
  "Home": 0xe047, /* html:Home (Home) -> linux:102 (KEY_HOME) -> atset1:57415 */
  "Insert": 0xe052, /* html:Insert (Insert) -> linux:110 (KEY_INSERT) -> atset1:57426 */
  "IntlBackslash": 0x56, /* html:IntlBackslash (IntlBackslash) -> linux:86 (KEY_102ND) -> atset1:86 */
  "IntlRo": 0x73, /* html:IntlRo (IntlRo) -> linux:89 (KEY_RO) -> atset1:115 */
  "IntlYen": 0x7d, /* html:IntlYen (IntlYen) -> linux:124 (KEY_YEN) -> atset1:125 */
  "KanaMode": 0x70, /* html:KanaMode (KanaMode) -> linux:93 (KEY_KATAKANAHIRAGANA) -> atset1:112 */
  "Katakana": 0x78, /* html:Katakana (Lang3) -> linux:90 (KEY_KATAKANA) -> atset1:120 */
  "KeyA": 0x1e, /* html:KeyA (KeyA) -> linux:30 (KEY_A) -> atset1:30 */
  "KeyB": 0x30, /* html:KeyB (KeyB) -> linux:48 (KEY_B) -> atset1:48 */
  "KeyC": 0x2e, /* html:KeyC (KeyC) -> linux:46 (KEY_C) -> atset1:46 */
  "KeyD": 0x20, /* html:KeyD (KeyD) -> linux:32 (KEY_D) -> atset1:32 */
  "KeyE": 0x12, /* html:KeyE (KeyE) -> linux:18 (KEY_E) -> atset1:18 */
  "KeyF": 0x21, /* html:KeyF (KeyF) -> linux:33 (KEY_F) -> atset1:33 */
  "KeyG": 0x22, /* html:KeyG (KeyG) -> linux:34 (KEY_G) -> atset1:34 */
  "KeyH": 0x23, /* html:KeyH (KeyH) -> linux:35 (KEY_H) -> atset1:35 */
  "KeyI": 0x17, /* html:KeyI (KeyI) -> linux:23 (KEY_I) -> atset1:23 */
  "KeyJ": 0x24, /* html:KeyJ (KeyJ) -> linux:36 (KEY_J) -> atset1:36 */
  "KeyK": 0x25, /* html:KeyK (KeyK) -> linux:37 (KEY_K) -> atset1:37 */
  "KeyL": 0x26, /* html:KeyL (KeyL) -> linux:38 (KEY_L) -> atset1:38 */
  "KeyM": 0x32, /* html:KeyM (KeyM) -> linux:50 (KEY_M) -> atset1:50 */
  "KeyN": 0x31, /* html:KeyN (KeyN) -> linux:49 (KEY_N) -> atset1:49 */
  "KeyO": 0x18, /* html:KeyO (KeyO) -> linux:24 (KEY_O) -> atset1:24 */
  "KeyP": 0x19, /* html:KeyP (KeyP) -> linux:25 (KEY_P) -> atset1:25 */
  "KeyQ": 0x10, /* html:KeyQ (KeyQ) -> linux:16 (KEY_Q) -> atset1:16 */
  "KeyR": 0x13, /* html:KeyR (KeyR) -> linux:19 (KEY_R) -> atset1:19 */
  "KeyS": 0x1f, /* html:KeyS (KeyS) -> linux:31 (KEY_S) -> atset1:31 */
  "KeyT": 0x14, /* html:KeyT (KeyT) -> linux:20 (KEY_T) -> atset1:20 */
  "KeyU": 0x16, /* html:KeyU (KeyU) -> linux:22 (KEY_U) -> atset1:22 */
  "KeyV": 0x2f, /* html:KeyV (KeyV) -> linux:47 (KEY_V) -> atset1:47 */
  "KeyW": 0x11, /* html:KeyW (KeyW) -> linux:17 (KEY_W) -> atset1:17 */
  "KeyX": 0x2d, /* html:KeyX (KeyX) -> linux:45 (KEY_X) -> atset1:45 */
  "KeyY": 0x15, /* html:KeyY (KeyY) -> linux:21 (KEY_Y) -> atset1:21 */
  "KeyZ": 0x2c, /* html:KeyZ (KeyZ) -> linux:44 (KEY_Z) -> atset1:44 */
  "Lang3": 0x78, /* html:Lang3 (Lang3) -> linux:90 (KEY_KATAKANA) -> atset1:120 */
  "Lang4": 0x77, /* html:Lang4 (Lang4) -> linux:91 (KEY_HIRAGANA) -> atset1:119 */
  "Lang5": 0x76, /* html:Lang5 (Lang5) -> linux:85 (KEY_ZENKAKUHANKAKU) -> atset1:118 */
  "LaunchApp1": 0xe06b, /* html:LaunchApp1 (LaunchApp1) -> linux:157 (KEY_COMPUTER) -> atset1:57451 */
  "LaunchApp2": 0xe021, /* html:LaunchApp2 (LaunchApp2) -> linux:140 (KEY_CALC) -> atset1:57377 */
  "LaunchMail": 0xe06c, /* html:LaunchMail (LaunchMail) -> linux:155 (KEY_MAIL) -> atset1:57452 */
  "MediaPlayPause": 0xe022, /* html:MediaPlayPause (MediaPlayPause) -> linux:164 (KEY_PLAYPAUSE) -> atset1:57378 */
  "MediaSelect": 0xe06d, /* html:MediaSelect (MediaSelect) -> linux:226 (KEY_MEDIA) -> atset1:57453 */
  "MediaStop": 0xe024, /* html:MediaStop (MediaStop) -> linux:166 (KEY_STOPCD) -> atset1:57380 */
  "MediaTrackNext": 0xe019, /* html:MediaTrackNext (MediaTrackNext) -> linux:163 (KEY_NEXTSONG) -> atset1:57369 */
  "MediaTrackPrevious": 0xe010, /* html:MediaTrackPrevious (MediaTrackPrevious) -> linux:165 (KEY_PREVIOUSSONG) -> atset1:57360 */
  "MetaLeft": 0xe05b, /* html:MetaLeft (MetaLeft) -> linux:125 (KEY_LEFTMETA) -> atset1:57435 */
  "MetaRight": 0xe05c, /* html:MetaRight (MetaRight) -> linux:126 (KEY_RIGHTMETA) -> atset1:57436 */
  "Minus": 0xc, /* html:Minus (Minus) -> linux:12 (KEY_MINUS) -> atset1:12 */
  "NonConvert": 0x7b, /* html:NonConvert (NonConvert) -> linux:94 (KEY_MUHENKAN) -> atset1:123 */
  "NumLock": 0x45, /* html:NumLock (NumLock) -> linux:69 (KEY_NUMLOCK) -> atset1:69 */
  "Numpad0": 0x52, /* html:Numpad0 (Numpad0) -> linux:82 (KEY_KP0) -> atset1:82 */
  "Numpad1": 0x4f, /* html:Numpad1 (Numpad1) -> linux:79 (KEY_KP1) -> atset1:79 */
  "Numpad2": 0x50, /* html:Numpad2 (Numpad2) -> linux:80 (KEY_KP2) -> atset1:80 */
  "Numpad3": 0x51, /* html:Numpad3 (Numpad3) -> linux:81 (KEY_KP3) -> atset1:81 */
  "Numpad4": 0x4b, /* html:Numpad4 (Numpad4) -> linux:75 (KEY_KP4) -> atset1:75 */
  "Numpad5": 0x4c, /* html:Numpad5 (Numpad5) -> linux:76 (KEY_KP5) -> atset1:76 */
  "Numpad6": 0x4d, /* html:Numpad6 (Numpad6) -> linux:77 (KEY_KP6) -> atset1:77 */
  "Numpad7": 0x47, /* html:Numpad7 (Numpad7) -> linux:71 (KEY_KP7) -> atset1:71 */
  "Numpad8": 0x48, /* html:Numpad8 (Numpad8) -> linux:72 (KEY_KP8) -> atset1:72 */
  "Numpad9": 0x49, /* html:Numpad9 (Numpad9) -> linux:73 (KEY_KP9) -> atset1:73 */
  "NumpadAdd": 0x4e, /* html:NumpadAdd (NumpadAdd) -> linux:78 (KEY_KPPLUS) -> atset1:78 */
  "NumpadComma": 0x7e, /* html:NumpadComma (NumpadComma) -> linux:121 (KEY_KPCOMMA) -> atset1:126 */
  "NumpadDecimal": 0x53, /* html:NumpadDecimal (NumpadDecimal) -> linux:83 (KEY_KPDOT) -> atset1:83 */
  "NumpadDivide": 0xe035, /* html:NumpadDivide (NumpadDivide) -> linux:98 (KEY_KPSLASH) -> atset1:57397 */
  "NumpadEnter": 0xe01c, /* html:NumpadEnter (NumpadEnter) -> linux:96 (KEY_KPENTER) -> atset1:57372 */
  "NumpadEqual": 0x59, /* html:NumpadEqual (NumpadEqual) -> linux:117 (KEY_KPEQUAL) -> atset1:89 */
  "NumpadMultiply": 0x37, /* html:NumpadMultiply (NumpadMultiply) -> linux:55 (KEY_KPASTERISK) -> atset1:55 */
  "NumpadParenLeft": 0xe076, /* html:NumpadParenLeft (NumpadParenLeft) -> linux:179 (KEY_KPLEFTPAREN) -> atset1:57462 */
  "NumpadParenRight": 0xe07b, /* html:NumpadParenRight (NumpadParenRight) -> linux:180 (KEY_KPRIGHTPAREN) -> atset1:57467 */
  "NumpadSubtract": 0x4a, /* html:NumpadSubtract (NumpadSubtract) -> linux:74 (KEY_KPMINUS) -> atset1:74 */
  "Open": 0x64, /* html:Open (Open) -> linux:134 (KEY_OPEN) -> atset1:100 */
  "PageDown": 0xe051, /* html:PageDown (PageDown) -> linux:109 (KEY_PAGEDOWN) -> atset1:57425 */
  "PageUp": 0xe049, /* html:PageUp (PageUp) -> linux:104 (KEY_PAGEUP) -> atset1:57417 */
  "Paste": 0x65, /* html:Paste (Paste) -> linux:135 (KEY_PASTE) -> atset1:101 */
  "Pause": 0xe046, /* html:Pause (Pause) -> linux:119 (KEY_PAUSE) -> atset1:57414 */
  "Period": 0x34, /* html:Period (Period) -> linux:52 (KEY_DOT) -> atset1:52 */
  "Power": 0xe05e, /* html:Power (Power) -> linux:116 (KEY_POWER) -> atset1:57438 */
  "PrintScreen": 0x54, /* html:PrintScreen (PrintScreen) -> linux:99 (KEY_SYSRQ) -> atset1:84 */
  "Props": 0xe006, /* html:Props (Props) -> linux:130 (KEY_PROPS) -> atset1:57350 */
  "Quote": 0x28, /* html:Quote (Quote) -> linux:40 (KEY_APOSTROPHE) -> atset1:40 */
  "ScrollLock": 0x46, /* html:ScrollLock (ScrollLock) -> linux:70 (KEY_SCROLLLOCK) -> atset1:70 */
  "Semicolon": 0x27, /* html:Semicolon (Semicolon) -> linux:39 (KEY_SEMICOLON) -> atset1:39 */
  "ShiftLeft": 0x2a, /* html:ShiftLeft (ShiftLeft) -> linux:42 (KEY_LEFTSHIFT) -> atset1:42 */
  "ShiftRight": 0x36, /* html:ShiftRight (ShiftRight) -> linux:54 (KEY_RIGHTSHIFT) -> atset1:54 */
  "Slash": 0x35, /* html:Slash (Slash) -> linux:53 (KEY_SLASH) -> atset1:53 */
  "Sleep": 0xe05f, /* html:Sleep (Sleep) -> linux:142 (KEY_SLEEP) -> atset1:57439 */
  "Space": 0x39, /* html:Space (Space) -> linux:57 (KEY_SPACE) -> atset1:57 */
  "Suspend": 0xe025, /* html:Suspend (Suspend) -> linux:205 (KEY_SUSPEND) -> atset1:57381 */
  "Tab": 0xf, /* html:Tab (Tab) -> linux:15 (KEY_TAB) -> atset1:15 */
  "Undo": 0xe007, /* html:Undo (Undo) -> linux:131 (KEY_UNDO) -> atset1:57351 */
  "WakeUp": 0xe063 /* html:WakeUp (WakeUp) -> linux:143 (KEY_WAKEUP) -> atset1:57443 */
};
},{}],25:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _int = require('./util/int.js');

var _logging = require('./util/logging.js');

var Log = _interopRequireWildcard(_logging);

var _strings = require('./util/strings.js');

var _browser = require('./util/browser.js');

var _eventtarget = require('./util/eventtarget.js');

var _eventtarget2 = _interopRequireDefault(_eventtarget);

var _display = require('./display.js');

var _display2 = _interopRequireDefault(_display);

var _inflator = require('./inflator.js');

var _inflator2 = _interopRequireDefault(_inflator);

var _deflator = require('./deflator.js');

var _deflator2 = _interopRequireDefault(_deflator);

var _keyboard = require('./input/keyboard.js');

var _keyboard2 = _interopRequireDefault(_keyboard);

var _mouse = require('./input/mouse.js');

var _mouse2 = _interopRequireDefault(_mouse);

var _cursor = require('./util/cursor.js');

var _cursor2 = _interopRequireDefault(_cursor);

var _websock = require('./websock.js');

var _websock2 = _interopRequireDefault(_websock);

var _des = require('./des.js');

var _des2 = _interopRequireDefault(_des);

var _keysym = require('./input/keysym.js');

var _keysym2 = _interopRequireDefault(_keysym);

var _xtscancodes = require('./input/xtscancodes.js');

var _xtscancodes2 = _interopRequireDefault(_xtscancodes);

var _encodings = require('./encodings.js');

require('./util/polyfill.js');

var _raw = require('./decoders/raw.js');

var _raw2 = _interopRequireDefault(_raw);

var _copyrect = require('./decoders/copyrect.js');

var _copyrect2 = _interopRequireDefault(_copyrect);

var _rre = require('./decoders/rre.js');

var _rre2 = _interopRequireDefault(_rre);

var _hextile = require('./decoders/hextile.js');

var _hextile2 = _interopRequireDefault(_hextile);

var _tight = require('./decoders/tight.js');

var _tight2 = _interopRequireDefault(_tight);

var _tightpng = require('./decoders/tightpng.js');

var _tightpng2 = _interopRequireDefault(_tightpng);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; } /*
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                * noVNC: HTML5 VNC client
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                * Copyright (C) 2020 The noVNC Authors
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                * Licensed under MPL 2.0 (see LICENSE.txt)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                *
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                * See README.md for usage and integration instructions.
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                *
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                */

// How many seconds to wait for a disconnect to finish
var DISCONNECT_TIMEOUT = 3;
var DEFAULT_BACKGROUND = 'rgb(40, 40, 40)';

// Extended clipboard pseudo-encoding formats
var extendedClipboardFormatText = 1;
/*eslint-disable no-unused-vars */
var extendedClipboardFormatRtf = 1 << 1;
var extendedClipboardFormatHtml = 1 << 2;
var extendedClipboardFormatDib = 1 << 3;
var extendedClipboardFormatFiles = 1 << 4;
/*eslint-enable */

// Extended clipboard pseudo-encoding actions
var extendedClipboardActionCaps = 1 << 24;
var extendedClipboardActionRequest = 1 << 25;
var extendedClipboardActionPeek = 1 << 26;
var extendedClipboardActionNotify = 1 << 27;
var extendedClipboardActionProvide = 1 << 28;

var RFB = function (_EventTargetMixin) {
    _inherits(RFB, _EventTargetMixin);

    function RFB(target, url, options) {
        _classCallCheck(this, RFB);

        if (!target) {
            throw new Error("Must specify target");
        }
        if (!url) {
            throw new Error("Must specify URL");
        }

        var _this = _possibleConstructorReturn(this, (RFB.__proto__ || Object.getPrototypeOf(RFB)).call(this));

        _this._target = target;
        _this._url = url;

        // Connection details
        options = options || {};
        _this._rfb_credentials = options.credentials || {};
        _this._shared = 'shared' in options ? !!options.shared : true;
        _this._repeaterID = options.repeaterID || '';
        _this._wsProtocols = options.wsProtocols || [];

        // Internal state
        _this._rfb_connection_state = '';
        _this._rfb_init_state = '';
        _this._rfb_auth_scheme = -1;
        _this._rfb_clean_disconnect = true;

        // Server capabilities
        _this._rfb_version = 0;
        _this._rfb_max_version = 3.8;
        _this._rfb_tightvnc = false;
        _this._rfb_xvp_ver = 0;

        _this._fb_width = 0;
        _this._fb_height = 0;

        _this._fb_name = "";

        _this._capabilities = { power: false };

        _this._supportsFence = false;

        _this._supportsContinuousUpdates = false;
        _this._enabledContinuousUpdates = false;

        _this._supportsSetDesktopSize = false;
        _this._screen_id = 0;
        _this._screen_flags = 0;

        _this._qemuExtKeyEventSupported = false;

        _this._clipboardText = null;
        _this._clipboardServerCapabilitiesActions = {};
        _this._clipboardServerCapabilitiesFormats = {};

        // Internal objects
        _this._sock = null; // Websock object
        _this._display = null; // Display object
        _this._flushing = false; // Display flushing state
        _this._keyboard = null; // Keyboard input handler object
        _this._mouse = null; // Mouse input handler object

        // Timers
        _this._disconnTimer = null; // disconnection timer
        _this._resizeTimeout = null; // resize rate limiting

        // Decoder states
        _this._decoders = {};

        _this._FBU = {
            rects: 0,
            x: 0,
            y: 0,
            width: 0,
            height: 0,
            encoding: null
        };

        // Mouse state
        _this._mouse_buttonMask = 0;
        _this._mouse_arr = [];
        _this._viewportDragging = false;
        _this._viewportDragPos = {};
        _this._viewportHasMoved = false;

        // Bound event handlers
        _this._eventHandlers = {
            focusCanvas: _this._focusCanvas.bind(_this),
            windowResize: _this._windowResize.bind(_this)
        };

        // main setup
        Log.Debug(">> RFB.constructor");

        // Create DOM elements
        _this._screen = document.createElement('div');
        _this._screen.style.display = 'flex';
        _this._screen.style.width = '100%';
        _this._screen.style.height = '100%';
        _this._screen.style.overflow = 'auto';
        _this._screen.style.background = DEFAULT_BACKGROUND;
        _this._canvas = document.createElement('canvas');
        _this._canvas.style.margin = 'auto';
        // Some browsers add an outline on focus
        _this._canvas.style.outline = 'none';
        // IE miscalculates width without this :(
        _this._canvas.style.flexShrink = '0';
        _this._canvas.width = 0;
        _this._canvas.height = 0;
        _this._canvas.tabIndex = -1;
        _this._screen.appendChild(_this._canvas);

        // Cursor
        _this._cursor = new _cursor2.default();

        // XXX: TightVNC 2.8.11 sends no cursor at all until Windows changes
        // it. Result: no cursor at all until a window border or an edit field
        // is hit blindly. But there are also VNC servers that draw the cursor
        // in the framebuffer and don't send the empty local cursor. There is
        // no way to satisfy both sides.
        //
        // The spec is unclear on this "initial cursor" issue. Many other
        // viewers (TigerVNC, RealVNC, Remmina) display an arrow as the
        // initial cursor instead.
        _this._cursorImage = RFB.cursors.none;

        // populate decoder array with objects
        _this._decoders[_encodings.encodings.encodingRaw] = new _raw2.default();
        _this._decoders[_encodings.encodings.encodingCopyRect] = new _copyrect2.default();
        _this._decoders[_encodings.encodings.encodingRRE] = new _rre2.default();
        _this._decoders[_encodings.encodings.encodingHextile] = new _hextile2.default();
        _this._decoders[_encodings.encodings.encodingTight] = new _tight2.default();
        _this._decoders[_encodings.encodings.encodingTightPNG] = new _tightpng2.default();

        // NB: nothing that needs explicit teardown should be done
        // before this point, since this can throw an exception
        try {
            _this._display = new _display2.default(_this._canvas);
        } catch (exc) {
            Log.Error("Display exception: " + exc);
            throw exc;
        }
        _this._display.onflush = _this._onFlush.bind(_this);

        _this._keyboard = new _keyboard2.default(_this._canvas);
        _this._keyboard.onkeyevent = _this._handleKeyEvent.bind(_this);

        _this._mouse = new _mouse2.default(_this._canvas);
        _this._mouse.onmousebutton = _this._handleMouseButton.bind(_this);
        _this._mouse.onmousemove = _this._handleMouseMove.bind(_this);

        _this._sock = new _websock2.default();
        _this._sock.on('message', function () {
            _this._handle_message();
        });
        _this._sock.on('open', function () {
            if (_this._rfb_connection_state === 'connecting' && _this._rfb_init_state === '') {
                _this._rfb_init_state = 'ProtocolVersion';
                Log.Debug("Starting VNC handshake");
            } else {
                _this._fail("Unexpected server connection while " + _this._rfb_connection_state);
            }
        });
        _this._sock.on('close', function (e) {
            Log.Debug("WebSocket on-close event");
            var msg = "";
            if (e.code) {
                msg = "(code: " + e.code;
                if (e.reason) {
                    msg += ", reason: " + e.reason;
                }
                msg += ")";
            }
            switch (_this._rfb_connection_state) {
                case 'connecting':
                    _this._fail("Connection closed " + msg);
                    break;
                case 'connected':
                    // Handle disconnects that were initiated server-side
                    _this._updateConnectionState('disconnecting');
                    _this._updateConnectionState('disconnected');
                    break;
                case 'disconnecting':
                    // Normal disconnection path
                    _this._updateConnectionState('disconnected');
                    break;
                case 'disconnected':
                    _this._fail("Unexpected server disconnect " + "when already disconnected " + msg);
                    break;
                default:
                    _this._fail("Unexpected server disconnect before connecting " + msg);
                    break;
            }
            _this._sock.off('close');
        });
        _this._sock.on('error', function (e) {
            return Log.Warn("WebSocket on-error event");
        });

        // Slight delay of the actual connection so that the caller has
        // time to set up callbacks
        setTimeout(_this._updateConnectionState.bind(_this, 'connecting'));

        _this.oncanvasfocus = function () {}; // Handler for canvas focused

        Log.Debug("<< RFB.constructor");

        // ===== PROPERTIES =====

        _this.dragViewport = false;
        _this.focusOnClick = true;

        _this._viewOnly = false;
        _this._clipViewport = false;
        _this._scaleViewport = false;
        _this._resizeSession = false;

        _this._showDotCursor = false;
        if (options.showDotCursor !== undefined) {
            Log.Warn("Specifying showDotCursor as a RFB constructor argument is deprecated");
            _this._showDotCursor = options.showDotCursor;
        }
        return _this;
    }

    // ===== PROPERTIES =====

    _createClass(RFB, [{
        key: 'disconnect',


        // ===== PUBLIC METHODS =====

        value: function disconnect() {
            this._updateConnectionState('disconnecting');
            this._sock.off('error');
            this._sock.off('message');
            this._sock.off('open');
        }
    }, {
        key: 'sendCredentials',
        value: function sendCredentials(creds) {
            this._rfb_credentials = creds;
            setTimeout(this._init_msg.bind(this), 0);
        }
    }, {
        key: 'sendCtrlAltDel',
        value: function sendCtrlAltDel() {
            if (this._rfb_connection_state !== 'connected' || this._viewOnly) {
                return;
            }
            Log.Info("Sending Ctrl-Alt-Del");

            this.sendKey(_keysym2.default.XK_Control_L, "ControlLeft", true);
            this.sendKey(_keysym2.default.XK_Alt_L, "AltLeft", true);
            this.sendKey(_keysym2.default.XK_Delete, "Delete", true);
            this.sendKey(_keysym2.default.XK_Delete, "Delete", false);
            this.sendKey(_keysym2.default.XK_Alt_L, "AltLeft", false);
            this.sendKey(_keysym2.default.XK_Control_L, "ControlLeft", false);
        }
    }, {
        key: 'machineShutdown',
        value: function machineShutdown() {
            this._xvpOp(1, 2);
        }
    }, {
        key: 'machineReboot',
        value: function machineReboot() {
            this._xvpOp(1, 3);
        }
    }, {
        key: 'machineReset',
        value: function machineReset() {
            this._xvpOp(1, 4);
        }

        // Send a key press. If 'down' is not specified then send a down key
        // followed by an up key.

    }, {
        key: 'sendKey',
        value: function sendKey(keysym, code, down) {
            if (this._rfb_connection_state !== 'connected' || this._viewOnly) {
                return;
            }

            if (down === undefined) {
                this.sendKey(keysym, code, true);
                this.sendKey(keysym, code, false);
                return;
            }

            var scancode = _xtscancodes2.default[code];

            if (this._qemuExtKeyEventSupported && scancode) {
                // 0 is NoSymbol
                keysym = keysym || 0;

                Log.Info("Sending key (" + (down ? "down" : "up") + "): keysym " + keysym + ", scancode " + scancode);

                RFB.messages.QEMUExtendedKeyEvent(this._sock, keysym, down, scancode);
            } else {
                if (!keysym) {
                    return;
                }
                Log.Info("Sending keysym (" + (down ? "down" : "up") + "): " + keysym);
                RFB.messages.keyEvent(this._sock, keysym, down ? 1 : 0);
            }
        }
    }, {
        key: 'focus',
        value: function focus() {
            this._canvas.focus();
            this.oncanvasfocus();
        }
    }, {
        key: 'blur',
        value: function blur() {
            this._canvas.blur();
        }
    }, {
        key: 'clipboardPasteFrom',
        value: function clipboardPasteFrom(text) {
            if (this._rfb_connection_state !== 'connected' || this._viewOnly) {
                return;
            }

            if (this._clipboardServerCapabilitiesFormats[extendedClipboardFormatText] && this._clipboardServerCapabilitiesActions[extendedClipboardActionNotify]) {

                this._clipboardText = text;
                RFB.messages.extendedClipboardNotify(this._sock, [extendedClipboardFormatText]);
            } else {
                var data = new Uint8Array(text.length);
                for (var i = 0; i < text.length; i++) {
                    // FIXME: text can have values outside of Latin1/Uint8
                    data[i] = text.charCodeAt(i);
                }

                RFB.messages.clientCutText(this._sock, data);
            }
        }

        // ===== PRIVATE METHODS =====

    }, {
        key: '_connect',
        value: function _connect() {
            Log.Debug(">> RFB.connect");

            Log.Info("connecting to " + this._url);

            try {
                // WebSocket.onopen transitions to the RFB init states
                this._sock.open(this._url, this._wsProtocols);
            } catch (e) {
                if (e.name === 'SyntaxError') {
                    this._fail("Invalid host or port (" + e + ")");
                } else {
                    this._fail("Error when opening socket (" + e + ")");
                }
            }

            // Make our elements part of the page
            this._target.appendChild(this._screen);

            this._cursor.attach(this._canvas);
            this._refreshCursor();

            // Monitor size changes of the screen
            // FIXME: Use ResizeObserver, or hidden overflow
            window.addEventListener('resize', this._eventHandlers.windowResize);

            // Always grab focus on some kind of click event
            this._canvas.addEventListener("mousedown", this._eventHandlers.focusCanvas);
            this._canvas.addEventListener("touchstart", this._eventHandlers.focusCanvas);

            Log.Debug("<< RFB.connect");
        }
    }, {
        key: '_disconnect',
        value: function _disconnect() {
            Log.Debug(">> RFB.disconnect");
            this._cursor.detach();
            this._canvas.removeEventListener("mousedown", this._eventHandlers.focusCanvas);
            this._canvas.removeEventListener("touchstart", this._eventHandlers.focusCanvas);
            window.removeEventListener('resize', this._eventHandlers.windowResize);
            this._keyboard.ungrab();
            this._mouse.ungrab();
            this._sock.close();
            try {
                this._target.removeChild(this._screen);
            } catch (e) {
                if (e.name === 'NotFoundError') {
                    // Some cases where the initial connection fails
                    // can disconnect before the _screen is created
                } else {
                    throw e;
                }
            }
            clearTimeout(this._resizeTimeout);
            Log.Debug("<< RFB.disconnect");
        }
    }, {
        key: '_focusCanvas',
        value: function _focusCanvas(event) {
            // Respect earlier handlers' request to not do side-effects
            if (event.defaultPrevented) {
                return;
            }

            if (!this.focusOnClick) {
                return;
            }

            this.focus();
        }
    }, {
        key: '_setDesktopName',
        value: function _setDesktopName(name) {
            this._fb_name = name;
            this.dispatchEvent(new CustomEvent("desktopname", { detail: { name: this._fb_name } }));
        }
    }, {
        key: '_windowResize',
        value: function _windowResize(event) {
            var _this2 = this;

            // If the window resized then our screen element might have
            // as well. Update the viewport dimensions.
            window.requestAnimationFrame(function () {
                _this2._updateClip();
                _this2._updateScale();
            });

            if (this._resizeSession) {
                // Request changing the resolution of the remote display to
                // the size of the local browser viewport.

                // In order to not send multiple requests before the browser-resize
                // is finished we wait 0.5 seconds before sending the request.
                clearTimeout(this._resizeTimeout);
                this._resizeTimeout = setTimeout(this._requestRemoteResize.bind(this), 500);
            }
        }

        // Update state of clipping in Display object, and make sure the
        // configured viewport matches the current screen size

    }, {
        key: '_updateClip',
        value: function _updateClip() {
            var cur_clip = this._display.clipViewport;
            var new_clip = this._clipViewport;

            if (this._scaleViewport) {
                // Disable viewport clipping if we are scaling
                new_clip = false;
            }

            if (cur_clip !== new_clip) {
                this._display.clipViewport = new_clip;
            }

            if (new_clip) {
                // When clipping is enabled, the screen is limited to
                // the size of the container.
                var size = this._screenSize();
                this._display.viewportChangeSize(size.w, size.h);
                this._fixScrollbars();
            }
        }
    }, {
        key: '_updateScale',
        value: function _updateScale() {
            if (!this._scaleViewport) {
                this._display.scale = 1.0;
            } else {
                var size = this._screenSize();
                this._display.autoscale(size.w, size.h);
            }
            this._fixScrollbars();
        }

        // Requests a change of remote desktop size. This message is an extension
        // and may only be sent if we have received an ExtendedDesktopSize message

    }, {
        key: '_requestRemoteResize',
        value: function _requestRemoteResize() {
            clearTimeout(this._resizeTimeout);
            this._resizeTimeout = null;

            if (!this._resizeSession || this._viewOnly || !this._supportsSetDesktopSize) {
                return;
            }

            var size = this._screenSize();
            RFB.messages.setDesktopSize(this._sock, Math.floor(size.w), Math.floor(size.h), this._screen_id, this._screen_flags);

            Log.Debug('Requested new desktop size: ' + size.w + 'x' + size.h);
        }

        // Gets the the size of the available screen

    }, {
        key: '_screenSize',
        value: function _screenSize() {
            var r = this._screen.getBoundingClientRect();
            return { w: r.width, h: r.height };
        }
    }, {
        key: '_fixScrollbars',
        value: function _fixScrollbars() {
            // This is a hack because Chrome screws up the calculation
            // for when scrollbars are needed. So to fix it we temporarily
            // toggle them off and on.
            var orig = this._screen.style.overflow;
            this._screen.style.overflow = 'hidden';
            // Force Chrome to recalculate the layout by asking for
            // an element's dimensions
            this._screen.getBoundingClientRect();
            this._screen.style.overflow = orig;
        }

        /*
         * Connection states:
         *   connecting
         *   connected
         *   disconnecting
         *   disconnected - permanent state
         */

    }, {
        key: '_updateConnectionState',
        value: function _updateConnectionState(state) {
            var _this3 = this;

            var oldstate = this._rfb_connection_state;

            if (state === oldstate) {
                Log.Debug("Already in state '" + state + "', ignoring");
                return;
            }

            // The 'disconnected' state is permanent for each RFB object
            if (oldstate === 'disconnected') {
                Log.Error("Tried changing state of a disconnected RFB object");
                return;
            }

            // Ensure proper transitions before doing anything
            switch (state) {
                case 'connected':
                    if (oldstate !== 'connecting') {
                        Log.Error("Bad transition to connected state, " + "previous connection state: " + oldstate);
                        return;
                    }
                    break;

                case 'disconnected':
                    if (oldstate !== 'disconnecting') {
                        Log.Error("Bad transition to disconnected state, " + "previous connection state: " + oldstate);
                        return;
                    }
                    break;

                case 'connecting':
                    if (oldstate !== '') {
                        Log.Error("Bad transition to connecting state, " + "previous connection state: " + oldstate);
                        return;
                    }
                    break;

                case 'disconnecting':
                    if (oldstate !== 'connected' && oldstate !== 'connecting') {
                        Log.Error("Bad transition to disconnecting state, " + "previous connection state: " + oldstate);
                        return;
                    }
                    break;

                default:
                    Log.Error("Unknown connection state: " + state);
                    return;
            }

            // State change actions

            this._rfb_connection_state = state;

            Log.Debug("New state '" + state + "', was '" + oldstate + "'.");

            if (this._disconnTimer && state !== 'disconnecting') {
                Log.Debug("Clearing disconnect timer");
                clearTimeout(this._disconnTimer);
                this._disconnTimer = null;

                // make sure we don't get a double event
                this._sock.off('close');
            }

            switch (state) {
                case 'connecting':
                    this._connect();
                    break;

                case 'connected':
                    this.dispatchEvent(new CustomEvent("connect", { detail: {} }));
                    break;

                case 'disconnecting':
                    this._disconnect();

                    this._disconnTimer = setTimeout(function () {
                        Log.Error("Disconnection timed out.");
                        _this3._updateConnectionState('disconnected');
                    }, DISCONNECT_TIMEOUT * 1000);
                    break;

                case 'disconnected':
                    this.dispatchEvent(new CustomEvent("disconnect", { detail: { clean: this._rfb_clean_disconnect } }));
                    break;
            }
        }

        /* Print errors and disconnect
         *
         * The parameter 'details' is used for information that
         * should be logged but not sent to the user interface.
         */

    }, {
        key: '_fail',
        value: function _fail(details) {
            switch (this._rfb_connection_state) {
                case 'disconnecting':
                    Log.Error("Failed when disconnecting: " + details);
                    break;
                case 'connected':
                    Log.Error("Failed while connected: " + details);
                    break;
                case 'connecting':
                    Log.Error("Failed when connecting: " + details);
                    break;
                default:
                    Log.Error("RFB failure: " + details);
                    break;
            }
            this._rfb_clean_disconnect = false; //This is sent to the UI

            // Transition to disconnected without waiting for socket to close
            this._updateConnectionState('disconnecting');
            this._updateConnectionState('disconnected');

            return false;
        }
    }, {
        key: '_setCapability',
        value: function _setCapability(cap, val) {
            this._capabilities[cap] = val;
            this.dispatchEvent(new CustomEvent("capabilities", { detail: { capabilities: this._capabilities } }));
        }
    }, {
        key: '_handle_message',
        value: function _handle_message() {
            if (this._sock.rQlen === 0) {
                Log.Warn("handle_message called on an empty receive queue");
                return;
            }

            switch (this._rfb_connection_state) {
                case 'disconnected':
                    Log.Error("Got data while disconnected");
                    break;
                case 'connected':
                    while (true) {
                        if (this._flushing) {
                            break;
                        }
                        if (!this._normal_msg()) {
                            break;
                        }
                        if (this._sock.rQlen === 0) {
                            break;
                        }
                    }
                    break;
                default:
                    this._init_msg();
                    break;
            }
        }
    }, {
        key: '_handleKeyEvent',
        value: function _handleKeyEvent(keysym, code, down) {
            this.sendKey(keysym, code, down);
        }
    }, {
        key: '_handleMouseButton',
        value: function _handleMouseButton(x, y, down, bmask) {
            if (down) {
                this._mouse_buttonMask |= bmask;
            } else {
                this._mouse_buttonMask &= ~bmask;
            }

            if (this.dragViewport) {
                if (down && !this._viewportDragging) {
                    this._viewportDragging = true;
                    this._viewportDragPos = { 'x': x, 'y': y };
                    this._viewportHasMoved = false;

                    // Skip sending mouse events
                    return;
                } else {
                    this._viewportDragging = false;

                    // If we actually performed a drag then we are done
                    // here and should not send any mouse events
                    if (this._viewportHasMoved) {
                        return;
                    }

                    // Otherwise we treat this as a mouse click event.
                    // Send the button down event here, as the button up
                    // event is sent at the end of this function.
                    RFB.messages.pointerEvent(this._sock, this._display.absX(x), this._display.absY(y), bmask);
                }
            }

            if (this._viewOnly) {
                return;
            } // View only, skip mouse events

            if (this._rfb_connection_state !== 'connected') {
                return;
            }
            RFB.messages.pointerEvent(this._sock, this._display.absX(x), this._display.absY(y), this._mouse_buttonMask);
        }
    }, {
        key: '_handleMouseMove',
        value: function _handleMouseMove(x, y) {
            if (this._viewportDragging) {
                var deltaX = this._viewportDragPos.x - x;
                var deltaY = this._viewportDragPos.y - y;

                if (this._viewportHasMoved || Math.abs(deltaX) > _browser.dragThreshold || Math.abs(deltaY) > _browser.dragThreshold) {
                    this._viewportHasMoved = true;

                    this._viewportDragPos = { 'x': x, 'y': y };
                    this._display.viewportChangePos(deltaX, deltaY);
                }

                // Skip sending mouse events
                return;
            }

            if (this._viewOnly) {
                return;
            } // View only, skip mouse events

            if (this._rfb_connection_state !== 'connected') {
                return;
            }
            RFB.messages.pointerEvent(this._sock, this._display.absX(x), this._display.absY(y), this._mouse_buttonMask);
        }

        // Message Handlers

    }, {
        key: '_negotiate_protocol_version',
        value: function _negotiate_protocol_version() {
            if (this._sock.rQwait("version", 12)) {
                return false;
            }

            var sversion = this._sock.rQshiftStr(12).substr(4, 7);
            Log.Info("Server ProtocolVersion: " + sversion);
            var is_repeater = 0;
            switch (sversion) {
                case "000.000":
                    // UltraVNC repeater
                    is_repeater = 1;
                    break;
                case "003.003":
                case "003.006": // UltraVNC
                case "003.889":
                    // Apple Remote Desktop
                    this._rfb_version = 3.3;
                    break;
                case "003.007":
                    this._rfb_version = 3.7;
                    break;
                case "003.008":
                case "004.000": // Intel AMT KVM
                case "004.001": // RealVNC 4.6
                case "005.000":
                    // RealVNC 5.3
                    this._rfb_version = 3.8;
                    break;
                default:
                    return this._fail("Invalid server version " + sversion);
            }

            if (is_repeater) {
                var repeaterID = "ID:" + this._repeaterID;
                while (repeaterID.length < 250) {
                    repeaterID += "\0";
                }
                this._sock.send_string(repeaterID);
                return true;
            }

            if (this._rfb_version > this._rfb_max_version) {
                this._rfb_version = this._rfb_max_version;
            }

            var cversion = "00" + parseInt(this._rfb_version, 10) + ".00" + this._rfb_version * 10 % 10;
            this._sock.send_string("RFB " + cversion + "\n");
            Log.Debug('Sent ProtocolVersion: ' + cversion);

            this._rfb_init_state = 'Security';
        }
    }, {
        key: '_negotiate_security',
        value: function _negotiate_security() {
            // Polyfill since IE and PhantomJS doesn't have
            // TypedArray.includes()
            function includes(item, array) {
                for (var i = 0; i < array.length; i++) {
                    if (array[i] === item) {
                        return true;
                    }
                }
                return false;
            }

            if (this._rfb_version >= 3.7) {
                // Server sends supported list, client decides
                var num_types = this._sock.rQshift8();
                if (this._sock.rQwait("security type", num_types, 1)) {
                    return false;
                }

                if (num_types === 0) {
                    this._rfb_init_state = "SecurityReason";
                    this._security_context = "no security types";
                    this._security_status = 1;
                    return this._init_msg();
                }

                var types = this._sock.rQshiftBytes(num_types);
                Log.Debug("Server security types: " + types);

                // Look for each auth in preferred order
                if (includes(1, types)) {
                    this._rfb_auth_scheme = 1; // None
                } else if (includes(22, types)) {
                    this._rfb_auth_scheme = 22; // XVP
                } else if (includes(16, types)) {
                    this._rfb_auth_scheme = 16; // Tight
                } else if (includes(2, types)) {
                    this._rfb_auth_scheme = 2; // VNC Auth
                } else {
                    return this._fail("Unsupported security types (types: " + types + ")");
                }

                this._sock.send([this._rfb_auth_scheme]);
            } else {
                // Server decides
                if (this._sock.rQwait("security scheme", 4)) {
                    return false;
                }
                this._rfb_auth_scheme = this._sock.rQshift32();

                if (this._rfb_auth_scheme == 0) {
                    this._rfb_init_state = "SecurityReason";
                    this._security_context = "authentication scheme";
                    this._security_status = 1;
                    return this._init_msg();
                }
            }

            this._rfb_init_state = 'Authentication';
            Log.Debug('Authenticating using scheme: ' + this._rfb_auth_scheme);

            return this._init_msg(); // jump to authentication
        }
    }, {
        key: '_handle_security_reason',
        value: function _handle_security_reason() {
            if (this._sock.rQwait("reason length", 4)) {
                return false;
            }
            var strlen = this._sock.rQshift32();
            var reason = "";

            if (strlen > 0) {
                if (this._sock.rQwait("reason", strlen, 4)) {
                    return false;
                }
                reason = this._sock.rQshiftStr(strlen);
            }

            if (reason !== "") {
                this.dispatchEvent(new CustomEvent("securityfailure", { detail: { status: this._security_status,
                        reason: reason } }));

                return this._fail("Security negotiation failed on " + this._security_context + " (reason: " + reason + ")");
            } else {
                this.dispatchEvent(new CustomEvent("securityfailure", { detail: { status: this._security_status } }));

                return this._fail("Security negotiation failed on " + this._security_context);
            }
        }

        // authentication

    }, {
        key: '_negotiate_xvp_auth',
        value: function _negotiate_xvp_auth() {
            if (this._rfb_credentials.username === undefined || this._rfb_credentials.password === undefined || this._rfb_credentials.target === undefined) {
                this.dispatchEvent(new CustomEvent("credentialsrequired", { detail: { types: ["username", "password", "target"] } }));
                return false;
            }

            var xvp_auth_str = String.fromCharCode(this._rfb_credentials.username.length) + String.fromCharCode(this._rfb_credentials.target.length) + this._rfb_credentials.username + this._rfb_credentials.target;
            this._sock.send_string(xvp_auth_str);
            this._rfb_auth_scheme = 2;
            return this._negotiate_authentication();
        }
    }, {
        key: '_negotiate_std_vnc_auth',
        value: function _negotiate_std_vnc_auth() {
            if (this._sock.rQwait("auth challenge", 16)) {
                return false;
            }

            if (this._rfb_credentials.password === undefined) {
                this.dispatchEvent(new CustomEvent("credentialsrequired", { detail: { types: ["password"] } }));
                return false;
            }

            // TODO(directxman12): make genDES not require an Array
            var challenge = Array.prototype.slice.call(this._sock.rQshiftBytes(16));
            var response = RFB.genDES(this._rfb_credentials.password, challenge);
            this._sock.send(response);
            this._rfb_init_state = "SecurityResult";
            return true;
        }
    }, {
        key: '_negotiate_tight_unix_auth',
        value: function _negotiate_tight_unix_auth() {
            if (this._rfb_credentials.username === undefined || this._rfb_credentials.password === undefined) {
                this.dispatchEvent(new CustomEvent("credentialsrequired", { detail: { types: ["username", "password"] } }));
                return false;
            }

            this._sock.send([0, 0, 0, this._rfb_credentials.username.length]);
            this._sock.send([0, 0, 0, this._rfb_credentials.password.length]);
            this._sock.send_string(this._rfb_credentials.username);
            this._sock.send_string(this._rfb_credentials.password);
            this._rfb_init_state = "SecurityResult";
            return true;
        }
    }, {
        key: '_negotiate_tight_tunnels',
        value: function _negotiate_tight_tunnels(numTunnels) {
            var clientSupportedTunnelTypes = {
                0: { vendor: 'TGHT', signature: 'NOTUNNEL' }
            };
            var serverSupportedTunnelTypes = {};
            // receive tunnel capabilities
            for (var i = 0; i < numTunnels; i++) {
                var cap_code = this._sock.rQshift32();
                var cap_vendor = this._sock.rQshiftStr(4);
                var cap_signature = this._sock.rQshiftStr(8);
                serverSupportedTunnelTypes[cap_code] = { vendor: cap_vendor, signature: cap_signature };
            }

            Log.Debug("Server Tight tunnel types: " + serverSupportedTunnelTypes);

            // Siemens touch panels have a VNC server that supports NOTUNNEL,
            // but forgets to advertise it. Try to detect such servers by
            // looking for their custom tunnel type.
            if (serverSupportedTunnelTypes[1] && serverSupportedTunnelTypes[1].vendor === "SICR" && serverSupportedTunnelTypes[1].signature === "SCHANNEL") {
                Log.Debug("Detected Siemens server. Assuming NOTUNNEL support.");
                serverSupportedTunnelTypes[0] = { vendor: 'TGHT', signature: 'NOTUNNEL' };
            }

            // choose the notunnel type
            if (serverSupportedTunnelTypes[0]) {
                if (serverSupportedTunnelTypes[0].vendor != clientSupportedTunnelTypes[0].vendor || serverSupportedTunnelTypes[0].signature != clientSupportedTunnelTypes[0].signature) {
                    return this._fail("Client's tunnel type had the incorrect " + "vendor or signature");
                }
                Log.Debug("Selected tunnel type: " + clientSupportedTunnelTypes[0]);
                this._sock.send([0, 0, 0, 0]); // use NOTUNNEL
                return false; // wait until we receive the sub auth count to continue
            } else {
                return this._fail("Server wanted tunnels, but doesn't support " + "the notunnel type");
            }
        }
    }, {
        key: '_negotiate_tight_auth',
        value: function _negotiate_tight_auth() {
            if (!this._rfb_tightvnc) {
                // first pass, do the tunnel negotiation
                if (this._sock.rQwait("num tunnels", 4)) {
                    return false;
                }
                var numTunnels = this._sock.rQshift32();
                if (numTunnels > 0 && this._sock.rQwait("tunnel capabilities", 16 * numTunnels, 4)) {
                    return false;
                }

                this._rfb_tightvnc = true;

                if (numTunnels > 0) {
                    this._negotiate_tight_tunnels(numTunnels);
                    return false; // wait until we receive the sub auth to continue
                }
            }

            // second pass, do the sub-auth negotiation
            if (this._sock.rQwait("sub auth count", 4)) {
                return false;
            }
            var subAuthCount = this._sock.rQshift32();
            if (subAuthCount === 0) {
                // empty sub-auth list received means 'no auth' subtype selected
                this._rfb_init_state = 'SecurityResult';
                return true;
            }

            if (this._sock.rQwait("sub auth capabilities", 16 * subAuthCount, 4)) {
                return false;
            }

            var clientSupportedTypes = {
                'STDVNOAUTH__': 1,
                'STDVVNCAUTH_': 2,
                'TGHTULGNAUTH': 129
            };

            var serverSupportedTypes = [];

            for (var i = 0; i < subAuthCount; i++) {
                this._sock.rQshift32(); // capNum
                var capabilities = this._sock.rQshiftStr(12);
                serverSupportedTypes.push(capabilities);
            }

            Log.Debug("Server Tight authentication types: " + serverSupportedTypes);

            for (var authType in clientSupportedTypes) {
                if (serverSupportedTypes.indexOf(authType) != -1) {
                    this._sock.send([0, 0, 0, clientSupportedTypes[authType]]);
                    Log.Debug("Selected authentication type: " + authType);

                    switch (authType) {
                        case 'STDVNOAUTH__':
                            // no auth
                            this._rfb_init_state = 'SecurityResult';
                            return true;
                        case 'STDVVNCAUTH_':
                            // VNC auth
                            this._rfb_auth_scheme = 2;
                            return this._init_msg();
                        case 'TGHTULGNAUTH':
                            // UNIX auth
                            this._rfb_auth_scheme = 129;
                            return this._init_msg();
                        default:
                            return this._fail("Unsupported tiny auth scheme " + "(scheme: " + authType + ")");
                    }
                }
            }

            return this._fail("No supported sub-auth types!");
        }
    }, {
        key: '_negotiate_authentication',
        value: function _negotiate_authentication() {
            switch (this._rfb_auth_scheme) {
                case 1:
                    // no auth
                    if (this._rfb_version >= 3.8) {
                        this._rfb_init_state = 'SecurityResult';
                        return true;
                    }
                    this._rfb_init_state = 'ClientInitialisation';
                    return this._init_msg();

                case 22:
                    // XVP auth
                    return this._negotiate_xvp_auth();

                case 2:
                    // VNC authentication
                    return this._negotiate_std_vnc_auth();

                case 16:
                    // TightVNC Security Type
                    return this._negotiate_tight_auth();

                case 129:
                    // TightVNC UNIX Security Type
                    return this._negotiate_tight_unix_auth();

                default:
                    return this._fail("Unsupported auth scheme (scheme: " + this._rfb_auth_scheme + ")");
            }
        }
    }, {
        key: '_handle_security_result',
        value: function _handle_security_result() {
            if (this._sock.rQwait('VNC auth response ', 4)) {
                return false;
            }

            var status = this._sock.rQshift32();

            if (status === 0) {
                // OK
                this._rfb_init_state = 'ClientInitialisation';
                Log.Debug('Authentication OK');
                return this._init_msg();
            } else {
                if (this._rfb_version >= 3.8) {
                    this._rfb_init_state = "SecurityReason";
                    this._security_context = "security result";
                    this._security_status = status;
                    return this._init_msg();
                } else {
                    this.dispatchEvent(new CustomEvent("securityfailure", { detail: { status: status } }));

                    return this._fail("Security handshake failed");
                }
            }
        }
    }, {
        key: '_negotiate_server_init',
        value: function _negotiate_server_init() {
            if (this._sock.rQwait("server initialization", 24)) {
                return false;
            }

            /* Screen size */
            var width = this._sock.rQshift16();
            var height = this._sock.rQshift16();

            /* PIXEL_FORMAT */
            var bpp = this._sock.rQshift8();
            var depth = this._sock.rQshift8();
            var big_endian = this._sock.rQshift8();
            var true_color = this._sock.rQshift8();

            var red_max = this._sock.rQshift16();
            var green_max = this._sock.rQshift16();
            var blue_max = this._sock.rQshift16();
            var red_shift = this._sock.rQshift8();
            var green_shift = this._sock.rQshift8();
            var blue_shift = this._sock.rQshift8();
            this._sock.rQskipBytes(3); // padding

            // NB(directxman12): we don't want to call any callbacks or print messages until
            //                   *after* we're past the point where we could backtrack

            /* Connection name/title */
            var name_length = this._sock.rQshift32();
            if (this._sock.rQwait('server init name', name_length, 24)) {
                return false;
            }
            var name = this._sock.rQshiftStr(name_length);
            name = (0, _strings.decodeUTF8)(name, true);

            if (this._rfb_tightvnc) {
                if (this._sock.rQwait('TightVNC extended server init header', 8, 24 + name_length)) {
                    return false;
                }
                // In TightVNC mode, ServerInit message is extended
                var numServerMessages = this._sock.rQshift16();
                var numClientMessages = this._sock.rQshift16();
                var numEncodings = this._sock.rQshift16();
                this._sock.rQskipBytes(2); // padding

                var totalMessagesLength = (numServerMessages + numClientMessages + numEncodings) * 16;
                if (this._sock.rQwait('TightVNC extended server init header', totalMessagesLength, 32 + name_length)) {
                    return false;
                }

                // we don't actually do anything with the capability information that TIGHT sends,
                // so we just skip the all of this.

                // TIGHT server message capabilities
                this._sock.rQskipBytes(16 * numServerMessages);

                // TIGHT client message capabilities
                this._sock.rQskipBytes(16 * numClientMessages);

                // TIGHT encoding capabilities
                this._sock.rQskipBytes(16 * numEncodings);
            }

            // NB(directxman12): these are down here so that we don't run them multiple times
            //                   if we backtrack
            Log.Info("Screen: " + width + "x" + height + ", bpp: " + bpp + ", depth: " + depth + ", big_endian: " + big_endian + ", true_color: " + true_color + ", red_max: " + red_max + ", green_max: " + green_max + ", blue_max: " + blue_max + ", red_shift: " + red_shift + ", green_shift: " + green_shift + ", blue_shift: " + blue_shift);

            // we're past the point where we could backtrack, so it's safe to call this
            this._setDesktopName(name);
            this._resize(width, height);

            if (!this._viewOnly) {
                this._keyboard.grab();
            }
            if (!this._viewOnly) {
                this._mouse.grab();
            }

            this._fb_depth = 24;

            if (this._fb_name === "Intel(r) AMT KVM") {
                Log.Warn("Intel AMT KVM only supports 8/16 bit depths. Using low color mode.");
                this._fb_depth = 8;
            }

            RFB.messages.pixelFormat(this._sock, this._fb_depth, true);
            this._sendEncodings();
            RFB.messages.fbUpdateRequest(this._sock, false, 0, 0, this._fb_width, this._fb_height);

            this._updateConnectionState('connected');
            return true;
        }
    }, {
        key: '_sendEncodings',
        value: function _sendEncodings() {
            var encs = [];

            var urlParams = new URLSearchParams(window.location.search);
            var qualityLevelDefault = _encodings.encodings.pseudoEncodingQualityLevel0 + 6;
            var compressionLevelDefault = _encodings.encodings.pseudoEncodingCompressLevel0 + 2;

            // Get the compression level query string or use set default if query returns null
            // compressionsetting: 0-9
            var compressionLevel = urlParams.get('compressionsetting') === null ? compressionLevelDefault : urlParams.get('compressionsetting') - 256;

            // get the quality level query string or use set default if the query returns null
            // qualitysetting: 0-9
            var qualityLevel = urlParams.get('qualitysetting') === null ? qualityLevelDefault : urlParams.get('qualitysetting') - 32;

            // In preference order
            encs.push(_encodings.encodings.encodingCopyRect);
            // Only supported with full depth support
            if (this._fb_depth == 24) {
                encs.push(_encodings.encodings.encodingTight);
                encs.push(_encodings.encodings.encodingTightPNG);
                encs.push(_encodings.encodings.encodingHextile);
                encs.push(_encodings.encodings.encodingRRE);
            }
            encs.push(_encodings.encodings.encodingRaw);

            // Psuedo-encoding settings
            // Push our custom configuration to encs[]
            encs.push(qualityLevel);
            encs.push(compressionLevel);

            encs.push(_encodings.encodings.pseudoEncodingDesktopSize);
            encs.push(_encodings.encodings.pseudoEncodingLastRect);
            encs.push(_encodings.encodings.pseudoEncodingQEMUExtendedKeyEvent);
            encs.push(_encodings.encodings.pseudoEncodingExtendedDesktopSize);
            encs.push(_encodings.encodings.pseudoEncodingXvp);
            encs.push(_encodings.encodings.pseudoEncodingFence);
            encs.push(_encodings.encodings.pseudoEncodingContinuousUpdates);
            encs.push(_encodings.encodings.pseudoEncodingDesktopName);
            encs.push(_encodings.encodings.pseudoEncodingExtendedClipboard);

            if (this._fb_depth == 24) {
                encs.push(_encodings.encodings.pseudoEncodingVMwareCursor);
                encs.push(_encodings.encodings.pseudoEncodingCursor);
            }

            RFB.messages.clientEncodings(this._sock, encs);
        }

        /* RFB protocol initialization states:
         *   ProtocolVersion
         *   Security
         *   Authentication
         *   SecurityResult
         *   ClientInitialization - not triggered by server message
         *   ServerInitialization
         */

    }, {
        key: '_init_msg',
        value: function _init_msg() {
            switch (this._rfb_init_state) {
                case 'ProtocolVersion':
                    return this._negotiate_protocol_version();

                case 'Security':
                    return this._negotiate_security();

                case 'Authentication':
                    return this._negotiate_authentication();

                case 'SecurityResult':
                    return this._handle_security_result();

                case 'SecurityReason':
                    return this._handle_security_reason();

                case 'ClientInitialisation':
                    this._sock.send([this._shared ? 1 : 0]); // ClientInitialisation
                    this._rfb_init_state = 'ServerInitialisation';
                    return true;

                case 'ServerInitialisation':
                    return this._negotiate_server_init();

                default:
                    return this._fail("Unknown init state (state: " + this._rfb_init_state + ")");
            }
        }
    }, {
        key: '_handle_set_colour_map_msg',
        value: function _handle_set_colour_map_msg() {
            Log.Debug("SetColorMapEntries");

            return this._fail("Unexpected SetColorMapEntries message");
        }
    }, {
        key: '_handle_server_cut_text',
        value: function _handle_server_cut_text() {
            Log.Debug("ServerCutText");

            if (this._sock.rQwait("ServerCutText header", 7, 1)) {
                return false;
            }

            this._sock.rQskipBytes(3); // Padding

            var length = this._sock.rQshift32();
            length = (0, _int.toSigned32bit)(length);

            if (this._sock.rQwait("ServerCutText content", Math.abs(length), 8)) {
                return false;
            }

            if (length >= 0) {
                //Standard msg
                var text = this._sock.rQshiftStr(length);
                if (this._viewOnly) {
                    return true;
                }

                this.dispatchEvent(new CustomEvent("clipboard", { detail: { text: text } }));
            } else {
                //Extended msg.
                length = Math.abs(length);
                var flags = this._sock.rQshift32();
                var formats = flags & 0x0000FFFF;
                var actions = flags & 0xFF000000;

                var isCaps = !!(actions & extendedClipboardActionCaps);
                if (isCaps) {
                    this._clipboardServerCapabilitiesFormats = {};
                    this._clipboardServerCapabilitiesActions = {};

                    // Update our server capabilities for Formats
                    for (var i = 0; i <= 15; i++) {
                        var index = 1 << i;

                        // Check if format flag is set.
                        if (formats & index) {
                            this._clipboardServerCapabilitiesFormats[index] = true;
                            // We don't send unsolicited clipboard, so we
                            // ignore the size
                            this._sock.rQshift32();
                        }
                    }

                    // Update our server capabilities for Actions
                    for (var _i = 24; _i <= 31; _i++) {
                        var _index = 1 << _i;
                        this._clipboardServerCapabilitiesActions[_index] = !!(actions & _index);
                    }

                    /*  Caps handling done, send caps with the clients
                        capabilities set as a response */
                    var clientActions = [extendedClipboardActionCaps, extendedClipboardActionRequest, extendedClipboardActionPeek, extendedClipboardActionNotify, extendedClipboardActionProvide];
                    RFB.messages.extendedClipboardCaps(this._sock, clientActions, { extendedClipboardFormatText: 0 });
                } else if (actions === extendedClipboardActionRequest) {
                    if (this._viewOnly) {
                        return true;
                    }

                    // Check if server has told us it can handle Provide and there is clipboard data to send.
                    if (this._clipboardText != null && this._clipboardServerCapabilitiesActions[extendedClipboardActionProvide]) {

                        if (formats & extendedClipboardFormatText) {
                            RFB.messages.extendedClipboardProvide(this._sock, [extendedClipboardFormatText], [this._clipboardText]);
                        }
                    }
                } else if (actions === extendedClipboardActionPeek) {
                    if (this._viewOnly) {
                        return true;
                    }

                    if (this._clipboardServerCapabilitiesActions[extendedClipboardActionNotify]) {

                        if (this._clipboardText != null) {
                            RFB.messages.extendedClipboardNotify(this._sock, [extendedClipboardFormatText]);
                        } else {
                            RFB.messages.extendedClipboardNotify(this._sock, []);
                        }
                    }
                } else if (actions === extendedClipboardActionNotify) {
                    if (this._viewOnly) {
                        return true;
                    }

                    if (this._clipboardServerCapabilitiesActions[extendedClipboardActionRequest]) {

                        if (formats & extendedClipboardFormatText) {
                            RFB.messages.extendedClipboardRequest(this._sock, [extendedClipboardFormatText]);
                        }
                    }
                } else if (actions === extendedClipboardActionProvide) {
                    if (this._viewOnly) {
                        return true;
                    }

                    if (!(formats & extendedClipboardFormatText)) {
                        return true;
                    }
                    // Ignore what we had in our clipboard client side.
                    this._clipboardText = null;

                    // FIXME: Should probably verify that this data was actually requested
                    var zlibStream = this._sock.rQshiftBytes(length - 4);
                    var streamInflator = new _inflator2.default();
                    var textData = null;

                    streamInflator.setInput(zlibStream);
                    for (var _i2 = 0; _i2 <= 15; _i2++) {
                        var format = 1 << _i2;

                        if (formats & format) {

                            var size = 0x00;
                            var sizeArray = streamInflator.inflate(4);

                            size |= sizeArray[0] << 24;
                            size |= sizeArray[1] << 16;
                            size |= sizeArray[2] << 8;
                            size |= sizeArray[3];
                            var chunk = streamInflator.inflate(size);

                            if (format === extendedClipboardFormatText) {
                                textData = chunk;
                            }
                        }
                    }
                    streamInflator.setInput(null);

                    if (textData !== null) {
                        var tmpText = "";
                        for (var _i3 = 0; _i3 < textData.length; _i3++) {
                            tmpText += String.fromCharCode(textData[_i3]);
                        }
                        textData = tmpText;

                        textData = (0, _strings.decodeUTF8)(textData);
                        if (textData.length > 0 && "\0" === textData.charAt(textData.length - 1)) {
                            textData = textData.slice(0, -1);
                        }

                        textData = textData.replace("\r\n", "\n");

                        this.dispatchEvent(new CustomEvent("clipboard", { detail: { text: textData } }));
                    }
                } else {
                    return this._fail("Unexpected action in extended clipboard message: " + actions);
                }
            }
            return true;
        }
    }, {
        key: '_handle_server_fence_msg',
        value: function _handle_server_fence_msg() {
            if (this._sock.rQwait("ServerFence header", 8, 1)) {
                return false;
            }
            this._sock.rQskipBytes(3); // Padding
            var flags = this._sock.rQshift32();
            var length = this._sock.rQshift8();

            if (this._sock.rQwait("ServerFence payload", length, 9)) {
                return false;
            }

            if (length > 64) {
                Log.Warn("Bad payload length (" + length + ") in fence response");
                length = 64;
            }

            var payload = this._sock.rQshiftStr(length);

            this._supportsFence = true;

            /*
             * Fence flags
             *
             *  (1<<0)  - BlockBefore
             *  (1<<1)  - BlockAfter
             *  (1<<2)  - SyncNext
             *  (1<<31) - Request
             */

            if (!(flags & 1 << 31)) {
                return this._fail("Unexpected fence response");
            }

            // Filter out unsupported flags
            // FIXME: support syncNext
            flags &= 1 << 0 | 1 << 1;

            // BlockBefore and BlockAfter are automatically handled by
            // the fact that we process each incoming message
            // synchronuosly.
            RFB.messages.clientFence(this._sock, flags, payload);

            return true;
        }
    }, {
        key: '_handle_xvp_msg',
        value: function _handle_xvp_msg() {
            if (this._sock.rQwait("XVP version and message", 3, 1)) {
                return false;
            }
            this._sock.rQskipBytes(1); // Padding
            var xvp_ver = this._sock.rQshift8();
            var xvp_msg = this._sock.rQshift8();

            switch (xvp_msg) {
                case 0:
                    // XVP_FAIL
                    Log.Error("XVP Operation Failed");
                    break;
                case 1:
                    // XVP_INIT
                    this._rfb_xvp_ver = xvp_ver;
                    Log.Info("XVP extensions enabled (version " + this._rfb_xvp_ver + ")");
                    this._setCapability("power", true);
                    break;
                default:
                    this._fail("Illegal server XVP message (msg: " + xvp_msg + ")");
                    break;
            }

            return true;
        }
    }, {
        key: '_normal_msg',
        value: function _normal_msg() {
            var msg_type = void 0;
            if (this._FBU.rects > 0) {
                msg_type = 0;
            } else {
                msg_type = this._sock.rQshift8();
            }

            var first = void 0,
                ret = void 0;
            switch (msg_type) {
                case 0:
                    // FramebufferUpdate
                    ret = this._framebufferUpdate();
                    if (ret && !this._enabledContinuousUpdates) {
                        RFB.messages.fbUpdateRequest(this._sock, true, 0, 0, this._fb_width, this._fb_height);
                    }
                    return ret;

                case 1:
                    // SetColorMapEntries
                    return this._handle_set_colour_map_msg();

                case 2:
                    // Bell
                    Log.Debug("Bell");
                    this.dispatchEvent(new CustomEvent("bell", { detail: {} }));
                    return true;

                case 3:
                    // ServerCutText
                    return this._handle_server_cut_text();

                case 150:
                    // EndOfContinuousUpdates
                    first = !this._supportsContinuousUpdates;
                    this._supportsContinuousUpdates = true;
                    this._enabledContinuousUpdates = false;
                    if (first) {
                        this._enabledContinuousUpdates = true;
                        this._updateContinuousUpdates();
                        Log.Info("Enabling continuous updates.");
                    } else {
                        // FIXME: We need to send a framebufferupdaterequest here
                        // if we add support for turning off continuous updates
                    }
                    return true;

                case 248:
                    // ServerFence
                    return this._handle_server_fence_msg();

                case 250:
                    // XVP
                    return this._handle_xvp_msg();

                default:
                    this._fail("Unexpected server message (type " + msg_type + ")");
                    Log.Debug("sock.rQslice(0, 30): " + this._sock.rQslice(0, 30));
                    return true;
            }
        }
    }, {
        key: '_onFlush',
        value: function _onFlush() {
            this._flushing = false;
            // Resume processing
            if (this._sock.rQlen > 0) {
                this._handle_message();
            }
        }
    }, {
        key: '_framebufferUpdate',
        value: function _framebufferUpdate() {
            if (this._FBU.rects === 0) {
                if (this._sock.rQwait("FBU header", 3, 1)) {
                    return false;
                }
                this._sock.rQskipBytes(1); // Padding
                this._FBU.rects = this._sock.rQshift16();

                // Make sure the previous frame is fully rendered first
                // to avoid building up an excessive queue
                if (this._display.pending()) {
                    this._flushing = true;
                    this._display.flush();
                    return false;
                }
            }

            while (this._FBU.rects > 0) {
                if (this._FBU.encoding === null) {
                    if (this._sock.rQwait("rect header", 12)) {
                        return false;
                    }
                    /* New FramebufferUpdate */

                    var hdr = this._sock.rQshiftBytes(12);
                    this._FBU.x = (hdr[0] << 8) + hdr[1];
                    this._FBU.y = (hdr[2] << 8) + hdr[3];
                    this._FBU.width = (hdr[4] << 8) + hdr[5];
                    this._FBU.height = (hdr[6] << 8) + hdr[7];
                    this._FBU.encoding = parseInt((hdr[8] << 24) + (hdr[9] << 16) + (hdr[10] << 8) + hdr[11], 10);
                }

                if (!this._handleRect()) {
                    return false;
                }

                this._FBU.rects--;
                this._FBU.encoding = null;
            }

            this._display.flip();

            return true; // We finished this FBU
        }
    }, {
        key: '_handleRect',
        value: function _handleRect() {
            switch (this._FBU.encoding) {
                case _encodings.encodings.pseudoEncodingLastRect:
                    this._FBU.rects = 1; // Will be decreased when we return
                    return true;

                case _encodings.encodings.pseudoEncodingVMwareCursor:
                    return this._handleVMwareCursor();

                case _encodings.encodings.pseudoEncodingCursor:
                    return this._handleCursor();

                case _encodings.encodings.pseudoEncodingQEMUExtendedKeyEvent:
                    // Old Safari doesn't support creating keyboard events
                    try {
                        var keyboardEvent = document.createEvent("keyboardEvent");
                        if (keyboardEvent.code !== undefined) {
                            this._qemuExtKeyEventSupported = true;
                        }
                    } catch (err) {
                        // Do nothing
                    }
                    return true;

                case _encodings.encodings.pseudoEncodingDesktopName:
                    return this._handleDesktopName();

                case _encodings.encodings.pseudoEncodingDesktopSize:
                    this._resize(this._FBU.width, this._FBU.height);
                    return true;

                case _encodings.encodings.pseudoEncodingExtendedDesktopSize:
                    return this._handleExtendedDesktopSize();

                default:
                    return this._handleDataRect();
            }
        }
    }, {
        key: '_handleVMwareCursor',
        value: function _handleVMwareCursor() {
            var hotx = this._FBU.x; // hotspot-x
            var hoty = this._FBU.y; // hotspot-y
            var w = this._FBU.width;
            var h = this._FBU.height;
            if (this._sock.rQwait("VMware cursor encoding", 1)) {
                return false;
            }

            var cursor_type = this._sock.rQshift8();

            this._sock.rQshift8(); //Padding

            var rgba = void 0;
            var bytesPerPixel = 4;

            //Classic cursor
            if (cursor_type == 0) {
                //Used to filter away unimportant bits.
                //OR is used for correct conversion in js.
                var PIXEL_MASK = 0xffffff00 | 0;
                rgba = new Array(w * h * bytesPerPixel);

                if (this._sock.rQwait("VMware cursor classic encoding", w * h * bytesPerPixel * 2, 2)) {
                    return false;
                }

                var and_mask = new Array(w * h);
                for (var pixel = 0; pixel < w * h; pixel++) {
                    and_mask[pixel] = this._sock.rQshift32();
                }

                var xor_mask = new Array(w * h);
                for (var _pixel = 0; _pixel < w * h; _pixel++) {
                    xor_mask[_pixel] = this._sock.rQshift32();
                }

                for (var _pixel2 = 0; _pixel2 < w * h; _pixel2++) {
                    if (and_mask[_pixel2] == 0) {
                        //Fully opaque pixel
                        var bgr = xor_mask[_pixel2];
                        var r = bgr >> 8 & 0xff;
                        var g = bgr >> 16 & 0xff;
                        var b = bgr >> 24 & 0xff;

                        rgba[_pixel2 * bytesPerPixel] = r; //r
                        rgba[_pixel2 * bytesPerPixel + 1] = g; //g
                        rgba[_pixel2 * bytesPerPixel + 2] = b; //b
                        rgba[_pixel2 * bytesPerPixel + 3] = 0xff; //a
                    } else if ((and_mask[_pixel2] & PIXEL_MASK) == PIXEL_MASK) {
                        //Only screen value matters, no mouse colouring
                        if (xor_mask[_pixel2] == 0) {
                            //Transparent pixel
                            rgba[_pixel2 * bytesPerPixel] = 0x00;
                            rgba[_pixel2 * bytesPerPixel + 1] = 0x00;
                            rgba[_pixel2 * bytesPerPixel + 2] = 0x00;
                            rgba[_pixel2 * bytesPerPixel + 3] = 0x00;
                        } else if ((xor_mask[_pixel2] & PIXEL_MASK) == PIXEL_MASK) {
                            //Inverted pixel, not supported in browsers.
                            //Fully opaque instead.
                            rgba[_pixel2 * bytesPerPixel] = 0x00;
                            rgba[_pixel2 * bytesPerPixel + 1] = 0x00;
                            rgba[_pixel2 * bytesPerPixel + 2] = 0x00;
                            rgba[_pixel2 * bytesPerPixel + 3] = 0xff;
                        } else {
                            //Unhandled xor_mask
                            rgba[_pixel2 * bytesPerPixel] = 0x00;
                            rgba[_pixel2 * bytesPerPixel + 1] = 0x00;
                            rgba[_pixel2 * bytesPerPixel + 2] = 0x00;
                            rgba[_pixel2 * bytesPerPixel + 3] = 0xff;
                        }
                    } else {
                        //Unhandled and_mask
                        rgba[_pixel2 * bytesPerPixel] = 0x00;
                        rgba[_pixel2 * bytesPerPixel + 1] = 0x00;
                        rgba[_pixel2 * bytesPerPixel + 2] = 0x00;
                        rgba[_pixel2 * bytesPerPixel + 3] = 0xff;
                    }
                }

                //Alpha cursor.
            } else if (cursor_type == 1) {
                if (this._sock.rQwait("VMware cursor alpha encoding", w * h * 4, 2)) {
                    return false;
                }

                rgba = new Array(w * h * bytesPerPixel);

                for (var _pixel3 = 0; _pixel3 < w * h; _pixel3++) {
                    var data = this._sock.rQshift32();

                    rgba[_pixel3 * 4] = data >> 24 & 0xff; //r
                    rgba[_pixel3 * 4 + 1] = data >> 16 & 0xff; //g
                    rgba[_pixel3 * 4 + 2] = data >> 8 & 0xff; //b
                    rgba[_pixel3 * 4 + 3] = data & 0xff; //a
                }
            } else {
                Log.Warn("The given cursor type is not supported: " + cursor_type + " given.");
                return false;
            }

            this._updateCursor(rgba, hotx, hoty, w, h);

            return true;
        }
    }, {
        key: '_handleCursor',
        value: function _handleCursor() {
            var hotx = this._FBU.x; // hotspot-x
            var hoty = this._FBU.y; // hotspot-y
            var w = this._FBU.width;
            var h = this._FBU.height;

            var pixelslength = w * h * 4;
            var masklength = Math.ceil(w / 8) * h;

            var bytes = pixelslength + masklength;
            if (this._sock.rQwait("cursor encoding", bytes)) {
                return false;
            }

            // Decode from BGRX pixels + bit mask to RGBA
            var pixels = this._sock.rQshiftBytes(pixelslength);
            var mask = this._sock.rQshiftBytes(masklength);
            var rgba = new Uint8Array(w * h * 4);

            var pix_idx = 0;
            for (var y = 0; y < h; y++) {
                for (var x = 0; x < w; x++) {
                    var mask_idx = y * Math.ceil(w / 8) + Math.floor(x / 8);
                    var alpha = mask[mask_idx] << x % 8 & 0x80 ? 255 : 0;
                    rgba[pix_idx] = pixels[pix_idx + 2];
                    rgba[pix_idx + 1] = pixels[pix_idx + 1];
                    rgba[pix_idx + 2] = pixels[pix_idx];
                    rgba[pix_idx + 3] = alpha;
                    pix_idx += 4;
                }
            }

            this._updateCursor(rgba, hotx, hoty, w, h);

            return true;
        }
    }, {
        key: '_handleDesktopName',
        value: function _handleDesktopName() {
            if (this._sock.rQwait("DesktopName", 4)) {
                return false;
            }

            var length = this._sock.rQshift32();

            if (this._sock.rQwait("DesktopName", length, 4)) {
                return false;
            }

            var name = this._sock.rQshiftStr(length);
            name = (0, _strings.decodeUTF8)(name, true);

            this._setDesktopName(name);

            return true;
        }
    }, {
        key: '_handleExtendedDesktopSize',
        value: function _handleExtendedDesktopSize() {
            if (this._sock.rQwait("ExtendedDesktopSize", 4)) {
                return false;
            }

            var number_of_screens = this._sock.rQpeek8();

            var bytes = 4 + number_of_screens * 16;
            if (this._sock.rQwait("ExtendedDesktopSize", bytes)) {
                return false;
            }

            var firstUpdate = !this._supportsSetDesktopSize;
            this._supportsSetDesktopSize = true;

            // Normally we only apply the current resize mode after a
            // window resize event. However there is no such trigger on the
            // initial connect. And we don't know if the server supports
            // resizing until we've gotten here.
            if (firstUpdate) {
                this._requestRemoteResize();
            }

            this._sock.rQskipBytes(1); // number-of-screens
            this._sock.rQskipBytes(3); // padding

            for (var i = 0; i < number_of_screens; i += 1) {
                // Save the id and flags of the first screen
                if (i === 0) {
                    this._screen_id = this._sock.rQshiftBytes(4); // id
                    this._sock.rQskipBytes(2); // x-position
                    this._sock.rQskipBytes(2); // y-position
                    this._sock.rQskipBytes(2); // width
                    this._sock.rQskipBytes(2); // height
                    this._screen_flags = this._sock.rQshiftBytes(4); // flags
                } else {
                    this._sock.rQskipBytes(16);
                }
            }

            /*
             * The x-position indicates the reason for the change:
             *
             *  0 - server resized on its own
             *  1 - this client requested the resize
             *  2 - another client requested the resize
             */

            // We need to handle errors when we requested the resize.
            if (this._FBU.x === 1 && this._FBU.y !== 0) {
                var msg = "";
                // The y-position indicates the status code from the server
                switch (this._FBU.y) {
                    case 1:
                        msg = "Resize is administratively prohibited";
                        break;
                    case 2:
                        msg = "Out of resources";
                        break;
                    case 3:
                        msg = "Invalid screen layout";
                        break;
                    default:
                        msg = "Unknown reason";
                        break;
                }
                Log.Warn("Server did not accept the resize request: " + msg);
            } else {
                this._resize(this._FBU.width, this._FBU.height);
            }

            return true;
        }
    }, {
        key: '_handleDataRect',
        value: function _handleDataRect() {
            var decoder = this._decoders[this._FBU.encoding];
            if (!decoder) {
                this._fail("Unsupported encoding (encoding: " + this._FBU.encoding + ")");
                return false;
            }

            try {
                return decoder.decodeRect(this._FBU.x, this._FBU.y, this._FBU.width, this._FBU.height, this._sock, this._display, this._fb_depth);
            } catch (err) {
                this._fail("Error decoding rect: " + err);
                return false;
            }
        }
    }, {
        key: '_updateContinuousUpdates',
        value: function _updateContinuousUpdates() {
            if (!this._enabledContinuousUpdates) {
                return;
            }

            RFB.messages.enableContinuousUpdates(this._sock, true, 0, 0, this._fb_width, this._fb_height);
        }
    }, {
        key: '_resize',
        value: function _resize(width, height) {
            this._fb_width = width;
            this._fb_height = height;

            this._display.resize(this._fb_width, this._fb_height);

            // Adjust the visible viewport based on the new dimensions
            this._updateClip();
            this._updateScale();

            this._updateContinuousUpdates();
        }
    }, {
        key: '_xvpOp',
        value: function _xvpOp(ver, op) {
            if (this._rfb_xvp_ver < ver) {
                return;
            }
            Log.Info("Sending XVP operation " + op + " (version " + ver + ")");
            RFB.messages.xvpOp(this._sock, ver, op);
        }
    }, {
        key: '_updateCursor',
        value: function _updateCursor(rgba, hotx, hoty, w, h) {
            this._cursorImage = {
                rgbaPixels: rgba,
                hotx: hotx, hoty: hoty, w: w, h: h
            };
            this._refreshCursor();
        }
    }, {
        key: '_shouldShowDotCursor',
        value: function _shouldShowDotCursor() {
            // Called when this._cursorImage is updated
            if (!this._showDotCursor) {
                // User does not want to see the dot, so...
                return false;
            }

            // The dot should not be shown if the cursor is already visible,
            // i.e. contains at least one not-fully-transparent pixel.
            // So iterate through all alpha bytes in rgba and stop at the
            // first non-zero.
            for (var i = 3; i < this._cursorImage.rgbaPixels.length; i += 4) {
                if (this._cursorImage.rgbaPixels[i]) {
                    return false;
                }
            }

            // At this point, we know that the cursor is fully transparent, and
            // the user wants to see the dot instead of this.
            return true;
        }
    }, {
        key: '_refreshCursor',
        value: function _refreshCursor() {
            if (this._rfb_connection_state !== "connecting" && this._rfb_connection_state !== "connected") {
                return;
            }
            var image = this._shouldShowDotCursor() ? RFB.cursors.dot : this._cursorImage;
            this._cursor.change(image.rgbaPixels, image.hotx, image.hoty, image.w, image.h);
        }
    }, {
        key: 'viewOnly',
        get: function get() {
            return this._viewOnly;
        },
        set: function set(viewOnly) {
            this._viewOnly = viewOnly;

            if (this._rfb_connection_state === "connecting" || this._rfb_connection_state === "connected") {
                if (viewOnly) {
                    this._keyboard.ungrab();
                    this._mouse.ungrab();
                } else {
                    this._keyboard.grab();
                    this._mouse.grab();
                }
            }
        }
    }, {
        key: 'capabilities',
        get: function get() {
            return this._capabilities;
        }
    }, {
        key: 'touchButton',
        get: function get() {
            return this._mouse.touchButton;
        },
        set: function set(button) {
            this._mouse.touchButton = button;
        }
    }, {
        key: 'clipViewport',
        get: function get() {
            return this._clipViewport;
        },
        set: function set(viewport) {
            this._clipViewport = viewport;
            this._updateClip();
        }
    }, {
        key: 'scaleViewport',
        get: function get() {
            return this._scaleViewport;
        },
        set: function set(scale) {
            this._scaleViewport = scale;
            // Scaling trumps clipping, so we may need to adjust
            // clipping when enabling or disabling scaling
            if (scale && this._clipViewport) {
                this._updateClip();
            }
            this._updateScale();
            if (!scale && this._clipViewport) {
                this._updateClip();
            }
        }
    }, {
        key: 'resizeSession',
        get: function get() {
            return this._resizeSession;
        },
        set: function set(resize) {
            this._resizeSession = resize;
            if (resize) {
                this._requestRemoteResize();
            }
        }
    }, {
        key: 'showDotCursor',
        get: function get() {
            return this._showDotCursor;
        },
        set: function set(show) {
            this._showDotCursor = show;
            this._refreshCursor();
        }
    }, {
        key: 'background',
        get: function get() {
            return this._screen.style.background;
        },
        set: function set(cssValue) {
            this._screen.style.background = cssValue;
        }
    }], [{
        key: 'genDES',
        value: function genDES(password, challenge) {
            var passwordChars = password.split('').map(function (c) {
                return c.charCodeAt(0);
            });
            return new _des2.default(passwordChars).encrypt(challenge);
        }
    }]);

    return RFB;
}(_eventtarget2.default);

// Class Methods


exports.default = RFB;
RFB.messages = {
    keyEvent: function keyEvent(sock, keysym, down) {
        var buff = sock._sQ;
        var offset = sock._sQlen;

        buff[offset] = 4; // msg-type
        buff[offset + 1] = down;

        buff[offset + 2] = 0;
        buff[offset + 3] = 0;

        buff[offset + 4] = keysym >> 24;
        buff[offset + 5] = keysym >> 16;
        buff[offset + 6] = keysym >> 8;
        buff[offset + 7] = keysym;

        sock._sQlen += 8;
        sock.flush();
    },
    QEMUExtendedKeyEvent: function QEMUExtendedKeyEvent(sock, keysym, down, keycode) {
        function getRFBkeycode(xt_scancode) {
            var upperByte = keycode >> 8;
            var lowerByte = keycode & 0x00ff;
            if (upperByte === 0xe0 && lowerByte < 0x7f) {
                return lowerByte | 0x80;
            }
            return xt_scancode;
        }

        var buff = sock._sQ;
        var offset = sock._sQlen;

        buff[offset] = 255; // msg-type
        buff[offset + 1] = 0; // sub msg-type

        buff[offset + 2] = down >> 8;
        buff[offset + 3] = down;

        buff[offset + 4] = keysym >> 24;
        buff[offset + 5] = keysym >> 16;
        buff[offset + 6] = keysym >> 8;
        buff[offset + 7] = keysym;

        var RFBkeycode = getRFBkeycode(keycode);

        buff[offset + 8] = RFBkeycode >> 24;
        buff[offset + 9] = RFBkeycode >> 16;
        buff[offset + 10] = RFBkeycode >> 8;
        buff[offset + 11] = RFBkeycode;

        sock._sQlen += 12;
        sock.flush();
    },
    pointerEvent: function pointerEvent(sock, x, y, mask) {
        var buff = sock._sQ;
        var offset = sock._sQlen;

        buff[offset] = 5; // msg-type

        buff[offset + 1] = mask;

        buff[offset + 2] = x >> 8;
        buff[offset + 3] = x;

        buff[offset + 4] = y >> 8;
        buff[offset + 5] = y;

        sock._sQlen += 6;
        sock.flush();
    },


    // Used to build Notify and Request data.
    _buildExtendedClipboardFlags: function _buildExtendedClipboardFlags(actions, formats) {
        var data = new Uint8Array(4);
        var formatFlag = 0x00000000;
        var actionFlag = 0x00000000;

        for (var i = 0; i < actions.length; i++) {
            actionFlag |= actions[i];
        }

        for (var _i4 = 0; _i4 < formats.length; _i4++) {
            formatFlag |= formats[_i4];
        }

        data[0] = actionFlag >> 24; // Actions
        data[1] = 0x00; // Reserved
        data[2] = 0x00; // Reserved
        data[3] = formatFlag; // Formats

        return data;
    },
    extendedClipboardProvide: function extendedClipboardProvide(sock, formats, inData) {
        // Deflate incomming data and their sizes
        var deflator = new _deflator2.default();
        var dataToDeflate = [];

        for (var i = 0; i < formats.length; i++) {
            // We only support the format Text at this time
            if (formats[i] != extendedClipboardFormatText) {
                throw new Error("Unsupported extended clipboard format for Provide message.");
            }

            // Change lone \r or \n into \r\n as defined in rfbproto
            inData[i] = inData[i].replace(/\r\n|\r|\n/gm, "\r\n");

            // Check if it already has \0
            var text = (0, _strings.encodeUTF8)(inData[i] + "\0");

            dataToDeflate.push(text.length >> 24 & 0xFF, text.length >> 16 & 0xFF, text.length >> 8 & 0xFF, text.length & 0xFF);

            for (var j = 0; j < text.length; j++) {
                dataToDeflate.push(text.charCodeAt(j));
            }
        }

        var deflatedData = deflator.deflate(new Uint8Array(dataToDeflate));

        // Build data  to send
        var data = new Uint8Array(4 + deflatedData.length);
        data.set(RFB.messages._buildExtendedClipboardFlags([extendedClipboardActionProvide], formats));
        data.set(deflatedData, 4);

        RFB.messages.clientCutText(sock, data, true);
    },
    extendedClipboardNotify: function extendedClipboardNotify(sock, formats) {
        var flags = RFB.messages._buildExtendedClipboardFlags([extendedClipboardActionNotify], formats);
        RFB.messages.clientCutText(sock, flags, true);
    },
    extendedClipboardRequest: function extendedClipboardRequest(sock, formats) {
        var flags = RFB.messages._buildExtendedClipboardFlags([extendedClipboardActionRequest], formats);
        RFB.messages.clientCutText(sock, flags, true);
    },
    extendedClipboardCaps: function extendedClipboardCaps(sock, actions, formats) {
        var formatKeys = Object.keys(formats);
        var data = new Uint8Array(4 + 4 * formatKeys.length);

        formatKeys.map(function (x) {
            return parseInt(x);
        });
        formatKeys.sort(function (a, b) {
            return a - b;
        });

        data.set(RFB.messages._buildExtendedClipboardFlags(actions, []));

        var loopOffset = 4;
        for (var i = 0; i < formatKeys.length; i++) {
            data[loopOffset] = formats[formatKeys[i]] >> 24;
            data[loopOffset + 1] = formats[formatKeys[i]] >> 16;
            data[loopOffset + 2] = formats[formatKeys[i]] >> 8;
            data[loopOffset + 3] = formats[formatKeys[i]] >> 0;

            loopOffset += 4;
            data[3] |= 1 << formatKeys[i]; // Update our format flags
        }

        RFB.messages.clientCutText(sock, data, true);
    },
    clientCutText: function clientCutText(sock, data) {
        var extended = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : false;

        var buff = sock._sQ;
        var offset = sock._sQlen;

        buff[offset] = 6; // msg-type

        buff[offset + 1] = 0; // padding
        buff[offset + 2] = 0; // padding
        buff[offset + 3] = 0; // padding

        var length = void 0;
        if (extended) {
            length = (0, _int.toUnsigned32bit)(-data.length);
        } else {
            length = data.length;
        }

        buff[offset + 4] = length >> 24;
        buff[offset + 5] = length >> 16;
        buff[offset + 6] = length >> 8;
        buff[offset + 7] = length;

        sock._sQlen += 8;

        // We have to keep track of from where in the data we begin creating the
        // buffer for the flush in the next iteration.
        var dataOffset = 0;

        var remaining = data.length;
        while (remaining > 0) {

            var flushSize = Math.min(remaining, sock._sQbufferSize - sock._sQlen);
            for (var i = 0; i < flushSize; i++) {
                buff[sock._sQlen + i] = data[dataOffset + i];
            }

            sock._sQlen += flushSize;
            sock.flush();

            remaining -= flushSize;
            dataOffset += flushSize;
        }
    },
    setDesktopSize: function setDesktopSize(sock, width, height, id, flags) {
        var buff = sock._sQ;
        var offset = sock._sQlen;

        buff[offset] = 251; // msg-type
        buff[offset + 1] = 0; // padding
        buff[offset + 2] = width >> 8; // width
        buff[offset + 3] = width;
        buff[offset + 4] = height >> 8; // height
        buff[offset + 5] = height;

        buff[offset + 6] = 1; // number-of-screens
        buff[offset + 7] = 0; // padding

        // screen array
        buff[offset + 8] = id >> 24; // id
        buff[offset + 9] = id >> 16;
        buff[offset + 10] = id >> 8;
        buff[offset + 11] = id;
        buff[offset + 12] = 0; // x-position
        buff[offset + 13] = 0;
        buff[offset + 14] = 0; // y-position
        buff[offset + 15] = 0;
        buff[offset + 16] = width >> 8; // width
        buff[offset + 17] = width;
        buff[offset + 18] = height >> 8; // height
        buff[offset + 19] = height;
        buff[offset + 20] = flags >> 24; // flags
        buff[offset + 21] = flags >> 16;
        buff[offset + 22] = flags >> 8;
        buff[offset + 23] = flags;

        sock._sQlen += 24;
        sock.flush();
    },
    clientFence: function clientFence(sock, flags, payload) {
        var buff = sock._sQ;
        var offset = sock._sQlen;

        buff[offset] = 248; // msg-type

        buff[offset + 1] = 0; // padding
        buff[offset + 2] = 0; // padding
        buff[offset + 3] = 0; // padding

        buff[offset + 4] = flags >> 24; // flags
        buff[offset + 5] = flags >> 16;
        buff[offset + 6] = flags >> 8;
        buff[offset + 7] = flags;

        var n = payload.length;

        buff[offset + 8] = n; // length

        for (var i = 0; i < n; i++) {
            buff[offset + 9 + i] = payload.charCodeAt(i);
        }

        sock._sQlen += 9 + n;
        sock.flush();
    },
    enableContinuousUpdates: function enableContinuousUpdates(sock, enable, x, y, width, height) {
        var buff = sock._sQ;
        var offset = sock._sQlen;

        buff[offset] = 150; // msg-type
        buff[offset + 1] = enable; // enable-flag

        buff[offset + 2] = x >> 8; // x
        buff[offset + 3] = x;
        buff[offset + 4] = y >> 8; // y
        buff[offset + 5] = y;
        buff[offset + 6] = width >> 8; // width
        buff[offset + 7] = width;
        buff[offset + 8] = height >> 8; // height
        buff[offset + 9] = height;

        sock._sQlen += 10;
        sock.flush();
    },
    pixelFormat: function pixelFormat(sock, depth, true_color) {
        var buff = sock._sQ;
        var offset = sock._sQlen;

        var bpp = void 0;

        if (depth > 16) {
            bpp = 32;
        } else if (depth > 8) {
            bpp = 16;
        } else {
            bpp = 8;
        }

        var bits = Math.floor(depth / 3);

        buff[offset] = 0; // msg-type

        buff[offset + 1] = 0; // padding
        buff[offset + 2] = 0; // padding
        buff[offset + 3] = 0; // padding

        buff[offset + 4] = bpp; // bits-per-pixel
        buff[offset + 5] = depth; // depth
        buff[offset + 6] = 0; // little-endian
        buff[offset + 7] = true_color ? 1 : 0; // true-color

        buff[offset + 8] = 0; // red-max
        buff[offset + 9] = (1 << bits) - 1; // red-max

        buff[offset + 10] = 0; // green-max
        buff[offset + 11] = (1 << bits) - 1; // green-max

        buff[offset + 12] = 0; // blue-max
        buff[offset + 13] = (1 << bits) - 1; // blue-max

        buff[offset + 14] = bits * 2; // red-shift
        buff[offset + 15] = bits * 1; // green-shift
        buff[offset + 16] = bits * 0; // blue-shift

        buff[offset + 17] = 0; // padding
        buff[offset + 18] = 0; // padding
        buff[offset + 19] = 0; // padding

        sock._sQlen += 20;
        sock.flush();
    },
    clientEncodings: function clientEncodings(sock, encodings) {
        var buff = sock._sQ;
        var offset = sock._sQlen;

        buff[offset] = 2; // msg-type
        buff[offset + 1] = 0; // padding

        buff[offset + 2] = encodings.length >> 8;
        buff[offset + 3] = encodings.length;

        var j = offset + 4;
        for (var i = 0; i < encodings.length; i++) {
            var enc = encodings[i];
            buff[j] = enc >> 24;
            buff[j + 1] = enc >> 16;
            buff[j + 2] = enc >> 8;
            buff[j + 3] = enc;

            j += 4;
        }

        sock._sQlen += j - offset;
        sock.flush();
    },
    fbUpdateRequest: function fbUpdateRequest(sock, incremental, x, y, w, h) {
        var buff = sock._sQ;
        var offset = sock._sQlen;

        if (typeof x === "undefined") {
            x = 0;
        }
        if (typeof y === "undefined") {
            y = 0;
        }

        buff[offset] = 3; // msg-type
        buff[offset + 1] = incremental ? 1 : 0;

        buff[offset + 2] = x >> 8 & 0xFF;
        buff[offset + 3] = x & 0xFF;

        buff[offset + 4] = y >> 8 & 0xFF;
        buff[offset + 5] = y & 0xFF;

        buff[offset + 6] = w >> 8 & 0xFF;
        buff[offset + 7] = w & 0xFF;

        buff[offset + 8] = h >> 8 & 0xFF;
        buff[offset + 9] = h & 0xFF;

        sock._sQlen += 10;
        sock.flush();
    },
    xvpOp: function xvpOp(sock, ver, op) {
        var buff = sock._sQ;
        var offset = sock._sQlen;

        buff[offset] = 250; // msg-type
        buff[offset + 1] = 0; // padding

        buff[offset + 2] = ver;
        buff[offset + 3] = op;

        sock._sQlen += 4;
        sock.flush();
    }
};

RFB.cursors = {
    none: {
        rgbaPixels: new Uint8Array(),
        w: 0, h: 0,
        hotx: 0, hoty: 0
    },

    dot: {
        /* eslint-disable indent */
        rgbaPixels: new Uint8Array([255, 255, 255, 255, 0, 0, 0, 255, 255, 255, 255, 255, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 0, 0, 0, 255, 255, 255, 255, 255]),
        /* eslint-enable indent */
        w: 3, h: 3,
        hotx: 1, hoty: 1
    }
};
},{"./decoders/copyrect.js":5,"./decoders/hextile.js":6,"./decoders/raw.js":7,"./decoders/rre.js":8,"./decoders/tight.js":9,"./decoders/tightpng.js":10,"./deflator.js":11,"./des.js":12,"./display.js":13,"./encodings.js":14,"./inflator.js":15,"./input/keyboard.js":18,"./input/keysym.js":19,"./input/mouse.js":21,"./input/xtscancodes.js":24,"./util/browser.js":26,"./util/cursor.js":27,"./util/eventtarget.js":29,"./util/int.js":30,"./util/logging.js":31,"./util/polyfill.js":32,"./util/strings.js":33,"./websock.js":34}],26:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.hasScrollbarGutter = exports.supportsImageMetadata = exports.supportsCursorURIs = exports.dragThreshold = exports.isTouchDevice = undefined;
exports.isMac = isMac;
exports.isWindows = isWindows;
exports.isIOS = isIOS;
exports.isSafari = isSafari;
exports.isIE = isIE;
exports.isEdge = isEdge;
exports.isFirefox = isFirefox;

var _logging = require('./logging.js');

var Log = _interopRequireWildcard(_logging);

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

// Touch detection
var isTouchDevice = exports.isTouchDevice = 'ontouchstart' in document.documentElement ||
// requried for Chrome debugger
document.ontouchstart !== undefined ||
// required for MS Surface
navigator.maxTouchPoints > 0 || navigator.msMaxTouchPoints > 0; /*
                                                                 * noVNC: HTML5 VNC client
                                                                 * Copyright (C) 2019 The noVNC Authors
                                                                 * Licensed under MPL 2.0 (see LICENSE.txt)
                                                                 *
                                                                 * See README.md for usage and integration instructions.
                                                                 *
                                                                 * Browser feature support detection
                                                                 */

window.addEventListener('touchstart', function onFirstTouch() {
    exports.isTouchDevice = isTouchDevice = true;
    window.removeEventListener('touchstart', onFirstTouch, false);
}, false);

// The goal is to find a certain physical width, the devicePixelRatio
// brings us a bit closer but is not optimal.
var dragThreshold = exports.dragThreshold = 10 * (window.devicePixelRatio || 1);

var _supportsCursorURIs = false;

try {
    var target = document.createElement('canvas');
    target.style.cursor = 'url("data:image/x-icon;base64,AAACAAEACAgAAAIAAgA4AQAAFgAAACgAAAAIAAAAEAAAAAEAIAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAD/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAAAAAAAAAAAAAAAAAAAA==") 2 2, default';

    if (target.style.cursor.indexOf("url") === 0) {
        Log.Info("Data URI scheme cursor supported");
        _supportsCursorURIs = true;
    } else {
        Log.Warn("Data URI scheme cursor not supported");
    }
} catch (exc) {
    Log.Error("Data URI scheme cursor test exception: " + exc);
}

var supportsCursorURIs = exports.supportsCursorURIs = _supportsCursorURIs;

var _supportsImageMetadata = false;
try {
    new ImageData(new Uint8ClampedArray(4), 1, 1);
    _supportsImageMetadata = true;
} catch (ex) {
    // ignore failure
}
var supportsImageMetadata = exports.supportsImageMetadata = _supportsImageMetadata;

var _hasScrollbarGutter = true;
try {
    // Create invisible container
    var container = document.createElement('div');
    container.style.visibility = 'hidden';
    container.style.overflow = 'scroll'; // forcing scrollbars
    document.body.appendChild(container);

    // Create a div and place it in the container
    var child = document.createElement('div');
    container.appendChild(child);

    // Calculate the difference between the container's full width
    // and the child's width - the difference is the scrollbars
    var scrollbarWidth = container.offsetWidth - child.offsetWidth;

    // Clean up
    container.parentNode.removeChild(container);

    _hasScrollbarGutter = scrollbarWidth != 0;
} catch (exc) {
    Log.Error("Scrollbar test exception: " + exc);
}
var hasScrollbarGutter = exports.hasScrollbarGutter = _hasScrollbarGutter;

/*
 * The functions for detection of platforms and browsers below are exported
 * but the use of these should be minimized as much as possible.
 *
 * It's better to use feature detection than platform detection.
 */

function isMac() {
    return navigator && !!/mac/i.exec(navigator.platform);
}

function isWindows() {
    return navigator && !!/win/i.exec(navigator.platform);
}

function isIOS() {
    return navigator && (!!/ipad/i.exec(navigator.platform) || !!/iphone/i.exec(navigator.platform) || !!/ipod/i.exec(navigator.platform));
}

function isSafari() {
    return navigator && navigator.userAgent.indexOf('Safari') !== -1 && navigator.userAgent.indexOf('Chrome') === -1;
}

function isIE() {
    return navigator && !!/trident/i.exec(navigator.userAgent);
}

function isEdge() {
    return navigator && !!/edge/i.exec(navigator.userAgent);
}

function isFirefox() {
    return navigator && !!/firefox/i.exec(navigator.userAgent);
}
},{"./logging.js":31}],27:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }(); /*
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * noVNC: HTML5 VNC client
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Copyright (C) 2019 The noVNC Authors
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Licensed under MPL 2.0 or any later version (see LICENSE.txt)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      */

var _browser = require('./browser.js');

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var useFallback = !_browser.supportsCursorURIs || _browser.isTouchDevice;

var Cursor = function () {
    function Cursor() {
        _classCallCheck(this, Cursor);

        this._target = null;

        this._canvas = document.createElement('canvas');

        if (useFallback) {
            this._canvas.style.position = 'fixed';
            this._canvas.style.zIndex = '65535';
            this._canvas.style.pointerEvents = 'none';
            // Can't use "display" because of Firefox bug #1445997
            this._canvas.style.visibility = 'hidden';
        }

        this._position = { x: 0, y: 0 };
        this._hotSpot = { x: 0, y: 0 };

        this._eventHandlers = {
            'mouseover': this._handleMouseOver.bind(this),
            'mouseleave': this._handleMouseLeave.bind(this),
            'mousemove': this._handleMouseMove.bind(this),
            'mouseup': this._handleMouseUp.bind(this),
            'touchstart': this._handleTouchStart.bind(this),
            'touchmove': this._handleTouchMove.bind(this),
            'touchend': this._handleTouchEnd.bind(this)
        };
    }

    _createClass(Cursor, [{
        key: 'attach',
        value: function attach(target) {
            if (this._target) {
                this.detach();
            }

            this._target = target;

            if (useFallback) {
                document.body.appendChild(this._canvas);

                // FIXME: These don't fire properly except for mouse
                ///       movement in IE. We want to also capture element
                //        movement, size changes, visibility, etc.
                var options = { capture: true, passive: true };
                this._target.addEventListener('mouseover', this._eventHandlers.mouseover, options);
                this._target.addEventListener('mouseleave', this._eventHandlers.mouseleave, options);
                this._target.addEventListener('mousemove', this._eventHandlers.mousemove, options);
                this._target.addEventListener('mouseup', this._eventHandlers.mouseup, options);

                // There is no "touchleave" so we monitor touchstart globally
                window.addEventListener('touchstart', this._eventHandlers.touchstart, options);
                this._target.addEventListener('touchmove', this._eventHandlers.touchmove, options);
                this._target.addEventListener('touchend', this._eventHandlers.touchend, options);
            }

            this.clear();
        }
    }, {
        key: 'detach',
        value: function detach() {
            if (!this._target) {
                return;
            }

            if (useFallback) {
                var options = { capture: true, passive: true };
                this._target.removeEventListener('mouseover', this._eventHandlers.mouseover, options);
                this._target.removeEventListener('mouseleave', this._eventHandlers.mouseleave, options);
                this._target.removeEventListener('mousemove', this._eventHandlers.mousemove, options);
                this._target.removeEventListener('mouseup', this._eventHandlers.mouseup, options);

                window.removeEventListener('touchstart', this._eventHandlers.touchstart, options);
                this._target.removeEventListener('touchmove', this._eventHandlers.touchmove, options);
                this._target.removeEventListener('touchend', this._eventHandlers.touchend, options);

                document.body.removeChild(this._canvas);
            }

            this._target = null;
        }
    }, {
        key: 'change',
        value: function change(rgba, hotx, hoty, w, h) {
            if (w === 0 || h === 0) {
                this.clear();
                return;
            }

            this._position.x = this._position.x + this._hotSpot.x - hotx;
            this._position.y = this._position.y + this._hotSpot.y - hoty;
            this._hotSpot.x = hotx;
            this._hotSpot.y = hoty;

            var ctx = this._canvas.getContext('2d');

            this._canvas.width = w;
            this._canvas.height = h;

            var img = void 0;
            try {
                // IE doesn't support this
                img = new ImageData(new Uint8ClampedArray(rgba), w, h);
            } catch (ex) {
                img = ctx.createImageData(w, h);
                img.data.set(new Uint8ClampedArray(rgba));
            }
            ctx.clearRect(0, 0, w, h);
            ctx.putImageData(img, 0, 0);

            if (useFallback) {
                this._updatePosition();
            } else {
                var url = this._canvas.toDataURL();
                this._target.style.cursor = 'url(' + url + ')' + hotx + ' ' + hoty + ', default';
            }
        }
    }, {
        key: 'clear',
        value: function clear() {
            this._target.style.cursor = 'none';
            this._canvas.width = 0;
            this._canvas.height = 0;
            this._position.x = this._position.x + this._hotSpot.x;
            this._position.y = this._position.y + this._hotSpot.y;
            this._hotSpot.x = 0;
            this._hotSpot.y = 0;
        }
    }, {
        key: '_handleMouseOver',
        value: function _handleMouseOver(event) {
            // This event could be because we're entering the target, or
            // moving around amongst its sub elements. Let the move handler
            // sort things out.
            this._handleMouseMove(event);
        }
    }, {
        key: '_handleMouseLeave',
        value: function _handleMouseLeave(event) {
            // Check if we should show the cursor on the element we are leaving to
            this._updateVisibility(event.relatedTarget);
        }
    }, {
        key: '_handleMouseMove',
        value: function _handleMouseMove(event) {
            this._updateVisibility(event.target);

            this._position.x = event.clientX - this._hotSpot.x;
            this._position.y = event.clientY - this._hotSpot.y;

            this._updatePosition();
        }
    }, {
        key: '_handleMouseUp',
        value: function _handleMouseUp(event) {
            var _this = this;

            // We might get this event because of a drag operation that
            // moved outside of the target. Check what's under the cursor
            // now and adjust visibility based on that.
            var target = document.elementFromPoint(event.clientX, event.clientY);
            this._updateVisibility(target);

            // Captures end with a mouseup but we can't know the event order of
            // mouseup vs releaseCapture.
            //
            // In the cases when releaseCapture comes first, the code above is
            // enough.
            //
            // In the cases when the mouseup comes first, we need wait for the
            // browser to flush all events and then check again if the cursor
            // should be visible.
            if (this._captureIsActive()) {
                window.setTimeout(function () {
                    // Refresh the target from elementFromPoint since queued events
                    // might have altered the DOM
                    target = document.elementFromPoint(event.clientX, event.clientY);
                    _this._updateVisibility(target);
                }, 0);
            }
        }
    }, {
        key: '_handleTouchStart',
        value: function _handleTouchStart(event) {
            // Just as for mouseover, we let the move handler deal with it
            this._handleTouchMove(event);
        }
    }, {
        key: '_handleTouchMove',
        value: function _handleTouchMove(event) {
            this._updateVisibility(event.target);

            this._position.x = event.changedTouches[0].clientX - this._hotSpot.x;
            this._position.y = event.changedTouches[0].clientY - this._hotSpot.y;

            this._updatePosition();
        }
    }, {
        key: '_handleTouchEnd',
        value: function _handleTouchEnd(event) {
            // Same principle as for mouseup
            var target = document.elementFromPoint(event.changedTouches[0].clientX, event.changedTouches[0].clientY);
            this._updateVisibility(target);
        }
    }, {
        key: '_showCursor',
        value: function _showCursor() {
            if (this._canvas.style.visibility === 'hidden') {
                this._canvas.style.visibility = '';
            }
        }
    }, {
        key: '_hideCursor',
        value: function _hideCursor() {
            if (this._canvas.style.visibility !== 'hidden') {
                this._canvas.style.visibility = 'hidden';
            }
        }

        // Should we currently display the cursor?
        // (i.e. are we over the target, or a child of the target without a
        // different cursor set)

    }, {
        key: '_shouldShowCursor',
        value: function _shouldShowCursor(target) {
            if (!target) {
                return false;
            }
            // Easy case
            if (target === this._target) {
                return true;
            }
            // Other part of the DOM?
            if (!this._target.contains(target)) {
                return false;
            }
            // Has the child its own cursor?
            // FIXME: How can we tell that a sub element has an
            //        explicit "cursor: none;"?
            if (window.getComputedStyle(target).cursor !== 'none') {
                return false;
            }
            return true;
        }
    }, {
        key: '_updateVisibility',
        value: function _updateVisibility(target) {
            // When the cursor target has capture we want to show the cursor.
            // So, if a capture is active - look at the captured element instead.
            if (this._captureIsActive()) {
                target = document.captureElement;
            }
            if (this._shouldShowCursor(target)) {
                this._showCursor();
            } else {
                this._hideCursor();
            }
        }
    }, {
        key: '_updatePosition',
        value: function _updatePosition() {
            this._canvas.style.left = this._position.x + "px";
            this._canvas.style.top = this._position.y + "px";
        }
    }, {
        key: '_captureIsActive',
        value: function _captureIsActive() {
            return document.captureElement && document.documentElement.contains(document.captureElement);
        }
    }]);

    return Cursor;
}();

exports.default = Cursor;
},{"./browser.js":26}],28:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.getPointerEvent = getPointerEvent;
exports.stopEvent = stopEvent;
exports.setCapture = setCapture;
exports.releaseCapture = releaseCapture;
/*
 * noVNC: HTML5 VNC client
 * Copyright (C) 2018 The noVNC Authors
 * Licensed under MPL 2.0 (see LICENSE.txt)
 *
 * See README.md for usage and integration instructions.
 */

/*
 * Cross-browser event and position routines
 */

function getPointerEvent(e) {
    return e.changedTouches ? e.changedTouches[0] : e.touches ? e.touches[0] : e;
}

function stopEvent(e) {
    e.stopPropagation();
    e.preventDefault();
}

// Emulate Element.setCapture() when not supported
var _captureRecursion = false;
var _elementForUnflushedEvents = null;
document.captureElement = null;
function _captureProxy(e) {
    // Recursion protection as we'll see our own event
    if (_captureRecursion) return;

    // Clone the event as we cannot dispatch an already dispatched event
    var newEv = new e.constructor(e.type, e);

    _captureRecursion = true;
    if (document.captureElement) {
        document.captureElement.dispatchEvent(newEv);
    } else {
        _elementForUnflushedEvents.dispatchEvent(newEv);
    }
    _captureRecursion = false;

    // Avoid double events
    e.stopPropagation();

    // Respect the wishes of the redirected event handlers
    if (newEv.defaultPrevented) {
        e.preventDefault();
    }

    // Implicitly release the capture on button release
    if (e.type === "mouseup") {
        releaseCapture();
    }
}

// Follow cursor style of target element
function _capturedElemChanged() {
    var proxyElem = document.getElementById("noVNC_mouse_capture_elem");
    proxyElem.style.cursor = window.getComputedStyle(document.captureElement).cursor;
}

var _captureObserver = new MutationObserver(_capturedElemChanged);

function setCapture(target) {
    if (target.setCapture) {

        target.setCapture();
        document.captureElement = target;

        // IE releases capture on 'click' events which might not trigger
        target.addEventListener('mouseup', releaseCapture);
    } else {
        // Release any existing capture in case this method is
        // called multiple times without coordination
        releaseCapture();

        var proxyElem = document.getElementById("noVNC_mouse_capture_elem");

        if (proxyElem === null) {
            proxyElem = document.createElement("div");
            proxyElem.id = "noVNC_mouse_capture_elem";
            proxyElem.style.position = "fixed";
            proxyElem.style.top = "0px";
            proxyElem.style.left = "0px";
            proxyElem.style.width = "100%";
            proxyElem.style.height = "100%";
            proxyElem.style.zIndex = 10000;
            proxyElem.style.display = "none";
            document.body.appendChild(proxyElem);

            // This is to make sure callers don't get confused by having
            // our blocking element as the target
            proxyElem.addEventListener('contextmenu', _captureProxy);

            proxyElem.addEventListener('mousemove', _captureProxy);
            proxyElem.addEventListener('mouseup', _captureProxy);
        }

        document.captureElement = target;

        // Track cursor and get initial cursor
        _captureObserver.observe(target, { attributes: true });
        _capturedElemChanged();

        proxyElem.style.display = "";

        // We listen to events on window in order to keep tracking if it
        // happens to leave the viewport
        window.addEventListener('mousemove', _captureProxy);
        window.addEventListener('mouseup', _captureProxy);
    }
}

function releaseCapture() {
    if (document.releaseCapture) {

        document.releaseCapture();
        document.captureElement = null;
    } else {
        if (!document.captureElement) {
            return;
        }

        // There might be events already queued. The event proxy needs
        // access to the captured element for these queued events.
        // E.g. contextmenu (right-click) in Microsoft Edge
        //
        // Before removing the capturedElem pointer we save it to a
        // temporary variable that the unflushed events can use.
        _elementForUnflushedEvents = document.captureElement;
        document.captureElement = null;

        _captureObserver.disconnect();

        var proxyElem = document.getElementById("noVNC_mouse_capture_elem");
        proxyElem.style.display = "none";

        window.removeEventListener('mousemove', _captureProxy);
        window.removeEventListener('mouseup', _captureProxy);
    }
}
},{}],29:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

/*
 * noVNC: HTML5 VNC client
 * Copyright (C) 2019 The noVNC Authors
 * Licensed under MPL 2.0 (see LICENSE.txt)
 *
 * See README.md for usage and integration instructions.
 */

var EventTargetMixin = function () {
    function EventTargetMixin() {
        _classCallCheck(this, EventTargetMixin);

        this._listeners = new Map();
    }

    _createClass(EventTargetMixin, [{
        key: "addEventListener",
        value: function addEventListener(type, callback) {
            if (!this._listeners.has(type)) {
                this._listeners.set(type, new Set());
            }
            this._listeners.get(type).add(callback);
        }
    }, {
        key: "removeEventListener",
        value: function removeEventListener(type, callback) {
            if (this._listeners.has(type)) {
                this._listeners.get(type).delete(callback);
            }
        }
    }, {
        key: "dispatchEvent",
        value: function dispatchEvent(event) {
            var _this = this;

            if (!this._listeners.has(event.type)) {
                return true;
            }
            this._listeners.get(event.type).forEach(function (callback) {
                return callback.call(_this, event);
            });
            return !event.defaultPrevented;
        }
    }]);

    return EventTargetMixin;
}();

exports.default = EventTargetMixin;
},{}],30:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.toUnsigned32bit = toUnsigned32bit;
exports.toSigned32bit = toSigned32bit;
/*
 * noVNC: HTML5 VNC client
 * Copyright (C) 2020 The noVNC Authors
 * Licensed under MPL 2.0 (see LICENSE.txt)
 *
 * See README.md for usage and integration instructions.
 */

function toUnsigned32bit(toConvert) {
    return toConvert >>> 0;
}

function toSigned32bit(toConvert) {
    return toConvert | 0;
}
},{}],31:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.init_logging = init_logging;
exports.get_logging = get_logging;
/*
 * noVNC: HTML5 VNC client
 * Copyright (C) 2019 The noVNC Authors
 * Licensed under MPL 2.0 (see LICENSE.txt)
 *
 * See README.md for usage and integration instructions.
 */

/*
 * Logging/debug routines
 */

var _log_level = 'warn';

var Debug = function Debug() {};
var Info = function Info() {};
var Warn = function Warn() {};
var Error = function Error() {};

function init_logging(level) {
    if (typeof level === 'undefined') {
        level = _log_level;
    } else {
        _log_level = level;
    }

    exports.Debug = Debug = exports.Info = Info = exports.Warn = Warn = exports.Error = Error = function Error() {};

    if (typeof window.console !== "undefined") {
        /* eslint-disable no-console, no-fallthrough */
        switch (level) {
            case 'debug':
                exports.Debug = Debug = console.debug.bind(window.console);
            case 'info':
                exports.Info = Info = console.info.bind(window.console);
            case 'warn':
                exports.Warn = Warn = console.warn.bind(window.console);
            case 'error':
                exports.Error = Error = console.error.bind(window.console);
            case 'none':
                break;
            default:
                throw new window.Error("invalid logging type '" + level + "'");
        }
        /* eslint-enable no-console, no-fallthrough */
    }
}

function get_logging() {
    return _log_level;
}

exports.Debug = Debug;
exports.Info = Info;
exports.Warn = Warn;
exports.Error = Error;

// Initialize logging level

init_logging();
},{}],32:[function(require,module,exports){
'use strict';

/*
 * noVNC: HTML5 VNC client
 * Copyright (C) 2018 The noVNC Authors
 * Licensed under MPL 2.0 or any later version (see LICENSE.txt)
 */

/* Polyfills to provide new APIs in old browsers */

/* Object.assign() (taken from MDN) */
if (typeof Object.assign != 'function') {
    // Must be writable: true, enumerable: false, configurable: true
    Object.defineProperty(Object, "assign", {
        value: function assign(target, varArgs) {
            // .length of function is 2
            'use strict';

            if (target == null) {
                // TypeError if undefined or null
                throw new TypeError('Cannot convert undefined or null to object');
            }

            var to = Object(target);

            for (var index = 1; index < arguments.length; index++) {
                var nextSource = arguments[index];

                if (nextSource != null) {
                    // Skip over if undefined or null
                    for (var nextKey in nextSource) {
                        // Avoid bugs when hasOwnProperty is shadowed
                        if (Object.prototype.hasOwnProperty.call(nextSource, nextKey)) {
                            to[nextKey] = nextSource[nextKey];
                        }
                    }
                }
            }
            return to;
        },
        writable: true,
        configurable: true
    });
}

/* CustomEvent constructor (taken from MDN) */
(function () {
    function CustomEvent(event, params) {
        params = params || { bubbles: false, cancelable: false, detail: undefined };
        var evt = document.createEvent('CustomEvent');
        evt.initCustomEvent(event, params.bubbles, params.cancelable, params.detail);
        return evt;
    }

    CustomEvent.prototype = window.Event.prototype;

    if (typeof window.CustomEvent !== "function") {
        window.CustomEvent = CustomEvent;
    }
})();
},{}],33:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.decodeUTF8 = decodeUTF8;
exports.encodeUTF8 = encodeUTF8;
/*
 * noVNC: HTML5 VNC client
 * Copyright (C) 2019 The noVNC Authors
 * Licensed under MPL 2.0 (see LICENSE.txt)
 *
 * See README.md for usage and integration instructions.
 */

// Decode from UTF-8
function decodeUTF8(utf8string) {
    var allowLatin1 = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : false;

    try {
        return decodeURIComponent(escape(utf8string));
    } catch (e) {
        if (e instanceof URIError) {
            if (allowLatin1) {
                // If we allow Latin1 we can ignore any decoding fails
                // and in these cases return the original string
                return utf8string;
            }
        }
        throw e;
    }
}

// Encode to UTF-8
function encodeUTF8(DOMString) {
    return unescape(encodeURIComponent(DOMString));
}
},{}],34:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }(); /*
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Websock: high-performance binary WebSockets
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Copyright (C) 2019 The noVNC Authors
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Licensed under MPL 2.0 (see LICENSE.txt)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      *
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Websock is similar to the standard WebSocket object but with extra
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * buffer handling.
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      *
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * Websock has built-in receive queue buffering; the message event
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * does not contain actual data but is simply a notification that
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * there is new data available. Several rQ* methods are available to
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      * read binary data off of the receive queue.
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      */

var _logging = require('./util/logging.js');

var Log = _interopRequireWildcard(_logging);

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

// this has performance issues in some versions Chromium, and
// doesn't gain a tremendous amount of performance increase in Firefox
// at the moment.  It may be valuable to turn it on in the future.
// Also copyWithin() for TypedArrays is not supported in IE 11 or
// Safari 13 (at the moment we want to support Safari 11).
var ENABLE_COPYWITHIN = false;
var MAX_RQ_GROW_SIZE = 40 * 1024 * 1024; // 40 MiB

var Websock = function () {
    function Websock() {
        _classCallCheck(this, Websock);

        this._websocket = null; // WebSocket object

        this._rQi = 0; // Receive queue index
        this._rQlen = 0; // Next write position in the receive queue
        this._rQbufferSize = 1024 * 1024 * 4; // Receive queue buffer size (4 MiB)
        // called in init: this._rQ = new Uint8Array(this._rQbufferSize);
        this._rQ = null; // Receive queue

        this._sQbufferSize = 1024 * 10; // 10 KiB
        // called in init: this._sQ = new Uint8Array(this._sQbufferSize);
        this._sQlen = 0;
        this._sQ = null; // Send queue

        this._eventHandlers = {
            message: function message() {},
            open: function open() {},
            close: function close() {},
            error: function error() {}
        };
    }

    // Getters and Setters


    _createClass(Websock, [{
        key: 'rQpeek8',
        value: function rQpeek8() {
            return this._rQ[this._rQi];
        }
    }, {
        key: 'rQskipBytes',
        value: function rQskipBytes(bytes) {
            this._rQi += bytes;
        }
    }, {
        key: 'rQshift8',
        value: function rQshift8() {
            return this._rQshift(1);
        }
    }, {
        key: 'rQshift16',
        value: function rQshift16() {
            return this._rQshift(2);
        }
    }, {
        key: 'rQshift32',
        value: function rQshift32() {
            return this._rQshift(4);
        }

        // TODO(directxman12): test performance with these vs a DataView

    }, {
        key: '_rQshift',
        value: function _rQshift(bytes) {
            var res = 0;
            for (var byte = bytes - 1; byte >= 0; byte--) {
                res += this._rQ[this._rQi++] << byte * 8;
            }
            return res;
        }
    }, {
        key: 'rQshiftStr',
        value: function rQshiftStr(len) {
            if (typeof len === 'undefined') {
                len = this.rQlen;
            }
            var str = "";
            // Handle large arrays in steps to avoid long strings on the stack
            for (var i = 0; i < len; i += 4096) {
                var part = this.rQshiftBytes(Math.min(4096, len - i));
                str += String.fromCharCode.apply(null, part);
            }
            return str;
        }
    }, {
        key: 'rQshiftBytes',
        value: function rQshiftBytes(len) {
            if (typeof len === 'undefined') {
                len = this.rQlen;
            }
            this._rQi += len;
            return new Uint8Array(this._rQ.buffer, this._rQi - len, len);
        }
    }, {
        key: 'rQshiftTo',
        value: function rQshiftTo(target, len) {
            if (len === undefined) {
                len = this.rQlen;
            }
            // TODO: make this just use set with views when using a ArrayBuffer to store the rQ
            target.set(new Uint8Array(this._rQ.buffer, this._rQi, len));
            this._rQi += len;
        }
    }, {
        key: 'rQslice',
        value: function rQslice(start) {
            var end = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : this.rQlen;

            return new Uint8Array(this._rQ.buffer, this._rQi + start, end - start);
        }

        // Check to see if we must wait for 'num' bytes (default to FBU.bytes)
        // to be available in the receive queue. Return true if we need to
        // wait (and possibly print a debug message), otherwise false.

    }, {
        key: 'rQwait',
        value: function rQwait(msg, num, goback) {
            if (this.rQlen < num) {
                if (goback) {
                    if (this._rQi < goback) {
                        throw new Error("rQwait cannot backup " + goback + " bytes");
                    }
                    this._rQi -= goback;
                }
                return true; // true means need more data
            }
            return false;
        }

        // Send Queue

    }, {
        key: 'flush',
        value: function flush() {
            if (this._sQlen > 0 && this._websocket.readyState === WebSocket.OPEN) {
                this._websocket.send(this._encode_message());
                this._sQlen = 0;
            }
        }
    }, {
        key: 'send',
        value: function send(arr) {
            this._sQ.set(arr, this._sQlen);
            this._sQlen += arr.length;
            this.flush();
        }
    }, {
        key: 'send_string',
        value: function send_string(str) {
            this.send(str.split('').map(function (chr) {
                return chr.charCodeAt(0);
            }));
        }

        // Event Handlers

    }, {
        key: 'off',
        value: function off(evt) {
            this._eventHandlers[evt] = function () {};
        }
    }, {
        key: 'on',
        value: function on(evt, handler) {
            this._eventHandlers[evt] = handler;
        }
    }, {
        key: '_allocate_buffers',
        value: function _allocate_buffers() {
            this._rQ = new Uint8Array(this._rQbufferSize);
            this._sQ = new Uint8Array(this._sQbufferSize);
        }
    }, {
        key: 'init',
        value: function init() {
            this._allocate_buffers();
            this._rQi = 0;
            this._websocket = null;
        }
    }, {
        key: 'open',
        value: function open(uri, protocols) {
            var _this = this;

            this.init();

            this._websocket = new WebSocket(uri, protocols);
            this._websocket.binaryType = 'arraybuffer';

            this._websocket.onmessage = this._recv_message.bind(this);
            this._websocket.onopen = function () {
                Log.Debug('>> WebSock.onopen');
                if (_this._websocket.protocol) {
                    Log.Info("Server choose sub-protocol: " + _this._websocket.protocol);
                }

                _this._eventHandlers.open();
                Log.Debug("<< WebSock.onopen");
            };
            this._websocket.onclose = function (e) {
                Log.Debug(">> WebSock.onclose");
                _this._eventHandlers.close(e);
                Log.Debug("<< WebSock.onclose");
            };
            this._websocket.onerror = function (e) {
                Log.Debug(">> WebSock.onerror: " + e);
                _this._eventHandlers.error(e);
                Log.Debug("<< WebSock.onerror: " + e);
            };
        }
    }, {
        key: 'close',
        value: function close() {
            if (this._websocket) {
                if (this._websocket.readyState === WebSocket.OPEN || this._websocket.readyState === WebSocket.CONNECTING) {
                    Log.Info("Closing WebSocket connection");
                    this._websocket.close();
                }

                this._websocket.onmessage = function () {};
            }
        }

        // private methods

    }, {
        key: '_encode_message',
        value: function _encode_message() {
            // Put in a binary arraybuffer
            // according to the spec, you can send ArrayBufferViews with the send method
            return new Uint8Array(this._sQ.buffer, 0, this._sQlen);
        }

        // We want to move all the unread data to the start of the queue,
        // e.g. compacting.
        // The function also expands the receive que if needed, and for
        // performance reasons we combine these two actions to avoid
        // unneccessary copying.

    }, {
        key: '_expand_compact_rQ',
        value: function _expand_compact_rQ(min_fit) {
            // if we're using less than 1/8th of the buffer even with the incoming bytes, compact in place
            // instead of resizing
            var required_buffer_size = (this._rQlen - this._rQi + min_fit) * 8;
            var resizeNeeded = this._rQbufferSize < required_buffer_size;

            if (resizeNeeded) {
                // Make sure we always *at least* double the buffer size, and have at least space for 8x
                // the current amount of data
                this._rQbufferSize = Math.max(this._rQbufferSize * 2, required_buffer_size);
            }

            // we don't want to grow unboundedly
            if (this._rQbufferSize > MAX_RQ_GROW_SIZE) {
                this._rQbufferSize = MAX_RQ_GROW_SIZE;
                if (this._rQbufferSize - this.rQlen < min_fit) {
                    throw new Error("Receive Queue buffer exceeded " + MAX_RQ_GROW_SIZE + " bytes, and the new message could not fit");
                }
            }

            if (resizeNeeded) {
                var old_rQbuffer = this._rQ.buffer;
                this._rQ = new Uint8Array(this._rQbufferSize);
                this._rQ.set(new Uint8Array(old_rQbuffer, this._rQi, this._rQlen - this._rQi));
            } else {
                if (ENABLE_COPYWITHIN) {
                    this._rQ.copyWithin(0, this._rQi, this._rQlen);
                } else {
                    this._rQ.set(new Uint8Array(this._rQ.buffer, this._rQi, this._rQlen - this._rQi));
                }
            }

            this._rQlen = this._rQlen - this._rQi;
            this._rQi = 0;
        }

        // push arraybuffer values onto the end of the receive que

    }, {
        key: '_decode_message',
        value: function _decode_message(data) {
            var u8 = new Uint8Array(data);
            if (u8.length > this._rQbufferSize - this._rQlen) {
                this._expand_compact_rQ(u8.length);
            }
            this._rQ.set(u8, this._rQlen);
            this._rQlen += u8.length;
        }
    }, {
        key: '_recv_message',
        value: function _recv_message(e) {
            this._decode_message(e.data);
            if (this.rQlen > 0) {
                this._eventHandlers.message();
                if (this._rQlen == this._rQi) {
                    // All data has now been processed, this means we
                    // can reset the receive queue.
                    this._rQlen = 0;
                    this._rQi = 0;
                }
            } else {
                Log.Debug("Ignoring empty message");
            }
        }
    }, {
        key: 'sQ',
        get: function get() {
            return this._sQ;
        }
    }, {
        key: 'rQ',
        get: function get() {
            return this._rQ;
        }
    }, {
        key: 'rQi',
        get: function get() {
            return this._rQi;
        },
        set: function set(val) {
            this._rQi = val;
        }

        // Receive Queue

    }, {
        key: 'rQlen',
        get: function get() {
            return this._rQlen - this._rQi;
        }
    }]);

    return Websock;
}();

exports.default = Websock;
},{"./util/logging.js":31}],35:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.shrinkBuf = shrinkBuf;
exports.arraySet = arraySet;
exports.flattenChunks = flattenChunks;
// reduce buffer size, avoiding mem copy
function shrinkBuf(buf, size) {
  if (buf.length === size) {
    return buf;
  }
  if (buf.subarray) {
    return buf.subarray(0, size);
  }
  buf.length = size;
  return buf;
};

function arraySet(dest, src, src_offs, len, dest_offs) {
  if (src.subarray && dest.subarray) {
    dest.set(src.subarray(src_offs, src_offs + len), dest_offs);
    return;
  }
  // Fallback to ordinary array
  for (var i = 0; i < len; i++) {
    dest[dest_offs + i] = src[src_offs + i];
  }
}

// Join array of chunks to single array.
function flattenChunks(chunks) {
  var i, l, len, pos, chunk, result;

  // calculate data length
  len = 0;
  for (i = 0, l = chunks.length; i < l; i++) {
    len += chunks[i].length;
  }

  // join chunks
  result = new Uint8Array(len);
  pos = 0;
  for (i = 0, l = chunks.length; i < l; i++) {
    chunk = chunks[i];
    result.set(chunk, pos);
    pos += chunk.length;
  }

  return result;
}

var Buf8 = exports.Buf8 = Uint8Array;
var Buf16 = exports.Buf16 = Uint16Array;
var Buf32 = exports.Buf32 = Int32Array;
},{}],36:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = adler32;
// Note: adler32 takes 12% for level 0 and 2% for level 6.
// It doesn't worth to make additional optimizationa as in original.
// Small size is preferable.

function adler32(adler, buf, len, pos) {
  var s1 = adler & 0xffff | 0,
      s2 = adler >>> 16 & 0xffff | 0,
      n = 0;

  while (len !== 0) {
    // Set limit ~ twice less than 5552, to keep
    // s2 in 31-bits, because we force signed ints.
    // in other case %= will fail.
    n = len > 2000 ? 2000 : len;
    len -= n;

    do {
      s1 = s1 + buf[pos++] | 0;
      s2 = s2 + s1 | 0;
    } while (--n);

    s1 %= 65521;
    s2 %= 65521;
  }

  return s1 | s2 << 16 | 0;
}
},{}],37:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = makeTable;
// Note: we can't get significant speed boost here.
// So write code to minimize size - no pregenerated tables
// and array tools dependencies.


// Use ordinary array, since untyped makes no boost here
function makeTable() {
  var c,
      table = [];

  for (var n = 0; n < 256; n++) {
    c = n;
    for (var k = 0; k < 8; k++) {
      c = c & 1 ? 0xEDB88320 ^ c >>> 1 : c >>> 1;
    }
    table[n] = c;
  }

  return table;
}

// Create table on load. Just 255 signed longs. Not a problem.
var crcTable = makeTable();

function crc32(crc, buf, len, pos) {
  var t = crcTable,
      end = pos + len;

  crc ^= -1;

  for (var i = pos; i < end; i++) {
    crc = crc >>> 8 ^ t[(crc ^ buf[i]) & 0xFF];
  }

  return crc ^ -1; // >>> 0;
}
},{}],38:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.deflateInfo = exports.deflateSetDictionary = exports.deflateEnd = exports.deflate = exports.deflateSetHeader = exports.deflateResetKeep = exports.deflateReset = exports.deflateInit2 = exports.deflateInit = exports.Z_DEFLATED = exports.Z_UNKNOWN = exports.Z_DEFAULT_STRATEGY = exports.Z_FIXED = exports.Z_RLE = exports.Z_HUFFMAN_ONLY = exports.Z_FILTERED = exports.Z_DEFAULT_COMPRESSION = exports.Z_BUF_ERROR = exports.Z_DATA_ERROR = exports.Z_STREAM_ERROR = exports.Z_STREAM_END = exports.Z_OK = exports.Z_BLOCK = exports.Z_FINISH = exports.Z_FULL_FLUSH = exports.Z_PARTIAL_FLUSH = exports.Z_NO_FLUSH = undefined;

var _common = require("../utils/common.js");

var utils = _interopRequireWildcard(_common);

var _trees = require("./trees.js");

var trees = _interopRequireWildcard(_trees);

var _adler = require("./adler32.js");

var _adler2 = _interopRequireDefault(_adler);

var _crc = require("./crc32.js");

var _crc2 = _interopRequireDefault(_crc);

var _messages = require("./messages.js");

var _messages2 = _interopRequireDefault(_messages);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

/* Public constants ==========================================================*/
/* ===========================================================================*/

/* Allowed flush values; see deflate() and inflate() below for details */
var Z_NO_FLUSH = exports.Z_NO_FLUSH = 0;
var Z_PARTIAL_FLUSH = exports.Z_PARTIAL_FLUSH = 1;
//export const Z_SYNC_FLUSH    = 2;
var Z_FULL_FLUSH = exports.Z_FULL_FLUSH = 3;
var Z_FINISH = exports.Z_FINISH = 4;
var Z_BLOCK = exports.Z_BLOCK = 5;
//export const Z_TREES         = 6;


/* Return codes for the compression/decompression functions. Negative values
 * are errors, positive values are used for special but normal events.
 */
var Z_OK = exports.Z_OK = 0;
var Z_STREAM_END = exports.Z_STREAM_END = 1;
//export const Z_NEED_DICT     = 2;
//export const Z_ERRNO         = -1;
var Z_STREAM_ERROR = exports.Z_STREAM_ERROR = -2;
var Z_DATA_ERROR = exports.Z_DATA_ERROR = -3;
//export const Z_MEM_ERROR     = -4;
var Z_BUF_ERROR = exports.Z_BUF_ERROR = -5;
//export const Z_VERSION_ERROR = -6;


/* compression levels */
//export const Z_NO_COMPRESSION      = 0;
//export const Z_BEST_SPEED          = 1;
//export const Z_BEST_COMPRESSION    = 9;
var Z_DEFAULT_COMPRESSION = exports.Z_DEFAULT_COMPRESSION = -1;

var Z_FILTERED = exports.Z_FILTERED = 1;
var Z_HUFFMAN_ONLY = exports.Z_HUFFMAN_ONLY = 2;
var Z_RLE = exports.Z_RLE = 3;
var Z_FIXED = exports.Z_FIXED = 4;
var Z_DEFAULT_STRATEGY = exports.Z_DEFAULT_STRATEGY = 0;

/* Possible values of the data_type field (though see inflate()) */
//export const Z_BINARY              = 0;
//export const Z_TEXT                = 1;
//export const Z_ASCII               = 1; // = Z_TEXT
var Z_UNKNOWN = exports.Z_UNKNOWN = 2;

/* The deflate compression method */
var Z_DEFLATED = exports.Z_DEFLATED = 8;

/*============================================================================*/

var MAX_MEM_LEVEL = 9;
/* Maximum value for memLevel in deflateInit2 */
var MAX_WBITS = 15;
/* 32K LZ77 window */
var DEF_MEM_LEVEL = 8;

var LENGTH_CODES = 29;
/* number of length codes, not counting the special END_BLOCK code */
var LITERALS = 256;
/* number of literal bytes 0..255 */
var L_CODES = LITERALS + 1 + LENGTH_CODES;
/* number of Literal or Length codes, including the END_BLOCK code */
var D_CODES = 30;
/* number of distance codes */
var BL_CODES = 19;
/* number of codes used to transfer the bit lengths */
var HEAP_SIZE = 2 * L_CODES + 1;
/* maximum heap size */
var MAX_BITS = 15;
/* All codes must not exceed MAX_BITS bits */

var MIN_MATCH = 3;
var MAX_MATCH = 258;
var MIN_LOOKAHEAD = MAX_MATCH + MIN_MATCH + 1;

var PRESET_DICT = 0x20;

var INIT_STATE = 42;
var EXTRA_STATE = 69;
var NAME_STATE = 73;
var COMMENT_STATE = 91;
var HCRC_STATE = 103;
var BUSY_STATE = 113;
var FINISH_STATE = 666;

var BS_NEED_MORE = 1; /* block not completed, need more input or more output */
var BS_BLOCK_DONE = 2; /* block flush performed */
var BS_FINISH_STARTED = 3; /* finish started, need only more output at next deflate */
var BS_FINISH_DONE = 4; /* finish done, accept no more input or output */

var OS_CODE = 0x03; // Unix :) . Don't detect, use this default.

function err(strm, errorCode) {
  strm.msg = _messages2.default[errorCode];
  return errorCode;
}

function rank(f) {
  return (f << 1) - (f > 4 ? 9 : 0);
}

function zero(buf) {
  var len = buf.length;while (--len >= 0) {
    buf[len] = 0;
  }
}

/* =========================================================================
 * Flush as much pending output as possible. All deflate() output goes
 * through this function so some applications may wish to modify it
 * to avoid allocating a large strm->output buffer and copying into it.
 * (See also read_buf()).
 */
function flush_pending(strm) {
  var s = strm.state;

  //_tr_flush_bits(s);
  var len = s.pending;
  if (len > strm.avail_out) {
    len = strm.avail_out;
  }
  if (len === 0) {
    return;
  }

  utils.arraySet(strm.output, s.pending_buf, s.pending_out, len, strm.next_out);
  strm.next_out += len;
  s.pending_out += len;
  strm.total_out += len;
  strm.avail_out -= len;
  s.pending -= len;
  if (s.pending === 0) {
    s.pending_out = 0;
  }
}

function flush_block_only(s, last) {
  trees._tr_flush_block(s, s.block_start >= 0 ? s.block_start : -1, s.strstart - s.block_start, last);
  s.block_start = s.strstart;
  flush_pending(s.strm);
}

function put_byte(s, b) {
  s.pending_buf[s.pending++] = b;
}

/* =========================================================================
 * Put a short in the pending buffer. The 16-bit value is put in MSB order.
 * IN assertion: the stream state is correct and there is enough room in
 * pending_buf.
 */
function putShortMSB(s, b) {
  //  put_byte(s, (Byte)(b >> 8));
  //  put_byte(s, (Byte)(b & 0xff));
  s.pending_buf[s.pending++] = b >>> 8 & 0xff;
  s.pending_buf[s.pending++] = b & 0xff;
}

/* ===========================================================================
 * Read a new buffer from the current input stream, update the adler32
 * and total number of bytes read.  All deflate() input goes through
 * this function so some applications may wish to modify it to avoid
 * allocating a large strm->input buffer and copying from it.
 * (See also flush_pending()).
 */
function read_buf(strm, buf, start, size) {
  var len = strm.avail_in;

  if (len > size) {
    len = size;
  }
  if (len === 0) {
    return 0;
  }

  strm.avail_in -= len;

  // zmemcpy(buf, strm->next_in, len);
  utils.arraySet(buf, strm.input, strm.next_in, len, start);
  if (strm.state.wrap === 1) {
    strm.adler = (0, _adler2.default)(strm.adler, buf, len, start);
  } else if (strm.state.wrap === 2) {
    strm.adler = (0, _crc2.default)(strm.adler, buf, len, start);
  }

  strm.next_in += len;
  strm.total_in += len;

  return len;
}

/* ===========================================================================
 * Set match_start to the longest match starting at the given string and
 * return its length. Matches shorter or equal to prev_length are discarded,
 * in which case the result is equal to prev_length and match_start is
 * garbage.
 * IN assertions: cur_match is the head of the hash chain for the current
 *   string (strstart) and its distance is <= MAX_DIST, and prev_length >= 1
 * OUT assertion: the match length is not greater than s->lookahead.
 */
function longest_match(s, cur_match) {
  var chain_length = s.max_chain_length; /* max hash chain length */
  var scan = s.strstart; /* current string */
  var match; /* matched string */
  var len; /* length of current match */
  var best_len = s.prev_length; /* best match length so far */
  var nice_match = s.nice_match; /* stop if match long enough */
  var limit = s.strstart > s.w_size - MIN_LOOKAHEAD ? s.strstart - (s.w_size - MIN_LOOKAHEAD) : 0 /*NIL*/;

  var _win = s.window; // shortcut

  var wmask = s.w_mask;
  var prev = s.prev;

  /* Stop when cur_match becomes <= limit. To simplify the code,
   * we prevent matches with the string of window index 0.
   */

  var strend = s.strstart + MAX_MATCH;
  var scan_end1 = _win[scan + best_len - 1];
  var scan_end = _win[scan + best_len];

  /* The code is optimized for HASH_BITS >= 8 and MAX_MATCH-2 multiple of 16.
   * It is easy to get rid of this optimization if necessary.
   */
  // Assert(s->hash_bits >= 8 && MAX_MATCH == 258, "Code too clever");

  /* Do not waste too much time if we already have a good match: */
  if (s.prev_length >= s.good_match) {
    chain_length >>= 2;
  }
  /* Do not look for matches beyond the end of the input. This is necessary
   * to make deflate deterministic.
   */
  if (nice_match > s.lookahead) {
    nice_match = s.lookahead;
  }

  // Assert((ulg)s->strstart <= s->window_size-MIN_LOOKAHEAD, "need lookahead");

  do {
    // Assert(cur_match < s->strstart, "no future");
    match = cur_match;

    /* Skip to next match if the match length cannot increase
     * or if the match length is less than 2.  Note that the checks below
     * for insufficient lookahead only occur occasionally for performance
     * reasons.  Therefore uninitialized memory will be accessed, and
     * conditional jumps will be made that depend on those values.
     * However the length of the match is limited to the lookahead, so
     * the output of deflate is not affected by the uninitialized values.
     */

    if (_win[match + best_len] !== scan_end || _win[match + best_len - 1] !== scan_end1 || _win[match] !== _win[scan] || _win[++match] !== _win[scan + 1]) {
      continue;
    }

    /* The check at best_len-1 can be removed because it will be made
     * again later. (This heuristic is not always a win.)
     * It is not necessary to compare scan[2] and match[2] since they
     * are always equal when the other bytes match, given that
     * the hash keys are equal and that HASH_BITS >= 8.
     */
    scan += 2;
    match++;
    // Assert(*scan == *match, "match[2]?");

    /* We check for insufficient lookahead only every 8th comparison;
     * the 256th check will be made at strstart+258.
     */
    do {
      // Do nothing
    } while (_win[++scan] === _win[++match] && _win[++scan] === _win[++match] && _win[++scan] === _win[++match] && _win[++scan] === _win[++match] && _win[++scan] === _win[++match] && _win[++scan] === _win[++match] && _win[++scan] === _win[++match] && _win[++scan] === _win[++match] && scan < strend);

    // Assert(scan <= s->window+(unsigned)(s->window_size-1), "wild scan");

    len = MAX_MATCH - (strend - scan);
    scan = strend - MAX_MATCH;

    if (len > best_len) {
      s.match_start = cur_match;
      best_len = len;
      if (len >= nice_match) {
        break;
      }
      scan_end1 = _win[scan + best_len - 1];
      scan_end = _win[scan + best_len];
    }
  } while ((cur_match = prev[cur_match & wmask]) > limit && --chain_length !== 0);

  if (best_len <= s.lookahead) {
    return best_len;
  }
  return s.lookahead;
}

/* ===========================================================================
 * Fill the window when the lookahead becomes insufficient.
 * Updates strstart and lookahead.
 *
 * IN assertion: lookahead < MIN_LOOKAHEAD
 * OUT assertions: strstart <= window_size-MIN_LOOKAHEAD
 *    At least one byte has been read, or avail_in == 0; reads are
 *    performed for at least two bytes (required for the zip translate_eol
 *    option -- not supported here).
 */
function fill_window(s) {
  var _w_size = s.w_size;
  var p, n, m, more, str;

  //Assert(s->lookahead < MIN_LOOKAHEAD, "already enough lookahead");

  do {
    more = s.window_size - s.lookahead - s.strstart;

    // JS ints have 32 bit, block below not needed
    /* Deal with !@#$% 64K limit: */
    //if (sizeof(int) <= 2) {
    //    if (more == 0 && s->strstart == 0 && s->lookahead == 0) {
    //        more = wsize;
    //
    //  } else if (more == (unsigned)(-1)) {
    //        /* Very unlikely, but possible on 16 bit machine if
    //         * strstart == 0 && lookahead == 1 (input done a byte at time)
    //         */
    //        more--;
    //    }
    //}


    /* If the window is almost full and there is insufficient lookahead,
     * move the upper half to the lower one to make room in the upper half.
     */
    if (s.strstart >= _w_size + (_w_size - MIN_LOOKAHEAD)) {

      utils.arraySet(s.window, s.window, _w_size, _w_size, 0);
      s.match_start -= _w_size;
      s.strstart -= _w_size;
      /* we now have strstart >= MAX_DIST */
      s.block_start -= _w_size;

      /* Slide the hash table (could be avoided with 32 bit values
       at the expense of memory usage). We slide even when level == 0
       to keep the hash table consistent if we switch back to level > 0
       later. (Using level 0 permanently is not an optimal usage of
       zlib, so we don't care about this pathological case.)
       */

      n = s.hash_size;
      p = n;
      do {
        m = s.head[--p];
        s.head[p] = m >= _w_size ? m - _w_size : 0;
      } while (--n);

      n = _w_size;
      p = n;
      do {
        m = s.prev[--p];
        s.prev[p] = m >= _w_size ? m - _w_size : 0;
        /* If n is not on any hash chain, prev[n] is garbage but
         * its value will never be used.
         */
      } while (--n);

      more += _w_size;
    }
    if (s.strm.avail_in === 0) {
      break;
    }

    /* If there was no sliding:
     *    strstart <= WSIZE+MAX_DIST-1 && lookahead <= MIN_LOOKAHEAD - 1 &&
     *    more == window_size - lookahead - strstart
     * => more >= window_size - (MIN_LOOKAHEAD-1 + WSIZE + MAX_DIST-1)
     * => more >= window_size - 2*WSIZE + 2
     * In the BIG_MEM or MMAP case (not yet supported),
     *   window_size == input_size + MIN_LOOKAHEAD  &&
     *   strstart + s->lookahead <= input_size => more >= MIN_LOOKAHEAD.
     * Otherwise, window_size == 2*WSIZE so more >= 2.
     * If there was sliding, more >= WSIZE. So in all cases, more >= 2.
     */
    //Assert(more >= 2, "more < 2");
    n = read_buf(s.strm, s.window, s.strstart + s.lookahead, more);
    s.lookahead += n;

    /* Initialize the hash value now that we have some input: */
    if (s.lookahead + s.insert >= MIN_MATCH) {
      str = s.strstart - s.insert;
      s.ins_h = s.window[str];

      /* UPDATE_HASH(s, s->ins_h, s->window[str + 1]); */
      s.ins_h = (s.ins_h << s.hash_shift ^ s.window[str + 1]) & s.hash_mask;
      //#if MIN_MATCH != 3
      //        Call update_hash() MIN_MATCH-3 more times
      //#endif
      while (s.insert) {
        /* UPDATE_HASH(s, s->ins_h, s->window[str + MIN_MATCH-1]); */
        s.ins_h = (s.ins_h << s.hash_shift ^ s.window[str + MIN_MATCH - 1]) & s.hash_mask;

        s.prev[str & s.w_mask] = s.head[s.ins_h];
        s.head[s.ins_h] = str;
        str++;
        s.insert--;
        if (s.lookahead + s.insert < MIN_MATCH) {
          break;
        }
      }
    }
    /* If the whole input has less than MIN_MATCH bytes, ins_h is garbage,
     * but this is not important since only literal bytes will be emitted.
     */
  } while (s.lookahead < MIN_LOOKAHEAD && s.strm.avail_in !== 0);

  /* If the WIN_INIT bytes after the end of the current data have never been
   * written, then zero those bytes in order to avoid memory check reports of
   * the use of uninitialized (or uninitialised as Julian writes) bytes by
   * the longest match routines.  Update the high water mark for the next
   * time through here.  WIN_INIT is set to MAX_MATCH since the longest match
   * routines allow scanning to strstart + MAX_MATCH, ignoring lookahead.
   */
  //  if (s.high_water < s.window_size) {
  //    var curr = s.strstart + s.lookahead;
  //    var init = 0;
  //
  //    if (s.high_water < curr) {
  //      /* Previous high water mark below current data -- zero WIN_INIT
  //       * bytes or up to end of window, whichever is less.
  //       */
  //      init = s.window_size - curr;
  //      if (init > WIN_INIT)
  //        init = WIN_INIT;
  //      zmemzero(s->window + curr, (unsigned)init);
  //      s->high_water = curr + init;
  //    }
  //    else if (s->high_water < (ulg)curr + WIN_INIT) {
  //      /* High water mark at or above current data, but below current data
  //       * plus WIN_INIT -- zero out to current data plus WIN_INIT, or up
  //       * to end of window, whichever is less.
  //       */
  //      init = (ulg)curr + WIN_INIT - s->high_water;
  //      if (init > s->window_size - s->high_water)
  //        init = s->window_size - s->high_water;
  //      zmemzero(s->window + s->high_water, (unsigned)init);
  //      s->high_water += init;
  //    }
  //  }
  //
  //  Assert((ulg)s->strstart <= s->window_size - MIN_LOOKAHEAD,
  //    "not enough room for search");
}

/* ===========================================================================
 * Copy without compression as much as possible from the input stream, return
 * the current block state.
 * This function does not insert new strings in the dictionary since
 * uncompressible data is probably not useful. This function is used
 * only for the level=0 compression option.
 * NOTE: this function should be optimized to avoid extra copying from
 * window to pending_buf.
 */
function deflate_stored(s, flush) {
  /* Stored blocks are limited to 0xffff bytes, pending_buf is limited
   * to pending_buf_size, and each stored block has a 5 byte header:
   */
  var max_block_size = 0xffff;

  if (max_block_size > s.pending_buf_size - 5) {
    max_block_size = s.pending_buf_size - 5;
  }

  /* Copy as much as possible from input to output: */
  for (;;) {
    /* Fill the window as much as possible: */
    if (s.lookahead <= 1) {

      //Assert(s->strstart < s->w_size+MAX_DIST(s) ||
      //  s->block_start >= (long)s->w_size, "slide too late");
      //      if (!(s.strstart < s.w_size + (s.w_size - MIN_LOOKAHEAD) ||
      //        s.block_start >= s.w_size)) {
      //        throw  new Error("slide too late");
      //      }

      fill_window(s);
      if (s.lookahead === 0 && flush === Z_NO_FLUSH) {
        return BS_NEED_MORE;
      }

      if (s.lookahead === 0) {
        break;
      }
      /* flush the current block */
    }
    //Assert(s->block_start >= 0L, "block gone");
    //    if (s.block_start < 0) throw new Error("block gone");

    s.strstart += s.lookahead;
    s.lookahead = 0;

    /* Emit a stored block if pending_buf will be full: */
    var max_start = s.block_start + max_block_size;

    if (s.strstart === 0 || s.strstart >= max_start) {
      /* strstart == 0 is possible when wraparound on 16-bit machine */
      s.lookahead = s.strstart - max_start;
      s.strstart = max_start;
      /*** FLUSH_BLOCK(s, 0); ***/
      flush_block_only(s, false);
      if (s.strm.avail_out === 0) {
        return BS_NEED_MORE;
      }
      /***/
    }
    /* Flush if we may have to slide, otherwise block_start may become
     * negative and the data will be gone:
     */
    if (s.strstart - s.block_start >= s.w_size - MIN_LOOKAHEAD) {
      /*** FLUSH_BLOCK(s, 0); ***/
      flush_block_only(s, false);
      if (s.strm.avail_out === 0) {
        return BS_NEED_MORE;
      }
      /***/
    }
  }

  s.insert = 0;

  if (flush === Z_FINISH) {
    /*** FLUSH_BLOCK(s, 1); ***/
    flush_block_only(s, true);
    if (s.strm.avail_out === 0) {
      return BS_FINISH_STARTED;
    }
    /***/
    return BS_FINISH_DONE;
  }

  if (s.strstart > s.block_start) {
    /*** FLUSH_BLOCK(s, 0); ***/
    flush_block_only(s, false);
    if (s.strm.avail_out === 0) {
      return BS_NEED_MORE;
    }
    /***/
  }

  return BS_NEED_MORE;
}

/* ===========================================================================
 * Compress as much as possible from the input stream, return the current
 * block state.
 * This function does not perform lazy evaluation of matches and inserts
 * new strings in the dictionary only for unmatched strings or for short
 * matches. It is used only for the fast compression options.
 */
function deflate_fast(s, flush) {
  var hash_head; /* head of the hash chain */
  var bflush; /* set if current block must be flushed */

  for (;;) {
    /* Make sure that we always have enough lookahead, except
     * at the end of the input file. We need MAX_MATCH bytes
     * for the next match, plus MIN_MATCH bytes to insert the
     * string following the next match.
     */
    if (s.lookahead < MIN_LOOKAHEAD) {
      fill_window(s);
      if (s.lookahead < MIN_LOOKAHEAD && flush === Z_NO_FLUSH) {
        return BS_NEED_MORE;
      }
      if (s.lookahead === 0) {
        break; /* flush the current block */
      }
    }

    /* Insert the string window[strstart .. strstart+2] in the
     * dictionary, and set hash_head to the head of the hash chain:
     */
    hash_head = 0 /*NIL*/;
    if (s.lookahead >= MIN_MATCH) {
      /*** INSERT_STRING(s, s.strstart, hash_head); ***/
      s.ins_h = (s.ins_h << s.hash_shift ^ s.window[s.strstart + MIN_MATCH - 1]) & s.hash_mask;
      hash_head = s.prev[s.strstart & s.w_mask] = s.head[s.ins_h];
      s.head[s.ins_h] = s.strstart;
      /***/
    }

    /* Find the longest match, discarding those <= prev_length.
     * At this point we have always match_length < MIN_MATCH
     */
    if (hash_head !== 0 /*NIL*/ && s.strstart - hash_head <= s.w_size - MIN_LOOKAHEAD) {
      /* To simplify the code, we prevent matches with the string
       * of window index 0 (in particular we have to avoid a match
       * of the string with itself at the start of the input file).
       */
      s.match_length = longest_match(s, hash_head);
      /* longest_match() sets match_start */
    }
    if (s.match_length >= MIN_MATCH) {
      // check_match(s, s.strstart, s.match_start, s.match_length); // for debug only

      /*** _tr_tally_dist(s, s.strstart - s.match_start,
                     s.match_length - MIN_MATCH, bflush); ***/
      bflush = trees._tr_tally(s, s.strstart - s.match_start, s.match_length - MIN_MATCH);

      s.lookahead -= s.match_length;

      /* Insert new strings in the hash table only if the match length
       * is not too large. This saves time but degrades compression.
       */
      if (s.match_length <= s.max_lazy_match /*max_insert_length*/ && s.lookahead >= MIN_MATCH) {
        s.match_length--; /* string at strstart already in table */
        do {
          s.strstart++;
          /*** INSERT_STRING(s, s.strstart, hash_head); ***/
          s.ins_h = (s.ins_h << s.hash_shift ^ s.window[s.strstart + MIN_MATCH - 1]) & s.hash_mask;
          hash_head = s.prev[s.strstart & s.w_mask] = s.head[s.ins_h];
          s.head[s.ins_h] = s.strstart;
          /***/
          /* strstart never exceeds WSIZE-MAX_MATCH, so there are
           * always MIN_MATCH bytes ahead.
           */
        } while (--s.match_length !== 0);
        s.strstart++;
      } else {
        s.strstart += s.match_length;
        s.match_length = 0;
        s.ins_h = s.window[s.strstart];
        /* UPDATE_HASH(s, s.ins_h, s.window[s.strstart+1]); */
        s.ins_h = (s.ins_h << s.hash_shift ^ s.window[s.strstart + 1]) & s.hash_mask;

        //#if MIN_MATCH != 3
        //                Call UPDATE_HASH() MIN_MATCH-3 more times
        //#endif
        /* If lookahead < MIN_MATCH, ins_h is garbage, but it does not
         * matter since it will be recomputed at next deflate call.
         */
      }
    } else {
      /* No match, output a literal byte */
      //Tracevv((stderr,"%c", s.window[s.strstart]));
      /*** _tr_tally_lit(s, s.window[s.strstart], bflush); ***/
      bflush = trees._tr_tally(s, 0, s.window[s.strstart]);

      s.lookahead--;
      s.strstart++;
    }
    if (bflush) {
      /*** FLUSH_BLOCK(s, 0); ***/
      flush_block_only(s, false);
      if (s.strm.avail_out === 0) {
        return BS_NEED_MORE;
      }
      /***/
    }
  }
  s.insert = s.strstart < MIN_MATCH - 1 ? s.strstart : MIN_MATCH - 1;
  if (flush === Z_FINISH) {
    /*** FLUSH_BLOCK(s, 1); ***/
    flush_block_only(s, true);
    if (s.strm.avail_out === 0) {
      return BS_FINISH_STARTED;
    }
    /***/
    return BS_FINISH_DONE;
  }
  if (s.last_lit) {
    /*** FLUSH_BLOCK(s, 0); ***/
    flush_block_only(s, false);
    if (s.strm.avail_out === 0) {
      return BS_NEED_MORE;
    }
    /***/
  }
  return BS_BLOCK_DONE;
}

/* ===========================================================================
 * Same as above, but achieves better compression. We use a lazy
 * evaluation for matches: a match is finally adopted only if there is
 * no better match at the next window position.
 */
function deflate_slow(s, flush) {
  var hash_head; /* head of hash chain */
  var bflush; /* set if current block must be flushed */

  var max_insert;

  /* Process the input block. */
  for (;;) {
    /* Make sure that we always have enough lookahead, except
     * at the end of the input file. We need MAX_MATCH bytes
     * for the next match, plus MIN_MATCH bytes to insert the
     * string following the next match.
     */
    if (s.lookahead < MIN_LOOKAHEAD) {
      fill_window(s);
      if (s.lookahead < MIN_LOOKAHEAD && flush === Z_NO_FLUSH) {
        return BS_NEED_MORE;
      }
      if (s.lookahead === 0) {
        break;
      } /* flush the current block */
    }

    /* Insert the string window[strstart .. strstart+2] in the
     * dictionary, and set hash_head to the head of the hash chain:
     */
    hash_head = 0 /*NIL*/;
    if (s.lookahead >= MIN_MATCH) {
      /*** INSERT_STRING(s, s.strstart, hash_head); ***/
      s.ins_h = (s.ins_h << s.hash_shift ^ s.window[s.strstart + MIN_MATCH - 1]) & s.hash_mask;
      hash_head = s.prev[s.strstart & s.w_mask] = s.head[s.ins_h];
      s.head[s.ins_h] = s.strstart;
      /***/
    }

    /* Find the longest match, discarding those <= prev_length.
     */
    s.prev_length = s.match_length;
    s.prev_match = s.match_start;
    s.match_length = MIN_MATCH - 1;

    if (hash_head !== 0 /*NIL*/ && s.prev_length < s.max_lazy_match && s.strstart - hash_head <= s.w_size - MIN_LOOKAHEAD /*MAX_DIST(s)*/) {
        /* To simplify the code, we prevent matches with the string
         * of window index 0 (in particular we have to avoid a match
         * of the string with itself at the start of the input file).
         */
        s.match_length = longest_match(s, hash_head);
        /* longest_match() sets match_start */

        if (s.match_length <= 5 && (s.strategy === Z_FILTERED || s.match_length === MIN_MATCH && s.strstart - s.match_start > 4096 /*TOO_FAR*/)) {

          /* If prev_match is also MIN_MATCH, match_start is garbage
           * but we will ignore the current match anyway.
           */
          s.match_length = MIN_MATCH - 1;
        }
      }
    /* If there was a match at the previous step and the current
     * match is not better, output the previous match:
     */
    if (s.prev_length >= MIN_MATCH && s.match_length <= s.prev_length) {
      max_insert = s.strstart + s.lookahead - MIN_MATCH;
      /* Do not insert strings in hash table beyond this. */

      //check_match(s, s.strstart-1, s.prev_match, s.prev_length);

      /***_tr_tally_dist(s, s.strstart - 1 - s.prev_match,
                     s.prev_length - MIN_MATCH, bflush);***/
      bflush = trees._tr_tally(s, s.strstart - 1 - s.prev_match, s.prev_length - MIN_MATCH);
      /* Insert in hash table all strings up to the end of the match.
       * strstart-1 and strstart are already inserted. If there is not
       * enough lookahead, the last two strings are not inserted in
       * the hash table.
       */
      s.lookahead -= s.prev_length - 1;
      s.prev_length -= 2;
      do {
        if (++s.strstart <= max_insert) {
          /*** INSERT_STRING(s, s.strstart, hash_head); ***/
          s.ins_h = (s.ins_h << s.hash_shift ^ s.window[s.strstart + MIN_MATCH - 1]) & s.hash_mask;
          hash_head = s.prev[s.strstart & s.w_mask] = s.head[s.ins_h];
          s.head[s.ins_h] = s.strstart;
          /***/
        }
      } while (--s.prev_length !== 0);
      s.match_available = 0;
      s.match_length = MIN_MATCH - 1;
      s.strstart++;

      if (bflush) {
        /*** FLUSH_BLOCK(s, 0); ***/
        flush_block_only(s, false);
        if (s.strm.avail_out === 0) {
          return BS_NEED_MORE;
        }
        /***/
      }
    } else if (s.match_available) {
      /* If there was no match at the previous position, output a
       * single literal. If there was a match but the current match
       * is longer, truncate the previous match to a single literal.
       */
      //Tracevv((stderr,"%c", s->window[s->strstart-1]));
      /*** _tr_tally_lit(s, s.window[s.strstart-1], bflush); ***/
      bflush = trees._tr_tally(s, 0, s.window[s.strstart - 1]);

      if (bflush) {
        /*** FLUSH_BLOCK_ONLY(s, 0) ***/
        flush_block_only(s, false);
        /***/
      }
      s.strstart++;
      s.lookahead--;
      if (s.strm.avail_out === 0) {
        return BS_NEED_MORE;
      }
    } else {
      /* There is no previous match to compare with, wait for
       * the next step to decide.
       */
      s.match_available = 1;
      s.strstart++;
      s.lookahead--;
    }
  }
  //Assert (flush != Z_NO_FLUSH, "no flush?");
  if (s.match_available) {
    //Tracevv((stderr,"%c", s->window[s->strstart-1]));
    /*** _tr_tally_lit(s, s.window[s.strstart-1], bflush); ***/
    bflush = trees._tr_tally(s, 0, s.window[s.strstart - 1]);

    s.match_available = 0;
  }
  s.insert = s.strstart < MIN_MATCH - 1 ? s.strstart : MIN_MATCH - 1;
  if (flush === Z_FINISH) {
    /*** FLUSH_BLOCK(s, 1); ***/
    flush_block_only(s, true);
    if (s.strm.avail_out === 0) {
      return BS_FINISH_STARTED;
    }
    /***/
    return BS_FINISH_DONE;
  }
  if (s.last_lit) {
    /*** FLUSH_BLOCK(s, 0); ***/
    flush_block_only(s, false);
    if (s.strm.avail_out === 0) {
      return BS_NEED_MORE;
    }
    /***/
  }

  return BS_BLOCK_DONE;
}

/* ===========================================================================
 * For Z_RLE, simply look for runs of bytes, generate matches only of distance
 * one.  Do not maintain a hash table.  (It will be regenerated if this run of
 * deflate switches away from Z_RLE.)
 */
function deflate_rle(s, flush) {
  var bflush; /* set if current block must be flushed */
  var prev; /* byte at distance one to match */
  var scan, strend; /* scan goes up to strend for length of run */

  var _win = s.window;

  for (;;) {
    /* Make sure that we always have enough lookahead, except
     * at the end of the input file. We need MAX_MATCH bytes
     * for the longest run, plus one for the unrolled loop.
     */
    if (s.lookahead <= MAX_MATCH) {
      fill_window(s);
      if (s.lookahead <= MAX_MATCH && flush === Z_NO_FLUSH) {
        return BS_NEED_MORE;
      }
      if (s.lookahead === 0) {
        break;
      } /* flush the current block */
    }

    /* See how many times the previous byte repeats */
    s.match_length = 0;
    if (s.lookahead >= MIN_MATCH && s.strstart > 0) {
      scan = s.strstart - 1;
      prev = _win[scan];
      if (prev === _win[++scan] && prev === _win[++scan] && prev === _win[++scan]) {
        strend = s.strstart + MAX_MATCH;
        do {
          // Do nothing
        } while (prev === _win[++scan] && prev === _win[++scan] && prev === _win[++scan] && prev === _win[++scan] && prev === _win[++scan] && prev === _win[++scan] && prev === _win[++scan] && prev === _win[++scan] && scan < strend);
        s.match_length = MAX_MATCH - (strend - scan);
        if (s.match_length > s.lookahead) {
          s.match_length = s.lookahead;
        }
      }
      //Assert(scan <= s->window+(uInt)(s->window_size-1), "wild scan");
    }

    /* Emit match if have run of MIN_MATCH or longer, else emit literal */
    if (s.match_length >= MIN_MATCH) {
      //check_match(s, s.strstart, s.strstart - 1, s.match_length);

      /*** _tr_tally_dist(s, 1, s.match_length - MIN_MATCH, bflush); ***/
      bflush = trees._tr_tally(s, 1, s.match_length - MIN_MATCH);

      s.lookahead -= s.match_length;
      s.strstart += s.match_length;
      s.match_length = 0;
    } else {
      /* No match, output a literal byte */
      //Tracevv((stderr,"%c", s->window[s->strstart]));
      /*** _tr_tally_lit(s, s.window[s.strstart], bflush); ***/
      bflush = trees._tr_tally(s, 0, s.window[s.strstart]);

      s.lookahead--;
      s.strstart++;
    }
    if (bflush) {
      /*** FLUSH_BLOCK(s, 0); ***/
      flush_block_only(s, false);
      if (s.strm.avail_out === 0) {
        return BS_NEED_MORE;
      }
      /***/
    }
  }
  s.insert = 0;
  if (flush === Z_FINISH) {
    /*** FLUSH_BLOCK(s, 1); ***/
    flush_block_only(s, true);
    if (s.strm.avail_out === 0) {
      return BS_FINISH_STARTED;
    }
    /***/
    return BS_FINISH_DONE;
  }
  if (s.last_lit) {
    /*** FLUSH_BLOCK(s, 0); ***/
    flush_block_only(s, false);
    if (s.strm.avail_out === 0) {
      return BS_NEED_MORE;
    }
    /***/
  }
  return BS_BLOCK_DONE;
}

/* ===========================================================================
 * For Z_HUFFMAN_ONLY, do not look for matches.  Do not maintain a hash table.
 * (It will be regenerated if this run of deflate switches away from Huffman.)
 */
function deflate_huff(s, flush) {
  var bflush; /* set if current block must be flushed */

  for (;;) {
    /* Make sure that we have a literal to write. */
    if (s.lookahead === 0) {
      fill_window(s);
      if (s.lookahead === 0) {
        if (flush === Z_NO_FLUSH) {
          return BS_NEED_MORE;
        }
        break; /* flush the current block */
      }
    }

    /* Output a literal byte */
    s.match_length = 0;
    //Tracevv((stderr,"%c", s->window[s->strstart]));
    /*** _tr_tally_lit(s, s.window[s.strstart], bflush); ***/
    bflush = trees._tr_tally(s, 0, s.window[s.strstart]);
    s.lookahead--;
    s.strstart++;
    if (bflush) {
      /*** FLUSH_BLOCK(s, 0); ***/
      flush_block_only(s, false);
      if (s.strm.avail_out === 0) {
        return BS_NEED_MORE;
      }
      /***/
    }
  }
  s.insert = 0;
  if (flush === Z_FINISH) {
    /*** FLUSH_BLOCK(s, 1); ***/
    flush_block_only(s, true);
    if (s.strm.avail_out === 0) {
      return BS_FINISH_STARTED;
    }
    /***/
    return BS_FINISH_DONE;
  }
  if (s.last_lit) {
    /*** FLUSH_BLOCK(s, 0); ***/
    flush_block_only(s, false);
    if (s.strm.avail_out === 0) {
      return BS_NEED_MORE;
    }
    /***/
  }
  return BS_BLOCK_DONE;
}

/* Values for max_lazy_match, good_match and max_chain_length, depending on
 * the desired pack level (0..9). The values given below have been tuned to
 * exclude worst case performance for pathological files. Better values may be
 * found for specific files.
 */
function Config(good_length, max_lazy, nice_length, max_chain, func) {
  this.good_length = good_length;
  this.max_lazy = max_lazy;
  this.nice_length = nice_length;
  this.max_chain = max_chain;
  this.func = func;
}

var configuration_table;

configuration_table = [
/*      good lazy nice chain */
new Config(0, 0, 0, 0, deflate_stored), /* 0 store only */
new Config(4, 4, 8, 4, deflate_fast), /* 1 max speed, no lazy matches */
new Config(4, 5, 16, 8, deflate_fast), /* 2 */
new Config(4, 6, 32, 32, deflate_fast), /* 3 */

new Config(4, 4, 16, 16, deflate_slow), /* 4 lazy matches */
new Config(8, 16, 32, 32, deflate_slow), /* 5 */
new Config(8, 16, 128, 128, deflate_slow), /* 6 */
new Config(8, 32, 128, 256, deflate_slow), /* 7 */
new Config(32, 128, 258, 1024, deflate_slow), /* 8 */
new Config(32, 258, 258, 4096, deflate_slow) /* 9 max compression */
];

/* ===========================================================================
 * Initialize the "longest match" routines for a new zlib stream
 */
function lm_init(s) {
  s.window_size = 2 * s.w_size;

  /*** CLEAR_HASH(s); ***/
  zero(s.head); // Fill with NIL (= 0);

  /* Set the default configuration parameters:
   */
  s.max_lazy_match = configuration_table[s.level].max_lazy;
  s.good_match = configuration_table[s.level].good_length;
  s.nice_match = configuration_table[s.level].nice_length;
  s.max_chain_length = configuration_table[s.level].max_chain;

  s.strstart = 0;
  s.block_start = 0;
  s.lookahead = 0;
  s.insert = 0;
  s.match_length = s.prev_length = MIN_MATCH - 1;
  s.match_available = 0;
  s.ins_h = 0;
}

function DeflateState() {
  this.strm = null; /* pointer back to this zlib stream */
  this.status = 0; /* as the name implies */
  this.pending_buf = null; /* output still pending */
  this.pending_buf_size = 0; /* size of pending_buf */
  this.pending_out = 0; /* next pending byte to output to the stream */
  this.pending = 0; /* nb of bytes in the pending buffer */
  this.wrap = 0; /* bit 0 true for zlib, bit 1 true for gzip */
  this.gzhead = null; /* gzip header information to write */
  this.gzindex = 0; /* where in extra, name, or comment */
  this.method = Z_DEFLATED; /* can only be DEFLATED */
  this.last_flush = -1; /* value of flush param for previous deflate call */

  this.w_size = 0; /* LZ77 window size (32K by default) */
  this.w_bits = 0; /* log2(w_size)  (8..16) */
  this.w_mask = 0; /* w_size - 1 */

  this.window = null;
  /* Sliding window. Input bytes are read into the second half of the window,
   * and move to the first half later to keep a dictionary of at least wSize
   * bytes. With this organization, matches are limited to a distance of
   * wSize-MAX_MATCH bytes, but this ensures that IO is always
   * performed with a length multiple of the block size.
   */

  this.window_size = 0;
  /* Actual size of window: 2*wSize, except when the user input buffer
   * is directly used as sliding window.
   */

  this.prev = null;
  /* Link to older string with same hash index. To limit the size of this
   * array to 64K, this link is maintained only for the last 32K strings.
   * An index in this array is thus a window index modulo 32K.
   */

  this.head = null; /* Heads of the hash chains or NIL. */

  this.ins_h = 0; /* hash index of string to be inserted */
  this.hash_size = 0; /* number of elements in hash table */
  this.hash_bits = 0; /* log2(hash_size) */
  this.hash_mask = 0; /* hash_size-1 */

  this.hash_shift = 0;
  /* Number of bits by which ins_h must be shifted at each input
   * step. It must be such that after MIN_MATCH steps, the oldest
   * byte no longer takes part in the hash key, that is:
   *   hash_shift * MIN_MATCH >= hash_bits
   */

  this.block_start = 0;
  /* Window position at the beginning of the current output block. Gets
   * negative when the window is moved backwards.
   */

  this.match_length = 0; /* length of best match */
  this.prev_match = 0; /* previous match */
  this.match_available = 0; /* set if previous match exists */
  this.strstart = 0; /* start of string to insert */
  this.match_start = 0; /* start of matching string */
  this.lookahead = 0; /* number of valid bytes ahead in window */

  this.prev_length = 0;
  /* Length of the best match at previous step. Matches not greater than this
   * are discarded. This is used in the lazy match evaluation.
   */

  this.max_chain_length = 0;
  /* To speed up deflation, hash chains are never searched beyond this
   * length.  A higher limit improves compression ratio but degrades the
   * speed.
   */

  this.max_lazy_match = 0;
  /* Attempt to find a better match only when the current match is strictly
   * smaller than this value. This mechanism is used only for compression
   * levels >= 4.
   */
  // That's alias to max_lazy_match, don't use directly
  //this.max_insert_length = 0;
  /* Insert new strings in the hash table only if the match length is not
   * greater than this length. This saves time but degrades compression.
   * max_insert_length is used only for compression levels <= 3.
   */

  this.level = 0; /* compression level (1..9) */
  this.strategy = 0; /* favor or force Huffman coding*/

  this.good_match = 0;
  /* Use a faster search when the previous match is longer than this */

  this.nice_match = 0; /* Stop searching when current match exceeds this */

  /* used by trees.c: */

  /* Didn't use ct_data typedef below to suppress compiler warning */

  // struct ct_data_s dyn_ltree[HEAP_SIZE];   /* literal and length tree */
  // struct ct_data_s dyn_dtree[2*D_CODES+1]; /* distance tree */
  // struct ct_data_s bl_tree[2*BL_CODES+1];  /* Huffman tree for bit lengths */

  // Use flat array of DOUBLE size, with interleaved fata,
  // because JS does not support effective
  this.dyn_ltree = new utils.Buf16(HEAP_SIZE * 2);
  this.dyn_dtree = new utils.Buf16((2 * D_CODES + 1) * 2);
  this.bl_tree = new utils.Buf16((2 * BL_CODES + 1) * 2);
  zero(this.dyn_ltree);
  zero(this.dyn_dtree);
  zero(this.bl_tree);

  this.l_desc = null; /* desc. for literal tree */
  this.d_desc = null; /* desc. for distance tree */
  this.bl_desc = null; /* desc. for bit length tree */

  //ush bl_count[MAX_BITS+1];
  this.bl_count = new utils.Buf16(MAX_BITS + 1);
  /* number of codes at each bit length for an optimal tree */

  //int heap[2*L_CODES+1];      /* heap used to build the Huffman trees */
  this.heap = new utils.Buf16(2 * L_CODES + 1); /* heap used to build the Huffman trees */
  zero(this.heap);

  this.heap_len = 0; /* number of elements in the heap */
  this.heap_max = 0; /* element of largest frequency */
  /* The sons of heap[n] are heap[2*n] and heap[2*n+1]. heap[0] is not used.
   * The same heap array is used to build all trees.
   */

  this.depth = new utils.Buf16(2 * L_CODES + 1); //uch depth[2*L_CODES+1];
  zero(this.depth);
  /* Depth of each subtree used as tie breaker for trees of equal frequency
   */

  this.l_buf = 0; /* buffer index for literals or lengths */

  this.lit_bufsize = 0;
  /* Size of match buffer for literals/lengths.  There are 4 reasons for
   * limiting lit_bufsize to 64K:
   *   - frequencies can be kept in 16 bit counters
   *   - if compression is not successful for the first block, all input
   *     data is still in the window so we can still emit a stored block even
   *     when input comes from standard input.  (This can also be done for
   *     all blocks if lit_bufsize is not greater than 32K.)
   *   - if compression is not successful for a file smaller than 64K, we can
   *     even emit a stored file instead of a stored block (saving 5 bytes).
   *     This is applicable only for zip (not gzip or zlib).
   *   - creating new Huffman trees less frequently may not provide fast
   *     adaptation to changes in the input data statistics. (Take for
   *     example a binary file with poorly compressible code followed by
   *     a highly compressible string table.) Smaller buffer sizes give
   *     fast adaptation but have of course the overhead of transmitting
   *     trees more frequently.
   *   - I can't count above 4
   */

  this.last_lit = 0; /* running index in l_buf */

  this.d_buf = 0;
  /* Buffer index for distances. To simplify the code, d_buf and l_buf have
   * the same number of elements. To use different lengths, an extra flag
   * array would be necessary.
   */

  this.opt_len = 0; /* bit length of current block with optimal trees */
  this.static_len = 0; /* bit length of current block with static trees */
  this.matches = 0; /* number of string matches in current block */
  this.insert = 0; /* bytes at end of window left to insert */

  this.bi_buf = 0;
  /* Output buffer. bits are inserted starting at the bottom (least
   * significant bits).
   */
  this.bi_valid = 0;
  /* Number of valid bits in bi_buf.  All bits above the last valid bit
   * are always zero.
   */

  // Used for window memory init. We safely ignore it for JS. That makes
  // sense only for pointers and memory check tools.
  //this.high_water = 0;
  /* High water mark offset in window for initialized bytes -- bytes above
   * this are set to zero in order to avoid memory check warnings when
   * longest match routines access bytes past the input.  This is then
   * updated to the new high water mark.
   */
}

function deflateResetKeep(strm) {
  var s;

  if (!strm || !strm.state) {
    return err(strm, Z_STREAM_ERROR);
  }

  strm.total_in = strm.total_out = 0;
  strm.data_type = Z_UNKNOWN;

  s = strm.state;
  s.pending = 0;
  s.pending_out = 0;

  if (s.wrap < 0) {
    s.wrap = -s.wrap;
    /* was made negative by deflate(..., Z_FINISH); */
  }
  s.status = s.wrap ? INIT_STATE : BUSY_STATE;
  strm.adler = s.wrap === 2 ? 0 // crc32(0, Z_NULL, 0)
  : 1; // adler32(0, Z_NULL, 0)
  s.last_flush = Z_NO_FLUSH;
  trees._tr_init(s);
  return Z_OK;
}

function deflateReset(strm) {
  var ret = deflateResetKeep(strm);
  if (ret === Z_OK) {
    lm_init(strm.state);
  }
  return ret;
}

function deflateSetHeader(strm, head) {
  if (!strm || !strm.state) {
    return Z_STREAM_ERROR;
  }
  if (strm.state.wrap !== 2) {
    return Z_STREAM_ERROR;
  }
  strm.state.gzhead = head;
  return Z_OK;
}

function deflateInit2(strm, level, method, windowBits, memLevel, strategy) {
  if (!strm) {
    // === Z_NULL
    return Z_STREAM_ERROR;
  }
  var wrap = 1;

  if (level === Z_DEFAULT_COMPRESSION) {
    level = 6;
  }

  if (windowBits < 0) {
    /* suppress zlib wrapper */
    wrap = 0;
    windowBits = -windowBits;
  } else if (windowBits > 15) {
    wrap = 2; /* write gzip wrapper instead */
    windowBits -= 16;
  }

  if (memLevel < 1 || memLevel > MAX_MEM_LEVEL || method !== Z_DEFLATED || windowBits < 8 || windowBits > 15 || level < 0 || level > 9 || strategy < 0 || strategy > Z_FIXED) {
    return err(strm, Z_STREAM_ERROR);
  }

  if (windowBits === 8) {
    windowBits = 9;
  }
  /* until 256-byte window bug fixed */

  var s = new DeflateState();

  strm.state = s;
  s.strm = strm;

  s.wrap = wrap;
  s.gzhead = null;
  s.w_bits = windowBits;
  s.w_size = 1 << s.w_bits;
  s.w_mask = s.w_size - 1;

  s.hash_bits = memLevel + 7;
  s.hash_size = 1 << s.hash_bits;
  s.hash_mask = s.hash_size - 1;
  s.hash_shift = ~~((s.hash_bits + MIN_MATCH - 1) / MIN_MATCH);

  s.window = new utils.Buf8(s.w_size * 2);
  s.head = new utils.Buf16(s.hash_size);
  s.prev = new utils.Buf16(s.w_size);

  // Don't need mem init magic for JS.
  //s.high_water = 0;  /* nothing written to s->window yet */

  s.lit_bufsize = 1 << memLevel + 6; /* 16K elements by default */

  s.pending_buf_size = s.lit_bufsize * 4;

  //overlay = (ushf *) ZALLOC(strm, s->lit_bufsize, sizeof(ush)+2);
  //s->pending_buf = (uchf *) overlay;
  s.pending_buf = new utils.Buf8(s.pending_buf_size);

  // It is offset from `s.pending_buf` (size is `s.lit_bufsize * 2`)
  //s->d_buf = overlay + s->lit_bufsize/sizeof(ush);
  s.d_buf = 1 * s.lit_bufsize;

  //s->l_buf = s->pending_buf + (1+sizeof(ush))*s->lit_bufsize;
  s.l_buf = (1 + 2) * s.lit_bufsize;

  s.level = level;
  s.strategy = strategy;
  s.method = method;

  return deflateReset(strm);
}

function deflateInit(strm, level) {
  return deflateInit2(strm, level, Z_DEFLATED, MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY);
}

function deflate(strm, flush) {
  var old_flush, s;
  var beg, val; // for gzip header write only

  if (!strm || !strm.state || flush > Z_BLOCK || flush < 0) {
    return strm ? err(strm, Z_STREAM_ERROR) : Z_STREAM_ERROR;
  }

  s = strm.state;

  if (!strm.output || !strm.input && strm.avail_in !== 0 || s.status === FINISH_STATE && flush !== Z_FINISH) {
    return err(strm, strm.avail_out === 0 ? Z_BUF_ERROR : Z_STREAM_ERROR);
  }

  s.strm = strm; /* just in case */
  old_flush = s.last_flush;
  s.last_flush = flush;

  /* Write the header */
  if (s.status === INIT_STATE) {

    if (s.wrap === 2) {
      // GZIP header
      strm.adler = 0; //crc32(0L, Z_NULL, 0);
      put_byte(s, 31);
      put_byte(s, 139);
      put_byte(s, 8);
      if (!s.gzhead) {
        // s->gzhead == Z_NULL
        put_byte(s, 0);
        put_byte(s, 0);
        put_byte(s, 0);
        put_byte(s, 0);
        put_byte(s, 0);
        put_byte(s, s.level === 9 ? 2 : s.strategy >= Z_HUFFMAN_ONLY || s.level < 2 ? 4 : 0);
        put_byte(s, OS_CODE);
        s.status = BUSY_STATE;
      } else {
        put_byte(s, (s.gzhead.text ? 1 : 0) + (s.gzhead.hcrc ? 2 : 0) + (!s.gzhead.extra ? 0 : 4) + (!s.gzhead.name ? 0 : 8) + (!s.gzhead.comment ? 0 : 16));
        put_byte(s, s.gzhead.time & 0xff);
        put_byte(s, s.gzhead.time >> 8 & 0xff);
        put_byte(s, s.gzhead.time >> 16 & 0xff);
        put_byte(s, s.gzhead.time >> 24 & 0xff);
        put_byte(s, s.level === 9 ? 2 : s.strategy >= Z_HUFFMAN_ONLY || s.level < 2 ? 4 : 0);
        put_byte(s, s.gzhead.os & 0xff);
        if (s.gzhead.extra && s.gzhead.extra.length) {
          put_byte(s, s.gzhead.extra.length & 0xff);
          put_byte(s, s.gzhead.extra.length >> 8 & 0xff);
        }
        if (s.gzhead.hcrc) {
          strm.adler = (0, _crc2.default)(strm.adler, s.pending_buf, s.pending, 0);
        }
        s.gzindex = 0;
        s.status = EXTRA_STATE;
      }
    } else // DEFLATE header
      {
        var header = Z_DEFLATED + (s.w_bits - 8 << 4) << 8;
        var level_flags = -1;

        if (s.strategy >= Z_HUFFMAN_ONLY || s.level < 2) {
          level_flags = 0;
        } else if (s.level < 6) {
          level_flags = 1;
        } else if (s.level === 6) {
          level_flags = 2;
        } else {
          level_flags = 3;
        }
        header |= level_flags << 6;
        if (s.strstart !== 0) {
          header |= PRESET_DICT;
        }
        header += 31 - header % 31;

        s.status = BUSY_STATE;
        putShortMSB(s, header);

        /* Save the adler32 of the preset dictionary: */
        if (s.strstart !== 0) {
          putShortMSB(s, strm.adler >>> 16);
          putShortMSB(s, strm.adler & 0xffff);
        }
        strm.adler = 1; // adler32(0L, Z_NULL, 0);
      }
  }

  //#ifdef GZIP
  if (s.status === EXTRA_STATE) {
    if (s.gzhead.extra /* != Z_NULL*/) {
        beg = s.pending; /* start of bytes to update crc */

        while (s.gzindex < (s.gzhead.extra.length & 0xffff)) {
          if (s.pending === s.pending_buf_size) {
            if (s.gzhead.hcrc && s.pending > beg) {
              strm.adler = (0, _crc2.default)(strm.adler, s.pending_buf, s.pending - beg, beg);
            }
            flush_pending(strm);
            beg = s.pending;
            if (s.pending === s.pending_buf_size) {
              break;
            }
          }
          put_byte(s, s.gzhead.extra[s.gzindex] & 0xff);
          s.gzindex++;
        }
        if (s.gzhead.hcrc && s.pending > beg) {
          strm.adler = (0, _crc2.default)(strm.adler, s.pending_buf, s.pending - beg, beg);
        }
        if (s.gzindex === s.gzhead.extra.length) {
          s.gzindex = 0;
          s.status = NAME_STATE;
        }
      } else {
      s.status = NAME_STATE;
    }
  }
  if (s.status === NAME_STATE) {
    if (s.gzhead.name /* != Z_NULL*/) {
        beg = s.pending; /* start of bytes to update crc */
        //int val;

        do {
          if (s.pending === s.pending_buf_size) {
            if (s.gzhead.hcrc && s.pending > beg) {
              strm.adler = (0, _crc2.default)(strm.adler, s.pending_buf, s.pending - beg, beg);
            }
            flush_pending(strm);
            beg = s.pending;
            if (s.pending === s.pending_buf_size) {
              val = 1;
              break;
            }
          }
          // JS specific: little magic to add zero terminator to end of string
          if (s.gzindex < s.gzhead.name.length) {
            val = s.gzhead.name.charCodeAt(s.gzindex++) & 0xff;
          } else {
            val = 0;
          }
          put_byte(s, val);
        } while (val !== 0);

        if (s.gzhead.hcrc && s.pending > beg) {
          strm.adler = (0, _crc2.default)(strm.adler, s.pending_buf, s.pending - beg, beg);
        }
        if (val === 0) {
          s.gzindex = 0;
          s.status = COMMENT_STATE;
        }
      } else {
      s.status = COMMENT_STATE;
    }
  }
  if (s.status === COMMENT_STATE) {
    if (s.gzhead.comment /* != Z_NULL*/) {
        beg = s.pending; /* start of bytes to update crc */
        //int val;

        do {
          if (s.pending === s.pending_buf_size) {
            if (s.gzhead.hcrc && s.pending > beg) {
              strm.adler = (0, _crc2.default)(strm.adler, s.pending_buf, s.pending - beg, beg);
            }
            flush_pending(strm);
            beg = s.pending;
            if (s.pending === s.pending_buf_size) {
              val = 1;
              break;
            }
          }
          // JS specific: little magic to add zero terminator to end of string
          if (s.gzindex < s.gzhead.comment.length) {
            val = s.gzhead.comment.charCodeAt(s.gzindex++) & 0xff;
          } else {
            val = 0;
          }
          put_byte(s, val);
        } while (val !== 0);

        if (s.gzhead.hcrc && s.pending > beg) {
          strm.adler = (0, _crc2.default)(strm.adler, s.pending_buf, s.pending - beg, beg);
        }
        if (val === 0) {
          s.status = HCRC_STATE;
        }
      } else {
      s.status = HCRC_STATE;
    }
  }
  if (s.status === HCRC_STATE) {
    if (s.gzhead.hcrc) {
      if (s.pending + 2 > s.pending_buf_size) {
        flush_pending(strm);
      }
      if (s.pending + 2 <= s.pending_buf_size) {
        put_byte(s, strm.adler & 0xff);
        put_byte(s, strm.adler >> 8 & 0xff);
        strm.adler = 0; //crc32(0L, Z_NULL, 0);
        s.status = BUSY_STATE;
      }
    } else {
      s.status = BUSY_STATE;
    }
  }
  //#endif

  /* Flush as much pending output as possible */
  if (s.pending !== 0) {
    flush_pending(strm);
    if (strm.avail_out === 0) {
      /* Since avail_out is 0, deflate will be called again with
       * more output space, but possibly with both pending and
       * avail_in equal to zero. There won't be anything to do,
       * but this is not an error situation so make sure we
       * return OK instead of BUF_ERROR at next call of deflate:
       */
      s.last_flush = -1;
      return Z_OK;
    }

    /* Make sure there is something to do and avoid duplicate consecutive
     * flushes. For repeated and useless calls with Z_FINISH, we keep
     * returning Z_STREAM_END instead of Z_BUF_ERROR.
     */
  } else if (strm.avail_in === 0 && rank(flush) <= rank(old_flush) && flush !== Z_FINISH) {
    return err(strm, Z_BUF_ERROR);
  }

  /* User must not provide more input after the first FINISH: */
  if (s.status === FINISH_STATE && strm.avail_in !== 0) {
    return err(strm, Z_BUF_ERROR);
  }

  /* Start a new block or continue the current one.
   */
  if (strm.avail_in !== 0 || s.lookahead !== 0 || flush !== Z_NO_FLUSH && s.status !== FINISH_STATE) {
    var bstate = s.strategy === Z_HUFFMAN_ONLY ? deflate_huff(s, flush) : s.strategy === Z_RLE ? deflate_rle(s, flush) : configuration_table[s.level].func(s, flush);

    if (bstate === BS_FINISH_STARTED || bstate === BS_FINISH_DONE) {
      s.status = FINISH_STATE;
    }
    if (bstate === BS_NEED_MORE || bstate === BS_FINISH_STARTED) {
      if (strm.avail_out === 0) {
        s.last_flush = -1;
        /* avoid BUF_ERROR next call, see above */
      }
      return Z_OK;
      /* If flush != Z_NO_FLUSH && avail_out == 0, the next call
       * of deflate should use the same flush parameter to make sure
       * that the flush is complete. So we don't have to output an
       * empty block here, this will be done at next call. This also
       * ensures that for a very small output buffer, we emit at most
       * one empty block.
       */
    }
    if (bstate === BS_BLOCK_DONE) {
      if (flush === Z_PARTIAL_FLUSH) {
        trees._tr_align(s);
      } else if (flush !== Z_BLOCK) {
        /* FULL_FLUSH or SYNC_FLUSH */

        trees._tr_stored_block(s, 0, 0, false);
        /* For a full flush, this empty block will be recognized
         * as a special marker by inflate_sync().
         */
        if (flush === Z_FULL_FLUSH) {
          /*** CLEAR_HASH(s); ***/ /* forget history */
          zero(s.head); // Fill with NIL (= 0);

          if (s.lookahead === 0) {
            s.strstart = 0;
            s.block_start = 0;
            s.insert = 0;
          }
        }
      }
      flush_pending(strm);
      if (strm.avail_out === 0) {
        s.last_flush = -1; /* avoid BUF_ERROR at next call, see above */
        return Z_OK;
      }
    }
  }
  //Assert(strm->avail_out > 0, "bug2");
  //if (strm.avail_out <= 0) { throw new Error("bug2");}

  if (flush !== Z_FINISH) {
    return Z_OK;
  }
  if (s.wrap <= 0) {
    return Z_STREAM_END;
  }

  /* Write the trailer */
  if (s.wrap === 2) {
    put_byte(s, strm.adler & 0xff);
    put_byte(s, strm.adler >> 8 & 0xff);
    put_byte(s, strm.adler >> 16 & 0xff);
    put_byte(s, strm.adler >> 24 & 0xff);
    put_byte(s, strm.total_in & 0xff);
    put_byte(s, strm.total_in >> 8 & 0xff);
    put_byte(s, strm.total_in >> 16 & 0xff);
    put_byte(s, strm.total_in >> 24 & 0xff);
  } else {
    putShortMSB(s, strm.adler >>> 16);
    putShortMSB(s, strm.adler & 0xffff);
  }

  flush_pending(strm);
  /* If avail_out is zero, the application will call deflate again
   * to flush the rest.
   */
  if (s.wrap > 0) {
    s.wrap = -s.wrap;
  }
  /* write the trailer only once! */
  return s.pending !== 0 ? Z_OK : Z_STREAM_END;
}

function deflateEnd(strm) {
  var status;

  if (!strm /*== Z_NULL*/ || !strm.state /*== Z_NULL*/) {
      return Z_STREAM_ERROR;
    }

  status = strm.state.status;
  if (status !== INIT_STATE && status !== EXTRA_STATE && status !== NAME_STATE && status !== COMMENT_STATE && status !== HCRC_STATE && status !== BUSY_STATE && status !== FINISH_STATE) {
    return err(strm, Z_STREAM_ERROR);
  }

  strm.state = null;

  return status === BUSY_STATE ? err(strm, Z_DATA_ERROR) : Z_OK;
}

/* =========================================================================
 * Initializes the compression dictionary from the given byte
 * sequence without producing any compressed output.
 */
function deflateSetDictionary(strm, dictionary) {
  var dictLength = dictionary.length;

  var s;
  var str, n;
  var wrap;
  var avail;
  var next;
  var input;
  var tmpDict;

  if (!strm /*== Z_NULL*/ || !strm.state /*== Z_NULL*/) {
      return Z_STREAM_ERROR;
    }

  s = strm.state;
  wrap = s.wrap;

  if (wrap === 2 || wrap === 1 && s.status !== INIT_STATE || s.lookahead) {
    return Z_STREAM_ERROR;
  }

  /* when using zlib wrappers, compute Adler-32 for provided dictionary */
  if (wrap === 1) {
    /* adler32(strm->adler, dictionary, dictLength); */
    strm.adler = (0, _adler2.default)(strm.adler, dictionary, dictLength, 0);
  }

  s.wrap = 0; /* avoid computing Adler-32 in read_buf */

  /* if dictionary would fill window, just replace the history */
  if (dictLength >= s.w_size) {
    if (wrap === 0) {
      /* already empty otherwise */
      /*** CLEAR_HASH(s); ***/
      zero(s.head); // Fill with NIL (= 0);
      s.strstart = 0;
      s.block_start = 0;
      s.insert = 0;
    }
    /* use the tail */
    // dictionary = dictionary.slice(dictLength - s.w_size);
    tmpDict = new utils.Buf8(s.w_size);
    utils.arraySet(tmpDict, dictionary, dictLength - s.w_size, s.w_size, 0);
    dictionary = tmpDict;
    dictLength = s.w_size;
  }
  /* insert dictionary into window and hash */
  avail = strm.avail_in;
  next = strm.next_in;
  input = strm.input;
  strm.avail_in = dictLength;
  strm.next_in = 0;
  strm.input = dictionary;
  fill_window(s);
  while (s.lookahead >= MIN_MATCH) {
    str = s.strstart;
    n = s.lookahead - (MIN_MATCH - 1);
    do {
      /* UPDATE_HASH(s, s->ins_h, s->window[str + MIN_MATCH-1]); */
      s.ins_h = (s.ins_h << s.hash_shift ^ s.window[str + MIN_MATCH - 1]) & s.hash_mask;

      s.prev[str & s.w_mask] = s.head[s.ins_h];

      s.head[s.ins_h] = str;
      str++;
    } while (--n);
    s.strstart = str;
    s.lookahead = MIN_MATCH - 1;
    fill_window(s);
  }
  s.strstart += s.lookahead;
  s.block_start = s.strstart;
  s.insert = s.lookahead;
  s.lookahead = 0;
  s.match_length = s.prev_length = MIN_MATCH - 1;
  s.match_available = 0;
  strm.next_in = next;
  strm.input = input;
  strm.avail_in = avail;
  s.wrap = wrap;
  return Z_OK;
}

exports.deflateInit = deflateInit;
exports.deflateInit2 = deflateInit2;
exports.deflateReset = deflateReset;
exports.deflateResetKeep = deflateResetKeep;
exports.deflateSetHeader = deflateSetHeader;
exports.deflate = deflate;
exports.deflateEnd = deflateEnd;
exports.deflateSetDictionary = deflateSetDictionary;
var deflateInfo = exports.deflateInfo = 'pako deflate (from Nodeca project)';

/* Not implemented
exports.deflateBound = deflateBound;
exports.deflateCopy = deflateCopy;
exports.deflateParams = deflateParams;
exports.deflatePending = deflatePending;
exports.deflatePrime = deflatePrime;
exports.deflateTune = deflateTune;
*/
},{"../utils/common.js":35,"./adler32.js":36,"./crc32.js":37,"./messages.js":42,"./trees.js":43}],39:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = inflate_fast;
// See state defs from inflate.js
var BAD = 30; /* got a data error -- remain here until reset */
var TYPE = 12; /* i: waiting for type bits, including last-flag bit */

/*
   Decode literal, length, and distance codes and write out the resulting
   literal and match bytes until either not enough input or output is
   available, an end-of-block is encountered, or a data error is encountered.
   When large enough input and output buffers are supplied to inflate(), for
   example, a 16K input buffer and a 64K output buffer, more than 95% of the
   inflate execution time is spent in this routine.

   Entry assumptions:

        state.mode === LEN
        strm.avail_in >= 6
        strm.avail_out >= 258
        start >= strm.avail_out
        state.bits < 8

   On return, state.mode is one of:

        LEN -- ran out of enough output space or enough available input
        TYPE -- reached end of block code, inflate() to interpret next block
        BAD -- error in block data

   Notes:

    - The maximum input bits used by a length/distance pair is 15 bits for the
      length code, 5 bits for the length extra, 15 bits for the distance code,
      and 13 bits for the distance extra.  This totals 48 bits, or six bytes.
      Therefore if strm.avail_in >= 6, then there is enough input to avoid
      checking for available input while decoding.

    - The maximum bytes that a single length/distance pair can output is 258
      bytes, which is the maximum length that can be coded.  inflate_fast()
      requires strm.avail_out >= 258 for each loop to avoid checking for
      output space.
 */
function inflate_fast(strm, start) {
  var state;
  var _in; /* local strm.input */
  var last; /* have enough input while in < last */
  var _out; /* local strm.output */
  var beg; /* inflate()'s initial strm.output */
  var end; /* while out < end, enough space available */
  //#ifdef INFLATE_STRICT
  var dmax; /* maximum distance from zlib header */
  //#endif
  var wsize; /* window size or zero if not using window */
  var whave; /* valid bytes in the window */
  var wnext; /* window write index */
  // Use `s_window` instead `window`, avoid conflict with instrumentation tools
  var s_window; /* allocated sliding window, if wsize != 0 */
  var hold; /* local strm.hold */
  var bits; /* local strm.bits */
  var lcode; /* local strm.lencode */
  var dcode; /* local strm.distcode */
  var lmask; /* mask for first level of length codes */
  var dmask; /* mask for first level of distance codes */
  var here; /* retrieved table entry */
  var op; /* code bits, operation, extra bits, or */
  /*  window position, window bytes to copy */
  var len; /* match length, unused bytes */
  var dist; /* match distance */
  var from; /* where to copy match from */
  var from_source;

  var input, output; // JS specific, because we have no pointers

  /* copy state to local variables */
  state = strm.state;
  //here = state.here;
  _in = strm.next_in;
  input = strm.input;
  last = _in + (strm.avail_in - 5);
  _out = strm.next_out;
  output = strm.output;
  beg = _out - (start - strm.avail_out);
  end = _out + (strm.avail_out - 257);
  //#ifdef INFLATE_STRICT
  dmax = state.dmax;
  //#endif
  wsize = state.wsize;
  whave = state.whave;
  wnext = state.wnext;
  s_window = state.window;
  hold = state.hold;
  bits = state.bits;
  lcode = state.lencode;
  dcode = state.distcode;
  lmask = (1 << state.lenbits) - 1;
  dmask = (1 << state.distbits) - 1;

  /* decode literals and length/distances until end-of-block or not enough
     input data or output space */

  top: do {
    if (bits < 15) {
      hold += input[_in++] << bits;
      bits += 8;
      hold += input[_in++] << bits;
      bits += 8;
    }

    here = lcode[hold & lmask];

    dolen: for (;;) {
      // Goto emulation
      op = here >>> 24 /*here.bits*/;
      hold >>>= op;
      bits -= op;
      op = here >>> 16 & 0xff /*here.op*/;
      if (op === 0) {
        /* literal */
        //Tracevv((stderr, here.val >= 0x20 && here.val < 0x7f ?
        //        "inflate:         literal '%c'\n" :
        //        "inflate:         literal 0x%02x\n", here.val));
        output[_out++] = here & 0xffff /*here.val*/;
      } else if (op & 16) {
        /* length base */
        len = here & 0xffff /*here.val*/;
        op &= 15; /* number of extra bits */
        if (op) {
          if (bits < op) {
            hold += input[_in++] << bits;
            bits += 8;
          }
          len += hold & (1 << op) - 1;
          hold >>>= op;
          bits -= op;
        }
        //Tracevv((stderr, "inflate:         length %u\n", len));
        if (bits < 15) {
          hold += input[_in++] << bits;
          bits += 8;
          hold += input[_in++] << bits;
          bits += 8;
        }
        here = dcode[hold & dmask];

        dodist: for (;;) {
          // goto emulation
          op = here >>> 24 /*here.bits*/;
          hold >>>= op;
          bits -= op;
          op = here >>> 16 & 0xff /*here.op*/;

          if (op & 16) {
            /* distance base */
            dist = here & 0xffff /*here.val*/;
            op &= 15; /* number of extra bits */
            if (bits < op) {
              hold += input[_in++] << bits;
              bits += 8;
              if (bits < op) {
                hold += input[_in++] << bits;
                bits += 8;
              }
            }
            dist += hold & (1 << op) - 1;
            //#ifdef INFLATE_STRICT
            if (dist > dmax) {
              strm.msg = 'invalid distance too far back';
              state.mode = BAD;
              break top;
            }
            //#endif
            hold >>>= op;
            bits -= op;
            //Tracevv((stderr, "inflate:         distance %u\n", dist));
            op = _out - beg; /* max distance in output */
            if (dist > op) {
              /* see if copy from window */
              op = dist - op; /* distance back in window */
              if (op > whave) {
                if (state.sane) {
                  strm.msg = 'invalid distance too far back';
                  state.mode = BAD;
                  break top;
                }

                // (!) This block is disabled in zlib defailts,
                // don't enable it for binary compatibility
                //#ifdef INFLATE_ALLOW_INVALID_DISTANCE_TOOFAR_ARRR
                //                if (len <= op - whave) {
                //                  do {
                //                    output[_out++] = 0;
                //                  } while (--len);
                //                  continue top;
                //                }
                //                len -= op - whave;
                //                do {
                //                  output[_out++] = 0;
                //                } while (--op > whave);
                //                if (op === 0) {
                //                  from = _out - dist;
                //                  do {
                //                    output[_out++] = output[from++];
                //                  } while (--len);
                //                  continue top;
                //                }
                //#endif
              }
              from = 0; // window index
              from_source = s_window;
              if (wnext === 0) {
                /* very common case */
                from += wsize - op;
                if (op < len) {
                  /* some from window */
                  len -= op;
                  do {
                    output[_out++] = s_window[from++];
                  } while (--op);
                  from = _out - dist; /* rest from output */
                  from_source = output;
                }
              } else if (wnext < op) {
                /* wrap around window */
                from += wsize + wnext - op;
                op -= wnext;
                if (op < len) {
                  /* some from end of window */
                  len -= op;
                  do {
                    output[_out++] = s_window[from++];
                  } while (--op);
                  from = 0;
                  if (wnext < len) {
                    /* some from start of window */
                    op = wnext;
                    len -= op;
                    do {
                      output[_out++] = s_window[from++];
                    } while (--op);
                    from = _out - dist; /* rest from output */
                    from_source = output;
                  }
                }
              } else {
                /* contiguous in window */
                from += wnext - op;
                if (op < len) {
                  /* some from window */
                  len -= op;
                  do {
                    output[_out++] = s_window[from++];
                  } while (--op);
                  from = _out - dist; /* rest from output */
                  from_source = output;
                }
              }
              while (len > 2) {
                output[_out++] = from_source[from++];
                output[_out++] = from_source[from++];
                output[_out++] = from_source[from++];
                len -= 3;
              }
              if (len) {
                output[_out++] = from_source[from++];
                if (len > 1) {
                  output[_out++] = from_source[from++];
                }
              }
            } else {
              from = _out - dist; /* copy direct from output */
              do {
                /* minimum length is three */
                output[_out++] = output[from++];
                output[_out++] = output[from++];
                output[_out++] = output[from++];
                len -= 3;
              } while (len > 2);
              if (len) {
                output[_out++] = output[from++];
                if (len > 1) {
                  output[_out++] = output[from++];
                }
              }
            }
          } else if ((op & 64) === 0) {
            /* 2nd level distance code */
            here = dcode[(here & 0xffff) + ( /*here.val*/hold & (1 << op) - 1)];
            continue dodist;
          } else {
            strm.msg = 'invalid distance code';
            state.mode = BAD;
            break top;
          }

          break; // need to emulate goto via "continue"
        }
      } else if ((op & 64) === 0) {
        /* 2nd level length code */
        here = lcode[(here & 0xffff) + ( /*here.val*/hold & (1 << op) - 1)];
        continue dolen;
      } else if (op & 32) {
        /* end-of-block */
        //Tracevv((stderr, "inflate:         end of block\n"));
        state.mode = TYPE;
        break top;
      } else {
        strm.msg = 'invalid literal/length code';
        state.mode = BAD;
        break top;
      }

      break; // need to emulate goto via "continue"
    }
  } while (_in < last && _out < end);

  /* return unused bytes (on entry, bits < 8, so in won't go too far back) */
  len = bits >> 3;
  _in -= len;
  bits -= len << 3;
  hold &= (1 << bits) - 1;

  /* update state and return */
  strm.next_in = _in;
  strm.next_out = _out;
  strm.avail_in = _in < last ? 5 + (last - _in) : 5 - (_in - last);
  strm.avail_out = _out < end ? 257 + (end - _out) : 257 - (_out - end);
  state.hold = hold;
  state.bits = bits;
  return;
};
},{}],40:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.inflateInfo = exports.inflateSetDictionary = exports.inflateGetHeader = exports.inflateEnd = exports.inflate = exports.inflateInit2 = exports.inflateInit = exports.inflateResetKeep = exports.inflateReset2 = exports.inflateReset = exports.Z_DEFLATED = exports.Z_BUF_ERROR = exports.Z_MEM_ERROR = exports.Z_DATA_ERROR = exports.Z_STREAM_ERROR = exports.Z_NEED_DICT = exports.Z_STREAM_END = exports.Z_OK = exports.Z_TREES = exports.Z_BLOCK = exports.Z_FINISH = undefined;

var _common = require("../utils/common.js");

var utils = _interopRequireWildcard(_common);

var _adler = require("./adler32.js");

var _adler2 = _interopRequireDefault(_adler);

var _crc = require("./crc32.js");

var _crc2 = _interopRequireDefault(_crc);

var _inffast = require("./inffast.js");

var _inffast2 = _interopRequireDefault(_inffast);

var _inftrees = require("./inftrees.js");

var _inftrees2 = _interopRequireDefault(_inftrees);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

var CODES = 0;
var LENS = 1;
var DISTS = 2;

/* Public constants ==========================================================*/
/* ===========================================================================*/

/* Allowed flush values; see deflate() and inflate() below for details */
//export const Z_NO_FLUSH      = 0;
//export const Z_PARTIAL_FLUSH = 1;
//export const Z_SYNC_FLUSH    = 2;
//export const Z_FULL_FLUSH    = 3;
var Z_FINISH = exports.Z_FINISH = 4;
var Z_BLOCK = exports.Z_BLOCK = 5;
var Z_TREES = exports.Z_TREES = 6;

/* Return codes for the compression/decompression functions. Negative values
 * are errors, positive values are used for special but normal events.
 */
var Z_OK = exports.Z_OK = 0;
var Z_STREAM_END = exports.Z_STREAM_END = 1;
var Z_NEED_DICT = exports.Z_NEED_DICT = 2;
//export const Z_ERRNO         = -1;
var Z_STREAM_ERROR = exports.Z_STREAM_ERROR = -2;
var Z_DATA_ERROR = exports.Z_DATA_ERROR = -3;
var Z_MEM_ERROR = exports.Z_MEM_ERROR = -4;
var Z_BUF_ERROR = exports.Z_BUF_ERROR = -5;
//export const Z_VERSION_ERROR = -6;

/* The deflate compression method */
var Z_DEFLATED = exports.Z_DEFLATED = 8;

/* STATES ====================================================================*/
/* ===========================================================================*/

var HEAD = 1; /* i: waiting for magic header */
var FLAGS = 2; /* i: waiting for method and flags (gzip) */
var TIME = 3; /* i: waiting for modification time (gzip) */
var OS = 4; /* i: waiting for extra flags and operating system (gzip) */
var EXLEN = 5; /* i: waiting for extra length (gzip) */
var EXTRA = 6; /* i: waiting for extra bytes (gzip) */
var NAME = 7; /* i: waiting for end of file name (gzip) */
var COMMENT = 8; /* i: waiting for end of comment (gzip) */
var HCRC = 9; /* i: waiting for header crc (gzip) */
var DICTID = 10; /* i: waiting for dictionary check value */
var DICT = 11; /* waiting for inflateSetDictionary() call */
var TYPE = 12; /* i: waiting for type bits, including last-flag bit */
var TYPEDO = 13; /* i: same, but skip check to exit inflate on new block */
var STORED = 14; /* i: waiting for stored size (length and complement) */
var COPY_ = 15; /* i/o: same as COPY below, but only first time in */
var COPY = 16; /* i/o: waiting for input or output to copy stored block */
var TABLE = 17; /* i: waiting for dynamic block table lengths */
var LENLENS = 18; /* i: waiting for code length code lengths */
var CODELENS = 19; /* i: waiting for length/lit and distance code lengths */
var LEN_ = 20; /* i: same as LEN below, but only first time in */
var LEN = 21; /* i: waiting for length/lit/eob code */
var LENEXT = 22; /* i: waiting for length extra bits */
var DIST = 23; /* i: waiting for distance code */
var DISTEXT = 24; /* i: waiting for distance extra bits */
var MATCH = 25; /* o: waiting for output space to copy string */
var LIT = 26; /* o: waiting for output space to write literal */
var CHECK = 27; /* i: waiting for 32-bit check value */
var LENGTH = 28; /* i: waiting for 32-bit length (gzip) */
var DONE = 29; /* finished check, done -- remain here until reset */
var BAD = 30; /* got a data error -- remain here until reset */
var MEM = 31; /* got an inflate() memory error -- remain here until reset */
var SYNC = 32; /* looking for synchronization bytes to restart inflate() */

/* ===========================================================================*/

var ENOUGH_LENS = 852;
var ENOUGH_DISTS = 592;
//var ENOUGH =  (ENOUGH_LENS+ENOUGH_DISTS);

var MAX_WBITS = 15;
/* 32K LZ77 window */
var DEF_WBITS = MAX_WBITS;

function zswap32(q) {
  return (q >>> 24 & 0xff) + (q >>> 8 & 0xff00) + ((q & 0xff00) << 8) + ((q & 0xff) << 24);
}

function InflateState() {
  this.mode = 0; /* current inflate mode */
  this.last = false; /* true if processing last block */
  this.wrap = 0; /* bit 0 true for zlib, bit 1 true for gzip */
  this.havedict = false; /* true if dictionary provided */
  this.flags = 0; /* gzip header method and flags (0 if zlib) */
  this.dmax = 0; /* zlib header max distance (INFLATE_STRICT) */
  this.check = 0; /* protected copy of check value */
  this.total = 0; /* protected copy of output count */
  // TODO: may be {}
  this.head = null; /* where to save gzip header information */

  /* sliding window */
  this.wbits = 0; /* log base 2 of requested window size */
  this.wsize = 0; /* window size or zero if not using window */
  this.whave = 0; /* valid bytes in the window */
  this.wnext = 0; /* window write index */
  this.window = null; /* allocated sliding window, if needed */

  /* bit accumulator */
  this.hold = 0; /* input bit accumulator */
  this.bits = 0; /* number of bits in "in" */

  /* for string and stored block copying */
  this.length = 0; /* literal or length of data to copy */
  this.offset = 0; /* distance back to copy string from */

  /* for table and code decoding */
  this.extra = 0; /* extra bits needed */

  /* fixed and dynamic code tables */
  this.lencode = null; /* starting table for length/literal codes */
  this.distcode = null; /* starting table for distance codes */
  this.lenbits = 0; /* index bits for lencode */
  this.distbits = 0; /* index bits for distcode */

  /* dynamic table building */
  this.ncode = 0; /* number of code length code lengths */
  this.nlen = 0; /* number of length code lengths */
  this.ndist = 0; /* number of distance code lengths */
  this.have = 0; /* number of code lengths in lens[] */
  this.next = null; /* next available space in codes[] */

  this.lens = new utils.Buf16(320); /* temporary storage for code lengths */
  this.work = new utils.Buf16(288); /* work area for code table building */

  /*
   because we don't have pointers in js, we use lencode and distcode directly
   as buffers so we don't need codes
  */
  //this.codes = new utils.Buf32(ENOUGH);       /* space for code tables */
  this.lendyn = null; /* dynamic table for length/literal codes (JS specific) */
  this.distdyn = null; /* dynamic table for distance codes (JS specific) */
  this.sane = 0; /* if false, allow invalid distance too far */
  this.back = 0; /* bits back of last unprocessed length/lit */
  this.was = 0; /* initial length of match */
}

function inflateResetKeep(strm) {
  var state;

  if (!strm || !strm.state) {
    return Z_STREAM_ERROR;
  }
  state = strm.state;
  strm.total_in = strm.total_out = state.total = 0;
  strm.msg = ''; /*Z_NULL*/
  if (state.wrap) {
    /* to support ill-conceived Java test suite */
    strm.adler = state.wrap & 1;
  }
  state.mode = HEAD;
  state.last = 0;
  state.havedict = 0;
  state.dmax = 32768;
  state.head = null /*Z_NULL*/;
  state.hold = 0;
  state.bits = 0;
  //state.lencode = state.distcode = state.next = state.codes;
  state.lencode = state.lendyn = new utils.Buf32(ENOUGH_LENS);
  state.distcode = state.distdyn = new utils.Buf32(ENOUGH_DISTS);

  state.sane = 1;
  state.back = -1;
  //Tracev((stderr, "inflate: reset\n"));
  return Z_OK;
}

function inflateReset(strm) {
  var state;

  if (!strm || !strm.state) {
    return Z_STREAM_ERROR;
  }
  state = strm.state;
  state.wsize = 0;
  state.whave = 0;
  state.wnext = 0;
  return inflateResetKeep(strm);
}

function inflateReset2(strm, windowBits) {
  var wrap;
  var state;

  /* get the state */
  if (!strm || !strm.state) {
    return Z_STREAM_ERROR;
  }
  state = strm.state;

  /* extract wrap request from windowBits parameter */
  if (windowBits < 0) {
    wrap = 0;
    windowBits = -windowBits;
  } else {
    wrap = (windowBits >> 4) + 1;
    if (windowBits < 48) {
      windowBits &= 15;
    }
  }

  /* set number of window bits, free window if different */
  if (windowBits && (windowBits < 8 || windowBits > 15)) {
    return Z_STREAM_ERROR;
  }
  if (state.window !== null && state.wbits !== windowBits) {
    state.window = null;
  }

  /* update state and reset the rest of it */
  state.wrap = wrap;
  state.wbits = windowBits;
  return inflateReset(strm);
}

function inflateInit2(strm, windowBits) {
  var ret;
  var state;

  if (!strm) {
    return Z_STREAM_ERROR;
  }
  //strm.msg = Z_NULL;                 /* in case we return an error */

  state = new InflateState();

  //if (state === Z_NULL) return Z_MEM_ERROR;
  //Tracev((stderr, "inflate: allocated\n"));
  strm.state = state;
  state.window = null /*Z_NULL*/;
  ret = inflateReset2(strm, windowBits);
  if (ret !== Z_OK) {
    strm.state = null /*Z_NULL*/;
  }
  return ret;
}

function inflateInit(strm) {
  return inflateInit2(strm, DEF_WBITS);
}

/*
 Return state with length and distance decoding tables and index sizes set to
 fixed code decoding.  Normally this returns fixed tables from inffixed.h.
 If BUILDFIXED is defined, then instead this routine builds the tables the
 first time it's called, and returns those tables the first time and
 thereafter.  This reduces the size of the code by about 2K bytes, in
 exchange for a little execution time.  However, BUILDFIXED should not be
 used for threaded applications, since the rewriting of the tables and virgin
 may not be thread-safe.
 */
var virgin = true;

var lenfix, distfix; // We have no pointers in JS, so keep tables separate

function fixedtables(state) {
  /* build fixed huffman tables if first call (may not be thread safe) */
  if (virgin) {
    var sym;

    lenfix = new utils.Buf32(512);
    distfix = new utils.Buf32(32);

    /* literal/length table */
    sym = 0;
    while (sym < 144) {
      state.lens[sym++] = 8;
    }
    while (sym < 256) {
      state.lens[sym++] = 9;
    }
    while (sym < 280) {
      state.lens[sym++] = 7;
    }
    while (sym < 288) {
      state.lens[sym++] = 8;
    }

    (0, _inftrees2.default)(LENS, state.lens, 0, 288, lenfix, 0, state.work, { bits: 9 });

    /* distance table */
    sym = 0;
    while (sym < 32) {
      state.lens[sym++] = 5;
    }

    (0, _inftrees2.default)(DISTS, state.lens, 0, 32, distfix, 0, state.work, { bits: 5 });

    /* do this just once */
    virgin = false;
  }

  state.lencode = lenfix;
  state.lenbits = 9;
  state.distcode = distfix;
  state.distbits = 5;
}

/*
 Update the window with the last wsize (normally 32K) bytes written before
 returning.  If window does not exist yet, create it.  This is only called
 when a window is already in use, or when output has been written during this
 inflate call, but the end of the deflate stream has not been reached yet.
 It is also called to create a window for dictionary data when a dictionary
 is loaded.

 Providing output buffers larger than 32K to inflate() should provide a speed
 advantage, since only the last 32K of output is copied to the sliding window
 upon return from inflate(), and since all distances after the first 32K of
 output will fall in the output data, making match copies simpler and faster.
 The advantage may be dependent on the size of the processor's data caches.
 */
function updatewindow(strm, src, end, copy) {
  var dist;
  var state = strm.state;

  /* if it hasn't been done already, allocate space for the window */
  if (state.window === null) {
    state.wsize = 1 << state.wbits;
    state.wnext = 0;
    state.whave = 0;

    state.window = new utils.Buf8(state.wsize);
  }

  /* copy state->wsize or less output bytes into the circular window */
  if (copy >= state.wsize) {
    utils.arraySet(state.window, src, end - state.wsize, state.wsize, 0);
    state.wnext = 0;
    state.whave = state.wsize;
  } else {
    dist = state.wsize - state.wnext;
    if (dist > copy) {
      dist = copy;
    }
    //zmemcpy(state->window + state->wnext, end - copy, dist);
    utils.arraySet(state.window, src, end - copy, dist, state.wnext);
    copy -= dist;
    if (copy) {
      //zmemcpy(state->window, end - copy, copy);
      utils.arraySet(state.window, src, end - copy, copy, 0);
      state.wnext = copy;
      state.whave = state.wsize;
    } else {
      state.wnext += dist;
      if (state.wnext === state.wsize) {
        state.wnext = 0;
      }
      if (state.whave < state.wsize) {
        state.whave += dist;
      }
    }
  }
  return 0;
}

function inflate(strm, flush) {
  var state;
  var input, output; // input/output buffers
  var next; /* next input INDEX */
  var put; /* next output INDEX */
  var have, left; /* available input and output */
  var hold; /* bit buffer */
  var bits; /* bits in bit buffer */
  var _in, _out; /* save starting available input and output */
  var copy; /* number of stored or match bytes to copy */
  var from; /* where to copy match bytes from */
  var from_source;
  var here = 0; /* current decoding table entry */
  var here_bits, here_op, here_val; // paked "here" denormalized (JS specific)
  //var last;                   /* parent table entry */
  var last_bits, last_op, last_val; // paked "last" denormalized (JS specific)
  var len; /* length to copy for repeats, bits to drop */
  var ret; /* return code */
  var hbuf = new utils.Buf8(4); /* buffer for gzip header crc calculation */
  var opts;

  var n; // temporary var for NEED_BITS

  var order = /* permutation of code lengths */
  [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15];

  if (!strm || !strm.state || !strm.output || !strm.input && strm.avail_in !== 0) {
    return Z_STREAM_ERROR;
  }

  state = strm.state;
  if (state.mode === TYPE) {
    state.mode = TYPEDO;
  } /* skip check */

  //--- LOAD() ---
  put = strm.next_out;
  output = strm.output;
  left = strm.avail_out;
  next = strm.next_in;
  input = strm.input;
  have = strm.avail_in;
  hold = state.hold;
  bits = state.bits;
  //---

  _in = have;
  _out = left;
  ret = Z_OK;

  inf_leave: // goto emulation
  for (;;) {
    switch (state.mode) {
      case HEAD:
        if (state.wrap === 0) {
          state.mode = TYPEDO;
          break;
        }
        //=== NEEDBITS(16);
        while (bits < 16) {
          if (have === 0) {
            break inf_leave;
          }
          have--;
          hold += input[next++] << bits;
          bits += 8;
        }
        //===//
        if (state.wrap & 2 && hold === 0x8b1f) {
          /* gzip header */
          state.check = 0 /*crc32(0L, Z_NULL, 0)*/;
          //=== CRC2(state.check, hold);
          hbuf[0] = hold & 0xff;
          hbuf[1] = hold >>> 8 & 0xff;
          state.check = (0, _crc2.default)(state.check, hbuf, 2, 0);
          //===//

          //=== INITBITS();
          hold = 0;
          bits = 0;
          //===//
          state.mode = FLAGS;
          break;
        }
        state.flags = 0; /* expect zlib header */
        if (state.head) {
          state.head.done = false;
        }
        if (!(state.wrap & 1) || /* check if zlib header allowed */
        (((hold & 0xff) << /*BITS(8)*/8) + (hold >> 8)) % 31) {
          strm.msg = 'incorrect header check';
          state.mode = BAD;
          break;
        }
        if ((hold & 0x0f) !== /*BITS(4)*/Z_DEFLATED) {
          strm.msg = 'unknown compression method';
          state.mode = BAD;
          break;
        }
        //--- DROPBITS(4) ---//
        hold >>>= 4;
        bits -= 4;
        //---//
        len = (hold & 0x0f) + /*BITS(4)*/8;
        if (state.wbits === 0) {
          state.wbits = len;
        } else if (len > state.wbits) {
          strm.msg = 'invalid window size';
          state.mode = BAD;
          break;
        }
        state.dmax = 1 << len;
        //Tracev((stderr, "inflate:   zlib header ok\n"));
        strm.adler = state.check = 1 /*adler32(0L, Z_NULL, 0)*/;
        state.mode = hold & 0x200 ? DICTID : TYPE;
        //=== INITBITS();
        hold = 0;
        bits = 0;
        //===//
        break;
      case FLAGS:
        //=== NEEDBITS(16); */
        while (bits < 16) {
          if (have === 0) {
            break inf_leave;
          }
          have--;
          hold += input[next++] << bits;
          bits += 8;
        }
        //===//
        state.flags = hold;
        if ((state.flags & 0xff) !== Z_DEFLATED) {
          strm.msg = 'unknown compression method';
          state.mode = BAD;
          break;
        }
        if (state.flags & 0xe000) {
          strm.msg = 'unknown header flags set';
          state.mode = BAD;
          break;
        }
        if (state.head) {
          state.head.text = hold >> 8 & 1;
        }
        if (state.flags & 0x0200) {
          //=== CRC2(state.check, hold);
          hbuf[0] = hold & 0xff;
          hbuf[1] = hold >>> 8 & 0xff;
          state.check = (0, _crc2.default)(state.check, hbuf, 2, 0);
          //===//
        }
        //=== INITBITS();
        hold = 0;
        bits = 0;
        //===//
        state.mode = TIME;
      /* falls through */
      case TIME:
        //=== NEEDBITS(32); */
        while (bits < 32) {
          if (have === 0) {
            break inf_leave;
          }
          have--;
          hold += input[next++] << bits;
          bits += 8;
        }
        //===//
        if (state.head) {
          state.head.time = hold;
        }
        if (state.flags & 0x0200) {
          //=== CRC4(state.check, hold)
          hbuf[0] = hold & 0xff;
          hbuf[1] = hold >>> 8 & 0xff;
          hbuf[2] = hold >>> 16 & 0xff;
          hbuf[3] = hold >>> 24 & 0xff;
          state.check = (0, _crc2.default)(state.check, hbuf, 4, 0);
          //===
        }
        //=== INITBITS();
        hold = 0;
        bits = 0;
        //===//
        state.mode = OS;
      /* falls through */
      case OS:
        //=== NEEDBITS(16); */
        while (bits < 16) {
          if (have === 0) {
            break inf_leave;
          }
          have--;
          hold += input[next++] << bits;
          bits += 8;
        }
        //===//
        if (state.head) {
          state.head.xflags = hold & 0xff;
          state.head.os = hold >> 8;
        }
        if (state.flags & 0x0200) {
          //=== CRC2(state.check, hold);
          hbuf[0] = hold & 0xff;
          hbuf[1] = hold >>> 8 & 0xff;
          state.check = (0, _crc2.default)(state.check, hbuf, 2, 0);
          //===//
        }
        //=== INITBITS();
        hold = 0;
        bits = 0;
        //===//
        state.mode = EXLEN;
      /* falls through */
      case EXLEN:
        if (state.flags & 0x0400) {
          //=== NEEDBITS(16); */
          while (bits < 16) {
            if (have === 0) {
              break inf_leave;
            }
            have--;
            hold += input[next++] << bits;
            bits += 8;
          }
          //===//
          state.length = hold;
          if (state.head) {
            state.head.extra_len = hold;
          }
          if (state.flags & 0x0200) {
            //=== CRC2(state.check, hold);
            hbuf[0] = hold & 0xff;
            hbuf[1] = hold >>> 8 & 0xff;
            state.check = (0, _crc2.default)(state.check, hbuf, 2, 0);
            //===//
          }
          //=== INITBITS();
          hold = 0;
          bits = 0;
          //===//
        } else if (state.head) {
          state.head.extra = null /*Z_NULL*/;
        }
        state.mode = EXTRA;
      /* falls through */
      case EXTRA:
        if (state.flags & 0x0400) {
          copy = state.length;
          if (copy > have) {
            copy = have;
          }
          if (copy) {
            if (state.head) {
              len = state.head.extra_len - state.length;
              if (!state.head.extra) {
                // Use untyped array for more conveniend processing later
                state.head.extra = new Array(state.head.extra_len);
              }
              utils.arraySet(state.head.extra, input, next,
              // extra field is limited to 65536 bytes
              // - no need for additional size check
              copy,
              /*len + copy > state.head.extra_max - len ? state.head.extra_max : copy,*/
              len);
              //zmemcpy(state.head.extra + len, next,
              //        len + copy > state.head.extra_max ?
              //        state.head.extra_max - len : copy);
            }
            if (state.flags & 0x0200) {
              state.check = (0, _crc2.default)(state.check, input, copy, next);
            }
            have -= copy;
            next += copy;
            state.length -= copy;
          }
          if (state.length) {
            break inf_leave;
          }
        }
        state.length = 0;
        state.mode = NAME;
      /* falls through */
      case NAME:
        if (state.flags & 0x0800) {
          if (have === 0) {
            break inf_leave;
          }
          copy = 0;
          do {
            // TODO: 2 or 1 bytes?
            len = input[next + copy++];
            /* use constant limit because in js we should not preallocate memory */
            if (state.head && len && state.length < 65536 /*state.head.name_max*/) {
              state.head.name += String.fromCharCode(len);
            }
          } while (len && copy < have);

          if (state.flags & 0x0200) {
            state.check = (0, _crc2.default)(state.check, input, copy, next);
          }
          have -= copy;
          next += copy;
          if (len) {
            break inf_leave;
          }
        } else if (state.head) {
          state.head.name = null;
        }
        state.length = 0;
        state.mode = COMMENT;
      /* falls through */
      case COMMENT:
        if (state.flags & 0x1000) {
          if (have === 0) {
            break inf_leave;
          }
          copy = 0;
          do {
            len = input[next + copy++];
            /* use constant limit because in js we should not preallocate memory */
            if (state.head && len && state.length < 65536 /*state.head.comm_max*/) {
              state.head.comment += String.fromCharCode(len);
            }
          } while (len && copy < have);
          if (state.flags & 0x0200) {
            state.check = (0, _crc2.default)(state.check, input, copy, next);
          }
          have -= copy;
          next += copy;
          if (len) {
            break inf_leave;
          }
        } else if (state.head) {
          state.head.comment = null;
        }
        state.mode = HCRC;
      /* falls through */
      case HCRC:
        if (state.flags & 0x0200) {
          //=== NEEDBITS(16); */
          while (bits < 16) {
            if (have === 0) {
              break inf_leave;
            }
            have--;
            hold += input[next++] << bits;
            bits += 8;
          }
          //===//
          if (hold !== (state.check & 0xffff)) {
            strm.msg = 'header crc mismatch';
            state.mode = BAD;
            break;
          }
          //=== INITBITS();
          hold = 0;
          bits = 0;
          //===//
        }
        if (state.head) {
          state.head.hcrc = state.flags >> 9 & 1;
          state.head.done = true;
        }
        strm.adler = state.check = 0;
        state.mode = TYPE;
        break;
      case DICTID:
        //=== NEEDBITS(32); */
        while (bits < 32) {
          if (have === 0) {
            break inf_leave;
          }
          have--;
          hold += input[next++] << bits;
          bits += 8;
        }
        //===//
        strm.adler = state.check = zswap32(hold);
        //=== INITBITS();
        hold = 0;
        bits = 0;
        //===//
        state.mode = DICT;
      /* falls through */
      case DICT:
        if (state.havedict === 0) {
          //--- RESTORE() ---
          strm.next_out = put;
          strm.avail_out = left;
          strm.next_in = next;
          strm.avail_in = have;
          state.hold = hold;
          state.bits = bits;
          //---
          return Z_NEED_DICT;
        }
        strm.adler = state.check = 1 /*adler32(0L, Z_NULL, 0)*/;
        state.mode = TYPE;
      /* falls through */
      case TYPE:
        if (flush === Z_BLOCK || flush === Z_TREES) {
          break inf_leave;
        }
      /* falls through */
      case TYPEDO:
        if (state.last) {
          //--- BYTEBITS() ---//
          hold >>>= bits & 7;
          bits -= bits & 7;
          //---//
          state.mode = CHECK;
          break;
        }
        //=== NEEDBITS(3); */
        while (bits < 3) {
          if (have === 0) {
            break inf_leave;
          }
          have--;
          hold += input[next++] << bits;
          bits += 8;
        }
        //===//
        state.last = hold & 0x01 /*BITS(1)*/;
        //--- DROPBITS(1) ---//
        hold >>>= 1;
        bits -= 1;
        //---//

        switch (hold & 0x03) {/*BITS(2)*/case 0:
            /* stored block */
            //Tracev((stderr, "inflate:     stored block%s\n",
            //        state.last ? " (last)" : ""));
            state.mode = STORED;
            break;
          case 1:
            /* fixed block */
            fixedtables(state);
            //Tracev((stderr, "inflate:     fixed codes block%s\n",
            //        state.last ? " (last)" : ""));
            state.mode = LEN_; /* decode codes */
            if (flush === Z_TREES) {
              //--- DROPBITS(2) ---//
              hold >>>= 2;
              bits -= 2;
              //---//
              break inf_leave;
            }
            break;
          case 2:
            /* dynamic block */
            //Tracev((stderr, "inflate:     dynamic codes block%s\n",
            //        state.last ? " (last)" : ""));
            state.mode = TABLE;
            break;
          case 3:
            strm.msg = 'invalid block type';
            state.mode = BAD;
        }
        //--- DROPBITS(2) ---//
        hold >>>= 2;
        bits -= 2;
        //---//
        break;
      case STORED:
        //--- BYTEBITS() ---// /* go to byte boundary */
        hold >>>= bits & 7;
        bits -= bits & 7;
        //---//
        //=== NEEDBITS(32); */
        while (bits < 32) {
          if (have === 0) {
            break inf_leave;
          }
          have--;
          hold += input[next++] << bits;
          bits += 8;
        }
        //===//
        if ((hold & 0xffff) !== (hold >>> 16 ^ 0xffff)) {
          strm.msg = 'invalid stored block lengths';
          state.mode = BAD;
          break;
        }
        state.length = hold & 0xffff;
        //Tracev((stderr, "inflate:       stored length %u\n",
        //        state.length));
        //=== INITBITS();
        hold = 0;
        bits = 0;
        //===//
        state.mode = COPY_;
        if (flush === Z_TREES) {
          break inf_leave;
        }
      /* falls through */
      case COPY_:
        state.mode = COPY;
      /* falls through */
      case COPY:
        copy = state.length;
        if (copy) {
          if (copy > have) {
            copy = have;
          }
          if (copy > left) {
            copy = left;
          }
          if (copy === 0) {
            break inf_leave;
          }
          //--- zmemcpy(put, next, copy); ---
          utils.arraySet(output, input, next, copy, put);
          //---//
          have -= copy;
          next += copy;
          left -= copy;
          put += copy;
          state.length -= copy;
          break;
        }
        //Tracev((stderr, "inflate:       stored end\n"));
        state.mode = TYPE;
        break;
      case TABLE:
        //=== NEEDBITS(14); */
        while (bits < 14) {
          if (have === 0) {
            break inf_leave;
          }
          have--;
          hold += input[next++] << bits;
          bits += 8;
        }
        //===//
        state.nlen = (hold & 0x1f) + /*BITS(5)*/257;
        //--- DROPBITS(5) ---//
        hold >>>= 5;
        bits -= 5;
        //---//
        state.ndist = (hold & 0x1f) + /*BITS(5)*/1;
        //--- DROPBITS(5) ---//
        hold >>>= 5;
        bits -= 5;
        //---//
        state.ncode = (hold & 0x0f) + /*BITS(4)*/4;
        //--- DROPBITS(4) ---//
        hold >>>= 4;
        bits -= 4;
        //---//
        //#ifndef PKZIP_BUG_WORKAROUND
        if (state.nlen > 286 || state.ndist > 30) {
          strm.msg = 'too many length or distance symbols';
          state.mode = BAD;
          break;
        }
        //#endif
        //Tracev((stderr, "inflate:       table sizes ok\n"));
        state.have = 0;
        state.mode = LENLENS;
      /* falls through */
      case LENLENS:
        while (state.have < state.ncode) {
          //=== NEEDBITS(3);
          while (bits < 3) {
            if (have === 0) {
              break inf_leave;
            }
            have--;
            hold += input[next++] << bits;
            bits += 8;
          }
          //===//
          state.lens[order[state.have++]] = hold & 0x07; //BITS(3);
          //--- DROPBITS(3) ---//
          hold >>>= 3;
          bits -= 3;
          //---//
        }
        while (state.have < 19) {
          state.lens[order[state.have++]] = 0;
        }
        // We have separate tables & no pointers. 2 commented lines below not needed.
        //state.next = state.codes;
        //state.lencode = state.next;
        // Switch to use dynamic table
        state.lencode = state.lendyn;
        state.lenbits = 7;

        opts = { bits: state.lenbits };
        ret = (0, _inftrees2.default)(CODES, state.lens, 0, 19, state.lencode, 0, state.work, opts);
        state.lenbits = opts.bits;

        if (ret) {
          strm.msg = 'invalid code lengths set';
          state.mode = BAD;
          break;
        }
        //Tracev((stderr, "inflate:       code lengths ok\n"));
        state.have = 0;
        state.mode = CODELENS;
      /* falls through */
      case CODELENS:
        while (state.have < state.nlen + state.ndist) {
          for (;;) {
            here = state.lencode[hold & (1 << state.lenbits) - 1]; /*BITS(state.lenbits)*/
            here_bits = here >>> 24;
            here_op = here >>> 16 & 0xff;
            here_val = here & 0xffff;

            if (here_bits <= bits) {
              break;
            }
            //--- PULLBYTE() ---//
            if (have === 0) {
              break inf_leave;
            }
            have--;
            hold += input[next++] << bits;
            bits += 8;
            //---//
          }
          if (here_val < 16) {
            //--- DROPBITS(here.bits) ---//
            hold >>>= here_bits;
            bits -= here_bits;
            //---//
            state.lens[state.have++] = here_val;
          } else {
            if (here_val === 16) {
              //=== NEEDBITS(here.bits + 2);
              n = here_bits + 2;
              while (bits < n) {
                if (have === 0) {
                  break inf_leave;
                }
                have--;
                hold += input[next++] << bits;
                bits += 8;
              }
              //===//
              //--- DROPBITS(here.bits) ---//
              hold >>>= here_bits;
              bits -= here_bits;
              //---//
              if (state.have === 0) {
                strm.msg = 'invalid bit length repeat';
                state.mode = BAD;
                break;
              }
              len = state.lens[state.have - 1];
              copy = 3 + (hold & 0x03); //BITS(2);
              //--- DROPBITS(2) ---//
              hold >>>= 2;
              bits -= 2;
              //---//
            } else if (here_val === 17) {
              //=== NEEDBITS(here.bits + 3);
              n = here_bits + 3;
              while (bits < n) {
                if (have === 0) {
                  break inf_leave;
                }
                have--;
                hold += input[next++] << bits;
                bits += 8;
              }
              //===//
              //--- DROPBITS(here.bits) ---//
              hold >>>= here_bits;
              bits -= here_bits;
              //---//
              len = 0;
              copy = 3 + (hold & 0x07); //BITS(3);
              //--- DROPBITS(3) ---//
              hold >>>= 3;
              bits -= 3;
              //---//
            } else {
              //=== NEEDBITS(here.bits + 7);
              n = here_bits + 7;
              while (bits < n) {
                if (have === 0) {
                  break inf_leave;
                }
                have--;
                hold += input[next++] << bits;
                bits += 8;
              }
              //===//
              //--- DROPBITS(here.bits) ---//
              hold >>>= here_bits;
              bits -= here_bits;
              //---//
              len = 0;
              copy = 11 + (hold & 0x7f); //BITS(7);
              //--- DROPBITS(7) ---//
              hold >>>= 7;
              bits -= 7;
              //---//
            }
            if (state.have + copy > state.nlen + state.ndist) {
              strm.msg = 'invalid bit length repeat';
              state.mode = BAD;
              break;
            }
            while (copy--) {
              state.lens[state.have++] = len;
            }
          }
        }

        /* handle error breaks in while */
        if (state.mode === BAD) {
          break;
        }

        /* check for end-of-block code (better have one) */
        if (state.lens[256] === 0) {
          strm.msg = 'invalid code -- missing end-of-block';
          state.mode = BAD;
          break;
        }

        /* build code tables -- note: do not change the lenbits or distbits
           values here (9 and 6) without reading the comments in inftrees.h
           concerning the ENOUGH constants, which depend on those values */
        state.lenbits = 9;

        opts = { bits: state.lenbits };
        ret = (0, _inftrees2.default)(LENS, state.lens, 0, state.nlen, state.lencode, 0, state.work, opts);
        // We have separate tables & no pointers. 2 commented lines below not needed.
        // state.next_index = opts.table_index;
        state.lenbits = opts.bits;
        // state.lencode = state.next;

        if (ret) {
          strm.msg = 'invalid literal/lengths set';
          state.mode = BAD;
          break;
        }

        state.distbits = 6;
        //state.distcode.copy(state.codes);
        // Switch to use dynamic table
        state.distcode = state.distdyn;
        opts = { bits: state.distbits };
        ret = (0, _inftrees2.default)(DISTS, state.lens, state.nlen, state.ndist, state.distcode, 0, state.work, opts);
        // We have separate tables & no pointers. 2 commented lines below not needed.
        // state.next_index = opts.table_index;
        state.distbits = opts.bits;
        // state.distcode = state.next;

        if (ret) {
          strm.msg = 'invalid distances set';
          state.mode = BAD;
          break;
        }
        //Tracev((stderr, 'inflate:       codes ok\n'));
        state.mode = LEN_;
        if (flush === Z_TREES) {
          break inf_leave;
        }
      /* falls through */
      case LEN_:
        state.mode = LEN;
      /* falls through */
      case LEN:
        if (have >= 6 && left >= 258) {
          //--- RESTORE() ---
          strm.next_out = put;
          strm.avail_out = left;
          strm.next_in = next;
          strm.avail_in = have;
          state.hold = hold;
          state.bits = bits;
          //---
          (0, _inffast2.default)(strm, _out);
          //--- LOAD() ---
          put = strm.next_out;
          output = strm.output;
          left = strm.avail_out;
          next = strm.next_in;
          input = strm.input;
          have = strm.avail_in;
          hold = state.hold;
          bits = state.bits;
          //---

          if (state.mode === TYPE) {
            state.back = -1;
          }
          break;
        }
        state.back = 0;
        for (;;) {
          here = state.lencode[hold & (1 << state.lenbits) - 1]; /*BITS(state.lenbits)*/
          here_bits = here >>> 24;
          here_op = here >>> 16 & 0xff;
          here_val = here & 0xffff;

          if (here_bits <= bits) {
            break;
          }
          //--- PULLBYTE() ---//
          if (have === 0) {
            break inf_leave;
          }
          have--;
          hold += input[next++] << bits;
          bits += 8;
          //---//
        }
        if (here_op && (here_op & 0xf0) === 0) {
          last_bits = here_bits;
          last_op = here_op;
          last_val = here_val;
          for (;;) {
            here = state.lencode[last_val + ((hold & (1 << last_bits + last_op) - 1) >> /*BITS(last.bits + last.op)*/last_bits)];
            here_bits = here >>> 24;
            here_op = here >>> 16 & 0xff;
            here_val = here & 0xffff;

            if (last_bits + here_bits <= bits) {
              break;
            }
            //--- PULLBYTE() ---//
            if (have === 0) {
              break inf_leave;
            }
            have--;
            hold += input[next++] << bits;
            bits += 8;
            //---//
          }
          //--- DROPBITS(last.bits) ---//
          hold >>>= last_bits;
          bits -= last_bits;
          //---//
          state.back += last_bits;
        }
        //--- DROPBITS(here.bits) ---//
        hold >>>= here_bits;
        bits -= here_bits;
        //---//
        state.back += here_bits;
        state.length = here_val;
        if (here_op === 0) {
          //Tracevv((stderr, here.val >= 0x20 && here.val < 0x7f ?
          //        "inflate:         literal '%c'\n" :
          //        "inflate:         literal 0x%02x\n", here.val));
          state.mode = LIT;
          break;
        }
        if (here_op & 32) {
          //Tracevv((stderr, "inflate:         end of block\n"));
          state.back = -1;
          state.mode = TYPE;
          break;
        }
        if (here_op & 64) {
          strm.msg = 'invalid literal/length code';
          state.mode = BAD;
          break;
        }
        state.extra = here_op & 15;
        state.mode = LENEXT;
      /* falls through */
      case LENEXT:
        if (state.extra) {
          //=== NEEDBITS(state.extra);
          n = state.extra;
          while (bits < n) {
            if (have === 0) {
              break inf_leave;
            }
            have--;
            hold += input[next++] << bits;
            bits += 8;
          }
          //===//
          state.length += hold & (1 << state.extra) - 1 /*BITS(state.extra)*/;
          //--- DROPBITS(state.extra) ---//
          hold >>>= state.extra;
          bits -= state.extra;
          //---//
          state.back += state.extra;
        }
        //Tracevv((stderr, "inflate:         length %u\n", state.length));
        state.was = state.length;
        state.mode = DIST;
      /* falls through */
      case DIST:
        for (;;) {
          here = state.distcode[hold & (1 << state.distbits) - 1]; /*BITS(state.distbits)*/
          here_bits = here >>> 24;
          here_op = here >>> 16 & 0xff;
          here_val = here & 0xffff;

          if (here_bits <= bits) {
            break;
          }
          //--- PULLBYTE() ---//
          if (have === 0) {
            break inf_leave;
          }
          have--;
          hold += input[next++] << bits;
          bits += 8;
          //---//
        }
        if ((here_op & 0xf0) === 0) {
          last_bits = here_bits;
          last_op = here_op;
          last_val = here_val;
          for (;;) {
            here = state.distcode[last_val + ((hold & (1 << last_bits + last_op) - 1) >> /*BITS(last.bits + last.op)*/last_bits)];
            here_bits = here >>> 24;
            here_op = here >>> 16 & 0xff;
            here_val = here & 0xffff;

            if (last_bits + here_bits <= bits) {
              break;
            }
            //--- PULLBYTE() ---//
            if (have === 0) {
              break inf_leave;
            }
            have--;
            hold += input[next++] << bits;
            bits += 8;
            //---//
          }
          //--- DROPBITS(last.bits) ---//
          hold >>>= last_bits;
          bits -= last_bits;
          //---//
          state.back += last_bits;
        }
        //--- DROPBITS(here.bits) ---//
        hold >>>= here_bits;
        bits -= here_bits;
        //---//
        state.back += here_bits;
        if (here_op & 64) {
          strm.msg = 'invalid distance code';
          state.mode = BAD;
          break;
        }
        state.offset = here_val;
        state.extra = here_op & 15;
        state.mode = DISTEXT;
      /* falls through */
      case DISTEXT:
        if (state.extra) {
          //=== NEEDBITS(state.extra);
          n = state.extra;
          while (bits < n) {
            if (have === 0) {
              break inf_leave;
            }
            have--;
            hold += input[next++] << bits;
            bits += 8;
          }
          //===//
          state.offset += hold & (1 << state.extra) - 1 /*BITS(state.extra)*/;
          //--- DROPBITS(state.extra) ---//
          hold >>>= state.extra;
          bits -= state.extra;
          //---//
          state.back += state.extra;
        }
        //#ifdef INFLATE_STRICT
        if (state.offset > state.dmax) {
          strm.msg = 'invalid distance too far back';
          state.mode = BAD;
          break;
        }
        //#endif
        //Tracevv((stderr, "inflate:         distance %u\n", state.offset));
        state.mode = MATCH;
      /* falls through */
      case MATCH:
        if (left === 0) {
          break inf_leave;
        }
        copy = _out - left;
        if (state.offset > copy) {
          /* copy from window */
          copy = state.offset - copy;
          if (copy > state.whave) {
            if (state.sane) {
              strm.msg = 'invalid distance too far back';
              state.mode = BAD;
              break;
            }
            // (!) This block is disabled in zlib defailts,
            // don't enable it for binary compatibility
            //#ifdef INFLATE_ALLOW_INVALID_DISTANCE_TOOFAR_ARRR
            //          Trace((stderr, "inflate.c too far\n"));
            //          copy -= state.whave;
            //          if (copy > state.length) { copy = state.length; }
            //          if (copy > left) { copy = left; }
            //          left -= copy;
            //          state.length -= copy;
            //          do {
            //            output[put++] = 0;
            //          } while (--copy);
            //          if (state.length === 0) { state.mode = LEN; }
            //          break;
            //#endif
          }
          if (copy > state.wnext) {
            copy -= state.wnext;
            from = state.wsize - copy;
          } else {
            from = state.wnext - copy;
          }
          if (copy > state.length) {
            copy = state.length;
          }
          from_source = state.window;
        } else {
          /* copy from output */
          from_source = output;
          from = put - state.offset;
          copy = state.length;
        }
        if (copy > left) {
          copy = left;
        }
        left -= copy;
        state.length -= copy;
        do {
          output[put++] = from_source[from++];
        } while (--copy);
        if (state.length === 0) {
          state.mode = LEN;
        }
        break;
      case LIT:
        if (left === 0) {
          break inf_leave;
        }
        output[put++] = state.length;
        left--;
        state.mode = LEN;
        break;
      case CHECK:
        if (state.wrap) {
          //=== NEEDBITS(32);
          while (bits < 32) {
            if (have === 0) {
              break inf_leave;
            }
            have--;
            // Use '|' insdead of '+' to make sure that result is signed
            hold |= input[next++] << bits;
            bits += 8;
          }
          //===//
          _out -= left;
          strm.total_out += _out;
          state.total += _out;
          if (_out) {
            strm.adler = state.check =
            /*UPDATE(state.check, put - _out, _out);*/
            state.flags ? (0, _crc2.default)(state.check, output, _out, put - _out) : (0, _adler2.default)(state.check, output, _out, put - _out);
          }
          _out = left;
          // NB: crc32 stored as signed 32-bit int, zswap32 returns signed too
          if ((state.flags ? hold : zswap32(hold)) !== state.check) {
            strm.msg = 'incorrect data check';
            state.mode = BAD;
            break;
          }
          //=== INITBITS();
          hold = 0;
          bits = 0;
          //===//
          //Tracev((stderr, "inflate:   check matches trailer\n"));
        }
        state.mode = LENGTH;
      /* falls through */
      case LENGTH:
        if (state.wrap && state.flags) {
          //=== NEEDBITS(32);
          while (bits < 32) {
            if (have === 0) {
              break inf_leave;
            }
            have--;
            hold += input[next++] << bits;
            bits += 8;
          }
          //===//
          if (hold !== (state.total & 0xffffffff)) {
            strm.msg = 'incorrect length check';
            state.mode = BAD;
            break;
          }
          //=== INITBITS();
          hold = 0;
          bits = 0;
          //===//
          //Tracev((stderr, "inflate:   length matches trailer\n"));
        }
        state.mode = DONE;
      /* falls through */
      case DONE:
        ret = Z_STREAM_END;
        break inf_leave;
      case BAD:
        ret = Z_DATA_ERROR;
        break inf_leave;
      case MEM:
        return Z_MEM_ERROR;
      case SYNC:
      /* falls through */
      default:
        return Z_STREAM_ERROR;
    }
  }

  // inf_leave <- here is real place for "goto inf_leave", emulated via "break inf_leave"

  /*
     Return from inflate(), updating the total counts and the check value.
     If there was no progress during the inflate() call, return a buffer
     error.  Call updatewindow() to create and/or update the window state.
     Note: a memory error from inflate() is non-recoverable.
   */

  //--- RESTORE() ---
  strm.next_out = put;
  strm.avail_out = left;
  strm.next_in = next;
  strm.avail_in = have;
  state.hold = hold;
  state.bits = bits;
  //---

  if (state.wsize || _out !== strm.avail_out && state.mode < BAD && (state.mode < CHECK || flush !== Z_FINISH)) {
    if (updatewindow(strm, strm.output, strm.next_out, _out - strm.avail_out)) {
      state.mode = MEM;
      return Z_MEM_ERROR;
    }
  }
  _in -= strm.avail_in;
  _out -= strm.avail_out;
  strm.total_in += _in;
  strm.total_out += _out;
  state.total += _out;
  if (state.wrap && _out) {
    strm.adler = state.check = /*UPDATE(state.check, strm.next_out - _out, _out);*/
    state.flags ? (0, _crc2.default)(state.check, output, _out, strm.next_out - _out) : (0, _adler2.default)(state.check, output, _out, strm.next_out - _out);
  }
  strm.data_type = state.bits + (state.last ? 64 : 0) + (state.mode === TYPE ? 128 : 0) + (state.mode === LEN_ || state.mode === COPY_ ? 256 : 0);
  if ((_in === 0 && _out === 0 || flush === Z_FINISH) && ret === Z_OK) {
    ret = Z_BUF_ERROR;
  }
  return ret;
}

function inflateEnd(strm) {

  if (!strm || !strm.state /*|| strm->zfree == (free_func)0*/) {
      return Z_STREAM_ERROR;
    }

  var state = strm.state;
  if (state.window) {
    state.window = null;
  }
  strm.state = null;
  return Z_OK;
}

function inflateGetHeader(strm, head) {
  var state;

  /* check state */
  if (!strm || !strm.state) {
    return Z_STREAM_ERROR;
  }
  state = strm.state;
  if ((state.wrap & 2) === 0) {
    return Z_STREAM_ERROR;
  }

  /* save header structure */
  state.head = head;
  head.done = false;
  return Z_OK;
}

function inflateSetDictionary(strm, dictionary) {
  var dictLength = dictionary.length;

  var state;
  var dictid;
  var ret;

  /* check state */
  if (!strm /* == Z_NULL */ || !strm.state /* == Z_NULL */) {
      return Z_STREAM_ERROR;
    }
  state = strm.state;

  if (state.wrap !== 0 && state.mode !== DICT) {
    return Z_STREAM_ERROR;
  }

  /* check for correct dictionary identifier */
  if (state.mode === DICT) {
    dictid = 1; /* adler32(0, null, 0)*/
    /* dictid = adler32(dictid, dictionary, dictLength); */
    dictid = (0, _adler2.default)(dictid, dictionary, dictLength, 0);
    if (dictid !== state.check) {
      return Z_DATA_ERROR;
    }
  }
  /* copy dictionary to window using updatewindow(), which will amend the
   existing dictionary if appropriate */
  ret = updatewindow(strm, dictionary, dictLength, dictLength);
  if (ret) {
    state.mode = MEM;
    return Z_MEM_ERROR;
  }
  state.havedict = 1;
  // Tracev((stderr, "inflate:   dictionary set\n"));
  return Z_OK;
}

exports.inflateReset = inflateReset;
exports.inflateReset2 = inflateReset2;
exports.inflateResetKeep = inflateResetKeep;
exports.inflateInit = inflateInit;
exports.inflateInit2 = inflateInit2;
exports.inflate = inflate;
exports.inflateEnd = inflateEnd;
exports.inflateGetHeader = inflateGetHeader;
exports.inflateSetDictionary = inflateSetDictionary;
var inflateInfo = exports.inflateInfo = 'pako inflate (from Nodeca project)';

/* Not implemented
exports.inflateCopy = inflateCopy;
exports.inflateGetDictionary = inflateGetDictionary;
exports.inflateMark = inflateMark;
exports.inflatePrime = inflatePrime;
exports.inflateSync = inflateSync;
exports.inflateSyncPoint = inflateSyncPoint;
exports.inflateUndermine = inflateUndermine;
*/
},{"../utils/common.js":35,"./adler32.js":36,"./crc32.js":37,"./inffast.js":39,"./inftrees.js":41}],41:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = inflate_table;

var _common = require("../utils/common.js");

var utils = _interopRequireWildcard(_common);

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

var MAXBITS = 15;
var ENOUGH_LENS = 852;
var ENOUGH_DISTS = 592;
//var ENOUGH = (ENOUGH_LENS+ENOUGH_DISTS);

var CODES = 0;
var LENS = 1;
var DISTS = 2;

var lbase = [/* Length codes 257..285 base */
3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258, 0, 0];

var lext = [/* Length codes 257..285 extra */
16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 16, 72, 78];

var dbase = [/* Distance codes 0..29 base */
1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577, 0, 0];

var dext = [/* Distance codes 0..29 extra */
16, 16, 16, 16, 17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22, 22, 23, 23, 24, 24, 25, 25, 26, 26, 27, 27, 28, 28, 29, 29, 64, 64];

function inflate_table(type, lens, lens_index, codes, table, table_index, work, opts) {
  var bits = opts.bits;
  //here = opts.here; /* table entry for duplication */

  var len = 0; /* a code's length in bits */
  var sym = 0; /* index of code symbols */
  var min = 0,
      max = 0; /* minimum and maximum code lengths */
  var root = 0; /* number of index bits for root table */
  var curr = 0; /* number of index bits for current table */
  var drop = 0; /* code bits to drop for sub-table */
  var left = 0; /* number of prefix codes available */
  var used = 0; /* code entries in table used */
  var huff = 0; /* Huffman code */
  var incr; /* for incrementing code, index */
  var fill; /* index for replicating entries */
  var low; /* low bits for current root entry */
  var mask; /* mask for low root bits */
  var next; /* next available space in table */
  var base = null; /* base value table to use */
  var base_index = 0;
  //  var shoextra;    /* extra bits table to use */
  var end; /* use base and extra for symbol > end */
  var count = new utils.Buf16(MAXBITS + 1); //[MAXBITS+1];    /* number of codes of each length */
  var offs = new utils.Buf16(MAXBITS + 1); //[MAXBITS+1];     /* offsets in table for each length */
  var extra = null;
  var extra_index = 0;

  var here_bits, here_op, here_val;

  /*
   Process a set of code lengths to create a canonical Huffman code.  The
   code lengths are lens[0..codes-1].  Each length corresponds to the
   symbols 0..codes-1.  The Huffman code is generated by first sorting the
   symbols by length from short to long, and retaining the symbol order
   for codes with equal lengths.  Then the code starts with all zero bits
   for the first code of the shortest length, and the codes are integer
   increments for the same length, and zeros are appended as the length
   increases.  For the deflate format, these bits are stored backwards
   from their more natural integer increment ordering, and so when the
   decoding tables are built in the large loop below, the integer codes
   are incremented backwards.
    This routine assumes, but does not check, that all of the entries in
   lens[] are in the range 0..MAXBITS.  The caller must assure this.
   1..MAXBITS is interpreted as that code length.  zero means that that
   symbol does not occur in this code.
    The codes are sorted by computing a count of codes for each length,
   creating from that a table of starting indices for each length in the
   sorted table, and then entering the symbols in order in the sorted
   table.  The sorted table is work[], with that space being provided by
   the caller.
    The length counts are used for other purposes as well, i.e. finding
   the minimum and maximum length codes, determining if there are any
   codes at all, checking for a valid set of lengths, and looking ahead
   at length counts to determine sub-table sizes when building the
   decoding tables.
   */

  /* accumulate lengths for codes (assumes lens[] all in 0..MAXBITS) */
  for (len = 0; len <= MAXBITS; len++) {
    count[len] = 0;
  }
  for (sym = 0; sym < codes; sym++) {
    count[lens[lens_index + sym]]++;
  }

  /* bound code lengths, force root to be within code lengths */
  root = bits;
  for (max = MAXBITS; max >= 1; max--) {
    if (count[max] !== 0) {
      break;
    }
  }
  if (root > max) {
    root = max;
  }
  if (max === 0) {
    /* no symbols to code at all */
    //table.op[opts.table_index] = 64;  //here.op = (var char)64;    /* invalid code marker */
    //table.bits[opts.table_index] = 1;   //here.bits = (var char)1;
    //table.val[opts.table_index++] = 0;   //here.val = (var short)0;
    table[table_index++] = 1 << 24 | 64 << 16 | 0;

    //table.op[opts.table_index] = 64;
    //table.bits[opts.table_index] = 1;
    //table.val[opts.table_index++] = 0;
    table[table_index++] = 1 << 24 | 64 << 16 | 0;

    opts.bits = 1;
    return 0; /* no symbols, but wait for decoding to report error */
  }
  for (min = 1; min < max; min++) {
    if (count[min] !== 0) {
      break;
    }
  }
  if (root < min) {
    root = min;
  }

  /* check for an over-subscribed or incomplete set of lengths */
  left = 1;
  for (len = 1; len <= MAXBITS; len++) {
    left <<= 1;
    left -= count[len];
    if (left < 0) {
      return -1;
    } /* over-subscribed */
  }
  if (left > 0 && (type === CODES || max !== 1)) {
    return -1; /* incomplete set */
  }

  /* generate offsets into symbol table for each length for sorting */
  offs[1] = 0;
  for (len = 1; len < MAXBITS; len++) {
    offs[len + 1] = offs[len] + count[len];
  }

  /* sort symbols by length, by symbol order within each length */
  for (sym = 0; sym < codes; sym++) {
    if (lens[lens_index + sym] !== 0) {
      work[offs[lens[lens_index + sym]]++] = sym;
    }
  }

  /*
   Create and fill in decoding tables.  In this loop, the table being
   filled is at next and has curr index bits.  The code being used is huff
   with length len.  That code is converted to an index by dropping drop
   bits off of the bottom.  For codes where len is less than drop + curr,
   those top drop + curr - len bits are incremented through all values to
   fill the table with replicated entries.
    root is the number of index bits for the root table.  When len exceeds
   root, sub-tables are created pointed to by the root entry with an index
   of the low root bits of huff.  This is saved in low to check for when a
   new sub-table should be started.  drop is zero when the root table is
   being filled, and drop is root when sub-tables are being filled.
    When a new sub-table is needed, it is necessary to look ahead in the
   code lengths to determine what size sub-table is needed.  The length
   counts are used for this, and so count[] is decremented as codes are
   entered in the tables.
    used keeps track of how many table entries have been allocated from the
   provided *table space.  It is checked for LENS and DIST tables against
   the constants ENOUGH_LENS and ENOUGH_DISTS to guard against changes in
   the initial root table size constants.  See the comments in inftrees.h
   for more information.
    sym increments through all symbols, and the loop terminates when
   all codes of length max, i.e. all codes, have been processed.  This
   routine permits incomplete codes, so another loop after this one fills
   in the rest of the decoding tables with invalid code markers.
   */

  /* set up for code type */
  // poor man optimization - use if-else instead of switch,
  // to avoid deopts in old v8
  if (type === CODES) {
    base = extra = work; /* dummy value--not used */
    end = 19;
  } else if (type === LENS) {
    base = lbase;
    base_index -= 257;
    extra = lext;
    extra_index -= 257;
    end = 256;
  } else {
    /* DISTS */
    base = dbase;
    extra = dext;
    end = -1;
  }

  /* initialize opts for loop */
  huff = 0; /* starting code */
  sym = 0; /* starting code symbol */
  len = min; /* starting code length */
  next = table_index; /* current table to fill in */
  curr = root; /* current table index bits */
  drop = 0; /* current bits to drop from code for index */
  low = -1; /* trigger new sub-table when len > root */
  used = 1 << root; /* use root table entries */
  mask = used - 1; /* mask for comparing low */

  /* check available table space */
  if (type === LENS && used > ENOUGH_LENS || type === DISTS && used > ENOUGH_DISTS) {
    return 1;
  }

  /* process all codes and make table entries */
  for (;;) {
    /* create table entry */
    here_bits = len - drop;
    if (work[sym] < end) {
      here_op = 0;
      here_val = work[sym];
    } else if (work[sym] > end) {
      here_op = extra[extra_index + work[sym]];
      here_val = base[base_index + work[sym]];
    } else {
      here_op = 32 + 64; /* end of block */
      here_val = 0;
    }

    /* replicate for those indices with low len bits equal to huff */
    incr = 1 << len - drop;
    fill = 1 << curr;
    min = fill; /* save offset to next table */
    do {
      fill -= incr;
      table[next + (huff >> drop) + fill] = here_bits << 24 | here_op << 16 | here_val | 0;
    } while (fill !== 0);

    /* backwards increment the len-bit code huff */
    incr = 1 << len - 1;
    while (huff & incr) {
      incr >>= 1;
    }
    if (incr !== 0) {
      huff &= incr - 1;
      huff += incr;
    } else {
      huff = 0;
    }

    /* go to next symbol, update count, len */
    sym++;
    if (--count[len] === 0) {
      if (len === max) {
        break;
      }
      len = lens[lens_index + work[sym]];
    }

    /* create new sub-table if needed */
    if (len > root && (huff & mask) !== low) {
      /* if first time, transition to sub-tables */
      if (drop === 0) {
        drop = root;
      }

      /* increment past last table */
      next += min; /* here min is 1 << curr */

      /* determine length of next table */
      curr = len - drop;
      left = 1 << curr;
      while (curr + drop < max) {
        left -= count[curr + drop];
        if (left <= 0) {
          break;
        }
        curr++;
        left <<= 1;
      }

      /* check for enough space */
      used += 1 << curr;
      if (type === LENS && used > ENOUGH_LENS || type === DISTS && used > ENOUGH_DISTS) {
        return 1;
      }

      /* point entry in root table to sub-table */
      low = huff & mask;
      /*table.op[low] = curr;
      table.bits[low] = root;
      table.val[low] = next - opts.table_index;*/
      table[low] = root << 24 | curr << 16 | next - table_index | 0;
    }
  }

  /* fill in remaining table entry if code is incomplete (guaranteed to have
   at most one remaining entry, since if the code is incomplete, the
   maximum code length that was allowed to get this far is one bit) */
  if (huff !== 0) {
    //table.op[next + huff] = 64;            /* invalid code marker */
    //table.bits[next + huff] = len - drop;
    //table.val[next + huff] = 0;
    table[next + huff] = len - drop << 24 | 64 << 16 | 0;
  }

  /* set return parameters */
  //opts.table_index += used;
  opts.bits = root;
  return 0;
};
},{"../utils/common.js":35}],42:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = {
  2: 'need dictionary', /* Z_NEED_DICT       2  */
  1: 'stream end', /* Z_STREAM_END      1  */
  0: '', /* Z_OK              0  */
  '-1': 'file error', /* Z_ERRNO         (-1) */
  '-2': 'stream error', /* Z_STREAM_ERROR  (-2) */
  '-3': 'data error', /* Z_DATA_ERROR    (-3) */
  '-4': 'insufficient memory', /* Z_MEM_ERROR     (-4) */
  '-5': 'buffer error', /* Z_BUF_ERROR     (-5) */
  '-6': 'incompatible version' /* Z_VERSION_ERROR (-6) */
};
},{}],43:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports._tr_align = exports._tr_tally = exports._tr_flush_block = exports._tr_stored_block = exports._tr_init = undefined;

var _common = require("../utils/common.js");

var utils = _interopRequireWildcard(_common);

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

/* Public constants ==========================================================*/
/* ===========================================================================*/

//var Z_FILTERED          = 1;
//var Z_HUFFMAN_ONLY      = 2;
//var Z_RLE               = 3;
var Z_FIXED = 4;
//var Z_DEFAULT_STRATEGY  = 0;

/* Possible values of the data_type field (though see inflate()) */
var Z_BINARY = 0;
var Z_TEXT = 1;
//var Z_ASCII             = 1; // = Z_TEXT
var Z_UNKNOWN = 2;

/*============================================================================*/

function zero(buf) {
  var len = buf.length;while (--len >= 0) {
    buf[len] = 0;
  }
}

// From zutil.h

var STORED_BLOCK = 0;
var STATIC_TREES = 1;
var DYN_TREES = 2;
/* The three kinds of block type */

var MIN_MATCH = 3;
var MAX_MATCH = 258;
/* The minimum and maximum match lengths */

// From deflate.h
/* ===========================================================================
 * Internal compression state.
 */

var LENGTH_CODES = 29;
/* number of length codes, not counting the special END_BLOCK code */

var LITERALS = 256;
/* number of literal bytes 0..255 */

var L_CODES = LITERALS + 1 + LENGTH_CODES;
/* number of Literal or Length codes, including the END_BLOCK code */

var D_CODES = 30;
/* number of distance codes */

var BL_CODES = 19;
/* number of codes used to transfer the bit lengths */

var HEAP_SIZE = 2 * L_CODES + 1;
/* maximum heap size */

var MAX_BITS = 15;
/* All codes must not exceed MAX_BITS bits */

var Buf_size = 16;
/* size of bit buffer in bi_buf */

/* ===========================================================================
 * Constants
 */

var MAX_BL_BITS = 7;
/* Bit length codes must not exceed MAX_BL_BITS bits */

var END_BLOCK = 256;
/* end of block literal code */

var REP_3_6 = 16;
/* repeat previous bit length 3-6 times (2 bits of repeat count) */

var REPZ_3_10 = 17;
/* repeat a zero length 3-10 times  (3 bits of repeat count) */

var REPZ_11_138 = 18;
/* repeat a zero length 11-138 times  (7 bits of repeat count) */

/* eslint-disable comma-spacing,array-bracket-spacing */
var extra_lbits = /* extra bits for each length code */
[0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0];

var extra_dbits = /* extra bits for each distance code */
[0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13];

var extra_blbits = /* extra bits for each bit length code */
[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 3, 7];

var bl_order = [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15];
/* eslint-enable comma-spacing,array-bracket-spacing */

/* The lengths of the bit length codes are sent in order of decreasing
 * probability, to avoid transmitting the lengths for unused bit length codes.
 */

/* ===========================================================================
 * Local data. These are initialized only once.
 */

// We pre-fill arrays with 0 to avoid uninitialized gaps

var DIST_CODE_LEN = 512; /* see definition of array dist_code below */

// !!!! Use flat array insdead of structure, Freq = i*2, Len = i*2+1
var static_ltree = new Array((L_CODES + 2) * 2);
zero(static_ltree);
/* The static literal tree. Since the bit lengths are imposed, there is no
 * need for the L_CODES extra codes used during heap construction. However
 * The codes 286 and 287 are needed to build a canonical tree (see _tr_init
 * below).
 */

var static_dtree = new Array(D_CODES * 2);
zero(static_dtree);
/* The static distance tree. (Actually a trivial tree since all codes use
 * 5 bits.)
 */

var _dist_code = new Array(DIST_CODE_LEN);
zero(_dist_code);
/* Distance codes. The first 256 values correspond to the distances
 * 3 .. 258, the last 256 values correspond to the top 8 bits of
 * the 15 bit distances.
 */

var _length_code = new Array(MAX_MATCH - MIN_MATCH + 1);
zero(_length_code);
/* length code for each normalized match length (0 == MIN_MATCH) */

var base_length = new Array(LENGTH_CODES);
zero(base_length);
/* First normalized length for each code (0 = MIN_MATCH) */

var base_dist = new Array(D_CODES);
zero(base_dist);
/* First normalized distance for each code (0 = distance of 1) */

function StaticTreeDesc(static_tree, extra_bits, extra_base, elems, max_length) {

  this.static_tree = static_tree; /* static tree or NULL */
  this.extra_bits = extra_bits; /* extra bits for each code or NULL */
  this.extra_base = extra_base; /* base index for extra_bits */
  this.elems = elems; /* max number of elements in the tree */
  this.max_length = max_length; /* max bit length for the codes */

  // show if `static_tree` has data or dummy - needed for monomorphic objects
  this.has_stree = static_tree && static_tree.length;
}

var static_l_desc;
var static_d_desc;
var static_bl_desc;

function TreeDesc(dyn_tree, stat_desc) {
  this.dyn_tree = dyn_tree; /* the dynamic tree */
  this.max_code = 0; /* largest code with non zero frequency */
  this.stat_desc = stat_desc; /* the corresponding static tree */
}

function d_code(dist) {
  return dist < 256 ? _dist_code[dist] : _dist_code[256 + (dist >>> 7)];
}

/* ===========================================================================
 * Output a short LSB first on the stream.
 * IN assertion: there is enough room in pendingBuf.
 */
function put_short(s, w) {
  //    put_byte(s, (uch)((w) & 0xff));
  //    put_byte(s, (uch)((ush)(w) >> 8));
  s.pending_buf[s.pending++] = w & 0xff;
  s.pending_buf[s.pending++] = w >>> 8 & 0xff;
}

/* ===========================================================================
 * Send a value on a given number of bits.
 * IN assertion: length <= 16 and value fits in length bits.
 */
function send_bits(s, value, length) {
  if (s.bi_valid > Buf_size - length) {
    s.bi_buf |= value << s.bi_valid & 0xffff;
    put_short(s, s.bi_buf);
    s.bi_buf = value >> Buf_size - s.bi_valid;
    s.bi_valid += length - Buf_size;
  } else {
    s.bi_buf |= value << s.bi_valid & 0xffff;
    s.bi_valid += length;
  }
}

function send_code(s, c, tree) {
  send_bits(s, tree[c * 2] /*.Code*/, tree[c * 2 + 1] /*.Len*/);
}

/* ===========================================================================
 * Reverse the first len bits of a code, using straightforward code (a faster
 * method would use a table)
 * IN assertion: 1 <= len <= 15
 */
function bi_reverse(code, len) {
  var res = 0;
  do {
    res |= code & 1;
    code >>>= 1;
    res <<= 1;
  } while (--len > 0);
  return res >>> 1;
}

/* ===========================================================================
 * Flush the bit buffer, keeping at most 7 bits in it.
 */
function bi_flush(s) {
  if (s.bi_valid === 16) {
    put_short(s, s.bi_buf);
    s.bi_buf = 0;
    s.bi_valid = 0;
  } else if (s.bi_valid >= 8) {
    s.pending_buf[s.pending++] = s.bi_buf & 0xff;
    s.bi_buf >>= 8;
    s.bi_valid -= 8;
  }
}

/* ===========================================================================
 * Compute the optimal bit lengths for a tree and update the total bit length
 * for the current block.
 * IN assertion: the fields freq and dad are set, heap[heap_max] and
 *    above are the tree nodes sorted by increasing frequency.
 * OUT assertions: the field len is set to the optimal bit length, the
 *     array bl_count contains the frequencies for each bit length.
 *     The length opt_len is updated; static_len is also updated if stree is
 *     not null.
 */
function gen_bitlen(s, desc)
//    deflate_state *s;
//    tree_desc *desc;    /* the tree descriptor */
{
  var tree = desc.dyn_tree;
  var max_code = desc.max_code;
  var stree = desc.stat_desc.static_tree;
  var has_stree = desc.stat_desc.has_stree;
  var extra = desc.stat_desc.extra_bits;
  var base = desc.stat_desc.extra_base;
  var max_length = desc.stat_desc.max_length;
  var h; /* heap index */
  var n, m; /* iterate over the tree elements */
  var bits; /* bit length */
  var xbits; /* extra bits */
  var f; /* frequency */
  var overflow = 0; /* number of elements with bit length too large */

  for (bits = 0; bits <= MAX_BITS; bits++) {
    s.bl_count[bits] = 0;
  }

  /* In a first pass, compute the optimal bit lengths (which may
   * overflow in the case of the bit length tree).
   */
  tree[s.heap[s.heap_max] * 2 + 1] /*.Len*/ = 0; /* root of the heap */

  for (h = s.heap_max + 1; h < HEAP_SIZE; h++) {
    n = s.heap[h];
    bits = tree[tree[n * 2 + 1] /*.Dad*/ * 2 + 1] /*.Len*/ + 1;
    if (bits > max_length) {
      bits = max_length;
      overflow++;
    }
    tree[n * 2 + 1] /*.Len*/ = bits;
    /* We overwrite tree[n].Dad which is no longer needed */

    if (n > max_code) {
      continue;
    } /* not a leaf node */

    s.bl_count[bits]++;
    xbits = 0;
    if (n >= base) {
      xbits = extra[n - base];
    }
    f = tree[n * 2] /*.Freq*/;
    s.opt_len += f * (bits + xbits);
    if (has_stree) {
      s.static_len += f * (stree[n * 2 + 1] /*.Len*/ + xbits);
    }
  }
  if (overflow === 0) {
    return;
  }

  // Trace((stderr,"\nbit length overflow\n"));
  /* This happens for example on obj2 and pic of the Calgary corpus */

  /* Find the first bit length which could increase: */
  do {
    bits = max_length - 1;
    while (s.bl_count[bits] === 0) {
      bits--;
    }
    s.bl_count[bits]--; /* move one leaf down the tree */
    s.bl_count[bits + 1] += 2; /* move one overflow item as its brother */
    s.bl_count[max_length]--;
    /* The brother of the overflow item also moves one step up,
     * but this does not affect bl_count[max_length]
     */
    overflow -= 2;
  } while (overflow > 0);

  /* Now recompute all bit lengths, scanning in increasing frequency.
   * h is still equal to HEAP_SIZE. (It is simpler to reconstruct all
   * lengths instead of fixing only the wrong ones. This idea is taken
   * from 'ar' written by Haruhiko Okumura.)
   */
  for (bits = max_length; bits !== 0; bits--) {
    n = s.bl_count[bits];
    while (n !== 0) {
      m = s.heap[--h];
      if (m > max_code) {
        continue;
      }
      if (tree[m * 2 + 1] /*.Len*/ !== bits) {
        // Trace((stderr,"code %d bits %d->%d\n", m, tree[m].Len, bits));
        s.opt_len += (bits - tree[m * 2 + 1] /*.Len*/) * tree[m * 2] /*.Freq*/;
        tree[m * 2 + 1] /*.Len*/ = bits;
      }
      n--;
    }
  }
}

/* ===========================================================================
 * Generate the codes for a given tree and bit counts (which need not be
 * optimal).
 * IN assertion: the array bl_count contains the bit length statistics for
 * the given tree and the field len is set for all tree elements.
 * OUT assertion: the field code is set for all tree elements of non
 *     zero code length.
 */
function gen_codes(tree, max_code, bl_count)
//    ct_data *tree;             /* the tree to decorate */
//    int max_code;              /* largest code with non zero frequency */
//    ushf *bl_count;            /* number of codes at each bit length */
{
  var next_code = new Array(MAX_BITS + 1); /* next code value for each bit length */
  var code = 0; /* running code value */
  var bits; /* bit index */
  var n; /* code index */

  /* The distribution counts are first used to generate the code values
   * without bit reversal.
   */
  for (bits = 1; bits <= MAX_BITS; bits++) {
    next_code[bits] = code = code + bl_count[bits - 1] << 1;
  }
  /* Check that the bit counts in bl_count are consistent. The last code
   * must be all ones.
   */
  //Assert (code + bl_count[MAX_BITS]-1 == (1<<MAX_BITS)-1,
  //        "inconsistent bit counts");
  //Tracev((stderr,"\ngen_codes: max_code %d ", max_code));

  for (n = 0; n <= max_code; n++) {
    var len = tree[n * 2 + 1] /*.Len*/;
    if (len === 0) {
      continue;
    }
    /* Now reverse the bits */
    tree[n * 2] /*.Code*/ = bi_reverse(next_code[len]++, len);

    //Tracecv(tree != static_ltree, (stderr,"\nn %3d %c l %2d c %4x (%x) ",
    //     n, (isgraph(n) ? n : ' '), len, tree[n].Code, next_code[len]-1));
  }
}

/* ===========================================================================
 * Initialize the various 'constant' tables.
 */
function tr_static_init() {
  var n; /* iterates over tree elements */
  var bits; /* bit counter */
  var length; /* length value */
  var code; /* code value */
  var dist; /* distance index */
  var bl_count = new Array(MAX_BITS + 1);
  /* number of codes at each bit length for an optimal tree */

  // do check in _tr_init()
  //if (static_init_done) return;

  /* For some embedded targets, global variables are not initialized: */
  /*#ifdef NO_INIT_GLOBAL_POINTERS
    static_l_desc.static_tree = static_ltree;
    static_l_desc.extra_bits = extra_lbits;
    static_d_desc.static_tree = static_dtree;
    static_d_desc.extra_bits = extra_dbits;
    static_bl_desc.extra_bits = extra_blbits;
  #endif*/

  /* Initialize the mapping length (0..255) -> length code (0..28) */
  length = 0;
  for (code = 0; code < LENGTH_CODES - 1; code++) {
    base_length[code] = length;
    for (n = 0; n < 1 << extra_lbits[code]; n++) {
      _length_code[length++] = code;
    }
  }
  //Assert (length == 256, "tr_static_init: length != 256");
  /* Note that the length 255 (match length 258) can be represented
   * in two different ways: code 284 + 5 bits or code 285, so we
   * overwrite length_code[255] to use the best encoding:
   */
  _length_code[length - 1] = code;

  /* Initialize the mapping dist (0..32K) -> dist code (0..29) */
  dist = 0;
  for (code = 0; code < 16; code++) {
    base_dist[code] = dist;
    for (n = 0; n < 1 << extra_dbits[code]; n++) {
      _dist_code[dist++] = code;
    }
  }
  //Assert (dist == 256, "tr_static_init: dist != 256");
  dist >>= 7; /* from now on, all distances are divided by 128 */
  for (; code < D_CODES; code++) {
    base_dist[code] = dist << 7;
    for (n = 0; n < 1 << extra_dbits[code] - 7; n++) {
      _dist_code[256 + dist++] = code;
    }
  }
  //Assert (dist == 256, "tr_static_init: 256+dist != 512");

  /* Construct the codes of the static literal tree */
  for (bits = 0; bits <= MAX_BITS; bits++) {
    bl_count[bits] = 0;
  }

  n = 0;
  while (n <= 143) {
    static_ltree[n * 2 + 1] /*.Len*/ = 8;
    n++;
    bl_count[8]++;
  }
  while (n <= 255) {
    static_ltree[n * 2 + 1] /*.Len*/ = 9;
    n++;
    bl_count[9]++;
  }
  while (n <= 279) {
    static_ltree[n * 2 + 1] /*.Len*/ = 7;
    n++;
    bl_count[7]++;
  }
  while (n <= 287) {
    static_ltree[n * 2 + 1] /*.Len*/ = 8;
    n++;
    bl_count[8]++;
  }
  /* Codes 286 and 287 do not exist, but we must include them in the
   * tree construction to get a canonical Huffman tree (longest code
   * all ones)
   */
  gen_codes(static_ltree, L_CODES + 1, bl_count);

  /* The static distance tree is trivial: */
  for (n = 0; n < D_CODES; n++) {
    static_dtree[n * 2 + 1] /*.Len*/ = 5;
    static_dtree[n * 2] /*.Code*/ = bi_reverse(n, 5);
  }

  // Now data ready and we can init static trees
  static_l_desc = new StaticTreeDesc(static_ltree, extra_lbits, LITERALS + 1, L_CODES, MAX_BITS);
  static_d_desc = new StaticTreeDesc(static_dtree, extra_dbits, 0, D_CODES, MAX_BITS);
  static_bl_desc = new StaticTreeDesc(new Array(0), extra_blbits, 0, BL_CODES, MAX_BL_BITS);

  //static_init_done = true;
}

/* ===========================================================================
 * Initialize a new block.
 */
function init_block(s) {
  var n; /* iterates over tree elements */

  /* Initialize the trees. */
  for (n = 0; n < L_CODES; n++) {
    s.dyn_ltree[n * 2] /*.Freq*/ = 0;
  }
  for (n = 0; n < D_CODES; n++) {
    s.dyn_dtree[n * 2] /*.Freq*/ = 0;
  }
  for (n = 0; n < BL_CODES; n++) {
    s.bl_tree[n * 2] /*.Freq*/ = 0;
  }

  s.dyn_ltree[END_BLOCK * 2] /*.Freq*/ = 1;
  s.opt_len = s.static_len = 0;
  s.last_lit = s.matches = 0;
}

/* ===========================================================================
 * Flush the bit buffer and align the output on a byte boundary
 */
function bi_windup(s) {
  if (s.bi_valid > 8) {
    put_short(s, s.bi_buf);
  } else if (s.bi_valid > 0) {
    //put_byte(s, (Byte)s->bi_buf);
    s.pending_buf[s.pending++] = s.bi_buf;
  }
  s.bi_buf = 0;
  s.bi_valid = 0;
}

/* ===========================================================================
 * Copy a stored block, storing first the length and its
 * one's complement if requested.
 */
function copy_block(s, buf, len, header)
//DeflateState *s;
//charf    *buf;    /* the input data */
//unsigned len;     /* its length */
//int      header;  /* true if block header must be written */
{
  bi_windup(s); /* align on byte boundary */

  if (header) {
    put_short(s, len);
    put_short(s, ~len);
  }
  //  while (len--) {
  //    put_byte(s, *buf++);
  //  }
  utils.arraySet(s.pending_buf, s.window, buf, len, s.pending);
  s.pending += len;
}

/* ===========================================================================
 * Compares to subtrees, using the tree depth as tie breaker when
 * the subtrees have equal frequency. This minimizes the worst case length.
 */
function smaller(tree, n, m, depth) {
  var _n2 = n * 2;
  var _m2 = m * 2;
  return tree[_n2] /*.Freq*/ < tree[_m2] /*.Freq*/ || tree[_n2] /*.Freq*/ === tree[_m2] /*.Freq*/ && depth[n] <= depth[m];
}

/* ===========================================================================
 * Restore the heap property by moving down the tree starting at node k,
 * exchanging a node with the smallest of its two sons if necessary, stopping
 * when the heap property is re-established (each father smaller than its
 * two sons).
 */
function pqdownheap(s, tree, k)
//    deflate_state *s;
//    ct_data *tree;  /* the tree to restore */
//    int k;               /* node to move down */
{
  var v = s.heap[k];
  var j = k << 1; /* left son of k */
  while (j <= s.heap_len) {
    /* Set j to the smallest of the two sons: */
    if (j < s.heap_len && smaller(tree, s.heap[j + 1], s.heap[j], s.depth)) {
      j++;
    }
    /* Exit if v is smaller than both sons */
    if (smaller(tree, v, s.heap[j], s.depth)) {
      break;
    }

    /* Exchange v with the smallest son */
    s.heap[k] = s.heap[j];
    k = j;

    /* And continue down the tree, setting j to the left son of k */
    j <<= 1;
  }
  s.heap[k] = v;
}

// inlined manually
// var SMALLEST = 1;

/* ===========================================================================
 * Send the block data compressed using the given Huffman trees
 */
function compress_block(s, ltree, dtree)
//    deflate_state *s;
//    const ct_data *ltree; /* literal tree */
//    const ct_data *dtree; /* distance tree */
{
  var dist; /* distance of matched string */
  var lc; /* match length or unmatched char (if dist == 0) */
  var lx = 0; /* running index in l_buf */
  var code; /* the code to send */
  var extra; /* number of extra bits to send */

  if (s.last_lit !== 0) {
    do {
      dist = s.pending_buf[s.d_buf + lx * 2] << 8 | s.pending_buf[s.d_buf + lx * 2 + 1];
      lc = s.pending_buf[s.l_buf + lx];
      lx++;

      if (dist === 0) {
        send_code(s, lc, ltree); /* send a literal byte */
        //Tracecv(isgraph(lc), (stderr," '%c' ", lc));
      } else {
        /* Here, lc is the match length - MIN_MATCH */
        code = _length_code[lc];
        send_code(s, code + LITERALS + 1, ltree); /* send the length code */
        extra = extra_lbits[code];
        if (extra !== 0) {
          lc -= base_length[code];
          send_bits(s, lc, extra); /* send the extra length bits */
        }
        dist--; /* dist is now the match distance - 1 */
        code = d_code(dist);
        //Assert (code < D_CODES, "bad d_code");

        send_code(s, code, dtree); /* send the distance code */
        extra = extra_dbits[code];
        if (extra !== 0) {
          dist -= base_dist[code];
          send_bits(s, dist, extra); /* send the extra distance bits */
        }
      } /* literal or match pair ? */

      /* Check that the overlay between pending_buf and d_buf+l_buf is ok: */
      //Assert((uInt)(s->pending) < s->lit_bufsize + 2*lx,
      //       "pendingBuf overflow");
    } while (lx < s.last_lit);
  }

  send_code(s, END_BLOCK, ltree);
}

/* ===========================================================================
 * Construct one Huffman tree and assigns the code bit strings and lengths.
 * Update the total bit length for the current block.
 * IN assertion: the field freq is set for all tree elements.
 * OUT assertions: the fields len and code are set to the optimal bit length
 *     and corresponding code. The length opt_len is updated; static_len is
 *     also updated if stree is not null. The field max_code is set.
 */
function build_tree(s, desc)
//    deflate_state *s;
//    tree_desc *desc; /* the tree descriptor */
{
  var tree = desc.dyn_tree;
  var stree = desc.stat_desc.static_tree;
  var has_stree = desc.stat_desc.has_stree;
  var elems = desc.stat_desc.elems;
  var n, m; /* iterate over heap elements */
  var max_code = -1; /* largest code with non zero frequency */
  var node; /* new node being created */

  /* Construct the initial heap, with least frequent element in
   * heap[SMALLEST]. The sons of heap[n] are heap[2*n] and heap[2*n+1].
   * heap[0] is not used.
   */
  s.heap_len = 0;
  s.heap_max = HEAP_SIZE;

  for (n = 0; n < elems; n++) {
    if (tree[n * 2] /*.Freq*/ !== 0) {
      s.heap[++s.heap_len] = max_code = n;
      s.depth[n] = 0;
    } else {
      tree[n * 2 + 1] /*.Len*/ = 0;
    }
  }

  /* The pkzip format requires that at least one distance code exists,
   * and that at least one bit should be sent even if there is only one
   * possible code. So to avoid special checks later on we force at least
   * two codes of non zero frequency.
   */
  while (s.heap_len < 2) {
    node = s.heap[++s.heap_len] = max_code < 2 ? ++max_code : 0;
    tree[node * 2] /*.Freq*/ = 1;
    s.depth[node] = 0;
    s.opt_len--;

    if (has_stree) {
      s.static_len -= stree[node * 2 + 1] /*.Len*/;
    }
    /* node is 0 or 1 so it does not have extra bits */
  }
  desc.max_code = max_code;

  /* The elements heap[heap_len/2+1 .. heap_len] are leaves of the tree,
   * establish sub-heaps of increasing lengths:
   */
  for (n = s.heap_len >> 1 /*int /2*/; n >= 1; n--) {
    pqdownheap(s, tree, n);
  }

  /* Construct the Huffman tree by repeatedly combining the least two
   * frequent nodes.
   */
  node = elems; /* next internal node of the tree */
  do {
    //pqremove(s, tree, n);  /* n = node of least frequency */
    /*** pqremove ***/
    n = s.heap[1 /*SMALLEST*/];
    s.heap[1 /*SMALLEST*/] = s.heap[s.heap_len--];
    pqdownheap(s, tree, 1 /*SMALLEST*/);
    /***/

    m = s.heap[1 /*SMALLEST*/]; /* m = node of next least frequency */

    s.heap[--s.heap_max] = n; /* keep the nodes sorted by frequency */
    s.heap[--s.heap_max] = m;

    /* Create a new node father of n and m */
    tree[node * 2] /*.Freq*/ = tree[n * 2] /*.Freq*/ + tree[m * 2] /*.Freq*/;
    s.depth[node] = (s.depth[n] >= s.depth[m] ? s.depth[n] : s.depth[m]) + 1;
    tree[n * 2 + 1] /*.Dad*/ = tree[m * 2 + 1] /*.Dad*/ = node;

    /* and insert the new node in the heap */
    s.heap[1 /*SMALLEST*/] = node++;
    pqdownheap(s, tree, 1 /*SMALLEST*/);
  } while (s.heap_len >= 2);

  s.heap[--s.heap_max] = s.heap[1 /*SMALLEST*/];

  /* At this point, the fields freq and dad are set. We can now
   * generate the bit lengths.
   */
  gen_bitlen(s, desc);

  /* The field len is now set, we can generate the bit codes */
  gen_codes(tree, max_code, s.bl_count);
}

/* ===========================================================================
 * Scan a literal or distance tree to determine the frequencies of the codes
 * in the bit length tree.
 */
function scan_tree(s, tree, max_code)
//    deflate_state *s;
//    ct_data *tree;   /* the tree to be scanned */
//    int max_code;    /* and its largest code of non zero frequency */
{
  var n; /* iterates over all tree elements */
  var prevlen = -1; /* last emitted length */
  var curlen; /* length of current code */

  var nextlen = tree[0 * 2 + 1] /*.Len*/; /* length of next code */

  var count = 0; /* repeat count of the current code */
  var max_count = 7; /* max repeat count */
  var min_count = 4; /* min repeat count */

  if (nextlen === 0) {
    max_count = 138;
    min_count = 3;
  }
  tree[(max_code + 1) * 2 + 1] /*.Len*/ = 0xffff; /* guard */

  for (n = 0; n <= max_code; n++) {
    curlen = nextlen;
    nextlen = tree[(n + 1) * 2 + 1] /*.Len*/;

    if (++count < max_count && curlen === nextlen) {
      continue;
    } else if (count < min_count) {
      s.bl_tree[curlen * 2] /*.Freq*/ += count;
    } else if (curlen !== 0) {

      if (curlen !== prevlen) {
        s.bl_tree[curlen * 2] /*.Freq*/++;
      }
      s.bl_tree[REP_3_6 * 2] /*.Freq*/++;
    } else if (count <= 10) {
      s.bl_tree[REPZ_3_10 * 2] /*.Freq*/++;
    } else {
      s.bl_tree[REPZ_11_138 * 2] /*.Freq*/++;
    }

    count = 0;
    prevlen = curlen;

    if (nextlen === 0) {
      max_count = 138;
      min_count = 3;
    } else if (curlen === nextlen) {
      max_count = 6;
      min_count = 3;
    } else {
      max_count = 7;
      min_count = 4;
    }
  }
}

/* ===========================================================================
 * Send a literal or distance tree in compressed form, using the codes in
 * bl_tree.
 */
function send_tree(s, tree, max_code)
//    deflate_state *s;
//    ct_data *tree; /* the tree to be scanned */
//    int max_code;       /* and its largest code of non zero frequency */
{
  var n; /* iterates over all tree elements */
  var prevlen = -1; /* last emitted length */
  var curlen; /* length of current code */

  var nextlen = tree[0 * 2 + 1] /*.Len*/; /* length of next code */

  var count = 0; /* repeat count of the current code */
  var max_count = 7; /* max repeat count */
  var min_count = 4; /* min repeat count */

  /* tree[max_code+1].Len = -1; */ /* guard already set */
  if (nextlen === 0) {
    max_count = 138;
    min_count = 3;
  }

  for (n = 0; n <= max_code; n++) {
    curlen = nextlen;
    nextlen = tree[(n + 1) * 2 + 1] /*.Len*/;

    if (++count < max_count && curlen === nextlen) {
      continue;
    } else if (count < min_count) {
      do {
        send_code(s, curlen, s.bl_tree);
      } while (--count !== 0);
    } else if (curlen !== 0) {
      if (curlen !== prevlen) {
        send_code(s, curlen, s.bl_tree);
        count--;
      }
      //Assert(count >= 3 && count <= 6, " 3_6?");
      send_code(s, REP_3_6, s.bl_tree);
      send_bits(s, count - 3, 2);
    } else if (count <= 10) {
      send_code(s, REPZ_3_10, s.bl_tree);
      send_bits(s, count - 3, 3);
    } else {
      send_code(s, REPZ_11_138, s.bl_tree);
      send_bits(s, count - 11, 7);
    }

    count = 0;
    prevlen = curlen;
    if (nextlen === 0) {
      max_count = 138;
      min_count = 3;
    } else if (curlen === nextlen) {
      max_count = 6;
      min_count = 3;
    } else {
      max_count = 7;
      min_count = 4;
    }
  }
}

/* ===========================================================================
 * Construct the Huffman tree for the bit lengths and return the index in
 * bl_order of the last bit length code to send.
 */
function build_bl_tree(s) {
  var max_blindex; /* index of last bit length code of non zero freq */

  /* Determine the bit length frequencies for literal and distance trees */
  scan_tree(s, s.dyn_ltree, s.l_desc.max_code);
  scan_tree(s, s.dyn_dtree, s.d_desc.max_code);

  /* Build the bit length tree: */
  build_tree(s, s.bl_desc);
  /* opt_len now includes the length of the tree representations, except
   * the lengths of the bit lengths codes and the 5+5+4 bits for the counts.
   */

  /* Determine the number of bit length codes to send. The pkzip format
   * requires that at least 4 bit length codes be sent. (appnote.txt says
   * 3 but the actual value used is 4.)
   */
  for (max_blindex = BL_CODES - 1; max_blindex >= 3; max_blindex--) {
    if (s.bl_tree[bl_order[max_blindex] * 2 + 1] /*.Len*/ !== 0) {
      break;
    }
  }
  /* Update opt_len to include the bit length tree and counts */
  s.opt_len += 3 * (max_blindex + 1) + 5 + 5 + 4;
  //Tracev((stderr, "\ndyn trees: dyn %ld, stat %ld",
  //        s->opt_len, s->static_len));

  return max_blindex;
}

/* ===========================================================================
 * Send the header for a block using dynamic Huffman trees: the counts, the
 * lengths of the bit length codes, the literal tree and the distance tree.
 * IN assertion: lcodes >= 257, dcodes >= 1, blcodes >= 4.
 */
function send_all_trees(s, lcodes, dcodes, blcodes)
//    deflate_state *s;
//    int lcodes, dcodes, blcodes; /* number of codes for each tree */
{
  var rank; /* index in bl_order */

  //Assert (lcodes >= 257 && dcodes >= 1 && blcodes >= 4, "not enough codes");
  //Assert (lcodes <= L_CODES && dcodes <= D_CODES && blcodes <= BL_CODES,
  //        "too many codes");
  //Tracev((stderr, "\nbl counts: "));
  send_bits(s, lcodes - 257, 5); /* not +255 as stated in appnote.txt */
  send_bits(s, dcodes - 1, 5);
  send_bits(s, blcodes - 4, 4); /* not -3 as stated in appnote.txt */
  for (rank = 0; rank < blcodes; rank++) {
    //Tracev((stderr, "\nbl code %2d ", bl_order[rank]));
    send_bits(s, s.bl_tree[bl_order[rank] * 2 + 1] /*.Len*/, 3);
  }
  //Tracev((stderr, "\nbl tree: sent %ld", s->bits_sent));

  send_tree(s, s.dyn_ltree, lcodes - 1); /* literal tree */
  //Tracev((stderr, "\nlit tree: sent %ld", s->bits_sent));

  send_tree(s, s.dyn_dtree, dcodes - 1); /* distance tree */
  //Tracev((stderr, "\ndist tree: sent %ld", s->bits_sent));
}

/* ===========================================================================
 * Check if the data type is TEXT or BINARY, using the following algorithm:
 * - TEXT if the two conditions below are satisfied:
 *    a) There are no non-portable control characters belonging to the
 *       "black list" (0..6, 14..25, 28..31).
 *    b) There is at least one printable character belonging to the
 *       "white list" (9 {TAB}, 10 {LF}, 13 {CR}, 32..255).
 * - BINARY otherwise.
 * - The following partially-portable control characters form a
 *   "gray list" that is ignored in this detection algorithm:
 *   (7 {BEL}, 8 {BS}, 11 {VT}, 12 {FF}, 26 {SUB}, 27 {ESC}).
 * IN assertion: the fields Freq of dyn_ltree are set.
 */
function detect_data_type(s) {
  /* black_mask is the bit mask of black-listed bytes
   * set bits 0..6, 14..25, and 28..31
   * 0xf3ffc07f = binary 11110011111111111100000001111111
   */
  var black_mask = 0xf3ffc07f;
  var n;

  /* Check for non-textual ("black-listed") bytes. */
  for (n = 0; n <= 31; n++, black_mask >>>= 1) {
    if (black_mask & 1 && s.dyn_ltree[n * 2] /*.Freq*/ !== 0) {
      return Z_BINARY;
    }
  }

  /* Check for textual ("white-listed") bytes. */
  if (s.dyn_ltree[9 * 2] /*.Freq*/ !== 0 || s.dyn_ltree[10 * 2] /*.Freq*/ !== 0 || s.dyn_ltree[13 * 2] /*.Freq*/ !== 0) {
    return Z_TEXT;
  }
  for (n = 32; n < LITERALS; n++) {
    if (s.dyn_ltree[n * 2] /*.Freq*/ !== 0) {
      return Z_TEXT;
    }
  }

  /* There are no "black-listed" or "white-listed" bytes:
   * this stream either is empty or has tolerated ("gray-listed") bytes only.
   */
  return Z_BINARY;
}

var static_init_done = false;

/* ===========================================================================
 * Initialize the tree data structures for a new zlib stream.
 */
function _tr_init(s) {

  if (!static_init_done) {
    tr_static_init();
    static_init_done = true;
  }

  s.l_desc = new TreeDesc(s.dyn_ltree, static_l_desc);
  s.d_desc = new TreeDesc(s.dyn_dtree, static_d_desc);
  s.bl_desc = new TreeDesc(s.bl_tree, static_bl_desc);

  s.bi_buf = 0;
  s.bi_valid = 0;

  /* Initialize the first block of the first file: */
  init_block(s);
}

/* ===========================================================================
 * Send a stored block
 */
function _tr_stored_block(s, buf, stored_len, last)
//DeflateState *s;
//charf *buf;       /* input block */
//ulg stored_len;   /* length of input block */
//int last;         /* one if this is the last block for a file */
{
  send_bits(s, (STORED_BLOCK << 1) + (last ? 1 : 0), 3); /* send block type */
  copy_block(s, buf, stored_len, true); /* with header */
}

/* ===========================================================================
 * Send one empty static block to give enough lookahead for inflate.
 * This takes 10 bits, of which 7 may remain in the bit buffer.
 */
function _tr_align(s) {
  send_bits(s, STATIC_TREES << 1, 3);
  send_code(s, END_BLOCK, static_ltree);
  bi_flush(s);
}

/* ===========================================================================
 * Determine the best encoding for the current block: dynamic trees, static
 * trees or store, and output the encoded block to the zip file.
 */
function _tr_flush_block(s, buf, stored_len, last)
//DeflateState *s;
//charf *buf;       /* input block, or NULL if too old */
//ulg stored_len;   /* length of input block */
//int last;         /* one if this is the last block for a file */
{
  var opt_lenb, static_lenb; /* opt_len and static_len in bytes */
  var max_blindex = 0; /* index of last bit length code of non zero freq */

  /* Build the Huffman trees unless a stored block is forced */
  if (s.level > 0) {

    /* Check if the file is binary or text */
    if (s.strm.data_type === Z_UNKNOWN) {
      s.strm.data_type = detect_data_type(s);
    }

    /* Construct the literal and distance trees */
    build_tree(s, s.l_desc);
    // Tracev((stderr, "\nlit data: dyn %ld, stat %ld", s->opt_len,
    //        s->static_len));

    build_tree(s, s.d_desc);
    // Tracev((stderr, "\ndist data: dyn %ld, stat %ld", s->opt_len,
    //        s->static_len));
    /* At this point, opt_len and static_len are the total bit lengths of
     * the compressed block data, excluding the tree representations.
     */

    /* Build the bit length tree for the above two trees, and get the index
     * in bl_order of the last bit length code to send.
     */
    max_blindex = build_bl_tree(s);

    /* Determine the best encoding. Compute the block lengths in bytes. */
    opt_lenb = s.opt_len + 3 + 7 >>> 3;
    static_lenb = s.static_len + 3 + 7 >>> 3;

    // Tracev((stderr, "\nopt %lu(%lu) stat %lu(%lu) stored %lu lit %u ",
    //        opt_lenb, s->opt_len, static_lenb, s->static_len, stored_len,
    //        s->last_lit));

    if (static_lenb <= opt_lenb) {
      opt_lenb = static_lenb;
    }
  } else {
    // Assert(buf != (char*)0, "lost buf");
    opt_lenb = static_lenb = stored_len + 5; /* force a stored block */
  }

  if (stored_len + 4 <= opt_lenb && buf !== -1) {
    /* 4: two words for the lengths */

    /* The test buf != NULL is only necessary if LIT_BUFSIZE > WSIZE.
     * Otherwise we can't have processed more than WSIZE input bytes since
     * the last block flush, because compression would have been
     * successful. If LIT_BUFSIZE <= WSIZE, it is never too late to
     * transform a block into a stored block.
     */
    _tr_stored_block(s, buf, stored_len, last);
  } else if (s.strategy === Z_FIXED || static_lenb === opt_lenb) {

    send_bits(s, (STATIC_TREES << 1) + (last ? 1 : 0), 3);
    compress_block(s, static_ltree, static_dtree);
  } else {
    send_bits(s, (DYN_TREES << 1) + (last ? 1 : 0), 3);
    send_all_trees(s, s.l_desc.max_code + 1, s.d_desc.max_code + 1, max_blindex + 1);
    compress_block(s, s.dyn_ltree, s.dyn_dtree);
  }
  // Assert (s->compressed_len == s->bits_sent, "bad compressed size");
  /* The above check is made mod 2^32, for files larger than 512 MB
   * and uLong implemented on 32 bits.
   */
  init_block(s);

  if (last) {
    bi_windup(s);
  }
  // Tracev((stderr,"\ncomprlen %lu(%lu) ", s->compressed_len>>3,
  //       s->compressed_len-7*last));
}

/* ===========================================================================
 * Save the match info and tally the frequency counts. Return true if
 * the current block must be flushed.
 */
function _tr_tally(s, dist, lc)
//    deflate_state *s;
//    unsigned dist;  /* distance of matched string */
//    unsigned lc;    /* match length-MIN_MATCH or unmatched char (if dist==0) */
{
  //var out_length, in_length, dcode;

  s.pending_buf[s.d_buf + s.last_lit * 2] = dist >>> 8 & 0xff;
  s.pending_buf[s.d_buf + s.last_lit * 2 + 1] = dist & 0xff;

  s.pending_buf[s.l_buf + s.last_lit] = lc & 0xff;
  s.last_lit++;

  if (dist === 0) {
    /* lc is the unmatched char */
    s.dyn_ltree[lc * 2] /*.Freq*/++;
  } else {
    s.matches++;
    /* Here, lc is the match length - MIN_MATCH */
    dist--; /* dist = match distance - 1 */
    //Assert((ush)dist < (ush)MAX_DIST(s) &&
    //       (ush)lc <= (ush)(MAX_MATCH-MIN_MATCH) &&
    //       (ush)d_code(dist) < (ush)D_CODES,  "_tr_tally: bad match");

    s.dyn_ltree[(_length_code[lc] + LITERALS + 1) * 2] /*.Freq*/++;
    s.dyn_dtree[d_code(dist) * 2] /*.Freq*/++;
  }

  // (!) This block is disabled in zlib defailts,
  // don't enable it for binary compatibility

  //#ifdef TRUNCATE_BLOCK
  //  /* Try to guess if it is profitable to stop the current block here */
  //  if ((s.last_lit & 0x1fff) === 0 && s.level > 2) {
  //    /* Compute an upper bound for the compressed length */
  //    out_length = s.last_lit*8;
  //    in_length = s.strstart - s.block_start;
  //
  //    for (dcode = 0; dcode < D_CODES; dcode++) {
  //      out_length += s.dyn_dtree[dcode*2]/*.Freq*/ * (5 + extra_dbits[dcode]);
  //    }
  //    out_length >>>= 3;
  //    //Tracev((stderr,"\nlast_lit %u, in %ld, out ~%ld(%ld%%) ",
  //    //       s->last_lit, in_length, out_length,
  //    //       100L - out_length*100L/in_length));
  //    if (s.matches < (s.last_lit>>1)/*int /2*/ && out_length < (in_length>>1)/*int /2*/) {
  //      return true;
  //    }
  //  }
  //#endif

  return s.last_lit === s.lit_bufsize - 1;
  /* We avoid equality with lit_bufsize because of wraparound at 64K
   * on 16 bit machines and because stored blocks are restricted to
   * 64K-1 bytes.
   */
}

exports._tr_init = _tr_init;
exports._tr_stored_block = _tr_stored_block;
exports._tr_flush_block = _tr_flush_block;
exports._tr_tally = _tr_tally;
exports._tr_align = _tr_align;
},{"../utils/common.js":35}],44:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = ZStream;
function ZStream() {
  /* next input byte */
  this.input = null; // JS specific, because we have no pointers
  this.next_in = 0;
  /* number of bytes available at input */
  this.avail_in = 0;
  /* total number of input bytes read so far */
  this.total_in = 0;
  /* next output byte should be put there */
  this.output = null; // JS specific, because we have no pointers
  this.next_out = 0;
  /* remaining free space at output */
  this.avail_out = 0;
  /* total number of bytes output so far */
  this.total_out = 0;
  /* last error message, NULL if no error */
  this.msg = '' /*Z_NULL*/;
  /* not visible by applications */
  this.state = null;
  /* best guess about the data type: binary or text */
  this.data_type = 2 /*Z_UNKNOWN*/;
  /* adler32 value of the uncompressed data */
  this.adler = 0;
}
},{}]},{},[2]);
