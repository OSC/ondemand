require 'test_helper'

# OodAppKit = OodAppKit

class BatchConnect::SessionContextsControllerTest < ActionController::TestCase

  test "create new session when cached cluster is no longer exists" do
    Dir.mktmpdir("session_context_controller_test") do |tmpdir|

      cache_json = File.new("#{tmpdir}/cache.json", 'w+')
      cache_json.write({cluster: 'old'}.to_json) # 'old' cluster is cached
      cache_json.close

      app_yml = File.new("#{tmpdir}/form.yml", 'w+')
      app_yml.write({
        'cluster': 'new',
        'form': [
          'some_input_string'
        ]
      }.transform_keys(&:to_s).to_yaml)
      app_yml.close

      # read form.yml and cache.json from the tmp directory
      BatchConnect::App.any_instance.stubs(:version).returns("1.0.0")
      BatchConnect::App.any_instance.stubs(:root).returns(Pathname(tmpdir.to_s))
      @controller.stubs(:cache_file).returns(Pathname(cache_json.path))

      # only the 'new' cluster is enabled (read from clusters.d)
      OodAppkit.stubs(:clusters).returns([
        OodCore::Cluster.new({ id: 'new', job: { some: 'job config' }})
      ])


      get :new, params: { token: 'dev/test' }
      assert_response :success
      assert_select "div .alert", 1 # OnDemand requires a newer version of the browser
      assert_select "input[type=hidden][id='batch_connect_session_context_cluster'][value=?]", "new"
    end
  end

  test "create new session when cached cluster exists, but is no longer wanted" do
    Dir.mktmpdir("session_context_controller_test") do |tmpdir|

      cache_json = File.new("#{tmpdir}/cache.json", 'w+')
      cache_json.write({cluster: 'old'}.to_json) # 'old' cluster is cached
      cache_json.close

      app_yml = File.new("#{tmpdir}/form.yml", 'w+')
      app_yml.write({
        'cluster': 'new',
        'form': [
          'some_input_string'
        ]
      }.transform_keys(&:to_s).to_yaml)
      app_yml.close

      # read form.yml and cache.json from the tmp directory
      BatchConnect::App.any_instance.stubs(:version).returns("1.0.0")
      BatchConnect::App.any_instance.stubs(:root).returns(Pathname(tmpdir.to_s))
      @controller.stubs(:cache_file).returns(Pathname(cache_json.path))

      # old and new clusters both enabled (read from clusters.d)
      OodAppkit.stubs(:clusters).returns([
        OodCore::Cluster.new({ id: 'new', job: { some: 'job config' }}),
        OodCore::Cluster.new({ id: 'old', job: { some: 'job config' }})
      ])


      get :new, params: { token: 'dev/test' }
      assert_response :success
      assert_select "div .alert", 1 # OnDemand requires a newer version of the browser
      assert_select "input[type=hidden][id='batch_connect_session_context_cluster'][value=?]", "new"
    end
  end
end
