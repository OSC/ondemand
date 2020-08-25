require 'test_helper'

class BatchConnect::SessionContextTest < ActiveSupport::TestCase
  test "should use default values" do
    app = BatchConnect::App.new(router: nil)
    app.stubs(:form_config).returns(attributes: { num_cores: { widget: "number_field", value: "1" } }, form: ["bc_account", "num_cores"])
    context = app.build_session_context

    assert_equal ["", "1"], [context["bc_account"].value, context["num_cores"].value]
  end

  test "should update cache using from_json" do
    app = BatchConnect::App.new(router: nil)
    app.stubs(:form_config).returns(attributes: { num_cores: { widget: "number_field", value: "1" } }, form: ["bc_account", "num_cores"])
    context = app.build_session_context

    context.from_json({"bc_account" => "PZS0714", "num_cores" => "28"}.to_json)

    assert_equal ["PZS0714", "28"], [context["bc_account"].value, context["num_cores"].value]
  end

  test "should update cache using attributes=" do
    app = BatchConnect::App.new(router: nil)
    app.stubs(:form_config).returns(attributes: { num_cores: { widget: "number_field", value: "1" } }, form: ["bc_account", "num_cores"])
    context = app.build_session_context

    context.attributes = {"bc_account" => "PZS0714", "num_cores" => "28"}

    assert_equal ["PZS0714", "28"], [context["bc_account"].value, context["num_cores"].value]
  end
  #
   test "should update cache using update_with_cache" do
     app = BatchConnect::App.new(router: nil)
     app.stubs(:form_config).returns(attributes: { num_cores: { widget: "number_field", value: "1" } }, form: ["bc_account", "num_cores"])
     context = app.build_session_context
  
     context.update_with_cache({"bc_account" => "PZS0714", "num_cores" => "28"})
  
     assert_equal ["PZS0714", "28"], [context["bc_account"].value, context["num_cores"].value]
   end

   test "should not update cache if global cache setting disabled" do
     with_modified_env(OOD_BATCH_CONNECT_CACHE_ATTR_VALUES: 'FALSE') do
       app = BatchConnect::App.new(router: nil)
       app.stubs(:form_config).returns(attributes: { num_cores: { widget: "number_field", value: "1" } }, form: ["bc_account", "num_cores"])
       context = app.build_session_context
  
       context.update_with_cache({"bc_account" => "PZS0714", "num_cores" => "28"})
  
       assert_equal ["", "1"], [context["bc_account"].value, context["num_cores"].value]
     end
   end
  
   test "should not update cache if per app cache disabled" do
     app = BatchConnect::App.new(router: nil)
     app.stubs(:form_config).returns(cacheable: false, attributes: { num_cores: { widget: "number_field", value: "1" } }, form: ["bc_account", "num_cores"])
     context = app.build_session_context
  
     context.update_with_cache({"bc_account" => "PZS0714", "num_cores" => "28"})
  
     assert_equal ["", "1"], [context["bc_account"].value,context["num_cores"].value ]
   end
  
   test "should not update single field if per attribute cache disabled" do
     app = BatchConnect::App.new(router: nil)
     app.stubs(:form_config).returns(attributes: {  num_cores: { widget: "number_field", value: "1", cacheable: false } }, form: ["bc_account", "num_cores"])
     context = app.build_session_context
     context.update_with_cache({"bc_account" => "PZS0714", :num_cores => 28})
     assert_equal ["PZS0714", "1"], [context["bc_account"].value, context["num_cores"].value]
   end
  
   test "should not update single field if per attribute cache disabled even if global cache setting disabled but per app cache enabled" do
     with_modified_env(OOD_BATCH_CONNECT_CACHE_ATTR_VALUES: 'FALSE') do
       app = BatchConnect::App.new(router: nil)
       app.stubs(:form_config).returns(cacheable: true, attributes: {  num_cores: { widget: "number_field", value: "1", cacheable: false } }, form: ["bc_account", "num_cores"])
       context = app.build_session_context
       context.update_with_cache({"bc_account" => "PZS0714", "num_cores" => "28"})
  
       assert_equal ["PZS0714", "1"], [context["bc_account"].value, context["num_cores"].value]
     end
   end
  
   test "should update single field if per attribute cache enabled even if global cache setting disabled" do
     with_modified_env(OOD_BATCH_CONNECT_CACHE_ATTR_VALUES: 'FALSE') do
       app = BatchConnect::App.new(router: nil)
       app.stubs(:form_config).returns(attributes: { num_cores: { widget: "number_field", value: "1", cacheable: true } }, form: ["bc_account", "num_cores"])
       context = app.build_session_context
  
       context.update_with_cache({"bc_account" => "PZS0714", "num_cores" => "28"})
  
       assert_equal ["", "28"], [context["bc_account"].value, context["num_cores"].value]
     end
   end
  
   test "should update single field if per attribute cache enabled even if per app cache disabled" do
     app = BatchConnect::App.new(router: nil)
     app.stubs(:form_config).returns(cacheable: false, attributes: { num_cores: { widget: "number_field", value: "1", cacheable: true } }, form: ["bc_account", "num_cores"])
     context = app.build_session_context
  
     context.update_with_cache({"bc_account" => "PZS0714", "num_cores" => "28"})
  
     assert_equal ["", "28"], [context["bc_account"].value, context["num_cores"].value]
   end

   test "should ignore bad cache keys when updating cache using update_with_cache" do
     app = BatchConnect::App.new(router: nil)
     app.stubs(:form_config).returns(attributes: { num_cores: { widget: "number_field", value: "1" } }, form: ["bc_account", "num_cores"])
     context = app.build_session_context

     context.update_with_cache({"bc_account" => "PZS0714", "num_cores" => "28", "bad_key_1" => "1", "bad_key_2" => "2"})

     assert_equal ["PZS0714", "28"], [context["bc_account"].value, context["num_cores"].value]
   end
end
