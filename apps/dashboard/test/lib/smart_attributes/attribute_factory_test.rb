require "smart_attributes"

class SmartAttributes::AttributeFactoryTest < ActiveSupport::TestCase

  test 'build should create expected attribute classes for known attribute ids' do
    expected_classes = {
      "auto_modules": "SmartAttributes::Attributes::AutoModules",
      "auto_primary_group": "SmartAttributes::Attributes::AutoPrimaryGroup",
      "bc_account": "SmartAttributes::Attributes::BCAccount",
      "bc_email_on_started": "SmartAttributes::Attributes::BcEmailOnStarted",
      "bc_num_hours": "SmartAttributes::Attributes::BcNumHours",
      "bc_num_slots": "SmartAttributes::Attributes::BcNumSlots",
      "bc_queue": "SmartAttributes::Attributes::BcQueue",
      "bc_vnc_idle": "SmartAttributes::Attributes::BcVncIdle",
      "bc_vnc_resolution": "SmartAttributes::Attributes::BcVncResolution",
    }

    expected_classes.each do |id, class_name|
      target = SmartAttributes::AttributeFactory.build(id, {})
      assert_equal class_name, target.class.name, "Invalid class: #{target.class.name} for id: #{id}"
    end
  end

end