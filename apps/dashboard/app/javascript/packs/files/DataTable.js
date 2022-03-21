import 'datatables.net';
import 'datatables.net-bs4/js/dataTables.bootstrap4';
import 'datatables.net-select';
import 'datatables.net-select-bs4';
import Handlebars from 'handlebars';
import {} from './SweetAlert.js';
import {} from './FileOps.js';
import {} from './UppyOps.js';


let table = null;
$(document).ready(function () {
    table = new DataTable();

    /* BUTTON ACTIONS */
    $("#new-file-btn").on("click", function () {
        $("#directory-contents").trigger('fileOpsNewFile');
    });

    $("#new-folder-btn").on("click", function () {
        $("#directory-contents").trigger('fileOpsNewFolder');
    });

    // Will have to work on this one later.  Not so straight forward.
    //
    // $("#upload-btn").on("click", function () {
    //     $("#directory-contents").trigger('uppyShowUploadPrompt');
    // });

    /* END BUTTON ACTIONS */

    /* TABLE ACTIONS */

    $("#directory-contents").on("reloadTable", function () {
        table.reloadTable();
    });

    $("#directory-contents").on("getDataFromJsonResponse", function (e, options) {
        table.dataFromJsonResponse(options.response);
    });

    /* END TABLE ACTIONS */
    
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
        this._table = $('#directory-contents').on('xhr.dt', function (e, settings, json, xhr) {
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
                { name: 'actions', orderable: false, data: null, render: (data, type, row, meta) => this.actionsBtnTemplate({ row_index: meta.row, file: row.type != 'd', data: row }) }, // FIXME: pass row index or something needed for finding item
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
            return await Promise.resolve(data);
        } catch (e) {
            const eventData = {
                'title': `Error occurred when attempting to access ${request_url}`,
                'message': e.message,
            };

            $("#directory-contents").trigger('swalShowError', eventData);

            $('#open-in-terminal-btn').addClass('disabled');
            return await Promise.reject(e);
        }
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

    actionsBtnTemplate() {
        let template_str = $('#actions-btn-template').html();
        return Handlebars.compile(template_str);
    }

}
