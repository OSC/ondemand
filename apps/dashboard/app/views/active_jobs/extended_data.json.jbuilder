  json.html_extended_data_table render(partial: 'active_jobs/extended_data_table', :locals => {:data => jobstatusdata}, :formats => [:html])
  json.status status_label(jobstatusdata.status)
