require 'test_helper'

class OodAppTest < ActiveSupport::TestCase
  test "passenger rack app detection" do
    Dir.mktmpdir { |dir|
      FileUtils.cp Rails.root.join("config.ru").to_s, dir
      assert OodApp.new(PathRouter.new(dir)).passenger_rack_app?
    }
  end

  test "passenger rails app detection" do
    Dir.mktmpdir { |dir|
      FileUtils.cp [Rails.root.join("config.ru").to_s, Rails.root.join("Gemfile").to_s, Rails.root.join("Gemfile.lock").to_s], dir
      assert OodApp.new(PathRouter.new(dir)).passenger_rails_app?
    }
  end

  # FIXME:
  # a rails app without a Gemfile.lock has no lock file that can be parsed
  # so we cannot determine which gems this app has
  # therefore it is a Rack app
  test "passenger rails app detection without Gemfile.lock" do
    Dir.mktmpdir { |dir|
      # here, instead of inspecting the Gemfile.lock, we need to inspect the Gemfile
      FileUtils.cp [Rails.root.join("config.ru").to_s, Rails.root.join("Gemfile").to_s], dir

      assert OodApp.new(PathRouter.new(dir)).passenger_rack_app?, "an app with a config.ru should be recognized as a rack app"

      #FIXME: to address the fixme above, change this assertion to true
      assert ! OodApp.new(PathRouter.new(dir)).passenger_rails_app?, "an app with a Gemfile but not a Gemfile.lock should not be recognized as a rails app"
    }
  end

  test "app is hidden if directory name begins with a period" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)

      app_dir = dir.join(".app").tap { |p| p.mkdir }
      assert OodApp.new(PathRouter.new(app_dir)).hidden?
    end
  end

  test "app is not hidden if directory name doesn't begin with a period" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)

      app_dir = dir.join("app").tap { |p| p.mkdir }
      refute OodApp.new(PathRouter.new(app_dir)).hidden?
    end
  end

  test "app is a backup if directory name has period in it" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)

      app_dir = dir.join("app.bak").tap { |p| p.mkdir }
      assert OodApp.new(PathRouter.new(app_dir)).backup?
    end
  end

  test "app is not a backup if directory name begins with a period" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)

      app_dir = dir.join(".app").tap { |p| p.mkdir }
      refute OodApp.new(PathRouter.new(app_dir)).backup?
    end
  end

  test "app is not a backup if directory name doesn't contain a period" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)

      app_dir = dir.join("app").tap { |p| p.mkdir }
      refute OodApp.new(PathRouter.new(app_dir)).backup?
    end
  end

  test "sys app with empty category should be hidden from nav" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)
      SysRouter.stubs(:base_path).returns(dir)

      app_dir = dir.join("app").tap { |p| p.mkdir }
      app_dir.join("manifest.yml").write("---\nname: Ood Dashboard\ndescription: stuff")

      refute OodApp.new(SysRouter.new(app_dir.basename.to_s)).should_appear_in_nav?
    end
  end

  test "sys app with category should appear in nav" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)
      SysRouter.stubs(:base_path).returns(dir)

      app_dir = dir.join("app").tap { |p| p.mkdir }
      app_dir.join("manifest.yml").write("---\nname: Jobs\ncategory: Jobs")

      assert OodApp.new(SysRouter.new(app_dir.basename.to_s)).should_appear_in_nav?
    end
  end

  # icon tests 
  test "app with no icons should return an empty path" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)
      app_dir = dir.join("app").tap(&:mkdir)
      
      app  = OodApp.new(PathRouter.new(app_dir))
      path = app.icon_path
      expected_path = Pathname.new('')

      assert_equal path, expected_path
      assert_equal false, app.image_icon?
    end
  end

  test "app with only a png icon should return png path" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)
      app_dir = dir.join("app").tap(&:mkdir)

      app_dir.join("icon.png").write("")
      app  = OodApp.new(PathRouter.new(app_dir))
      path = app.icon_path
      expected_path = app_dir.join("icon.png")

      assert_equal path, expected_path
      assert_equal true, app.image_icon?
    end
  end

  test "app with only a svg icon should return svg path" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)
      app_dir = dir.join("app").tap(&:mkdir)

      app_dir.join("icon.svg").write("")
      app  = OodApp.new(PathRouter.new(app_dir))
      path = app.icon_path
      expected_path = app_dir.join("icon.svg")

      assert_equal path, expected_path
      assert_equal true, app.image_icon?
    end
  end

  test "app with both png and svg icons should return only the svg icon path" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)
      app_dir = dir.join("app").tap(&:mkdir)
      
      app_dir.join("icon.svg").write("")
      app_dir.join("icon.png").write("")

      app  = OodApp.new(PathRouter.new(app_dir))
      path = app.icon_path
      expected_path = app_dir.join("icon.svg")

      assert_equal path, expected_path
      assert_equal true, app.image_icon?
    end
  end

  test "app with svg icon should return the app icon uri" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)
      app_dir = dir.join("app").tap(&:mkdir)

      app_dir.join("icon.svg").write("")
    
      router = PathRouter.new(app_dir)
      app = OodApp.new(router)
      uri = app.icon_uri
      expected_uri = "/apps/icon/app/path/#{router.owner}" 

      assert_equal uri, expected_uri
      assert_equal true, app.image_icon?
    end
  end

  test "app with png icon should return the app icon uri" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)
      app_dir = dir.join("app").tap(&:mkdir)

      app_dir.join("icon.png").write("")

      router = PathRouter.new(app_dir)
      app = OodApp.new(router)
      uri = app.icon_uri
      expected_uri = "/apps/icon/app/path/#{router.owner}" 

      assert_equal uri, expected_uri
      assert_equal true, app.image_icon? 
    end
  end

  test "app only with valid manifest icon should return respective manifest icon" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)
      app_dir = dir.join("app").tap(&:mkdir)

      app_dir.join("manifest.yml").write("---\nicon: fa://code")
      
      app = OodApp.new(PathRouter.new(app_dir))
      manifest = Manifest.load(app_dir.join("manifest.yml"))

      assert_equal app.icon_uri, manifest.icon
      assert_equal false, app.image_icon?
    end
  end

  test "app without icons should only return font awesome's cog uri" do
    Dir.mktmpdir "apps" do |dir|
      dir = Pathname.new(dir)
      app_dir = dir.join("app").tap(&:mkdir)
      app = OodApp.new(PathRouter.new(app_dir))

      assert_equal "fas://cog", app.icon_uri
      assert_equal false, app.image_icon?
    end
  end

  test "with absolute manifest#url in app#url" do
    app = OodApp.new(OpenStruct.new(type: '', owner: '', name: '', token: ''))
    app.stubs(:manifest).returns(OpenStruct.new(:url => 'http://www.google.com'))

    assert_equal 'http://www.google.com', app.url
  end

  test "with relative manifest#url preserve in app#url" do
    app = OodApp.new(OpenStruct.new(type: '', owner: '', name: '', token: ''))
    app.stubs(:manifest).returns(OpenStruct.new(:url => 'www.google.com'))

    assert_equal 'www.google.com', app.url
  end

  test "with relative manifest#url without dot change app#url to internal url" do
    app = OodApp.new(OpenStruct.new(type: '', owner: '', name: '', token: ''))
    app.stubs(:manifest).returns(OpenStruct.new(:url => 'files'))

    assert_equal '/files', app.url
  end

  test "fix_if_internal_url avoids changing url prefixed with /" do
    #FIXME: not sure how to stub base uri of the app...this did not work
    # Rails.application.routes.url_helpers.stubs(:root_path).returns('/pun/sys/dashboard')

    assert_equal '/files', OodApp.fix_if_internal_url('/files', '/pun/sys/dashboard')
  end
end
