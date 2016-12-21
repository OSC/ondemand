require 'test_helper'

class ManifestTest < ActiveSupport::TestCase

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
    assert_equal save_result, true, "Result should save"
    assert_instance_of Manifest, new_manifest, "Not a Manifest Object"
    assert_equal manifest.to_yaml, new_manifest.to_yaml, "The saved manifest does not match the original"
  end

  test "save an InvalidManifest" do
    manifest_file = Tempfile.new('manifest.yml', Dir.mktmpdir).path
    manifest = Manifest.load("test/fixtures/files/manifest_invalid")
    save_result = manifest.save(manifest_file + "empty")
    new_manifest = Manifest.load(manifest_file + "empty")
    assert_equal save_result, false, "Result should not save"
    assert_instance_of MissingManifest, new_manifest, "Should not exist"
  end

  test "save a MissingManifest" do
    manifest_file = Tempfile.new('manifest.yml', Dir.mktmpdir).path
    manifest = Manifest.load("test/fixtures/files/manifest_missing")
    save_result = manifest.save(manifest_file + "empty")
    new_manifest = Manifest.load(manifest_file + "empty")
    assert_equal save_result, false, "Result should not save"
    assert_instance_of MissingManifest, new_manifest, "Should not exist"
  end

end
