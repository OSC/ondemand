# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready turbolinks:load', ->
  if($('#all-apps-table').length != 0)
    $('#all-apps-table').DataTable({
      stateSave: true
    })
