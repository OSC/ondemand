import 'datatables.net';
import 'datatables.net-bs4/js/dataTables.bootstrap4';
import 'datatables.net-select';
import 'datatables.net-select-bs4';
import Handlebars from 'handlebars';
export { CONTENTID, TRIGGERID };

const TRIGGERID = {
    changeDirectory: 'changeDirectory',
    changeDirectoryPrompt: 'changeDirectoryPrompt',
    clearClipboard: 'clearClipboard',
    closeSwal: 'closeSwal',
    copyFile: 'copyFile',
    createFile: 'createFile',
    createFolder: 'createFolder',
    deleteFile: 'deleteFile',
    deletePrompt: 'deletePrompt',
    download: 'download',
    getJsonResponse: 'getJsonResponse',
    moveFile: 'moveFile',
    newFile: 'newFile',
    newFilePrompt: 'newFilePrompt',
    newFolderPrompt: 'newFolderPrompt',
    newFolder: 'newFolder',
    reloadTable: 'reloadTable',
    renameFile: 'renameFile',
    renameFilePrompt: 'renameFilePrompt',
    showError: 'showError',
    showInput: 'showInput',
    showLoading: 'showLoading',
    showPrompt: 'showPrompt',
    updateClipboard: 'updateClipboard',
    updateClipboardView: 'updateClipboardView',
};

const CONTENTID = {
    table: '#directory-contents',
};

let table = null;

jQuery(function () {
    table = new DataTable();

    /* BUTTON ACTIONS */
    $("#new-file-btn").on("click", function () {
        $(CONTENTID.table).trigger(TRIGGERID.newFilePrompt);
    });

    $("#new-folder-btn").on("click", function () {
        $(CONTENTID.table).trigger(TRIGGERID.newFolderPrompt);
    });

    $("#download-btn").on("click", function () {
        let selection = table.getTable().rows({ selected: true }).data();
        const eventData = {
            selection: selection
        };

        $(CONTENTID.table).trigger(TRIGGERID.download, eventData);

    });

    $("#delete-btn").on("click", function () {
        let files = table.getTable().rows({ selected: true }).data().toArray().map((f) => f.name);
        const eventData = {
            files: files
        };

        $(CONTENTID.table).trigger(TRIGGERID.deletePrompt, eventData);

    });

    $("#copy-move-btn").on("click", function () {
        let selection = table.getTable().rows({ selected: true }).data();
        const eventData = {
            selection: selection
        };

        $(CONTENTID.table).trigger(TRIGGERID.updateClipboard, eventData);

    });

    $("#goto-btn").on("click", function () {
        $(CONTENTID.table).trigger(TRIGGERID.changeDirectoryPrompt);
    });

    // TODO:
    // Will have to work on this one later.  Not so straight forward.
    //
    // $("#upload-btn").on("click", function () {
    //     $(CONTENTID.table).trigger('uppyShowUploadPrompt');
    // });

    /* END BUTTON ACTIONS */

    /* TABLE ACTIONS */

    $(CONTENTID.table).on(TRIGGERID.reloadTable, function (e, options) {
        table.reloadTable(options.url);
    });

    $(CONTENTID.table).on(TRIGGERID.getJsonResponse, function (e, options) {
        table.dataFromJsonResponse(options.response);
    });

    $(document).on('click', '.rename-file', function (e) {
        e.preventDefault();
        let rowId = e.currentTarget.dataset.rowIndex;
        let row = table.getTable().row(rowId).data();
        let fileName = $($.parseHTML(row.name)).text();

        const eventData = {
            file: fileName,
        };

        $(CONTENTID.table).trigger(TRIGGERID.renameFilePrompt, eventData);

    });

    $(document).on('click', '.delete-file', function (e) {
        e.preventDefault();
        let rowId = e.currentTarget.dataset.rowIndex;
        let row = table.getTable().row(rowId).data();
        let fileName = $($.parseHTML(row.name)).text();

        const eventData = {
            files: [fileName]
        };

        $(CONTENTID.table).trigger(TRIGGERID.deletePrompt, eventData);

    });

    $('#show-dotfiles').on('change', () => {
        let visible = $('#show-dotfiles').is(':checked');

        table.setShowDotFiles(visible);
        table.updateDotFileVisibility();
    });

    $('#show-owner-mode').on('change', () => {
        let visible = $('#show-owner-mode').is(':checked');

        table.setShowOwnerMode(visible);
        table.updateShowOwnerModeVisibility();
    });


    /* END TABLE ACTIONS */

    /* DATATABLE LISTENERS */
    // prepend show dotfiles checkbox to search box

    table.getTable().on('draw.dtSelect.dt select.dtSelect.dt deselect.dtSelect.dt info.dt', function () {
        table.updateDatatablesStatus();
    });

    // if only 1 selected item, do not allow to de-select
    table.getTable().on('user-select', function (e, dt, type, cell, originalEvent) {
        var selected_rows = dt.rows({ selected: true });

        if (originalEvent.target.closest('.actions-btn-group')) {
            // dont do user select event when opening or working with actions btn dropdown
            e.preventDefault();
        }
        else if (selected_rows.count() == 1 && cell.index().row == selected_rows.indexes()[0]) {
            // dont do user select because already selected
            e.preventDefault();
        }
        else {
            // row need to find the checkbox to give it the focus
            cell.node().closest('tr').querySelector('input[type=checkbox]').focus();
        }
    });

    table.getTable().on('deselect', function (e, dt, type, indexes) {
        dt.rows(indexes).nodes().toArray().forEach(e => $(e).find('input[type=checkbox]').prop('checked', false));
    });

    table.getTable().on('select', function (e, dt, type, indexes) {
        dt.rows(indexes).nodes().toArray().forEach(e => $(e).find('input[type=checkbox]').prop('checked', true));
    });

    $('#directory-contents tbody').on('click', 'tr td:first-child input[type=checkbox]', function () {
        // input checkbox checked or not

        if ($(this).is(':checked')) {
            // select row
            table.getTable().row(this.closest('tr')).select();
        }
        else {
            // deselect row
            table.getTable().row(this.closest('tr')).deselect();
        }

        this.focus();
    });

    $('#directory-contents tbody').on('keydown', 'input, a', function (e) {
        if (e.key == "ArrowDown") {
            e.preventDefault();

            // let tr = this.closest('tr').nextSibling;
            let tr = $(this.closest('tr')).next('tr').get(0);
            if (tr) {
                tr.querySelector('input[type=checkbox]').focus();

                // deselect if not holding shift key to work
                // like native file browsers
                if (!e.shiftKey) {
                    table.getTable().rows().deselect();
                }

                // select if moving down
                table.getTable().row(tr).select();
            }
        }
        else if (e.key == "ArrowUp") {
            e.preventDefault();

            let tr = $(this.closest('tr')).prev('tr').get(0);
            if (tr) {
                tr.querySelector('input[type=checkbox]').focus();

                // deselect if not holding shift key to work
                // like native file browsers
                if (!e.shiftKey) {
                    table.getTable().rows().deselect();
                }

                // select if moving up
                table.getTable().row(tr).select();
            }
        }
    });

    $.fn.dataTable.ext.search.push(
        function (settings, data, dataIndex) {
            return table.getShowDotFiles() || !data[2].startsWith('.');
        }
    )

    /* END DATATABLE LISTENERS */
});

