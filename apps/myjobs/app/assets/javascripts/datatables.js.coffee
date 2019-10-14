# Place all the DataTables related behaviors and hooks here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  # Set up datatable
  $('.data-table').DataTable
    autoWidth: true
    order: [0, 'desc'],
    stateSave: true,
    columnDefs: [{
      orderable: false
      targets: 'no-sort'
    }, {
      width: '10%',
      targets: [3, 4]
    }, {
      width: '15%',
      targets: 0
    }]
    iDisplayLength: 25

jQuery ->
# Set up datatable
  $('.data-table-new-job').DataTable
    autoWidth: true
    order: [2, 'asc'],
    stateSave: true,
    columnDefs: [{
      orderable: false
      targets: 'no-sort'
    }]
    iDisplayLength: 10

jQuery ->
# Set up datatable
  $('.data-table-templates').DataTable
    order: [0, 'desc'],
    columnDefs: [{
      orderable: false
      targets: 'no-sort'
    }]
