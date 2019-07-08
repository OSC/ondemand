(function(global) {
    'use strict';

    var rendy;

    if (typeof module === 'object' && module.exports) {
        rendy               = require('rendy');
        module.exports      = new CloudFuncProto();
    } else {
        rendy               = window.rendy;
        global.CloudFunc    = new CloudFuncProto();
    }

    function CloudFuncProto() {
        var CloudFunc               = this,
            Entity                  = new entityProto(),
            FS;

        /* Constants (common to both client and server) */

        /* the name of the program */
        this.NAME                   = 'File Explorer';

        /* if the link is this line - in the browser js disabled */
        this.FS    =   FS           = '/fs';

        this.apiURL                 = '/api/v1';
        this.MAX_FILE_SIZE          = 500 * 1024;
        this.Entity                 = Entity;

        function entityProto() {
            var Entities = {
                '&nbsp;': ' ',
                '&lt;'  : '<',
                '&gt;'   : '>'
            };

            this.encode = function(str) {
                Object.keys(Entities).forEach(function(code) {
                    var char    = Entities[code],
                        reg     = RegExp(char, 'g');

                    str = str.replace(reg, code);
                });

                return str;
            };

            this.decode = function(str) {
                Object.keys(Entities).forEach(function(code) {
                    var char    = Entities[code],
                        reg     = RegExp(code, 'g');

                    str = str.replace(reg, char);
                });

                return str;
            };
        }

        this.formatMsg              = function(msg, name, status) {
            if (!status)
                status = 'ok';

            if (name)
                name = '("' + name + '")';
            else
                name = '';

            msg = msg + ': ' + status + name;

            return msg;
        };

        /** The function returns the web page title
         * @pPath
         */
        this.getTitle               = function(pPath) {
            if (!CloudFunc.Path)
                CloudFunc.Path = '/';

            return  CloudFunc.NAME + ' - ' + (pPath || CloudFunc.Path);

        };

        /** The function receives the path of each directory in the directory array
         * @param url -  folder address
         */
        function getPathLink(url, prefix, template) {
            var namesRaw, names, length,
                pathHTML    = '',
                path        = '/';

            if (!url)
                throw Error('url could not be empty!');

            if (!template)
                throw Error('template could not be empty!');

            namesRaw    = url.split('/')
                .slice(1, -1),

                names       = [].concat('/', namesRaw),

                length      = names.length - 1;

            names.forEach(function(name, index) {
                var slash       = '',
                    isLast      = index === length;

                if (index)
                    path        += name + '/';

                if (index && isLast) {
                    pathHTML    += name + '/';
                } else {
                    if (index)
                        slash = '/';

                    pathHTML    += rendy(template, {
                        path: path,
                        name: name,
                        slash: slash,
                        prefix: prefix
                    });
                }
            });

            return pathHTML;
        }

        /*
         * OSC_CUSTOM_CODE change the date format from 'DD.MM.YYYY' to 'MM/DD/YYYY' format
         * @param dotDate - The date in format 'DD.MM.YYYY'
         * @return string - The date in format 'MM/DD/YYYY'
         *                  The date in format '          ' if input is null.
         */
        function buildPrettyDate(dotDate) {
            var prettyDate = '           ';
            if (dotDate != null) {
                prettyDate = dotDate.replace(/(\d\d).(\d\d).(\d{4})/, "$2/$1/$3");
            }
            return prettyDate;
        }

        /**
         * The function builds a table of files from JSON-file information
         * @param params - File information
         *
         */
        this.buildFromJSON          = function(params) {

            var file, i, n, type, attribute, size, date, owner, mode,
                dotDot, link, dataName,
                linkResult,
                prefix          = params.prefix,
                template        = params.template,
                templateFile    = template.file,
                templateLink    = template.link,
                json            = params.data,
                files           = json.files,
                path            = json.path;

            /*
             * Fix for when the user selects file instead of a directory.
             * Displays a message that the user needs to select a directory instead of a file.
             * https://github.com/OSC/ood-fileexplorer/issues/128
             */
            if (!path) {
                path = '/';
                files = [];
                DOM.Dialog.alert("ERROR", "You must select a directory.");
            }

            /*
             * Build a directory path with subdirectories
             */
            var htmlPath        = getPathLink(path, prefix, template.pathLink),

                fileTable       = rendy(template.path, {
                    link        : prefix + FS + path,
                    fullPath    : path,
                    path        : htmlPath
                }),

                // OSC_CUSTOM_CODE change 'date' to 'modified date'
                header         = rendy(templateFile, {
                    tag         : 'div',
                    attribute   : '',
                    className   : 'fm-header',
                    type        : '',
                    name        : 'name',
                    size        : 'size',
                    date        : 'modified date',
                    owner       : 'owner',
                    mode        : 'mode'
                });

            fileTable          += header;

            /* save path */
            CloudFunc.Path      = path;

            fileTable           += '<ul data-name="js-files" class="files">';
            /* If the path is not the root route */
            if (path !== '/') {
                /* remove the last slash in the selected path and from the current location */
                dotDot          = path.substr(path, path.lastIndexOf('/'));
                dotDot          = dotDot.substr(dotDot, dotDot.lastIndexOf('/'));
                /* If previously in the root directory */
                if (dotDot === '')
                    dotDot = '/';

                link            = prefix + FS + dotDot;

                linkResult      = rendy(template.link, {
                    link        : link,
                    title       : '..',
                    name        : '..'
                });

                dataName        = 'data-name="js-file-.." ',
                    attribute       = 'draggable="true" ' + dataName,
                    /* Save the path to the top-level directory
                     * OSC_CUSTOM_CODE use blank date instead of '--.--.----'
                     * */
                    fileTable += rendy(template.file, {
                        tag         : 'li',
                        attribute   : attribute,
                        className   : '',
                        type        : 'directory',
                        name        : linkResult,
                        size        : '&lt;dir&gt;',
                        date        : '          ',
                        owner       : '.',
                        mode        : '--- --- ---'
                    });
            }

            n = files.length;
            for (i = 0; i < n; i++) {
                file            = files[i];
                link            = prefix + FS + path + file.name;
                var isDotfile   = file.name.charAt(0) === "."; // OSC_CUSTOM_CODE add var, true if file starts with '.'

                if (file.size === 'dir') {
                    type        = 'directory';
                    attribute   = '';
                    size        = '&lt;dir&gt;';
                } else {
                    type        = 'text-file';
                    attribute   = 'target="_blank" ';
                    size        = file.size;
                }

                // OSC_CUSTOM_CODE call buildPrettyDate() function and use blank date instead of '--.--.----'
                date    = buildPrettyDate(file.date) || '          ';
                owner   = file.owner || 'root';
                mode    = file.mode;

                linkResult  = rendy(templateLink, {
                    link        : link,
                    title       : file.name,
                    name        : Entity.encode(file.name),
                    attribute   : attribute
                });

                dataName        = 'data-name="js-file-' + file.name + '" ';
                attribute       = 'draggable="true" ' + dataName;

                fileTable += rendy(templateFile, {
                    tag         : 'li',
                    attribute   : attribute,
                    className   : isDotfile ? 'dotfile' : '',  // OSC_CUSTOM_CODE add dotfiles class to dotfiles
                    /*
                     * If a folder - displays a folder icon
                     * In the opposite case - file
                     */
                    type        : type,
                    name        : linkResult,
                    size        : size,
                    date        : date,
                    owner       : owner,
                    mode        : mode
                });
            }

            fileTable          += '</ul>';

            return fileTable;
        };
    }
})(this);
