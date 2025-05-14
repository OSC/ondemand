import {EVENTNAME as SWAL_EVENTNAME} from './sweet_alert.js';
import { getGlobusLink, updateGlobusLink } from './globus.js';
import { downloadEnabled } from '../config.js';
export { CONTENTID, EVENTNAME };

const EVENTNAME = {
    getJsonResponse: 'getJsonResponse',
    reloadTable: 'reloadTable',
    goto: 'goto',
};

const CONTENTID = '#directory-contents';
const SPINNERID = '#tloading_spinner';

let table = null;

jQuery(function () {
    table = new DataTable();

    /* END BUTTON ACTIONS */

    /* TABLE ACTIONS */
    
    window.onpopstate = function(event) {
      table.goto(location.href)
    };

    $(CONTENTID).on(EVENTNAME.reloadTable, function (e, options) {
        let url = $.isEmptyObject(options) ? '' : options.url;
        table.reloadTable(url);
    });

    $(CONTENTID).on(EVENTNAME.getJsonResponse, function (e, options) {
        table.dataFromJsonResponse(options.response);
    });

    $(CONTENTID).on(EVENTNAME.goto, function (e, options) {
        table.goto(options.path)
    });

    $('#show-dotfiles').on('change', function() {
        table.setShowDotFiles(this.checked);
        table.updateDotFileVisibility();
    });
    $('#show-dotfiles').on('keypress', function(event) {
        if (event.which === 13) {
          this.checked = !this.checked;
          this.dispatchEvent(new Event('change'));
        }
    });

    $('#show-owner-mode').on('change', function() {
        table.setShowOwnerMode(this.checked);
        table.updateShowOwnerModeVisibility();
    });
    $('#show-owner-mode').on('keypress', function(event) {
        if (event.which === 13) {
          this.checked = !this.checked;
          this.dispatchEvent(new Event('change'));
        }
    });

    $('#select_all').on('click', function() {
        if ($(this).is(":checked")) {
            table.getTable().rows({ search: 'applied' }).select();
        } else {
            table.getTable().rows().deselect();
        }
    })

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

    toHumanSize(number) {
      if(number === null) {
        return '-';
      } else {
        const unitIndex = number == 0 ? 0 : Math.floor(Math.log(number) / Math.log(1000));
        return `${((number / Math.pow(1000, unitIndex)).toFixed(2))} ${['B', 'kB', 'MB', 'GB', 'TB', 'PB'][unitIndex]}`;
      }
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
                "<'row'<'col-sm-12'<'dt-status-bar'<'datatables-status float-end'><'transfers-status'>>>>" +
                "<'row'<'col-sm-12'tr>>", // normally this is <'row'<'col-sm-5'i><'col-sm-7'p>> but we disabled pagination so have info take whole row
            columns: [
                {
                    data: null,
                    orderable: false,
                    defaultContent: '<input type="checkbox">',
                    render: (data, type, row, meta) => {
                        return `<input type='checkbox' data-dl-url='${row.download_url}'>`;
                    }
                },
                { data: 'type', render: (data, type, row, meta) => data == 'd' ? '<span title="directory" class="fa fa-folder" style="color: gold"><span class="sr-only"> dir</span></span>' : '<span title="file" class="fa fa-file" style="color: lightgrey"><span class="sr-only"> file</span></span>' }, // type
                { name: 'name', data: 'name', className: 'text-break', render: (data, type, row, meta) => this.renderNameColumn(data, type, row, meta) }, // name
                { name: 'actions', orderable: false, searchable: false, data: null, render: (data, type, row, meta) => this.actionsBtnTemplate({ row_index: meta.row, file: row.type != 'd', data: row }) },
                {
                    data: 'size',
                    render: (data, type, row, meta) => {
                        return type == "display" ? this.toHumanSize(row.size) : data;
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

        this.updateGlobus();
    }

    async reloadTable(url) {
        var request_url = url || history.state.currentDirectoryUrl;

        this.toggleSpinner();

        try {
            const response = await fetch(request_url, { headers: { 'Accept': 'application/json' }, cache: 'no-store' });
            const data = await this.dataFromJsonResponse(response);
            history.state.currentFilenames = Array.from(data.files, x => x.name);
            $('#shell-wrapper').replaceWith((data.shell_dropdown_html));

            this._table.clear();
            this._table.rows.add(data.files);
            this._table.draw();

            $('#open-in-terminal-btn').attr('href', data.shell_url);
            $('#open-in-terminal-btn').removeClass('disabled');

            if ($('#select_all').is(':checked')) {
                $('#select_all').click();
            }

            let result = await Promise.resolve(data);
            $('td input[type=checkbox]').on('keypress', function(event) {
                if (event.which === 13) {
                    this.checked = !this.checked;
                    this.dispatchEvent(new Event('change'));
                    if (this.checked) {
                        table.getTable().row(this.closest('tr')).select();
                    } else {
                        table.getTable().row(this.closest('tr')).deselect();
                    }
                }
            });

            this.toggleSpinner();

            return result;
        } catch (e) {
            const eventData = {
                'title': `Error occurred when attempting to access ${request_url}`,
                'message': e.message,
            };

            $(CONTENTID).trigger(SWAL_EVENTNAME.showError, eventData);

            $('#open-in-terminal-btn').addClass('disabled');

            this.toggleSpinner()
            
            // Removed this as it was causing a JS Error and there is no reprocution from removing it.
            // return await Promise.reject(e);
        }
    }

    toggleSpinner() {
        document.querySelector(SPINNERID).classList.toggle('d-none');
        document.querySelector(CONTENTID).classList.toggle('d-none');
    }

    updateDotFileVisibility() {
        this.reloadTable();
    }

    updateGlobus() {
      if ($('#globus-link').length) {
        $('#globus-link').attr('href', getGlobusLink(history.state.currentDirectory));
        updateGlobusLink(history.state.currentDirectory, $('#globus-link'), $('#globus-wrapper'));
      }
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

    renderNameColumn(data, type, row, meta) {
        let element = undefined;

        if(row.type == 'f' && !downloadEnabled()) {
            element = document.createElement('span');
        } else {
            element = document.createElement('a');
            element.href = row.url;
        }

        // dataset.type is only used in testing.
        element.dataset.type = row.type;
        element.classList.add('name');
        element.textContent = data;

        return element.outerHTML;
    }

    actionsBtnTemplate(options) {
        // options: { row_index: meta.row,
        //            file: row.type != 'd',
        //            data: row }
        const rowIndex = options.row_index;
        const file = options.file;
        const data = options.data;
        
        // Create the button group container
        const btnGroup = document.createElement('div');
        btnGroup.classList.add('btn-group', 'actions-btn-group');
          
        // Create the button
        const button = document.createElement('button');
        button.type = 'button';
        button.classList.add('actions-btn', 'btn', 'btn-outline-dark', 'btn-sm', 'dropdown-toggle');
        button.setAttribute('data-bs-toggle', 'dropdown');
        button.setAttribute('aria-haspopup', 'true');
        button.setAttribute('aria-expanded', 'false');
          
        // Create the icon inside the button
        const icon = document.createElement('span');
        icon.classList.add('fa', 'fa-ellipsis-v');
        button.appendChild(icon);
          
        // Append the button to the button group
        btnGroup.appendChild(button);
          
        // Create the dropdown menu
        const dropdownMenu = document.createElement('ul');
        dropdownMenu.classList.add('dropdown-menu');
          
        // Check if this is a file and create View and Edit options
        if (file) {
            if (data.url && downloadEnabled()) {
                const viewItem = document.createElement('li');
                const viewLink = document.createElement('a');
                viewLink.href = data.url;
                viewLink.classList.add('view-file', 'dropdown-item');
                viewLink.target = '_blank';
                viewLink.setAttribute('data-row-index', rowIndex);
                viewLink.innerHTML = '<i class="fas fa-eye" aria-hidden="true"></i> View';
                viewItem.appendChild(viewLink);
                dropdownMenu.appendChild(viewItem);
            }
          
            if (data.edit_url) {
                const editItem = document.createElement('li');
                const editLink = document.createElement('a');
                editLink.href = data.edit_url;
                editLink.classList.add('edit-file', 'dropdown-item');
                editLink.target = '_blank';
                editLink.setAttribute('data-row-index', rowIndex);
                editLink.innerHTML = '<i class="fas fa-edit" aria-hidden="true"></i> Edit';
                editItem.appendChild(editLink);
                dropdownMenu.appendChild(editItem);
            }
        }
          
        // Create Rename option
        const renameItem = document.createElement('li');
        const renameLink = document.createElement('a');
        renameLink.href = '#';
        renameLink.classList.add('rename-file', 'dropdown-item');
        renameLink.setAttribute('data-row-index', rowIndex);
        renameLink.innerHTML = '<i class="fas fa-font" aria-hidden="true"></i> Rename';
        renameItem.appendChild(renameLink);
        dropdownMenu.appendChild(renameItem);
          
        // Create Download option if it's enabled and the URL exists
        if (downloadEnabled() && data.download_url) {
            const downloadItem = document.createElement('li');
            const downloadLink = document.createElement('a');
            downloadLink.href = data.download_url;
            downloadLink.classList.add('download-file', 'dropdown-item');
            downloadLink.setAttribute('data-row-index', rowIndex);
            downloadLink.innerHTML = '<i class="fas fa-download" aria-hidden="true"></i> Download';
            downloadItem.appendChild(downloadLink);
            dropdownMenu.appendChild(downloadItem);
        }
          
        // Add a divider between options
        const dividerItem = document.createElement('li');
        dividerItem.classList.add('dropdown-divider', 'mt-4');
        dropdownMenu.appendChild(dividerItem);
          
        // Create the Delete option
        const deleteItem = document.createElement('li');
        const deleteLink = document.createElement('a');
        deleteLink.href = '#';
        deleteLink.classList.add('delete-file', 'dropdown-item', 'text-danger');
        deleteLink.setAttribute('data-row-index', rowIndex);
        deleteLink.innerHTML = '<i class="fas fa-trash" aria-hidden="true"></i> Delete';
        deleteItem.appendChild(deleteLink);
        dropdownMenu.appendChild(deleteItem);
          
        // Append the dropdown menu to the button group
        btnGroup.appendChild(dropdownMenu);
          
        // Return the button group element html as a string
        return btnGroup.outerHTML;          
    }

    updateDatatablesStatus() {
        // from "function info ( api )" of https://cdn.datatables.net/select/1.3.1/js/dataTables.select.js
        let api = this._table;
        let rows = api.rows({ selected: true }).flatten().length,
            page_info = api.page.info(),
            msg = page_info.recordsTotal == page_info.recordsDisplay ? `Showing ${page_info.recordsDisplay} rows` : `Showing ${page_info.recordsDisplay} of ${page_info.recordsTotal} rows`;

        $('.datatables-status').html(`${msg} - ${rows} rows selected`);
    }

    goto(url, pushState = true, show_processing_indicator = true) {
        if(url == history.state.currentDirectoryUrl)
          pushState = false;
        this.reloadTable(url)
          .then((data) => {
            if(data) {
                $('#path-breadcrumbs').html(data.breadcrumbs_html);
                if(pushState) {
                    // Clear search query when moving to another directory.
                    this._table.search('').draw();
            
                    history.pushState({
                        currentDirectory: data.path,
                        currentDirectoryUrl: data.url,
                        currentFilesPath: data.files_path,
                        currentFilesUploadPath: data.files_upload_path,
                        currentFilesystem: data.filesystem,
                        currentFilenames: Array.from(data.files, x => x.name)
                    }, data.name, data.url);
                }
                this.updateGlobus();
            }
          })
          .finally(() => {
            //TODO: after processing is available via ActiveJobs merge
            // if(show_processing_indicator)
            //   table.processing(false)
          });
      }    

}
