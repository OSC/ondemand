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
      url: joinRoot(Routes.osc_job_path(id))
      contentType: "application/json; charset=utf-8"
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log jqXHR
      success: (data, textStatus, jqXHR) ->
        # TODO remove the console.log, this is for devving
        console.log data

        update_status_label(id, data.status_label)
        update_job_details_panel(data)
        update_open_dir_button(data.fs_root)
        update_edit_button(id)
        update_submit_button(id, data.status.char)
        update_stop_button(id, data.status.char)
        update_template_button(data.script_path, data.batch_host)
        list_folder_contents(data)

  else
    update_job_details_panel()
    update_open_dir_button()
    update_edit_button()
    update_submit_button()
    update_stop_button()
    update_template_button()
    list_folder_contents()

@show_job_panel = (show) ->
  if show?
    $("#jobDetailsPanel").fadeIn(200)
  else
    $("#jobDetailsPanel").fadeOut(100)

@update_status_label = (id, label) ->
  if label? && id?
    $("#status_label_#{id}").html(label)

@update_job_details_panel = (data) ->
  if data?
    $("#jobDetailsName").text(data.name)
    # TODO On selected change, do an ajax call to change it on the object
    $("#jobDetailsServerSelect option[value=#{data.batch_host}]").prop("selected", "selected")
    $("#jobDetailsStagedDir").text(data.staged_dir)
    show_job_panel(true)
  else
    show_job_panel()

@update_open_dir_button = (path) ->
  if path?
    $("#open_dir_button").attr("href", path)
    $("#open_dir_button").removeAttr("disabled")
    $("#open_dir_button").unbind('click', false)
  else
    $("#open_dir_button").attr("href", "#")
    $("#open_dir_button").attr("disabled", true)
    $("#open_dir_button").bind('click', false)

@update_copy_button = (id) ->
  if id?
    $("#copy_button").attr("href", joinRoot(Routes.copy_osc_job_path(id)))
    $("#copy_button").data("method", "PUT")
    $("#copy_button").removeAttr("disabled")
    $("#copy_button").unbind('click', false)
  else
    $("#copy_button").attr("href", "#")
    $("#copy_button").attr("disabled", true)
    $("#copy_button").bind('click', false)

@update_edit_button = (id) ->
  if id?
    $("#edit_button").attr("href", joinRoot(Routes.edit_osc_job_path(id)))
    $("#edit_button").removeAttr("disabled")
    $("#edit_button").unbind('click', false)
  else
    $("#edit_button").removeAttr("href")
    $("#edit_button").attr("disabled", true)
    $("#edit_button").bind('click', false)

@update_submit_button = (id, status_char) ->
  if id? && !status_char?
      $("#submit_button").attr("href", joinRoot(Routes.submit_osc_job_path(id)))
      $("#submit_button").data("method", "PUT")
      $("#submit_button").removeAttr("disabled")
      $("#submit_button").unbind('click', false)
  else
    $("#submit_button").removeAttr("href")
    $("#submit_button").attr("disabled", true)
    $("#submit_button").bind('click', false)

@update_stop_button = (id, status_char) ->
  if id? && status_char? && (status_char == "R" || status_char == "Q")
    $("#stop_button").attr("href", joinRoot(Routes.stop_osc_job_path(id)))
    $("#stop_button").data("method", "PUT")
    $("#stop_button").removeAttr("disabled")
    $("#stop_button").unbind('click', false)
  else
    $("#stop_button").removeAttr("href")
    $("#stop_button").attr("disabled", true)
    $("#stop_button").bind('click', false)

@update_template_button = (path, host) ->
  if path?
    $("#template_button").attr("href", joinRoot(Routes.new_template_path({ path: path, host: host })))
    $("#template_button").removeAttr("disabled")
    $("#template_button").unbind('click', false)
  else
    $("#template_button").removeAttr("href")
    $("#template_button").attr("disabled", true)
    $("#template_button").bind('click', false)

@update_destroy_button = (id) ->
  if id?
    $("#destroy_button").attr("href", joinRoot(Routes.osc_job_path(id)))
    $("#destroy_button").data("method", "DELETE")
    $("#destroy_button").removeAttr("disabled")
    $("#destroy_button").unbind('click', false)
  else
    $("#destroy_button").removeAttr("href")
    $("#destroy_button").attr("disabled", true)
    $("#destroy_button").bind('click', false)

# Return the directory path of a file path
abs_path = (filepath) ->
  if filepath?
    f = filepath.split('/')
    f.pop()
    f.join('/')

@list_folder_contents = (data) ->
  if data?
    list = "<ul>"
    for content in data.folder_contents
      formatted_path = content.path.replace(data.staged_dir, "")
      formatted_path = "<strong>#{formatted_path}</strong>" if content.name == data.staged_script_name
      formatted_path = "<a href=\"#{content.fsurl}\" target='_blank'>#{formatted_path}</a>" if content.type == "dir"
      list += "<li>#{formatted_path}</li>"
    list += "</ul>"
    $("#jobDetailsStagedDirContents").html(list)
  else
    $("#jobDetailsStagedDirContents").html("")
