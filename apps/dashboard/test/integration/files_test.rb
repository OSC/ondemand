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
end