class DataTable {
    _table = null;

    constructor() {
        this.loadDataTable();
        this.reloadTable();
    }

    getTable() {
        return this._table;
    }

    loadDataTable() {
        this._table = $(CONTENTID.table).on('xhr.dt', function (e, settings, json, xhr) {
            // new ajax request for new data so update date/time
            // if(json && json.time){
            if (json && json.time) {
                history.replaceState(_.merge({}, history.state, { currentDirectoryUpdatedAt: json.time }), null);
            }
        }).DataTable({
            autoWidth: false,
            language: {
                search: 'Filter:',
            },
            order: [[1, "asc"], [2, "asc"]],
            rowId: 'id',
            paging: false,
            scrollCollapse: true,
            select: {
                style: 'os',
                className: 'selected',
                toggleable: true,
                // don't trigger select checkbox column as select
                // if you need to omit more columns, use a "selectable" class on the columns you want to support selection
                selector: 'td:not(:first-child)'
            },
            // https://datatables.net/reference/option/dom
            // dom: '', dataTables_info nowrap
            //
            // put breadcrmbs below filter!!!
            dom: "<'row'<'col-sm-12'f>>" + // normally <'row'<'col-sm-6'l><'col-sm-6'f>> but we disabled pagination so l is not needed (dropdown for selecting # rows)
                "<'row'<'col-sm-12'<'dt-status-bar'<'datatables-status float-right'><'transfers-status'>>>>" +
                "<'row'<'col-sm-12'tr>>", // normally this is <'row'<'col-sm-5'i><'col-sm-7'p>> but we disabled pagination so have info take whole row
            columns: [
                {
                    data: null,
                    orderable: false,
                    defaultContent: '<input type="checkbox">',
                    render: function (data, type, row, meta) {
                        var api = new $.fn.dataTable.Api(meta.settings);
                        let selected = api.rows(meta.row, { selected: true }).count() > 0;
                        return `<input type="checkbox" ${selected ? 'checked' : ''}> ${selected ? 'checked' : ''}`;
                    }
                },
                { data: 'type', render: (data, type, row, meta) => data == 'd' ? '<span title="directory" class="fa fa-folder" style="color: gold"><span class="sr-only"> dir</span></span>' : '<span title="file" class="fa fa-file" style="color: lightgrey"><span class="sr-only"> file</span></span>' }, // type
                { name: 'name', data: 'name', className: 'text-break', render: (data, type, row, meta) => `<a class="${row.type} name ${row.type == 'd' ? '' : 'view-file'}" href="${row.url}">${Handlebars.escapeExpression(data)}</a>` }, // name
                { name: 'actions', orderable: false, data: null, render: (data, type, row, meta) => this.actionsBtnTemplate({ row_index: meta.row, file: row.type != 'd', data: row }) },
                {
                    data: 'size',
                    render: (data, type, row, meta) => {
                        return type == "display" ? row.human_size : data;
                    }
                }, // human_size
                {
                    data: 'modified_at', render: (data, type, row, meta) => {
                        if (type == "display") {
                            let date = new Date(data * 1000)

                            // Return formatted date "3/23/2021 10:52:28 AM"
                            return isNaN(data) ? 'Invalid Date' : `${date.toLocaleDateString()} ${date.toLocaleTimeString()}`
                        }
                        else {
                            return data;
                        }
                    }
                }, // modified_at
                { name: 'owner', data: 'owner', visible: this.getShowOwnerMode() }, // owner
                {
                    name: 'mode', data: 'mode', visible: this.getShowOwnerMode(), render: (data, type, row, meta) => {

                        // mode after base conversion is a string such as "100755"
                        let mode = data.toString(8)

                        // only care about the last 3 bits (755)
                        let chmodDisplay = mode.substring(mode.length - 3)

                        return chmodDisplay
                    }
                } // mode
            ]
        });

        $('#directory-contents_filter').prepend(`<label style="margin-right: 20px" for="show-dotfiles"><input type="checkbox" id="show-dotfiles" ${this.getShowDotFiles() ? 'checked' : ''}> Show Dotfiles</label>`)
        $('#directory-contents_filter').prepend(`<label style="margin-right: 14px" for="show-owner-mode"><input type="checkbox" id="show-owner-mode" ${this.getShowOwnerMode() ? 'checked' : ''}> Show Owner/Mode</label>`)

    }

