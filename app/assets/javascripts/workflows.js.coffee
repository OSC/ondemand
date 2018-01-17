# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# When the user returns to the page, perform a subtle refresh of the selected information.
$(window).focus ->
  if active_var()
    request_job_data(active_var())
  return

# This method is called when a user selects a job.
@update_display = (id) ->
  disable_all_buttons()
  update_script_details_panel()
  request_job_data(id)
  update_destroy_button(id)

@request_job_data = (id) ->
  show_loading_button()
  if id?
    $.ajax
      type: 'GET'
      url: Routes.workflow_path(id)
      contentType: "application/json; charset=utf-8"
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        show_job_panel()
        console.log jqXHR
      success: (data, textStatus, jqXHR) ->
        show_job_panel()
        update_job_panel(id, data)
      complete: ->
        hide_loading_button()
  else
    show_job_panel()
    hide_loading_button()

@update_job_panel = (id, data) ->
  update_status_label(id, data.status_label)
  update_job_details_panel(data)
  update_open_dir_button(data.fs_root)
  update_edit_button(id)
  update_copy_button(id)
  update_submit_button(id, data.active)
  update_stop_button(id, data.active)
  update_template_button(id)
  list_folder_contents(data)
  if missing_data_path()
# If the template folder does not exist we need to disable certain buttons.
    update_open_dir_button()
    update_terminal_button()
    update_edit_button()
    update_submit_button()
    update_copy_button()
  if missing_data_cluster()
    update_submit_button()

@disable_all_buttons = ->
  update_open_dir_button()
  update_edit_button()
  update_terminal_button()
  update_submit_button()
  update_stop_button()
  update_template_button()
  update_copy_button()
  update_destroy_button()
  list_folder_contents()

@hide_loading_button = ->
  $("#loading_button").invisible()

@show_loading_button = ->
  $("#loading_button").visible()

@show_job_panel = (show) ->
  if show?
    $("#job-details-panel").show()
  else
    $("#job-details-panel").hide()

@show_script_details_panel = (show) ->
  if show?
    $("#script-details-panel").show()
  else
    $("#script-details-panel").hide()

@update_status_label = (id, label) ->
  if label? && id?
    $("#status_label_#{id}").html(label)

@update_job_details_panel = (data) ->
  show_job_panel()
  if data?
    update_missing_data_cluster_view()
    update_missing_data_path_view()
    update_missing_data_script_view()
    $("#job-details-name").text(data.name)
    $("#job-details-server").val(data.host_title)
    $("#job-details-staged-dir").text(data.staged_dir)
    $("#job-details-script-name").text(data.staged_script_name || ' ')
    if data.account == null or data.account == ""
      $("#job-details-account").addClass("text-muted")
      $("#job-details-account").text("Not specified")
    else
      $("#job-details-account").removeClass("text-muted")
      $("#job-details-account").text(data.account)
    show_job_panel(true)

@update_script_details_panel = (content) ->
  if content?
    $("#script-name").text(content.name)
    $("#open-script-dir-button").attr("href", "#{content.fs_base}")
    $("#open-terminal-dir-button").attr("href", "#{content.terminal_base}")
    $("#open-editor-button").attr("href", "#{content.editor_url}")
    update_terminal_button(content.terminal_base)
    $.ajax
      type: 'GET'
      url: content.apiurl
      contentType: "application/json; charset=utf-8"
      dataType: "text"
      error: (jqXHR, textStatus, errorThrown) ->
        show_script_details_panel()
        console.log jqXHR
      success: (filedata, textStatus, jqXHR) ->
        show_script_details_panel()
        $("#script-text-data").text(filedata)
        show_script_details_panel(true)
  else
    show_script_details_panel()


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
    $("#copy_button").attr("href", Routes.copy_workflow_path(id))
    $("#copy_button").data("method", "PUT")
    $("#copy_button").removeAttr("disabled")
    $("#copy_button").unbind('click', false)
  else
    $("#copy_button").attr("href", "#")
    $("#copy_button").attr("disabled", true)
    $("#copy_button").bind('click', false)

