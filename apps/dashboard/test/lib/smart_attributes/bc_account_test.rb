require 'test_helper'

module SmartAttributes
  class BcAccountTest < ActiveSupport::TestCase
    test "widget default" do
      attribute = SmartAttributes::AttributeFactory.build_bc_account({})
      assert_equal("text_field", attribute.widget)
      assert_equal("Account", attribute.label)
      assert_equal({ script: { accounting_id: nil } }, attribute.submit)
    end

    test "widget should be select" do
      attribute = SmartAttributes::AttributeFactory.build_bc_account({ widget: "select", label: "label", value: "value" })
      assert_equal("select", attribute.widget)
      assert_equal("label", attribute.label)
      assert_equal({ script: { accounting_id: "value" } }, attribute.submit)
    end
  end
end