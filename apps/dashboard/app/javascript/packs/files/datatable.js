import 'datatables.net';
import 'datatables.net-bs4/js/dataTables.bootstrap4';
import 'datatables.net-select';
import 'datatables.net-select-bs4';


window.update_datatables_status = update_datatables_status;
window.getShowOwnerMode = getShowOwnerMode;
window.getShowDotFiles = getShowDotFiles;
window.setShowOwnerMode = setShowOwnerMode;
window.setShowDotFiles = setShowDotFiles;
window.updateDotFileVisibility = updateDotFileVisibility;
window.updateShowOwnerModeVisibility = updateShowOwnerModeVisibility;

window.actionsBtnTemplate = (function(){
  let template_str  = $('#actions-btn-template').html();
  return Handlebars.compile(template_str);
})();  


window.table = null;

$(document).ready(function(){

  table = $('#directory-contents').on('xhr.dt', function ( e, settings, json, xhr ) {
    // new ajax request for new data so update date/time
    if(json && json.time){
      history.replaceState(_.merge({}, history.state, {currentDirectoryUpdatedAt: json.time}), null);
    }
  }).DataTable({
    autoWidth: false,
    language: {
      search: 'Filter:',
    },
    order: [[1, "asc"], [2, "asc"]],
    rowId: 'id',
    paging:false,
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
         "<'row'<'col-sm-12'<'dt-status-bar'<'datatables-status float-right'><'transfers-status'>>>>"+
         "<'row'<'col-sm-12'tr>>", // normally this is <'row'<'col-sm-5'i><'col-sm-7'p>> but we disabled pagination so have info take whole row
    columns: [
      {
        data: null,
        orderable: false,
        defaultContent: '<input type="checkbox">',
        render: function(data, type, row, meta) {
          var api = new $.fn.dataTable.Api( meta.settings );
          let selected = api.rows(meta.row, { selected: true }).count() > 0;
          return `<input type="checkbox" ${selected ? 'checked' : ''}> ${selected ? 'checked' : ''}`;
        }
      },
      { data: 'type', render: (data, type, row, meta) => data == 'd' ? '<span title="directory" class="fa fa-folder" style="color: gold"><span class="sr-only"> dir</span></span>' : '<span title="file" class="fa fa-file" style="color: lightgrey"><span class="sr-only"> file</span></span>' }, // type
      { name: 'name', data: 'name', className: 'text-break', render: (data, type, row, meta) => `<a class="${row.type} name ${row.type == 'd' ? '' : 'view-file' }" href="${row.url}">${Handlebars.escapeExpression(data)}</a>` }, // name
      { name: 'actions', orderable: false, data: null, render: (data, type, row, meta) => actionsBtnTemplate({ row_index: meta.row, file: row.type != 'd', data: row  }) }, // FIXME: pass row index or something needed for finding item
      { data: 'size',
        render: (data, type, row, meta) => {
          return type == "display" ? row.human_size : data;
        }
      }, // human_size
      { data: 'modified_at', render: (data, type, row, meta) => {
        if(type == "display"){
          let date = new Date(data * 1000)
  
          // Return formatted date "3/23/2021 10:52:28 AM"
          return isNaN(data) ? 'Invalid Date' : `${date.toLocaleDateString()} ${date.toLocaleTimeString()}`
        }
        else{
          return data;
        }
      }}, // modified_at
      { name: 'owner', data: 'owner', visible: getShowOwnerMode() }, // owner
      { name: 'mode', data: 'mode', visible: getShowOwnerMode(), render: (data, type, row, meta) => {
  
        // mode after base conversion is a string such as "100755"
        let mode = data.toString(8)
  
        // only care about the last 3 bits (755)
        let chmodDisplay = mode.substring(mode.length - 3)
  
        return chmodDisplay
      }} // mode
    ]
  });
  

  // prepend show dotfiles checkbox to search box
  $('#directory-contents_filter').prepend(`<label style="margin-right: 20px" for="show-dotfiles"><input type="checkbox" id="show-dotfiles" ${ getShowDotFiles() ? 'checked' : ''}> Show Dotfiles</label>`)
  $('#directory-contents_filter').prepend(`<label style="margin-right: 14px" for="show-owner-mode"><input type="checkbox" id="show-owner-mode" ${ getShowOwnerMode() ? 'checked' : ''}> Show Owner/Mode</label>`)

  table.on('draw.dtSelect.dt select.dtSelect.dt deselect.dtSelect.dt info.dt', function () {
    update_datatables_status(table);
  });

  // if only 1 selected item, do not allow to de-select
  table.on('user-select', function ( e, dt, type, cell, originalEvent  ) {
    var selected_rows = dt.rows( { selected: true  }  );

    if(originalEvent.target.closest('.actions-btn-group')){
      // dont do user select event when opening or working with actions btn dropdown
      e.preventDefault();
    }
    else if(selected_rows.count() == 1 && cell.index().row == selected_rows.indexes()[0] ){
      // dont do user select because already selected
      e.preventDefault();
    }
    else{
      // row need to find the checkbox to give it the focus
      cell.node().closest('tr').querySelector('input[type=checkbox]').focus();
    }
  });

  table.on( 'deselect', function ( e, dt, type, indexes ) {
    dt.rows(indexes).nodes().toArray().forEach(e => $(e).find('input[type=checkbox]').prop('checked', false));
    });

    table.on( 'select', function ( e, dt, type, indexes ) {
    dt.rows(indexes).nodes().toArray().forEach(e => $(e).find('input[type=checkbox]').prop('checked', true));
  });

  $('#directory-contents tbody').on('click', 'tr td:first-child input[type=checkbox]', function(){
    // input checkbox checked or not

    if($(this).is(':checked')){
      // select row
      table.row(this.closest('tr')).select();
    }
    else{
      // deselect row
      table.row(this.closest('tr')).deselect();
    }

    this.focus();
  });

  $('#directory-contents tbody').on('keydown', 'input, a', function(e){
    if(e.key == "ArrowDown"){
      e.preventDefault();

      // let tr = this.closest('tr').nextSibling;
      let tr = $(this.closest('tr')).next('tr').get(0);
      if(tr){
        tr.querySelector('input[type=checkbox]').focus();

        // deselect if not holding shift key to work
        // like native file browsers
        if(! e.shiftKey){
          table.rows().deselect();
        }

        // select if moving down
        table.row(tr).select();
      }
    }
    else if(e.key == "ArrowUp"){
      e.preventDefault();

      let tr = $(this.closest('tr')).prev('tr').get(0);
      if(tr){
        tr.querySelector('input[type=checkbox]').focus();

        // deselect if not holding shift key to work
        // like native file browsers
        if(! e.shiftKey){
          table.rows().deselect();
        }

        // select if moving up
        table.row(tr).select();
      }
    }
  });

  $.fn.dataTable.ext.search.push(
    function( settings, data, dataIndex  ) {
      return getShowDotFiles() || ! data[2].startsWith('.');
    }
  )


  $('#directory-contents tbody').on('click', '.delete-file', function(e){
    e.preventDefault();
  
    let row = table.row(this.dataset.rowIndex).data();
    deleteFiles([row.name]);
  });
  

});

function update_datatables_status(api){
  // from "function info ( api )" of https://cdn.datatables.net/select/1.3.1/js/dataTables.select.js
  let rows    = api.rows( { selected: true } ).flatten().length,
      page_info = api.page.info(),
      msg = page_info.recordsTotal == page_info.recordsDisplay ? `Showing ${page_info.recordsDisplay} rows` : `Showing ${page_info.recordsDisplay} of ${page_info.recordsTotal} rows`;

  $('.datatables-status').html(`${msg} - ${rows} rows selected`);
}


function getShowOwnerMode() {
  return localStorage.getItem('show-owner-mode') == 'true'
}

function getShowDotFiles() {
  return localStorage.getItem('show-dotfiles') == 'true'
}

function setShowOwnerMode(visible) {
  localStorage.setItem('show-owner-mode', new Boolean(visible));
}

function setShowDotFiles(visible) {
  localStorage.setItem('show-dotfiles', new Boolean(visible));
}

function updateDotFileVisibility() {
  table.draw();
}

function updateShowOwnerModeVisibility() {
  let visible = getShowOwnerMode();

  table.column('owner:name').visible(visible);
  table.column('mode:name').visible(visible);
}