@update_copy_template_button = (path) ->
  if path?
    $("#copy_template_button").attr("href", Routes.new_template_path({ path: path }))
    $("#copy_template_button").data("method", "GET")
    $("#copy_template_button").removeAttr("disabled")
    $("#copy_template_button").unbind('click', false)
  else
    $("#copy_template_button").attr("href", "#")
    $("#copy_template_button").attr("disabled", true)
    $("#copy_template_button").bind('click', false)

@update_edit_button = (id) ->
  if id?
    $("#edit_button").attr("href", Routes.edit_workflow_path(id))
    $("#edit_button").removeAttr("disabled")
    $("#edit_button").unbind('click', false)
  else
    $("#edit_button").removeAttr("href")
    $("#edit_button").attr("disabled", true)
    $("#edit_button").bind('click', false)

@update_terminal_button = (path) ->
  if path?
    $("#terminal_button").attr("href", path)
    $("#terminal_button").removeAttr("disabled")
    $("#terminal_button").unbind('click', false)
  else
    $("#terminal_button").removeAttr("href")
    $("#terminal_button").attr("disabled", true)
    $("#terminal_button").bind('click', false)

@update_submit_button = (id, active) ->
  if id? && !active
      $("#submit_button").attr("href", Routes.submit_workflow_path(id))
      $("#submit_button").data("method", "PUT")
      $("#submit_button").removeAttr("disabled")
      $("#submit_button").unbind('click', false)
  else
    $("#submit_button").removeAttr("href")
    $("#submit_button").attr("disabled", true)
    $("#submit_button").bind('click', false)

@update_stop_button = (id, active) ->
  if id? && active
    $("#stop_button").attr("href", Routes.stop_workflow_path(id))
    $("#stop_button").data("method", "PUT")
    $("#stop_button").removeAttr("disabled")
    $("#stop_button").unbind('click', false)
  else
    $("#stop_button").removeAttr("href")
    $("#stop_button").attr("disabled", true)
    $("#stop_button").bind('click', false)

@update_template_button = (id) ->
  if id?
    params = { jobid: "#{id}" }
    $("#template_button").attr("href", Routes.new_template_path( params ))
    $("#template_button").removeAttr("disabled")
    $("#template_button").unbind('click', false)
  else
    $("#template_button").removeAttr("href")
    $("#template_button").attr("disabled", true)
    $("#template_button").bind('click', false)

@update_destroy_button = (id) ->
  if id?
    $("#destroy_button").attr("href", Routes.workflow_path(id))
    $("#destroy_button").data("method", "DELETE")
    $("#destroy_button").removeAttr("disabled")
    $("#destroy_button").unbind('click', false)
  else
    $("#destroy_button").removeAttr("href")
    $("#destroy_button").attr("disabled", true)
    $("#destroy_button").bind('click', false)

@update_destroy_template_button = (path) ->
  if path?
    $("#destroy_template_button").attr("href", Routes.template_path("delete", path: path))
    $("#destroy_template_button").data("method", "DELETE")
    $("#destroy_template_button").removeAttr("disabled")
    $("#destroy_template_button").unbind('click', false)
  else
    $("#destroy_template_button").removeAttr("href")
    $("#destroy_template_button").attr("disabled", true)
    $("#destroy_template_button").bind('click', false)

# Return the directory path of a file path
abs_path = (filepath) ->
  if filepath?
    f = filepath.split('/')
    f.pop()
    f.join('/')

@list_folder_contents = (data) ->
  submit_script = null
  if data?
    list = "<ul class='list-group'>"
    for content in data.folder_contents
      formatted_path = content.path.replace(data.staged_dir, "")
      if content.name == data.staged_script_name
        formatted_path = "<strong>#{formatted_path}</strong>"
        submit_script = content
      formatted_path = "<a href='#{if content.type is "dir" then content.fsurl else content.editor_url}' target='_blank'>#{formatted_path}</a>"
      list += "<li class='list-group-item'>#{formatted_path}</li>"
    list += "</ul>"
    $("#job-details-staged-dir-contents").html(list)
  else
    $("#job-details-staged-dir-contents").html("")
  update_script_details_panel(submit_script)

