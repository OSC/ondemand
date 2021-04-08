  json.html_extended_panel render partial: 'active_jobs/extended_panel.html.erb', :locals => {:data => jobstatusdata}
  json.status jobstatusdata.status
  json.html_ganglia_graphs_table render partial: 'active_jobs/ganglia_graphs_table.html.erb', :locals => {:d => jobstatusdata}