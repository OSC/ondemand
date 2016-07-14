# Make a NavConfig singleton
NAV = OpenStruct.new.tap do |n|
  # simple deployment to just show home directory Files
  n.files = true
  n.files_osc = false # OSC specific project space directories
  n.shells = true
  n.systemstatus = false # system status
  n.jobs = false
  n.desktops = false
  n.suport_url = "#" # displays in menu AND in 500 page /errors/internal_server_error
  n.docs_url = "#"
  n.passwd_url = "#"


  # OSC Configuration:
  n.files = true
  n.files_osc = true # OSC specific project space directories
  n.shells = true
  n.systemstatus = true # system status
  n.jobs = true
  n.desktops = true
  n.support_url = "https://www.osc.edu/contact/supercomputing_support" # displays in menu AND in 500 page /errors/internal_server_error
  n.docs_url = "https://www.osc.edu/ondemand"
  n.passwd_url = "https://my.osc.edu"
end

