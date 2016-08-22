require 'test_helper'

class TemplatesControllerTest < ActionController::TestCase
  setup do
    @template = Template.new('./test/test_templates/template_one')
    @template_bad = Template.new('./test/test_templates/template_two_broken')
  end

  # Verify the templates are loaded properly.
  test "valid_template" do
    assert_equal( @template.path.to_s, "./test/test_templates/template_one" )
    assert @template.path.exist?

    assert_equal( @template_bad.path.to_s, "./test/test_templates/template_two_broken" )
    assert @template_bad.path.exist?
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:templates)
  end

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
