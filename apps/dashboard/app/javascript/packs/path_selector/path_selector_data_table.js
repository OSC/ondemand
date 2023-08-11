
export class PathSelectorTable {
  _table = null;

  // input data that should be passed into the constructor
  tableId         = undefined;
  filesPath       = undefined;
  breadcrumbId    = undefined;
  homeDirectory   = undefined;
  selectButtonId  = undefined;
  inputFieldId    = undefined;
  modalId         = undefined;

  constructor(options) {
      this.tableId        = options.tableId;
      this.filesPath      = options.filesPath;
      this.breadcrumbId   = options.breadcrumbId;
      this.homeDirectory  = options.homeDirectory;
      this.selectButtonId = options.selectButtonId;
      this.inputFieldId   = options.inputFieldId;
      this.modalId        = options.modalId;

      this.initDataTable();
      this.reloadTable(this.initialUrl());

      $(`#${this.tableId} tbody`).on('click', 'tr', (event) => { this.clickRow(event) });
      $(`#${this.breadcrumbId}`).on('click', 'li', (event) => { this.clickBreadcrumb(event) });
      $(`#${this.selectButtonId}`).on('click', (event) => { this.selectPath(event) });
  }

  initDataTable() {

    this._table = $(`#${this.tableId}`).DataTable({
      autoWidth: false,
      language: {
        search: 'Filter:',
      },
      order: [[0, "asc"], [1, "asc"]],
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
          data: 'type',
          render: (data, _type, _row, _meta) => data == 'd' ? '<span title="directory" class="fa fa-folder gold"><span class="sr-only">directory</span></span>' : '<span title="file" class="fa fa-file black"><span class="sr-only">file</span></span>'
        },
        {
            name: 'name',
            data: 'name',
            className: 'text-break',
            render: (data, _type, _row, _meta) => {
                return `<span>${data}</span>`;
            }

        }
      ],
      createdRow: function (row, data, _dataIndex) {
        row.classList.add('clickable');
        row.dataset['apiUrl'] = data.url;
        row.dataset['pathType'] = data.type;
      },
    });
  }

  async reloadTable(url) {
    try {
      const response = await fetch(url, { headers: { 'Accept': 'application/json' }, cache: 'no-store' });
      const data = await this.dataFromJsonResponse(response);
      $(`#${this.breadcrumbId}`).html(data.path_selector_breadcrumbs_html);
      this._table.clear();
      this._table.rows.add(data.files);
      this._table.draw();
      this.setLastVisited(data.path);
    } catch (err) {
      console.log(err);
    }
  }

  dataFromJsonResponse(response) {
    return new Promise((resolve, reject) => {
      Promise.resolve(response)
        .then(response => response.ok ? Promise.resolve(response) : Promise.reject(new Error(response.statusText)))
        .then(response => response.json())
        .then(data => this.filterFileResponse(data))
        .then(data => data.error_message ? Promise.reject(new Error(data.error_message)) : resolve(data))
        .catch((e) => reject(e))
    });
  }

  clickRow(event) {
    const row = $(event.target).closest('tr').get(0);
    const url = row.dataset['apiUrl'];
    const pathType = row.dataset['pathType'];

    // only reload table for directories. and correct last visited
    // if it's a file.
    if(pathType == 'f') {
      const currentDir = this.getLastVisited();
      const fileName = url.split('/').slice(-1)[0];
      this.setLastVisited(`${currentDir}/${fileName}`);
    } else {
      this.reloadTable(url);
    }
  }

  clickBreadcrumb(event) {
    const path = event.target.id;
    this.reloadTable(path);
  }

  selectPath(_event) {
    const currentPath = this.getLastVisited();
    const inputField = document.getElementById(this.inputFieldId);
    inputField.value = currentPath;
    $(`#${this.modalId}`).modal('hide');
  }

  storageKey() {
    return `${this.tableId}_last_visited`;
  }

  // note that this is storing the file system path, not the path of the URL 
  // i.e., '/home/annie' not '/pun/sys/dashboard/files/fs/home/annie'
  getLastVisited() {
    const lastVisited = localStorage.getItem(this.storageKey());
    if(lastVisited === null) {
      return this.homeDirectory;
    } else {
      return lastVisited;
    }
  }

  setLastVisited(path) {
    localStorage.setItem(this.storageKey(), path);
  }

  initialUrl() {
    const last = this.getLastVisited();

    if(last.startsWith('/')) {
      return `${this.filesPath}${last}`;
    } else {
      return `${this.filesPath}/${last}`;
    }
  }

  // filter the response from the files API to remove things like hidden files/directories
  filterFileResponse(data) {
    const filteredFiles = data.files.filter((file) => {
      return !file.name.startsWith('.');
    });

    data.files = filteredFiles;
    return data;
  }
}
