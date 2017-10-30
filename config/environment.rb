# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Load the dotenv files
require File.expand_path('../dotenv', __FILE__)

# Load the dashboard specific configuration.
require File.expand_path('../configuration', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!
