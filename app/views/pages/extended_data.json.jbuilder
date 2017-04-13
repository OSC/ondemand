json.html render partial: 'pages/extended_panel.html.erb', :locals => {:data => jobstatusdata}
json.status status_label(jobstatusdata.status)
