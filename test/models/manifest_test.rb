require 'test_helper'

class ManifestTest < ActiveSupport::TestCase

  @@hash1 = { :name => "brian", :description => "ginger", :role => "developer" }
  @@hash2 = { "name" => "jeremy", "description" => nil, "role" => "monsignor", "url" => nil }
  @@hash3 = { name: "eric", description: "senior developer", role: "visionary" }
  @@hash4 = { name: nil, description: nil, role: nil, url: "http://127.0.0.1" }

  test "load a valid manifest" do
    manifest = Manifest.load("test/fixtures/files/manifest_valid")
    assert_instance_of Manifest, manifest, "Not a Manifest Object"
  end

  test "load an invalid manifest" do
    manifest = Manifest.load("test/fixtures/files/manifest_invalid")
    assert_instance_of InvalidManifest, manifest, "Not an InvalidManifest Object"
  end

  test "load an empty manifest" do
    manifest = Manifest.load("test/fixtures/files/manifest_empty")
    assert_instance_of InvalidManifest, manifest, "Not an InvalidManifest Object"
  end

  test "load a missing manifest" do
    manifest = Manifest.load("test/fixtures/files/manifest_missing")
    assert_instance_of MissingManifest, manifest, "Not a MissingManifest Object"
  end

  test "save a valid manifest" do
    manifest_file = Tempfile.new('manifest.yml', Dir.mktmpdir).path
    manifest = Manifest.load("test/fixtures/files/manifest_valid")
    save_result = manifest.save(manifest_file)
    new_manifest = Manifest.load(manifest_file)
    assert_equal true, save_result, "Result should save"
    assert_instance_of Manifest, new_manifest, "Not a Manifest Object"
    assert_equal manifest.to_yaml, new_manifest.to_yaml, "The saved manifest does not match the original"
  end

  test "save an InvalidManifest" do
    manifest_file = Tempfile.new('manifest.yml', Dir.mktmpdir).path
    manifest = Manifest.load("test/fixtures/files/manifest_invalid")
    save_result = manifest.save(manifest_file + "empty")
    new_manifest = Manifest.load(manifest_file + "empty")
    assert_equal false, save_result, "Result should not save"
    assert_instance_of MissingManifest, new_manifest, "Should not exist"
  end

  test "save a MissingManifest" do
    manifest_file = Tempfile.new('manifest.yml', Dir.mktmpdir).path
    manifest = Manifest.load("test/fixtures/files/manifest_missing")
    save_result = manifest.save(manifest_file + "empty")
    new_manifest = Manifest.load(manifest_file + "empty")
    assert_equal false, save_result, "Result should not save"
    assert_instance_of MissingManifest, new_manifest, "Should not exist"
  end

  test "merge manifests" do
    manifest_one = Manifest.new @@hash1
    manifest_two = Manifest.new @@hash2

    returned_manifest = manifest_one.merge manifest_two
    assert_instance_of Manifest, returned_manifest, "Merge did not return a manifest"
    assert_equal "jeremy", returned_manifest.name, "name string did not update"
    assert_equal "jeremy", manifest_one.name, "name string did not update in place"
    assert_equal "", manifest_one.description, "nil should return empty string for description"
    assert_nil manifest_one.url, "manifest url should be nil"
    assert_equal "monsignor", manifest_one.role, "role was not added"
  end

  test "merge hash into manifest" do
    manifest = Manifest.new @@hash4

    manifest.merge @@hash3

    assert_equal @@hash3[:role], manifest.role, "role does not match"
    assert_equal @@hash4[:url], manifest.url, "url does not match"

    manifest.merge @@hash4

    assert_equal "", manifest.name, "nil name should return empty string"
    assert_equal "", manifest.description, "nil description should return empty string"
    assert_nil manifest.role, "nil role should return nil"
  end

end
