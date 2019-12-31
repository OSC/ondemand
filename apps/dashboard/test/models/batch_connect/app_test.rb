require 'test_helper'

class BatchConnect::AppTest < ActiveSupport::TestCase

  def with_batch_connect_yaml(yaml)
    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir)
      r.path.join("form.yml.erb").write(yaml)

      app = BatchConnect::App.new(router: r)

      yield app, Pathname.new(dir)
    }
  end

  test "app with malformed form.yml" do
    with_batch_connect_yaml("--x-\nnot a valid form yaml") do |app, app_path|
      refute app.valid?
    end
  end

  test "form.yml.erb can use __FILE__" do
    with_batch_connect_yaml("---\ntitle: <%= File.expand_path(File.dirname(__FILE__)) %>") do |app, app_path|
      assert_equal app_path.to_s, app.title, "When rendering form.yml.erb __FILE__ doesn't return correct value"
    end
  end

  test "one cluster dependency" do
    BatchConnect::App.any_instance.stubs(:clusters).returns(OodCore::Clusters.new([
       OodCore::Cluster.new({id: 'owens', job: {adapter: 'slurm'}}),
       OodCore::Cluster.new({id: 'pitzer', job: {adapter: 'slurm'}})
    ]))

    with_batch_connect_yaml("---\ncluster: owens") do |app, app_path|
      assert_equal [:owens], app.cluster_ids
      assert_equal [:owens], app.cluster_dependencies.map(&:id)
    end
  end

  test "missing app handled gracefully" do
    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir + "/missing_app")
      app = BatchConnect::App.new(router: r)

      assert ! app.valid?
      assert_match /app does not exist/, app.validation_reason
    }
  end

  test "default app title" do
    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir + "/missing_app")
      assert_equal "Missing App", BatchConnect::App.new(router: r).title
      assert_equal "Missing App: Owens Vdi", BatchConnect::App.new(router: r, sub_app: "owens-vdi").title
    }
  end


  test "sub_apps_list doesn't crash when local directory inaccessible" do
    begin
      # place in begin/ensure so we can delete the directory after setting
      # back the permissions to 0700 on the local sub directory
      # the normal Dir.mktmpdir {} would result in an exception being thrown
      # when deleting the directories at the end of the test run
      #
      appdir = Pathname.new(Dir.mktmpdir)

      # create local dir but make it inaccessible
      localdir = appdir.join("local")
      localdir.mkdir
      localdir.chmod(0000)

      app = BatchConnect::App.new(router: PathRouter.new(appdir))

      assert 1, app.sub_app_list.count
      assert_equal app, app.sub_app_list.first
    ensure
      localdir.chmod(0700)
      appdir.rmtree
    end
  end

end
