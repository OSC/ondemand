# frozen_string_literal: true

require 'application_system_test_case'

class BatchConnectSessionsTest < ApplicationSystemTestCase

  def setup
    stub_sys_apps
  end

  def test_data
    {
      'id':              'abc-123',
      'cluster_id':      'owens',
      "job_id":          '123456',
      "created_at":      1_701_184_869,
      "token":           'sys/bc_paraview',
      "title":           'Code Server',
      "script_type":     'basic',
      "cache_completed": false
    }
  end

  def create_test_file(dir)
    BatchConnect::Session.stubs(:db_root).returns(Pathname.new(dir))
    File.write("#{dir}/abc-123", test_data.to_json)
  end

  test 'no sessions' do
    visit(batch_connect_sessions_path)
    no_session_text = find('#batch_connect_sessions').find('p').text
    assert_equal(I18n.t('dashboard.batch_connect_no_sessions'), no_session_text)
  end

  test 'queued session' do
    Dir.mktmpdir do |dir|
      create_test_file(dir)
      visit(batch_connect_sessions_path)
      assert(false)
    end
  end
end
