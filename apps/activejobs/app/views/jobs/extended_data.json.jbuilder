json.html render partial: 'jobs/extended_panel.html.erb', :locals => {:data => jobstatusdata}
json.status jobstatusdata.status
