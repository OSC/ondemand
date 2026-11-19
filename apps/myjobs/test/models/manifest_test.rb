# frozen_string_literal: true

require 'test_helper'

class ManifestTest < ActiveSupport::TestCase
  test 'renders notes as sanitized markdown html by default' do
    path = Rails.root.join('test/test_templates/template_one/manifest.yml')
    notes = "Running a MATLAB script\n\nwith **bold** text"
    manifest = Manifest.new(path, { 'name' => 'Matlab', 'notes' => notes, 'script' => 'main_job.sh' })

    assert_includes manifest.notes, '<p>'
    assert_includes manifest.notes, '<strong>bold</strong>'
    refute_includes manifest.notes, '**bold**'
  end

  test 'sanitizes script tags from markdown notes' do
    path = Rails.root.join('test/test_templates/template_one/manifest.yml')
    notes = "Safe text <script>alert('xss')</script>"
    manifest = Manifest.new(path, { 'name' => 'Test', 'notes' => notes })

    refute_includes manifest.notes, '<script>'
    assert_includes manifest.notes, 'Safe text'
  end
end
