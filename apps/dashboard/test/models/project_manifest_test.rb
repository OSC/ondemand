require 'test_helper'

class ProjectManifestTest < ActiveSupport::TestCase

  test 'ProjectManifest writes files entries' do
    opts = { files: ['file1', 'file2'] }

    valid_manifest = <<~HEREDOC
      ---
      files:
      - file1
      - file2
    HEREDOC

    manifest = ProjectManifest.new(opts)

    Dir.mktmpdir do |dir|
      path = dir << '/manifest.yml'
      manifest.save(path)

      assert_equal valid_manifest, File.read(path)
    end
  end
end
