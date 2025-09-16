  json.html_extended_panel render(partial: 'active_jobs/extended_panel', :locals => {:data => jobstatusdata}, :formats => [:html])
  json.status status_label(jobstatusdata.status)
  json.html_ganglia_graphs_table render(partial: 'active_jobs/ganglia_graphs_table', :locals => {:d => jobstatusdata}, :formats => [:html])
