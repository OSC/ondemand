# Place all the DataTables related behaviors and hooks here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  # Set up datatable
  $('.data-table').DataTable
    order: [1, 'desc']
    columnDefs: [{
      orderable: false
      targets: 'no-sort'
    }]
    iDisplayLength: 50
