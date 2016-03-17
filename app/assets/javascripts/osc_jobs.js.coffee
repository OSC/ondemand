# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@update_display = (id) ->
  request_job_data(id)
  update_copy_button(id)
  show_job_panel(id)

@request_job_data = (id) ->
  if id?
    $.ajax
      type: 'GET'
      url: '.' + Routes.osc_job_path(id)
      contentType: "application/json; charset=utf-8"
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log jqXHR
      success: (data, textStatus, jqXHR) ->
        # TODO add display method
        console.log data

@update_copy_button = (id) ->
  if id?
    $("#copy_button").attr("href", '.' + Routes.copy_osc_job_path(id))
    $("#copy_button").data("method", "put")
  else
    $("#copy_button").attr("href", '#')
    $("#copy_button").data("method", "get")

@show_job_panel = (id) ->
  if id?
    $("#jobDetailsPanel").fadeIn(200)
  else
    $("#jobDetailsPanel").fadeOut(200)
