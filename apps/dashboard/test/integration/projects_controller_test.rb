require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest

  def setup
    OodAppkit.stubs(:dataroot).returns(Rails.root.join('test/fixtures/projects'))
    Configuration.stubs(:jobs_app_alpha?).returns(true)
    Rails.application.reload_routes!
    stub_sinfo
  end

  test "should get index" do
    get projects_path
    assert_response :success
  end

  test "should get new" do
    get new_project_path
    assert_response :success
  end

  test 'should redirect when it cannot find the project' do
    get project_path('wont_find_this')
    assert_response :redirect
  end

  test 'should redirect from edit when it cannot find the project' do
    Dir.mktmpdir do |dir|
      OodAppkit.stubs(:dataroot).returns(Pathname.new(dir))
      assert !Dir.exist?("#{dir}/projects/1")

      get edit_project_path('1')
      assert_response :redirect
    end
  end

  test "safe to get with invalid dataroot" do
    OodAppkit.stubs(:dataroot).returns(Pathname.new('/dev/null'))
    get projects_path
    assert_response :success
  end

  test "makes the directory if it doesnt exist" do
    Dir.mktmpdir do |dir|
      OodAppkit.stubs(:dataroot).returns(Pathname.new(dir))
      assert !Dir.exist?("#{dir}/projects")

      get projects_path
      assert_response :success

      assert Dir.exist?("#{dir}/projects")
    end
  end

  test "gets JSON reponse" do
    project_dir = Rails.root.join('test/fixtures/projects/json_response')
    OodAppkit.stubs(:dataroot).returns(project_dir)
    Project.stubs(:lookup_table).returns({ 'json_response' => project_dir.to_s })
    Project.any_instance.expects(:size).once.returns(2097152)

    get project_path('json_response', format: :json)
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal 'json_response', json['id']
    assert_equal 'JsonResponseName', json['name']
    assert_equal 'JsonResponseDescription', json['description']
    assert_equal project_dir.to_s, json['directory']
    assert_equal 'fas://user', json['icon']
    assert_equal 2097152, json['size']
    assert_equal '2 MB', json['human_size']
  end

  test "project size is not added to JSON reponse when Configuration.project_size_enabled is false" do
    project_dir = Rails.root.join('test/fixtures/projects/json_response')
    OodAppkit.stubs(:dataroot).returns(project_dir)
    Configuration.stubs(:project_size_enabled).returns(false)
    Project.stubs(:lookup_table).returns({ 'json_response' => project_dir.to_s })
    Project.any_instance.expects(:size).never

    get project_path('json_response', format: :json)
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal 'json_response', json['id']
    assert_equal 'JsonResponseName', json['name']
    assert_equal 'JsonResponseDescription', json['description']
    assert_equal project_dir.to_s, json['directory']
    assert_equal 'fas://user', json['icon']
    assert_equal false, json.has_key?('size')
    assert_equal false, json.has_key?('human_size')
  end
end
