# frozen_string_literal: true

# The FilesController serves files itself by unsetting this header
# and using 'config/initializers/validate_send_files.rb' to validate files it
# serves.  The AppsController also uses send_file to serve icons that may not be
# on the allowlist.  So we add this configuration to allow the AppsController
# to serve app icons through Nginx.  No other controller should be using send_file
# outside these 2 use cases.
Rails.application.config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'
