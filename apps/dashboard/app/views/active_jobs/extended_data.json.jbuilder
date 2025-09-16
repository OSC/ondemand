  json.html_extended_data_table render(partial: 'active_jobs/extended_data_table', :locals => {:data => jobstatusdata}, :formats => [:html])
  json.status status_label(jobstatusdata.status)
  json.html_extended_panel render(partial: 'active_jobs/extended_panel', :locals => {:d => jobstatusdata}, :formats => [:html])
