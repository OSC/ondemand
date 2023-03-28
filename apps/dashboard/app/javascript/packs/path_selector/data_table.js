import isDOMElement from '@uppy/utils/lib/isDOMElement';
import Handlebars from 'handlebars';
import {EVENTNAME as SWAL_EVENTNAME} from './sweet_alert.js';

export { CONTENTID, EVENTNAME };

const EVENTNAME = {
    getJsonResponse: 'getJsonResponse',
    reloadTable: 'reloadTable',
    goto: 'goto',
    click: 'click',
};

const CONTENTID = '#directory-contents';
const SELECTNAVPATH = '#select-nav-path';
const CONTAINERCONTENTID = "#container-directory-contents";
const BREADCRUMBID = "#path-breadcrumbs";
const BUTTONSELECTPATH = "#button-select-path";
const WORKINGDIRECTORY = "#batch_connect_session_context_working_dir";
let table = null;


jQuery(function () {
    table = new DataTable();


    /* END BUTTON ACTIONS */

    /* TABLE ACTIONS */
    $(SELECTNAVPATH).on(EVENTNAME.click, function(e, options) {
        let url = $(WORKINGDIRECTORY).val() ? $(WORKINGDIRECTORY).val() : $('#path_selector_home_dir').text();
        let path = $('#path_selector_url').text();
        url = path + url;
        
        let eventData = {
            'url': url,
        }
        
        $(CONTENTID).trigger(EVENTNAME.reloadTable, eventData);
    });

    $(CONTENTID).on(EVENTNAME.reloadTable, function (e, options) {
        let url = $.isEmptyObject(options) ? '' : options.url;
        table.reloadTable(url);
    });

    $(CONTENTID).on(EVENTNAME.getJsonResponse, function (e, options) {
        table.dataFromJsonResponse(options.response);
    });


    $(CONTENTID).on(EVENTNAME.click, 'td', function (e) {
        let data = table.getTable().row(this.closest('td')).data();
        let eventData = {
            'url': data.url,
        };
    
        $(CONTENTID).trigger(EVENTNAME.reloadTable, eventData);
    });


    $(BREADCRUMBID).on(EVENTNAME.click, 'li', function (e) {
        let eventData = {
            'url': e.target.id,
        };
    
        $(CONTENTID).trigger(EVENTNAME.reloadTable, eventData);
    });


    $(BUTTONSELECTPATH).on(EVENTNAME.click, function (e) {
        e.preventDefault();
        $(WORKINGDIRECTORY).val(table._currentWorkingDirectory);
        $(CONTAINERCONTENTID).hide();
    });


    /* END TABLE ACTIONS */

    /* DATATABLE LISTENERS */
    // prepend show dotfiles checkbox to search box

    /* END DATATABLE LISTENERS */

    $.fn.dataTable.ext.search.push(
        function (settings, data, dataIndex) {
            let total = table.getShowDotFiles() + table.getShowFiles();

            let isDirectory = (data[0].trim() == "dir");
            let isFile = !isDirectory;
            let isHidden = data[1].startsWith('.');

            if( total == 0 ) {
                // show only non-hidden directories
                return isDirectory && !isHidden;
            
            } else if(total == 1 ) {
                // show all directories, even if hidden
                return !isFile;
            
            } else if(total == 2 ) {
                // show everything except hidden
                return !isHidden;
            
            } else if(total == 3 ) {
                // show everything
                return true;
            
            } else {
                return false;
            }
        }
    );    

});

class DataTable {
    _table = null;
    _url = null;
    _currentWorkingDirectory = null;

    constructor(url) {
        this.loadDataTable();
        this.reloadTable();
    }

    getTable() {
        return this._table;
    }

    loadDataTable() {
    
        this._table = $(CONTENTID).on('xhr.dt', function (e, settings, json, xhr) {
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
                { data: 'type', render: (data, type, row, meta) => data == 'd' ? '<span title="directory" class="fa fa-folder" style="color: gold"><span class="sr-only"> dir</span></span>' : '<span title="file" class="fa fafile" style="color: lightgrey"><span class="sr-only"> file</span></span>' }, // type
                { 
                    name: 'name', 
                    data: 'name', 
                    className: 'text-break',
                    render: (data, type, row, meta) => {
                        return `<span id='${row.id}' data="${row.url}" style="cursor: pointer;">${row.name}</a>`;
                    }
 
                },
                { visible: false, name: 'actions', orderable: false, data: null, render: (data, type, row, meta) => this.actionsBtnTemplate({ row_index: meta.row, file: row.type != 'd', data: row }) },
                {
                    visible: false,
                    data: 'size',
                    render: (data, type, row, meta) => {
                        return type == "display" ? row.human_size : data;
                    }
                }, // human_size
                {
                    visible: false,
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
                { name: 'owner', data: 'owner', visible: false }, // owner
                {
                    name: 'mode', 
                    data: 'mode', 
                    visible: false,
                } // mode
            ]
        });
        
    }

    async reloadTable(url) {
        if(url) {
            this._url = url;
        }

        var request_url = this._url;


        if (history.state != null && url == history.state.currentDirectoryUrl) {
            request_url = url || history.state.currentDirectoryUrl;
        }

        if(request_url) {
            try {
                const response = await fetch(request_url, { headers: { 'Accept': 'application/json' }, cache: 'no-store' });
                const data = await this.dataFromJsonResponse(response);
                this._currentWorkingDirectory = data.path;
                $('#path-breadcrumbs').html(data.path_selector_breadcrumbs_html);
                this._table.clear();
                this._table.rows.add(data.files);
                this._table.draw();

                let result = await Promise.resolve(data);
                return result;
            } catch (e) {
                const eventData = {
                    'title': `Error occurred when attempting to access ${request_url}`,
                    'message': e.message,
                };

                $(CONTENTID).trigger(SWAL_EVENTNAME.showError, eventData);

                $('#open-in-terminal-btn').addClass('disabled');                
            }
        }
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
        return '';
    }

    updateDatatablesStatus() {
        // from "function info ( api )" of https://cdn.datatables.net/select/1.3.1/js/dataTables.select.js
        let api = this._table;
        let rows = api.rows({ selected: true }).flatten().length,
            page_info = api.page.info(),
            msg = page_info.recordsTotal == page_info.recordsDisplay ? `Showing ${page_info.recordsDisplay} rows` : `Showing ${page_info.recordsDisplay} of ${page_info.recordsTotal} rows`;

        $('.datatables-status').html(`${msg} - ${rows} rows selected`);
    }

    getShowDotFiles() {
        return $('#modal-path-selector').data('pathSelectorShowHidden') === true ? 1 : 0;
    }

    getShowFiles() {
        return $('#modal-path-selector').data('pathSelectorShowFiles') === true ? 2 : 0;
    }
}
