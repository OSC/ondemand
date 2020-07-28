require 'test_helper'

class BatchConnect::AppTest < ActiveSupport::TestCase
  test "app with malformed form.yml" do
    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir)
      r.path.join("form.yml").write("--x-\nnot a valid form yaml")

      app = BatchConnect::App.new(router: r)
      assert ! app.valid?
    }
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

  test "form.yml.erb can use __FILE__" do
    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir)
      r.path.join("form.yml.erb").write("---\ntitle: <%= File.expand_path(File.dirname(__FILE__)) %>")

      app = BatchConnect::App.new(router: r)
      assert_equal dir, app.title, "When rendering form.yml.erb __FILE__ doesn't return correct value"
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

  def good_clusters
    [
      OodCore::Cluster.new({id: 'owens', job: {foo: 'bar'}}),
      OodCore::Cluster.new({id: 'pitzer', job: {foo: 'bar'}})
    ]
  end

  def bad_clusters
    [
      # ruby not allowed bc the acl
      OodCore::Cluster.new({
        id: 'ruby',
        job: { foo: 'bar'},
        acls: [{ adapter: 'group', groups: ['hopefully-doesnt-exist'], type: 'whitelist' }]
      })
    ]
  end

  test "app with multiple clusters" do
    OodAppkit.stubs(:clusters).returns(good_clusters + bad_clusters)

    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir)
      r.path.join("form.yml").write("cluster:\n  - owens\n  - pitzer\n  - ruby")

      app = BatchConnect::App.new(router: r)
      assert app.valid?
      assert_equal good_clusters, app.clusters # make sure you only allow good clusters
    }
  end

  test "app with a single invalid cluster" do
    OodAppkit.stubs(:clusters).returns(good_clusters + bad_clusters)

    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir)
      r.path.join("form.yml").write("cluster:\n  - ruby")

      app = BatchConnect::App.new(router: r)
      assert ! app.valid?
      assert_equal [], app.clusters
    }
  end

  test "app with a single valid cluster" do
    OodAppkit.stubs(:clusters).returns(good_clusters + bad_clusters)

    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir)
      # note the format here, it's a string not array for backward compatability
      r.path.join("form.yml").write("cluster: \'owens\'")

      app = BatchConnect::App.new(router: r)
      assert app.valid?
      assert_equal [ OodCore::Cluster.new({id: 'owens', job: {foo: 'bar'}}) ], app.clusters
    }
  end

  test "app with special case of all clusters (*)" do
    OodAppkit.stubs(:clusters).returns(good_clusters + bad_clusters)

    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir)
      # note the format here, it's a string not array for backward compatability
      # and it's the special case * (not the regex .*). Also note the quotes, those
      # are nessecary for yaml to parse it correctly
      r.path.join("form.yml").write("cluster: '*'")

      app = BatchConnect::App.new(router: r)
      assert app.valid?
      assert_equal good_clusters, app.clusters # make sure you only allow good clusters
    }
  end

  test "app with all clusters regex" do
    OodAppkit.stubs(:clusters).returns(good_clusters + bad_clusters)

    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir)
      # not the special case * but the regex .*
      r.path.join("form.yml").write("cluster: .*")

      app = BatchConnect::App.new(router: r)
      assert app.valid?
      assert_equal good_clusters, app.clusters # make sure you only allow good clusters
    }
  end

  test "app with single regex to get owens" do
    OodAppkit.stubs(:clusters).returns(good_clusters + bad_clusters)

    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir)
      r.path.join("form.yml").write("cluster: o.*")

      app = BatchConnect::App.new(router: r)
      assert app.valid?
      assert_equal [ OodCore::Cluster.new({id: 'owens', job: {foo: 'bar'}}) ], app.clusters
    }
  end

  test "app with single regex to get owens and pitzer" do
    OodAppkit.stubs(:clusters).returns(good_clusters + bad_clusters)

    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir)
      # try to pick up owens pitzter and ruby by regexs
      r.path.join("form.yml").write("cluster:\n  - o.*\n  - p.*\n  - r.*")

      app = BatchConnect::App.new(router: r)
      assert app.valid?
      assert_equal good_clusters, app.clusters # make sure you only allow good clusters
    }
  end

  test "app with user defined cluster" do
    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir)
      r.path.join("form.yml").write("form:\n  - cluster")

      app = BatchConnect::App.new(router: r)
      # it's valid but there are no clusters. they're user defined and not validated by us
      assert app.valid?
      assert_equal [], app.clusters
    }
  end

  test "app with empty configured cluster is not configured with any cluster" do
    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir)
      r.path.join("form.yml").write("cluster: \"\"")

      app = BatchConnect::App.new(router: r)
      # it's valid but there are no clusters. Empty configurations are the same as
      # user defined
      assert app.valid?
      assert_equal [], app.configured_clusters
      assert_equal [], app.clusters
    }
  end

   test "app disregards empty cluster strings" do
    OodAppkit.stubs(:clusters).returns(good_clusters + bad_clusters)

    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir)
      # note the empty string and the string with whitespace
      r.path.join("form.yml").write("cluster:\n  - owens\n  - \"\"\n  - \"  \"")

      app = BatchConnect::App.new(router: r)

      assert app.valid?
      # only owens gets through
      assert_equal [ 'owens' ], app.configured_clusters
      assert_equal [ OodCore::Cluster.new({id: 'owens', job: {foo: 'bar'}}) ], app.clusters
    }
  end

  test "app does not include quick_pitzer when given pitzer" do
    clusters = good_clusters +
      [
        OodCore::Cluster.new({ id: 'quick_pitzer', job: { foo: 'bar' } }),
        OodCore::Cluster.new({ id: 'owens_login', job: { foo: 'bar' } }),
        OodCore::Cluster.new({ id: '_owens_', job: { foo: 'bar' } }),
        OodCore::Cluster.new({ id: '_pitzer_', job: { foo: 'bar' } }),
        OodCore::Cluster.new({ id: 'pit', job: { foo: 'bar' } }),
        OodCore::Cluster.new({ id: 'owen', job: { foo: 'bar' } })
      ]

    OodAppkit.stubs(:clusters).returns(clusters + bad_clusters)

    Dir.mktmpdir { |dir|
      r = PathRouter.new(dir)
      r.path.join("form.yml").write("cluster:\n  - \"owens\"\n  - \"pitzer\"")

      app = BatchConnect::App.new(router: r)

      assert app.valid?
      assert_equal good_clusters, app.clusters
    }
  end
end
