require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest

  def setup
    OodAppkit.stubs(:dataroot).returns(Rails.root.join('test/fixtures/projects'))
    Configuration.stubs(:jobs_app_alpha?).returns(true)
    Rails.application.reload_routes!
    get projects_path
    assert :success 

    # generate a CSRF token for redirects
    doc = Nokogiri::XML(@response.body)
    @token = doc.xpath("/html/head/meta[@name='csrf-token']/@content").to_s
  end

  test "gets index" do 
    get projects_path
    assert_response :success
  end

  test "successfully creates new project" do
    get new_project_path
    assert_response :success

    params = { project: { name: 'test-project', icon: 'fas://cog' } }
    header = { 'X-CSRF-Token' => @token }

    post projects_path, params: params, headers: header

    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "unsuccessfully creates new project" do
    get new_project_path
    assert_response :success

    params = { project: { name: 'invalid name', icon: 'fas://cog' } }
    header = { 'X-CSRF-Token' => @token }

    post projects_path, params: params, headers: header

    assert_response :redirect
    follow_redirect!
    assert_response :success
    # flash needed
  end

  test "deletes project" do
    create_project

    header = { 'X-CSRF-Token' => @token }

    delete project_path('test-project'), headers: header
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "update project redirects with success flash" do
    create_project

    header =  { 'X-CSRF-Token' => @token }

    patch project_path('test-project'), headers: header

    params = { project: { name: 'test-project-update' } }
    patch project_path('test-project'), headers: header
    # needs to get flash and ensure redirect still
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "update with invalid redirects with error flash" do
    create_project

    header =  { 'X-CSRF-Token' => @token }

    params = { project: { name: 'bad test project update' } }
    patch project_path('test-project'), headers: header
    # need to get flash too
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "gets edit" do
    # I think the project needs to exist to edit, :dir is missing in template
    Dir.mktmpdir do |dir|
      Project.stubs(dir).returns(Pathname.new("#{dir}/projects/project_1"))
      assert  !Dir.exist?("#{dir}/projects/project_1")

      get edit_project_path(dir)
      assert_response :success
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
        assert  !Dir.exist?("#{dir}/projects")

        get projects_path
        assert_response :success

        assert Dir.exist?("#{dir}/projects")
    end
  end

  def create_project
    get new_project_path

    params = { project: { name: 'test-project', icon: 'fas://cog' } }
    header = { 'X-CSRF-Token' => @token }

    post projects_path, params: params, headers: header
    follow_redirect!
  end
end
