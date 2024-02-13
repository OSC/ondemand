# frozen_string_literal: true

require 'application_system_test_case'

# unclear why this is needed, but it is.
require 'ood_core/job/adapters/slurm'

class BatchConnectSessionsTest < ApplicationSystemTestCase

  def setup
    stub_sys_apps
  end

  def test_data
    {
      'id':              test_bc_id,
      'cluster_id':      'owens',
      "job_id":          test_job_id,
      "created_at":      1_701_184_869,
      "token":           'sys/bc_paraview',
      "title":           'Code Server',
      "script_type":     'basic',
      "cache_completed": false
    }
  end

  def test_job_id
    '1234'
  end

  def test_bc_id
    'abc-123'
  end

  def create_test_file(dir)
    BatchConnect::Session.stubs(:db_root).returns(Pathname.new(dir))
    File.write("#{dir}/#{test_bc_id}", test_data.to_json)
  end

  def stub_scheduler(state)
    info = OodCore::Job::Info.new(id: test_job_id, status: state.to_sym)
    OodCore::Job::Adapters::Slurm.any_instance.stubs(:info).returns(info)
  end

  test 'no sessions' do
    visit(batch_connect_sessions_path)
    no_session_text = find('#batch_connect_sessions').find('p').text
    assert_equal(I18n.t('dashboard.batch_connect_no_sessions'), no_session_text)
  end

  test 'queued session' do
    Dir.mktmpdir do |dir|
      create_test_file(dir)
      stub_scheduler(:queued)
      visit(batch_connect_sessions_path)
      
      card = find("#id_#{test_bc_id}")
      assert_not_nil(card)

      header_text = card.find('div[class="h5"]').text
      assert_equal("Code Server (#{test_job_id})\nQueued", header_text)
    end
  end
end
