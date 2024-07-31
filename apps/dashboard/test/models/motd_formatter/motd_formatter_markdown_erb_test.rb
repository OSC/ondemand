require 'test_helper'

class MotdFormatterMarkdownErbTest < ActiveSupport::TestCase
  include MotdFormatter
  test "motd-formatter-md-erb returns valid motd file when given a valid motd file" do
    path = "#{Rails.root}/test/fixtures/files/motd_valid"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterMarkdownErb.new(motd_file)
    expected_file = OodAppkit.markdown.render(motd_file.content)

    assert_equal expected_file, formatted_motd.content
  end

  test "motd-formatter-md-erb returns valid motd md-erb rendered file when given a valid motd md-erb file" do
    path = "#{Rails.root}/test/fixtures/files/motd_valid_erb_md"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterMarkdownErb.new(motd_file)
    expected_file = OodAppkit.markdown.render("# Welcome to the Ohio Supercomputer Center!")
    
    assert_equal expected_file, formatted_motd.content
  end

  test "motd-formatter-md-erb returns a standard error when given a invalid motd erb file" do
    path = "#{Rails.root}/test/fixtures/files/motd_erb_standard_error"
    motd_file = MotdFile.new(path)
    
    assert_raises(Exception) {
      MotdFormatterMarkdownErb.new(motd_file)
    }
  end

  test "motd-formatter-md-erb returns an empty string when given an empty motd file" do
    path = "#{Rails.root}/test/fixtures/files/motd_empty"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterMarkdownErb.new(motd_file)

    assert_equal '', formatted_motd.content
  end

  test "motd-formatter-md-erb returns an empty string when given a missing file" do
    path = "#{Rails.root}/test/fixtures/files/motd_missing"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterMarkdownErb.new(motd_file)

    assert_equal '', formatted_motd.content
  end

  test "motd-formatter-md-erb returns an empty stirng when given nill" do
    motd_file = nil
    formatted_motd = MotdFormatterMarkdownErb.new(motd_file)

    assert_not_nil formatted_motd.content
  end

  test 'content is html safe by default' do
    path = "#{Rails.root}/test/fixtures/files/motd_md_erb_w_html"
    motd = MotdFile.new(path)
    formatted_motd = MotdFormatterMarkdownErb.new(motd)
    content = formatted_motd.content

    expected_content = "<h1>Some Markdown file</h1>\n" \
    "\n" \
    "var msg = 'this was a script';\n"

    assert_not_nil(content)
    assert_equal(expected_content, content)
  end

  # this test is very similar to above, but the content
  # has a <script> tag still in it.
  test 'content can contain html if configured' do
    Configuration.stubs(:motd_render_html).returns(true)

    path = "#{Rails.root}/test/fixtures/files/motd_md_erb_w_html"
    motd = MotdFile.new(path)
    formatted_motd = MotdFormatterMarkdownErb.new(motd)
    content = formatted_motd.content

    expected_content = "<h1>Some Markdown file</h1>\n" \
    "\n" \
    "<script>var msg = 'this was a script';</script>\n"

    assert_not_nil(content)
    assert_equal(expected_content, content)
  end

end

