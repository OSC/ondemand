require "smart_attributes/attribute"
require "smart_attributes/attribute_factory"

# The main namespace for SmartAttributes
module SmartAttributes
  require "smart_attributes/attributes/auto_accounts"
  require "smart_attributes/attributes/auto_groups"
  require "smart_attributes/attributes/auto_modules"
  require "smart_attributes/attributes/auto_primary_group"
  require "smart_attributes/attributes/auto_queues"
  require "smart_attributes/attributes/auto_qos"
  require "smart_attributes/attributes/auto_scripts"
  require "smart_attributes/attributes/bc_account"
  require "smart_attributes/attributes/bc_email_on_started"
  require "smart_attributes/attributes/bc_num_hours"
  require "smart_attributes/attributes/bc_num_slots"
  require "smart_attributes/attributes/bc_queue"
  require "smart_attributes/attributes/bc_vnc_idle"
  require "smart_attributes/attributes/bc_vnc_resolution"
end
