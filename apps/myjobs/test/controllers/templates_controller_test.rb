require 'test_helper'

class TemplatesControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end

  #test "should create template" do
  #  assert_difference('Template.count') do
  #    post :create, template: { name: @template.name, path: @template.path }
  #  end
  #
  #  assert_redirected_to template_path(assigns(:template))
  #end

  #test "should update template" do
  #  patch :update, id: @template, template: { name: @template.name, path: @template.path }
  #  assert_redirected_to template_path(assigns(:template))
  #end

  #test "should destroy template" do
  #  assert_difference('Template.count', -1) do
  #    delete :destroy, id: @template
  #  end

end
