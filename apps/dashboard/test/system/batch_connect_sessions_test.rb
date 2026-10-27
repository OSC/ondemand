# frozen_string_literal: true

require 'application_system_test_case'

# unclear why this is needed, but it is.
require 'ood_core/job/adapters/slurm'

class BatchConnectSessionsTest < ApplicationSystemTestCase

  def setup
    stub_sys_apps
  end

  def get_test_data(token: 'sys/bc_paraview', title: 'Paraview', script_type: 'basic')
    {
      'id':              get_test_bc_id,
      'cluster_id':      'owens',
      "job_id":          get_test_job_id,
      "created_at":      1_701_184_869,
      "token":           token,
      "title":           title,
      "script_type":     script_type,
      "cache_completed": false
    }
  end

  def get_test_job_id
    '1234'
  end

  def get_test_bc_id
    'abc-123'
  end

  def create_test_file(dir, token: 'sys/bc_paraview', title: 'Paraview', script_type: 'basic')
    BatchConnect::Session.stubs(:db_root).returns(Pathname.new(dir))
    File.write("#{dir}/#{get_test_bc_id}", get_test_data(token: token, title: title, script_type: script_type).to_json)
  end

  def create_vnc_running_session(dir, token: 'sys/bc_paraview', title: 'Paraview')
    create_test_file(dir, token: token, title: title, script_type: 'vnc')
    OodAppkit.stubs(:dataroot).returns(Pathname.new(dir))

    session = BatchConnect::Session.new.from_json(
      get_test_data(token: token, title: title, script_type: 'vnc').to_json
    )
    FileUtils.mkdir_p(session.staged_root)
    File.write(session.connect_file, vnc_connect_info.stringify_keys.to_yaml)
  end

  def vnc_connect_info
    {
      host:      'node1.example.edu',
      port:      5901,
      password:  'testpassword',
      websocket: '5901'
    }
  end

  def stub_scheduler(state, cores: 1, nodes: 1)
    info = OodCore::Job::Info.new(
      id: get_test_job_id, status: state.to_sym, procs: cores.to_i, 
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

      card = find("#id_#{get_test_bc_id}")
      assert_not_nil(card)

      header_text = card.find('.h5').text
      assert_equal("Paraview (#{get_test_job_id})\nQueued", header_text)
    end
  end

  test 'completed session' do
    Dir.mktmpdir do |dir|
      create_test_file(dir, token: 'sys/bc_jupyter', title: 'Jupyter')
      stub_scheduler(:completed)
      visit(batch_connect_sessions_path)

      card = find("#id_#{get_test_bc_id}")
      assert_not_nil(card)

      header_text = card.find('.h5').text
      assert_equal("Jupyter (#{get_test_job_id})\nCompleted | |", header_text)
    end
  end

  test 'completed session with completed view' do
    Dir.mktmpdir do |dir|
      create_test_file(dir)
      stub_scheduler(:completed)
      visit(batch_connect_sessions_path)

      card = find("#id_#{get_test_bc_id}")
      assert_not_nil(card)

      header_text = card.find('.h5').text
      assert_equal("Paraview (#{get_test_job_id})\nCompleted | |", header_text)

      completed_text = card.find('#completed_test_div').text
      assert_equal('This is a test message for a completed view.', completed_text)
    end
  end

  test 'running session' do
    Dir.mktmpdir do |dir|
      create_test_file(dir, token: 'sys/bc_jupyter', title: 'Jupyter')
      stub_scheduler(:running)
      visit(batch_connect_sessions_path)

      card = find("#id_#{get_test_bc_id}")
      assert_not_nil(card)

      header_text = card.find('.h5').text
      assert_equal("Jupyter (#{get_test_job_id})\n1 node | 1 core | Starting", header_text)
    end
  end

  test 'running session with info view' do
    Dir.mktmpdir do |dir|
      create_test_file(dir, token: 'sys/bc_paraview', title: 'Paraview')
      stub_scheduler(:running)
      visit(batch_connect_sessions_path)

      card = find("#id_#{get_test_bc_id}")
      assert_not_nil(card)

      header_text = card.find('.h5').text
      assert_equal("Paraview (#{get_test_job_id})\n1 node | 1 core | Starting", header_text)

      info_text = card.find("#info_test_div").text
      assert_equal('This is a test message for an info view.', info_text)
    end
  end

  test 'running sessions with 0 nodes and cores' do
    Dir.mktmpdir do |dir|
      create_test_file(dir, token: 'sys/bc_jupyter', title: 'Jupyter')
      stub_scheduler(:running, nodes: 0, cores: 0)
      visit(batch_connect_sessions_path)

      card = find("#id_#{get_test_bc_id}")
      assert_not_nil(card)

      header_text = card.find('.h5').text
      assert_equal("Jupyter (#{get_test_job_id})\nStarting", header_text)
    end
  end

  test 'running sessions with 0 nodes and 1 core' do
    Dir.mktmpdir do |dir|
      create_test_file(dir, token: 'sys/bc_jupyter', title: 'Jupyter')
      stub_scheduler(:running, nodes: 0, cores: 1)
      visit(batch_connect_sessions_path)

      card = find("#id_#{get_test_bc_id}")
      assert_not_nil(card)

      header_text = card.find('.h5').text
      assert_equal("Jupyter (#{get_test_job_id})\n1 core | Starting", header_text)
    end
  end

  test 'running sessions with 1 nodes and 0 cores' do
    Dir.mktmpdir do |dir|
      create_test_file(dir, token: 'sys/bc_jupyter', title: 'Jupyter')
      stub_scheduler(:running, nodes: 0, cores: 1)
      visit(batch_connect_sessions_path)

      card = find("#id_#{get_test_bc_id}")
      assert_not_nil(card)

      header_text = card.find('.h5').text
      assert_equal("Jupyter (#{get_test_job_id})\n1 core | Starting", header_text)
    end
  end

  test 'running sessions correctly pluralize nodes and cores' do
    Dir.mktmpdir do |dir|
      create_test_file(dir, token: 'sys/bc_jupyter', title: 'Jupyter')
      stub_scheduler(:running, nodes: 2, cores: 2)
      visit(batch_connect_sessions_path)

      card = find("#id_#{get_test_bc_id}")
      assert_not_nil(card)

      header_text = card.find('.h5').text
      assert_equal("Jupyter (#{get_test_job_id})\n2 nodes | 2 cores | Starting", header_text)
    end
  end

  test 'session cards hold focus when replaced' do 
    Dir.mktmpdir do |dir|
      create_test_file(dir, token: 'sys/bc_jupyter', title: 'Jupyter')
      stub_scheduler(:running, nodes: 2, cores: 2)
      # The production configuration clamps environment values to at least 10s.
      Configuration.stubs(:bc_sessions_poll_delay).returns(10)
      visit(batch_connect_sessions_path)

      card_id = "id_#{get_test_bc_id}"
      assert_selector("##{card_id}")
      identities = evaluate_script <<~JS
        (() => {
          #{session_focus_dom(card_id)}
          return controls.filter(element =>
            element.getClientRects().length > 0 && !element.disabled &&
            getComputedStyle(element).visibility !== 'hidden').map(describe);
        })()
      JS
      assert_not_empty identities

      identities.each do |identity|
        # A second replacement also proves that polling continues after restoration.
        2.times do
          focus_session_control(card_id, identity)
          assert_replaced_session_focus(card_id, identity)
        end
      end

      classless = identities.find do |identity|
        identity['tag'] == 'button' && identity['id'].empty? && !identity['text'].strip.empty?
      end
      assert_not_nil classless
      focus_session_control(card_id, classless, classless: true)
      assert_replaced_session_focus(card_id, classless)

      visit root_path
    end
  end

  test 'session card connection tabs remain selected when replaced' do
    Dir.mktmpdir do |dir|
      with_modified_env({ ENABLE_NATIVE_VNC: 'true' }) do
        Configuration.stubs(:bc_sessions_poll_delay).returns(100)
        create_vnc_running_session(dir)
        stub_scheduler(:running)

        visit(batch_connect_sessions_path)

        card_selector = "#id_#{get_test_bc_id}"
        assert_selector(card_selector)

        within(card_selector) do
          assert_selector('.h5', text: /Running/)
          assert_selector('.nav-link', text: 'Native Instructions')
          click_link('Native Instructions')
          assert_selector('.nav-link.active', text: 'Native Instructions')
        end

        execute_script("$('#{card_selector}').attr('data-original-marker', 'true')")
        assert_no_selector("#{card_selector}[data-original-marker='true']", wait: 5)

        within(card_selector) do
          assert_selector('.nav-link.active', text: 'Native Instructions')
          assert_text('establish the SSH tunnel')
        end

        visit root_path
      end
    end
  end

  private

  # Share a primitive identity description; never retain nodes across replacements.
  def session_focus_dom(card_id)
    <<~JS
      const card = document.getElementById(#{card_id.to_json});
      const controls = card ? Array.from(card.querySelectorAll(
        'a[href], button, input, select, textarea, [tabindex]:not([tabindex="-1"])')) : [];
      const describe = element => ({
        tag: element.tagName.toLowerCase(),
        id: element.id,
        classes: Array.from(element.classList).sort(),
        text: element.textContent,
        name: element.getAttribute('name'),
        type: element.getAttribute('type'),
        href: element.getAttribute('href')
      });
    JS
  end

  # Mark the card and focus the uniquely identified control in the same browser turn.
  def focus_session_control(card_id, identity, classless: false)
    result = evaluate_script <<~JS
      (() => {
        #{session_focus_dom(card_id)}
        const identity = #{identity.to_json};
        const matches = controls.filter(element => {
          const candidate = describe(element);
          return Object.keys(identity).every(key =>
            JSON.stringify(candidate[key]) === JSON.stringify(identity[key]));
        });
        if (matches.length !== 1) return { matches: matches.length, focused: false };
        card.dataset.focusTestMarker = 'original';
        const target = matches[0];
        if (#{classless}) target.removeAttribute('class');
        target.focus();
        return { matches: matches.length, focused: document.activeElement === target };
      })()
    JS
    assert_equal({ 'matches' => 1, 'focused' => true }, result)
  end

  # Replacement and the active element's card/identity must agree in one snapshot.
  def assert_replaced_session_focus(card_id, identity)
    expected = { 'marker' => nil, 'card' => card_id, 'identity' => identity }
    snapshot = nil
    page.document.synchronize(errors: [Capybara::ExpectationNotMet]) do
      snapshot = evaluate_script <<~JS
        (() => {
          #{session_focus_dom(card_id)}
          const active = document.activeElement;
          return {
            marker: card ? card.getAttribute('data-focus-test-marker') : 'missing',
            card: active.closest('.session-panel')?.id || null,
            identity: describe(active)
          };
        })()
      JS
      unless snapshot == expected
        raise Capybara::ExpectationNotMet, "Expected #{expected.inspect}; observed #{snapshot.inspect}"
      end
    end
    assert_equal expected, snapshot
  rescue Capybara::ExpectationNotMet => e
    flunk e.message
  end
end
