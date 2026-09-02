require 'test_helper'

module SmartAttributes
  class BcAccountTest < ActiveSupport::TestCase
    test "widget should default to text_field" do
      attribute = SmartAttributes::AttributeFactory.build_bc_account({})
      assert_equal("text_field", attribute.widget)
    end

    test "widget should be select" do
      attribute = SmartAttributes::AttributeFactory.build_bc_account({ widget: "select" })
      assert_equal("select", attribute.widget)
    end
  end
end