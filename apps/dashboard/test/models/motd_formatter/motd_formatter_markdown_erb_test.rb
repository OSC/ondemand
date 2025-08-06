require 'test_helper'

class MotdFormatterMarkdownErbTest < ActiveSupport::TestCase
  test "motd-formatter-md-erb returns valid motd file when given a valid motd file" do
    with_modified_env({ 'MOTD_FORMAT': "markdown_erb",'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_valid" }) do
      motd_file = MotdFile.new
      expected_file = OodAppkit.markdown.render(motd_file.content)

      assert_equal expected_file, motd_file.formatter.content
    end
  end

  test "motd-formatter-md-erb returns valid motd md-erb rendered file when given a valid motd md-erb file" do
    with_modified_env({ 'MOTD_FORMAT': "markdown_erb",'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_valid_erb_md" }) do
      expected_file = OodAppkit.markdown.render("# Welcome to the Ohio Supercomputer Center!")
      assert_equal expected_file, MotdFile.new.formatter.content
    end
  end

  test "motd-formatter-md-erb returns a standard error when given a invalid motd erb file" do
    with_modified_env({ 'MOTD_FORMAT': "markdown_erb",'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_erb_standard_error" }) do
      assert_raises(Exception) {
        MotdFile.new.formatter
      }
    end
  end

  test "motd-formatter-md-erb returns an empty string when given an empty motd file" do
    with_modified_env({ 'MOTD_FORMAT': "markdown_erb",'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_empty" }) do
      assert_equal '', MotdFile.new.formatter.content
    end
  end 

  test "motd-formatter-md-erb returns an empty string when given a missing file" do
    with_modified_env({ 'MOTD_FORMAT': "markdown_erb",'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_missing" }) do
      assert_nil MotdFile.new.formatter
    end
  end

  test 'content is html safe by default' do
    with_modified_env({ 'MOTD_FORMAT': "markdown_erb",'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_md_erb_w_html" }) do
      expected_content = "<h1>Some Markdown file</h1>\n" \
      "\n" \
      "var msg = 'this was a script';\n"
      result_content = MotdFile.new.formatter.content
      assert_not_nil(result_content)
      assert_equal(expected_content, result_content)
    end
  end

  # this test is very similar to above, but the content
  # has a <script> tag still in it.
  test 'content can contain html if configured' do
    Configuration.stubs(:motd_render_html).returns(true)
    with_modified_env({ 'MOTD_FORMAT': "markdown_erb",'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_md_erb_w_html" }) do  
      expected_content = "<h1>Some Markdown file</h1>\n" \
      "\n" \
      "<script>var msg = 'this was a script';</script>\n"
      content = MotdFile.new.formatter.content
      assert_not_nil(content)
      assert_equal(expected_content, content)
    end
  end
end