$ ->
  $('#new_job_template_selectpicker').on 'change', ->
    selected = JSON.parse($(this).find('option:selected').val())
    $("#script_path_field").val("#{selected.path}")
    $("#name_field").val("#{selected.name}")
    $("#batch_host_select").val("#{selected.host}")
    return
  return

  #######  NEW JOB  ########

@update_new_job_display = (row) ->
  if row?
    update_script_label(row.data("name"))
    update_notes(row.data("notes"))
    update_name(row.data("name"))
    update_host(row.data("host"))
    update_script(row.data("script"))
    update_staging_template_dir(row.data("path"))
    update_open_template_button(row.data("fs"))
    get_folder_contents_from_api(row.data("api"))
    update_copy_template_button(row.data("path"))
    update_open_dir_button(row.data("fs"))
    update_terminal_button(row.data("shell"))
    update_destroy_template_button(row.data("delete"))

@update_script_label = (label) ->
  if label?
    $("#script-name-label").text("#{label}")
  else
    $("#script-name-label").text("")

@update_notes = (notes) ->
  if notes?
    $("#notes-field").text("#{notes}")
  else
    $("#notes-field").text("")

@update_name = (name) ->
  if name?
    $("#name-field").val("#{name}")
  else
    $("#name-field").val("")

@update_host = (host) ->
  $("#batch_host_select").val("#{host}")

@update_script = (script) ->
  if script?
    $("#script-path-field").val("#{script}")
  else
    $("#script-path-field").val("")

@update_staging_template_dir = (template) ->
  if template?
    $("#staging-template-dir").val("#{template}")
  else
    $("#staging-template-dir").val("")

@update_open_template_button = (path) ->
  if path?
    $("#open-template-dir-button").attr("href", path)
    $("#open-template-dir-button").removeAttr("disabled")
    $("#open-template-dir-button").unbind('click', false)
  else
    $("#open-template-dir-button").attr("href", "#")
    $("#open-template-dir-button").attr("disabled", true)
    $("#open-template-dir-button").bind('click', false)

# TODO can probably refactor to use this on the index as well
@get_folder_contents_from_api = (apiurl) ->
  update_folder_contents()
  if apiurl?
    $.ajax
      type: 'GET'
      url: apiurl
      contentType: "application/json; charset=utf-8"
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log jqXHR
      success: (filedata, textStatus, jqXHR) ->
        update_folder_contents(filedata)

@update_folder_contents = (data) ->
  $("#template-details-view").attr("hidden", true)
  if data?
    $("#template-location").html("#{data.path}")
    format_files_from_json(data.path, data.files)
    $("#template-details-view").removeAttr("hidden")

@format_files_from_json = (dir, files) ->
  list = "<ul class='list-group'>"
  for content in files
    list += "<li class='list-group-item'>#{content.name}</li>"
  list += "</ul>"
  $("#template-folder-contents").html("#{list}")

@missing_data_cluster = ->
  active_row().hasClass('missing-cluster')

@missing_data_path = ->
  active_row().hasClass('missing-dir')

@missing_data_script = ->
  active_row().hasClass('missing-script')

@update_missing_data_cluster_view = ->
  $('#job-details-submit-to').toggleClass("missing-cluster", missing_data_cluster())
  $("#edit-job-options-script-link").attr("href", Routes.edit_workflow_path(active_var()))

@update_missing_data_path_view = ->
  $('#script-details-view').toggleClass("missing-dir", missing_data_path())

@update_missing_data_script_view = ->
  # No need to show this block if the directory is invalid
  $('#script-details-name-view').toggle(!missing_data_path())
  $('#script-details-name-view').toggleClass("missing-script", missing_data_script())
  $("#edit-job-options-link").attr("href", Routes.edit_workflow_path(active_var()))

$ ->
  $('#reset-template-data').on 'click', ->
    update_new_job_display(active_row())
