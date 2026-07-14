# frozen_string_literal: true

require 'test_helper'

class WorkflowsControllerTest < ActionController::TestCase
  setup do
    @workflow = workflows(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:workflows)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  # test "should create workflow" do
  #   assert_difference('Workflow.count') do
  #     post :create, workflow: { batch_host: @workflow.batch_host, name: @workflow.name, staging_template_dir: '/tmp' }
  #   end

  #   assert_redirected_to workflows_path
  # end

  test 'should show workflow' do
    get :show, params: { id: @workflow }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @workflow }
    assert_response :success
  end

  test 'should update workflow' do
    patch :update, params: { id: @workflow, workflow: { batch_host: @workflow.batch_host, name: @workflow.name } }
    assert_redirected_to workflows_path
  end

  test 'should destroy workflow' do
    assert_difference('Workflow.count', -1) do
      delete :destroy, params: { id: @workflow }
    end

    assert_redirected_to workflows_path
  end

  test 'set_locale reads locale from user settings file' do
    Dir.mktmpdir do |temp_data_dir|
      settings_path = File.join(temp_data_dir, 'settings.yml')
      File.write(settings_path, { 'locale' => 'zh-CN' }.to_yaml)
      Configuration.stubs(:user_settings_file).returns(settings_path)

      get :index
      assert_response :success
      assert_equal :"zh-CN", I18n.locale
    end
  end

  test 'set_locale falls back to default when no user settings file' do
    Dir.mktmpdir do |temp_data_dir|
      settings_path = File.join(temp_data_dir, 'settings.yml')
      Configuration.stubs(:user_settings_file).returns(settings_path)

      get :index
      assert_response :success
      assert_equal ::Configuration.locale, I18n.locale
    end
  end

  test 'set_locale falls back to default when saved locale is invalid' do
    Dir.mktmpdir do |temp_data_dir|
      settings_path = File.join(temp_data_dir, 'settings.yml')
      File.write(settings_path, { 'locale' => 'klingon' }.to_yaml)
      Configuration.stubs(:user_settings_file).returns(settings_path)

      get :index
      assert_response :success
      assert_equal ::Configuration.locale, I18n.locale
    end
  end

  test 'set_locale falls back to default when saved locale is a gem locale without translations' do
    Dir.mktmpdir do |temp_data_dir|
      settings_path = File.join(temp_data_dir, 'settings.yml')
      # 'de' is contributed by the dotiw gem and appears in I18n.available_locales
      # but has no jobcomposer translations, so it must be rejected.
      File.write(settings_path, { 'locale' => 'de' }.to_yaml)
      Configuration.stubs(:user_settings_file).returns(settings_path)

      get :index
      assert_response :success
      assert_equal ::Configuration.locale, I18n.locale
    end
  end

  teardown do
    I18n.locale = I18n.default_locale
  end
end
