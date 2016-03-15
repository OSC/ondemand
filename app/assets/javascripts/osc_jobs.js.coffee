# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ajaxStop ->
  window.location.reload()

@copy_job = (id) ->
  if id?
    $.ajax
      type: 'PUT'
      url: '.' + Routes.copy_osc_job_path(id)
      contentType: "application/json; charset=utf-8"
      dataType: "json"
