  json.html_extended_panel render partial: 'jobs/extended_panel.html.erb', :locals => {:data => jobstatusdata}
  json.status jobstatusdata.status
  json.html_ganglia_graphs_table render partial: 'jobs/ganglia_graphs_table.html.erb', :locals => {:d => jobstatusdata}