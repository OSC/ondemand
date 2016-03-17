# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@update_display = (id) ->
  update_copy_button(id)

@update_copy_button = (id) ->
  if id?
    $("#copy_button").attr("href", '.' + Routes.copy_osc_job_path(id))
    $("#copy_button").data("method", "put")
  else
    $("#copy_button").attr("href", '#')
    $("#copy_button").data("method", "get")

