require 'test_helper'

class ManifestTest < ActiveSupport::TestCase

  @@hash1 = { :name => "brian", :description => "ginger", :role => "developer" }
  @@hash2 = { "name" => "jeremy", "description" => nil, "role" => "monsignor", "url" => nil }
  @@hash3 = { name: "eric", description: "senior developer", role: "visionary" }
  @@hash4 = { name: nil, description: nil, role: nil, url: "http://127.0.0.1" }

  test "load a valid manifest" do
    manifest = Manifest.load("test/fixtures/files/manifest_valid")
    assert manifest.valid?, "manifest should be valid"
    assert manifest.exist?, "manifest should exist"
  end

  test "load an invalid manifest" do
    manifest = Manifest.load("test/fixtures/files/manifest_invalid")
    assert !manifest.valid?, "manifest should not be valid"
    assert manifest.exist?, "manifest should exist"
  end

  test "load an empty manifest" do
    manifest = Manifest.load("test/fixtures/files/manifest_empty")
    assert !manifest.valid?, "manifest should not be valid"
    assert manifest.exist?, "manifest should exist"
  end

  test "load a missing manifest" do
    manifest = Manifest.load("test/fixtures/files/manifest_missing")
    assert !manifest.valid?, "manifest should not be valid"
    assert !manifest.exist?, "manifest should not exist"
  end

  test "save a valid manifest" do
    Dir.mktmpdir { |dir|
      manifest_file = Tempfile.new('manifest.yml', dir).path
      manifest = Manifest.load("test/fixtures/files/manifest_valid")
      save_result = manifest.save(manifest_file)
      new_manifest = Manifest.load(manifest_file)
      assert_equal true, save_result, "Result should save"
      assert_instance_of Manifest, new_manifest, "Not a Manifest Object"
      assert_equal manifest.to_yaml, new_manifest.to_yaml, "The saved manifest does not match the original"
    }
  end

  test "save an InvalidManifest" do
    Dir.mktmpdir { |dir|
      manifest_file = Tempfile.new('manifest.yml', dir).path
      manifest = Manifest.load("test/fixtures/files/manifest_invalid")
      save_result = manifest.save(manifest_file + "empty")
      new_manifest = Manifest.load(manifest_file + "empty")
      assert_equal false, save_result, "Result should not save"
      assert_instance_of Manifest::MissingManifest, new_manifest, "Should not exist"
    }
  end

  test "save a MissingManifest" do
    Dir.mktmpdir { |dir|
      manifest_file = Tempfile.new('manifest.yml', dir).path
      manifest = Manifest.load("test/fixtures/files/manifest_missing")
      save_result = manifest.save(manifest_file + "empty")
      new_manifest = Manifest.load(manifest_file + "empty")
      assert_equal false, save_result, "Result should not save"
      assert_instance_of Manifest::MissingManifest, new_manifest, "Should not exist"
    }
  end

  test "merge manifests" do
    manifest_one = Manifest.new @@hash1
    manifest_two = Manifest.new @@hash2

    returned_manifest = manifest_one.merge manifest_two
    assert_instance_of Manifest, returned_manifest, "Merge did not return a manifest"
    assert_equal "jeremy", returned_manifest.name, "name string did not update"
    assert_equal "brian", manifest_one.name, "manifest should not update in place"
    assert_equal "", returned_manifest.description, "nil should return empty string for description"
    assert_equal "", returned_manifest.url, "nil manifest url accessor should return empty string"
    assert_equal "monsignor", returned_manifest.role, "role was not added"
  end

  test "merge hash into manifest" do
    manifest_one = Manifest.new @@hash4

    manifest_two = manifest_one.merge @@hash3

    assert_equal @@hash3[:role], manifest_two.role, "role does not match"
    assert_equal @@hash4[:url], manifest_two.url, "url does not match"

    manifest_three = manifest_one.merge @@hash4

    assert_equal "", manifest_three.name, "nil name should return empty string"
    assert_equal "", manifest_three.description, "nil description should return empty string"
    assert_equal "", manifest_three.role, "nil role should return empty string"
  end

  test "keys are read correctly" do
    manifest = Manifest.load("test/fixtures/files/manifest_valid")
    metadata = {
      "tags" => 'test',
      "field_of_science" => 'CS'
    }
    description = "**Ruby VDI** provides a remote desktop on an Ruby shared node at the Ohio\n" +
      "Supercomputer Center (OSC). Care must be taken to avoid heavy computation as\n" +
      "the resources are shared with many users."

    assert_equal "Ruby VDI", manifest.name
    assert_equal description, manifest.description
    assert_equal "vdi", manifest.role
    assert_equal "fa://desktop", manifest.icon
    assert_equal "Desktops", manifest.category
    assert_equal "Virtual Desktop Interface", manifest.subcategory
    assert_equal "/pun/sys/vncsim/%{app_token}/sessions", manifest.url
    assert_equal metadata, manifest.metadata
    assert_equal 'this is the caption from a manifest', manifest.caption
  end

  test "default keys are safe" do
    manifest = Manifest.load("test/fixtures/files/manifest_invalid")

    assert_equal "", manifest.name
    assert_equal "", manifest.description
    assert_equal "", manifest.role
    assert_equal "", manifest.icon
    assert_equal "", manifest.category
    assert_equal "", manifest.subcategory
    assert_equal "", manifest.url
    assert_equal({}, manifest.metadata)
  end

  test 'manifest only writes valid entries' do
    opts = { name: 'Ruby', 
             description: 'test hash', 
             icon: 'fas://cog',
             url: '/some/location',
             category: 'some category',
             subcategory: 'some subcategory',
             role: 'some role',
             metadata: { some_key: 'value' },
             new_window: false,
             caption: 'some caption',
             invalid_key: 'invalid value',
             files: ['file1', 'file2']
          }

    valid_manifest = <<~HEREDOC
      ---
      name: Ruby
      description: test hash
      icon: fas://cog
      url: "/some/location"
      category: some category
      subcategory: some subcategory
      role: some role
      metadata:
        some_key: value
      new_window: false
      caption: some caption
    HEREDOC

    manifest = Manifest.new(opts)

    Dir.mktmpdir do |dir|
      path = dir << '/manifest.yml'
      manifest.save(path)

      assert_equal valid_manifest, File.read(path)
    end
  end
end