    async reloadTable(url) {
        var request_url = url || history.state.currentDirectoryUrl;

        try {
            const response = await fetch(request_url, { headers: { 'Accept': 'application/json' } });
            const data = await this.dataFromJsonResponse(response);
            $('#shell-wrapper').replaceWith((data.shell_dropdown_html));
            this._table.clear();
            this._table.rows.add(data.files);
            this._table.draw();

            $('#open-in-terminal-btn').attr('href', data.shell_url);
            $('#open-in-terminal-btn').removeClass('disabled');

            $(CONTENTID.table).trigger(TRIGGERID.updateClipboardView);
            return await Promise.resolve(data);
        } catch (e) {
            const eventData = {
                'title': `Error occurred when attempting to access ${request_url}`,
                'message': e.message,
            };

            $(CONTENTID.table).trigger(TRIGGERID.showError, eventData);

            $('#open-in-terminal-btn').addClass('disabled');
            return await Promise.reject(e);
        }
    }

    updateDotFileVisibility() {
        this.reloadTable();
    }

    updateShowOwnerModeVisibility() {
        let visible = this.getShowOwnerMode();

        this._table.column('owner:name').visible(visible);
        this._table.column('mode:name').visible(visible);
    }


    setShowOwnerMode(visible) {
        localStorage.setItem('show-owner-mode', new Boolean(visible));
    }

    setShowDotFiles(visible) {
        localStorage.setItem('show-dotfiles', new Boolean(visible));
    }


    getShowDotFiles() {
        return localStorage.getItem('show-dotfiles') == 'true'
    }

    getShowOwnerMode() {
        return localStorage.getItem('show-owner-mode') == 'true'
    }

    dataFromJsonResponse(response) {
        return new Promise((resolve, reject) => {
            Promise.resolve(response)
                .then(response => response.ok ? Promise.resolve(response) : Promise.reject(new Error(response.statusText)))
                .then(response => response.json())
                .then(data => data.error_message ? Promise.reject(new Error(data.error_message)) : resolve(data))
                .catch((e) => reject(e))
        });
    }

    actionsBtnTemplate(options) {
        let template_str = $('#actions-btn-template').html();
        let compiled = Handlebars.compile(template_str);
        let results = compiled(options);
        return results;
    }

    updateDatatablesStatus() {
        // from "function info ( api )" of https://cdn.datatables.net/select/1.3.1/js/dataTables.select.js
        let api = this._table;
        let rows = api.rows({ selected: true }).flatten().length,
            page_info = api.page.info(),
            msg = page_info.recordsTotal == page_info.recordsDisplay ? `Showing ${page_info.recordsDisplay} rows` : `Showing ${page_info.recordsDisplay} of ${page_info.recordsTotal} rows`;

        $('.datatables-status').html(`${msg} - ${rows} rows selected`);
    }

}
