NAV = OpenStruct.new.tap do |n|
  # simple deployment configuration to just show Files and Clusters
  n.files = true
   n.shells = true
  n.suport_url = "#" # displays in menu AND in 500 page /errors/internal_server_error
  n.docs_url = "#"
  n.passwd_url = "#"

  n.osc = false # OSC specific project space directories and develop dropdown
  n.systemstatus = false # system status
  n.jobs = false
  n.desktops = false


  # OSC Configuration:
  n.files = true
  n.shells = true
  n.support_url = "https://www.osc.edu/contact/supercomputing_support" # displays in menu AND in 500 page /errors/internal_server_error
  n.docs_url = "https://www.osc.edu/ondemand"
  n.passwd_url = "https://my.osc.edu"

  n.osc = true # OSC specific project space directories and develop dropdown
  n.systemstatus = true # system status
  n.jobs = true
  n.desktops = true
end

