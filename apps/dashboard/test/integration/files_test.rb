# frozen_string_literal: true

require 'test_helper'

class FilesIntegrationTest < ActionDispatch::IntegrationTest
  def put_file(path, file, content_type: 'text/plain')
    # force binary encoding here, but the default utf-8 has the same behaviour
    data = File.read(file).force_encoding('BINARY')
    headers = { 'CONTENT_TYPE' => content_type, 'X-CSRF-Token' => @token }
    put path, params: data, headers: headers
  end

  def setup
    # lot's of setup here to get a valid csrf-token
    get files_path
    assert :success

    doc = Nokogiri::XML(@response.body)
    @token = doc.xpath("/html/head/meta[@name='csrf-token']/@content").to_s
  end

  def upload_and_test(filename, content_type: 'text/plain')
    Dir.mktmpdir do |tmpdir|
      src_file = "test/fixtures/files/upload/#{filename}"
      dest_file = "#{tmpdir}/#{filename}"

      put_file("#{files_path}/#{dest_file}", src_file, content_type: content_type)

      assert :success
      assert_equal '{}', @response.body
      assert_equal '0', `diff #{src_file} #{dest_file}; echo $?`.chomp
    end
  end

  def download_and_test(filename, content_type)
    Dir.mktmpdir do |tmpdir|
      src_file = "test/fixtures/files/download/#{filename}"
      dest_file = "#{tmpdir}/#{filename}"

      put_file("#{files_path}/#{dest_file}", src_file)

      get files_path(filepath: dest_file, download: true)

      assert_equal response.headers['Content-Type'], content_type
    end
  end

  def edit_file_path(filepath:, fs: 'fs')
    "/files/edit/#{fs}#{filepath}"
  end

  test 'can download file as text/plain' do
    download_and_test('test_text.txt', 'text/plain')
  end

  test 'can download file as image/png' do
    download_and_test('osc-logo.png', 'image/png')
  end

  test 'can download file as application/x-yaml' do
    download_and_test('test.yml', 'application/x-yaml')
  end

  test 'can upload file with non-ASCII characters' do
    upload_and_test('funny_characters.sh')
  end

  test 'can upload file lots of utf8 characters' do
    upload_and_test('lots_of_utf8.txt')
  end

  test 'can upload file image files as text/plain' do
    upload_and_test('osc-logo.png')
  end

  test 'can upload file image files as image/png' do
    upload_and_test('osc-logo.png', content_type: 'image/png')
  end

  test 'can upload file binary files as text/plain' do
    upload_and_test('hello-world-c')
  end

  test 'can upload file binary files as text/plain as application/octet-stream' do
    upload_and_test('hello-world-c', content_type: 'application/octet-stream')
  end

  test 'edit redirects when file is not editable' do
    Dir.mktmpdir do |tmpdir|
      not_editable_file = "#{tmpdir}/readonly_file.txt"
      FileUtils.touch(not_editable_file)
      FileUtils.chmod(0o444, not_editable_file)

      get edit_file_path(filepath: not_editable_file)

      assert_redirected_to root_path
      follow_redirect!
      assert_equal "#{not_editable_file} is not an editable file", flash[:alert]
    end
  end

  test 'edit respects file size limit' do
    size_limit = 20
    with_modified_env(OOD_FILE_EDITOR_MAX_SIZE: size_limit.to_s) do
      Dir.mktmpdir do |tmpdir|
        small_file = "#{tmpdir}/small_file.txt"
        File.write(small_file, 'x' * size_limit)

        get edit_file_path(filepath: small_file)
        assert_response :success

        large_file = "#{tmpdir}/large_file.txt"
        File.write(large_file, 'x' * (size_limit + 1))

        get edit_file_path(filepath: large_file)
        assert_redirected_to root_path
        follow_redirect!
        assert_match(/exceeds editor limit of #{size_limit} B/, flash[:alert])
        assert_match(/Please download the file to edit or view it locally/, flash[:alert])
      end
    end
  end
end
