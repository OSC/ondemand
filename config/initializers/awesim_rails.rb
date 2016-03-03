#
# Configure the AwesimRails specific options here
# see: https://github.com/AweSim-OSC/awesim_rails
#

AwesimRails.configure do |config|
  # The app title used in the layout
  # Default: Rails.application.class.parent_name.titleize
  #config.app_title = 'New Title Here'

  # Whether dynamic routing is used to host local files under `AwesimRails.dataroot`
  # Default: true
  #config.routes = false

  # Set the URL route used for hosting of local files
  # Default: '/files'
  #config.content_path = '/files'

  # Whether dynamic routing is used to host documentation
  # Default: true
  #config.docs.routes = false

  # The URL route used for hosting the documentation
  # Default: '/docs'
  #config.docs.uri = '/docs'

  # The path on the local filesystem where documentation is hosted from
  # Default: 'docs'
  #config.docs.path = 'docs'
end
