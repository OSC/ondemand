# frozen_string_literal: true

require 'application_system_test_case'

# unclear why this is needed, but it is.
require 'ood_core/job/adapters/slurm'

class BatchConnectSessionsTest < ApplicationSystemTestCase

  def setup
    stub_sys_apps
  end

  def test_data(token: 'sys/bc_paraview', title: 'Paraview')
    {
      'id':              test_bc_id,
      'cluster_id':      'owens',
      "job_id":          test_job_id,
      "created_at":      1_701_184_869,
      "token":           token,
      "title":           title,
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

  def create_test_file(dir, token: 'sys/bc_paraview', title: 'Paraview')
    BatchConnect::Session.stubs(:db_root).returns(Pathname.new(dir))
    File.write("#{dir}/#{test_bc_id}", test_data(token: token, title: title).to_json)
  end

  def stub_scheduler(state, cores: 1, nodes: 1)
    info = OodCore::Job::Info.new(
      id: test_job_id, status: state.to_sym, procs: cores.to_i, 
      allocated_nodes: Array.new(nodes.to_i, { name: 'foo', features: [] })
    )
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

      header_text = card.find('.h5').text
      assert_equal("Paraview (#{test_job_id})\nQueued", header_text)
    end
  end

  test 'completed session' do
    Dir.mktmpdir do |dir|
      create_test_file(dir, token: 'sys/bc_jupyter', title: 'Jupyter')
      stub_scheduler(:completed)
      visit(batch_connect_sessions_path)

      card = find("#id_#{test_bc_id}")
      assert_not_nil(card)

      header_text = card.find('.h5').text
      assert_equal("Jupyter (#{test_job_id})\nCompleted | |", header_text)
    end
  end

  test 'completed session with completed view' do
    Dir.mktmpdir do |dir|
      create_test_file(dir)
      stub_scheduler(:completed)
      visit(batch_connect_sessions_path)

      card = find("#id_#{test_bc_id}")
      assert_not_nil(card)

      header_text = card.find('.h5').text
      assert_equal("Paraview (#{test_job_id})\nCompleted | |", header_text)

      completed_text = card.find('#completed_test_div').text
      assert_equal('This is a test message for a completed view.', completed_text)
    end
  end

  test 'running session' do
    Dir.mktmpdir do |dir|
      create_test_file(dir, token: 'sys/bc_jupyter', title: 'Jupyter')
      stub_scheduler(:running)
      visit(batch_connect_sessions_path)

      card = find("#id_#{test_bc_id}")
      assert_not_nil(card)

      header_text = card.find('.h5').text
      assert_equal("Jupyter (#{test_job_id})\n1 node | 1 core | Starting", header_text)
    end
  end

  test 'running session with info view' do
    Dir.mktmpdir do |dir|
      create_test_file(dir, token: 'sys/bc_paraview', title: 'Paraview')
      stub_scheduler(:running)
      visit(batch_connect_sessions_path)

      card = find("#id_#{test_bc_id}")
      assert_not_nil(card)

      header_text = card.find('.h5').text
      assert_equal("Paraview (#{test_job_id})\n1 node | 1 core | Starting", header_text)

      info_text = card.find("#info_test_div").text
      assert_equal('This is a test message for an info view.', info_text)
    end
  end

  test 'running sessions with 0 nodes and cores' do
    Dir.mktmpdir do |dir|
      create_test_file(dir, token: 'sys/bc_jupyter', title: 'Jupyter')
      stub_scheduler(:running, nodes: 0, cores: 0)
      visit(batch_connect_sessions_path)

      card = find("#id_#{test_bc_id}")
      assert_not_nil(card)

      header_text = card.find('.h5').text
      assert_equal("Jupyter (#{test_job_id})\nStarting", header_text)
    end
  end

  test 'running sessions with 0 nodes and 1 core' do
    Dir.mktmpdir do |dir|
      create_test_file(dir, token: 'sys/bc_jupyter', title: 'Jupyter')
      stub_scheduler(:running, nodes: 0, cores: 1)
      visit(batch_connect_sessions_path)

      card = find("#id_#{test_bc_id}")
      assert_not_nil(card)

      header_text = card.find('.h5').text
      assert_equal("Jupyter (#{test_job_id})\n1 core | Starting", header_text)
    end
  end

  test 'running sessions with 1 nodes and 0 cores' do
    Dir.mktmpdir do |dir|
      create_test_file(dir, token: 'sys/bc_jupyter', title: 'Jupyter')
      stub_scheduler(:running, nodes: 0, cores: 1)
      visit(batch_connect_sessions_path)

      card = find("#id_#{test_bc_id}")
      assert_not_nil(card)

      header_text = card.find('.h5').text
      assert_equal("Jupyter (#{test_job_id})\n1 core | Starting", header_text)
    end
  end

  test 'running sessions correctly pluralize nodes and cores' do
    Dir.mktmpdir do |dir|
      create_test_file(dir, token: 'sys/bc_jupyter', title: 'Jupyter')
      stub_scheduler(:running, nodes: 2, cores: 2)
      visit(batch_connect_sessions_path)

      card = find("#id_#{test_bc_id}")
      assert_not_nil(card)

      header_text = card.find('.h5').text
      assert_equal("Jupyter (#{test_job_id})\n2 nodes | 2 cores | Starting", header_text)
    end
  end
end
