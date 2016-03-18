# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@update_display = (id) ->
  request_job_data(id)
  update_copy_button(id)
  update_destroy_button(id)

@request_job_data = (id) ->
  if id?
    show_job_panel()
    $.ajax
      type: 'GET'
      url: '.' + Routes.osc_job_path(id)
      contentType: "application/json; charset=utf-8"
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log jqXHR
      success: (data, textStatus, jqXHR) ->
        update_job_details_panel(data)
        update_template_button(data.script_path, data.batch_host)
        # TODO remove the console.log, this is for devving
        console.log data
  else
    update_job_details_panel()
    update_template_button()

@show_job_panel = (show) ->
  if show?
    $("#jobDetailsPanel").fadeIn(200)
  else
    $("#jobDetailsPanel").fadeOut(200)

@update_job_details_panel = (data) ->
  if data?
    $("#jobDetailsName").text(data.name)
    # TODO On selected change, do an ajax call to change it on the object
    $("#jobDetailsServerSelect option[value=#{data.batch_host}]").prop("selected", "selected")
    show_job_panel(true)
  else
    show_job_panel()

@update_copy_button = (id) ->
  if id?
    $("#copy_button").attr("href", "." + Routes.copy_osc_job_path(id))
    $("#copy_button").data("method", "PUT")
    $("#copy_button").removeAttr("disabled")
    $("#copy_button").unbind('click', false)
  else
    $("#copy_button").attr("href", "#")
    $("#copy_button").attr("disabled", true)
    $("#copy_button").bind('click', false)

@update_stop_button = (running) ->
  if running?
    # TODO Create a route that will stop a running job.
    $("#stop_button").attr("href", ' TODO ')
    $("#stop_button").removeAttr("disabled")
    $("#stop_button").unbind('click', false)
  else
    $("#stop_button").removeAttr("href")
    $("#stop_button").attr("disabled", true)
    $("#stop_button").bind('click', false)

@update_template_button = (path, host) ->
  if path?
    $("#template_button").attr("href", "." + Routes.new_template_path({ path: path, host: host }))
    $("#template_button").removeAttr("disabled")
    $("#template_button").unbind('click', false)
  else
    $("#template_button").removeAttr("href")
    $("#template_button").attr("disabled", true)
    $("#template_button").bind('click', false)

@update_destroy_button = (id) ->
  if id?
    $("#destroy_button").attr("href", "." + Routes.osc_job_path(id))
    $("#destroy_button").data("method", "DELETE")
    $("#destroy_button").removeAttr("disabled")
    $("#destroy_button").unbind('click', false)
  else
    $("#destroy_button").removeAttr("href")
    $("#destroy_button").attr("disabled", true)
    $("#destroy_button").bind('click', false)


