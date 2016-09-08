var CloudCmd, Util, DOM;

(function(CloudCmd, Util, DOM) {
    'use strict';

    var Info    = DOM.CurrentInfo,
        Events  = DOM.Events,
        Buffer  = DOM.Buffer,

        Chars   = [],
        KEY     = {
            BACKSPACE   : 8,
            TAB         : 9,
            ENTER       : 13,
            ESC         : 27,

            SPACE       : 32,
            PAGE_UP     : 33,
            PAGE_DOWN   : 34,
            END         : 35,
            HOME        : 36,

            LEFT        : 37,
            UP          : 38,
            RIGHT       : 39,
            DOWN        : 40,

            INSERT      : 45,
            DELETE      : 46,

            ZERO        : 48,

            A           : 65,

            C           : 67,
            D           : 68,

            G           : 71,

            O           : 79,
            Q           : 81,
            R           : 82,
            S           : 83,
            T           : 84,
            U           : 85,

            V           : 86,

            X           : 88,

            Z           : 90,

            INSERT_MAC  : 96,

            ASTERISK    : 106,
            PLUS        : 107,
            MINUS       : 109,

            F1          : 112,
            F2          : 113,
            F3          : 114,
            F4          : 115,
            F5          : 116,
            F6          : 117,
            F7          : 118,
            F8          : 119,
            F9          : 120,
            F10         : 121,

            EQUAL       : 187,
            HYPHEN      : 189,
            DOT         : 190,
            SLASH       : 191,
            TRA         : 192, /* Typewritten Reverse Apostrophe (`) */
            BACKSLASH   : 220,

            BRACKET_CLOSE: 221
        };

    KeyProto.prototype = KEY;
    CloudCmd.Key = KeyProto;

    function KeyProto() {
        var Key = this,
            Binded;

        this.isBind     = function() {
            return Binded;
        };

        this.setBind    = function() {
            Binded = true;
        };

        this.unsetBind  = function() {
            Binded = false;
        };

        this.bind   = function() {
            Events.addKey(listener);
            Binded = true;
        };

        function listener(event) {
            /* get selected file */
            var keyCode         = event.keyCode,
                alt             = event.altKey,
                ctrl            = event.ctrlKey,
                shift           = event.shiftKey,
                meta            = event.metaKey,
                isBetween       = keyCode >= KEY.ZERO && keyCode <= KEY.Z,
                isSymbol,
                char            = '';

            /*
             * event.keyIdentifier deprecated in chrome v51
             * but event.key is absent in chrome <= v51
             */
            if (event.key)
                char = event.key;
            else
                char = fromCharCode(event.keyIdentifier);

            isSymbol = ~['.', '_', '-', '+', '='].indexOf(char);

            if (!isSymbol) {
                isSymbol = getSymbol(shift, keyCode);

                if (isSymbol)
                    char = isSymbol;
            }

            /* in case buttons can be processed */
            if (Key.isBind())
                if (!alt && !ctrl && !meta && (isBetween || isSymbol))
                    setCurrentByChar(char);
                else {
                    Chars       = [];
                    switchKey(event);
                }
        }

        function getSymbol(shift, keyCode) {
            var char;

            switch (keyCode) {
            case KEY.DOT:
                char = '.';
                break;

            case KEY.HYPHEN:
                char = shift ? '_' : '-';
                break;

            case KEY.EQUAL:
                char = shift ? '+' : '=';
                break;
            }

            return char;
        }

        function fromCharCode(keyIdentifier) {
            var code    = keyIdentifier.substring(2),
                hex     = parseInt(code, 16),
                char    = String.fromCharCode(hex);

            return char;
        }

        function setCurrentByChar(char) {
            var name, isMatch, byName, firstByName,
                skipCount   = 0,
                skipN       = 0,
                setted      = false,
                current     = Info.element,
                files       = Info.files,
                escapeChar  = Util.escapeRegExp(char),
                regExp      = new RegExp('^' + escapeChar + '.*$', 'i'),
                i           = 0,
                n           = Chars.length;

            while(i < n && char === Chars[i]) {
                i++;
            }

            if (!i)
                Chars = [];

            skipN           = skipCount = i;
            Chars.push(char);

            n               = files.length;
            for (i = 0; i < n; i++) {
                current     = files[i];
                name        = DOM.getCurrentName(current);
                isMatch     = name.match(regExp);

                if (isMatch && name !== '..') {
                    byName = DOM.getCurrentByName(name);

                    if (!skipCount) {
                        setted = true;
                        DOM.setCurrentFile(byName);
                        break;
                    } else {
                        if (skipN === skipCount)
                            firstByName = byName;

                        --skipCount;
                    }
                }
            }

            if (!setted) {
                DOM.setCurrentFile(firstByName);
                Chars = [char];
            }
        }

        function switchKey(event) {
            var i, name, isSelected, isDir, prev, next,
                Operation       = CloudCmd.Operation,
                current         = Info.element,
                panel           = Info.panel,
                path            = Info.path,
                keyCode         = event.keyCode,
                alt             = event.altKey,
                shift           = event.shiftKey,
                ctrl            = event.ctrlKey,
                meta            = event.metaKey,
                ctrlMeta        = ctrl || meta;

            if (current) {
                // OSC_CUSTOM_CODE this was using the incorrect method calls
                // Updating these from fixes the arrow key functionality
                // and probably any other bugs resulting from use of 'next' and 'prev'
                prev            = current.previousElementSibling;
                next            = current.nextElementSibling;
            }

            switch (keyCode) {
            case Key.INSERT:
                DOM .toggleSelectedFile(current)
                    .setCurrentFile(next);
                break;

            case Key.INSERT_MAC:
                DOM .toggleSelectedFile(current)
                    .setCurrentFile(next);
                break;

            case Key.DELETE:
                if (shift)
                    Operation.show('delete:silent');
                else
                    Operation.show('delete');
                break;

            case Key.ASTERISK:
                DOM.toggleAllSelectedFiles(current);
                break;

            case Key.PLUS:
                DOM.expandSelection();
                event.preventDefault();
                break;

            case Key.MINUS:
                DOM.shrinkSelection();
                event.preventDefault();
                break;

            case Key.SPACE:
                isDir   = Info.isDir,
                name    = Info.name;

                if (!isDir || name === '..')
                    isSelected    = true;
                else
                    isSelected    = DOM.isSelected(current);

                Util.exec.if(isSelected, function() {
                    DOM.toggleSelectedFile(current);
                }, function(callback) {
                    DOM.loadCurrentSize(callback, current);
                });

                event.preventDefault();
                break;

            /* navigation on file table:        *
             * in case of pressing button 'up', *
             * select previous row              */
            case Key.UP:
                if (shift)
                    DOM.toggleSelectedFile(current);

                DOM.setCurrentFile(prev);
                event.preventDefault();
                break;

            /* in case of pressing button 'down', *
             * select next row                    */
            case Key.DOWN:
                if (shift)
                    DOM.toggleSelectedFile(current);

                DOM.setCurrentFile(next);
                event.preventDefault();
                break;

            /* in case of pressing button 'Home',  *
             * go to top element                   */
            case Key.HOME:
                DOM.setCurrentFile(Info.first);
                event.preventDefault();
                break;

            /* in case of pressing button 'End', select last element */
            case Key.END:
                DOM.setCurrentFile(Info.last);
                event.preventDefault();
                break;

            /* если нажали клавишу page down проматываем экран */
            case Key.PAGE_DOWN:
                DOM.scrollByPages(panel, 1);

                for (i = 0; i < 30; i++) {
                    // OSC_CUSTOM_CODE use nextElementSibling instead of nextSibling
                    if (!current.nextElementSibling)
                        break;

                    // OSC_CUSTOM_CODE use nextElementSibling instead of nextSibling
                    current = current.nextElementSibling;
                }

                DOM.setCurrentFile(current);
                event.preventDefault();
                break;

            /* если нажали клавишу page up проматываем экран */
            case Key.PAGE_UP:
                DOM.scrollByPages(panel, -1);

                for (i = 0; i < 30; i++) {
                    // OSC_CUSTOM_CODE use previousElementSibling instead of previousSibling
                    if (!current.previousElementSibling)
                        break;

                    // OSC_CUSTOM_CODE use previousElementSibling instead of previousSibling
                    current = current.previousElementSibling;
                }

                DOM.setCurrentFile(current);
                event.preventDefault();
                break;

            /* open directory */
            case Key.ENTER:
                if (Info.isDir)
                    CloudCmd.loadDir({
                        path: path === '/' ? '/' : path + '/'
                    });
                break;

            case Key.BACKSPACE:
                CloudCmd.goToParentDir();
                event.preventDefault();
                break;

            case Key.BACKSLASH:
                if (ctrlMeta)
                    CloudCmd.loadDir({
                        path: '/'
                    });
                break;

            case Key.A:
                if (ctrlMeta) {
                    DOM.toggleAllSelectedFiles();
                    event.preventDefault();
                }

                break;

            case Key.G:
                if (alt)
                    DOM.goToDirectory();

                break;

            /**
             * обновляем страницу,
             * загружаем содержимое каталога
             * при этом данные берём всегда с
             * сервера, а не из кэша
             * (обновляем кэш)
             */
            case Key.R:
                if (ctrlMeta) {
                    CloudCmd.log('reloading page...\n');
                    CloudCmd.refresh();
                    event.preventDefault();
                }
                break;
            }
        }
    }

})(CloudCmd, Util, DOM);
