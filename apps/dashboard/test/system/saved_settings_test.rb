# frozen_string_literal: true

require 'application_system_test_case'

class SavedSettingsTest < ApplicationSystemTestCase
  def setup
    stub_sys_apps
    Configuration.stubs(:bc_saved_settings).returns(true)
    Configuration.stubs(:bc_saved_settings?).returns(true)
  end

  def stub_user_settings(file = nil)
    file = "#{Rails.root}/test/fixtures/file_output/user_settings/saved_settings_menu.yml" if file.blank?
    Configuration.stubs(:user_settings_file).returns(file)
  end

  test 'can save, show, edit and delete settings' do
    with_modified_env({ ENABLE_NATIVE_VNC: '1' }) do
      Dir.mktmpdir do |dir|
        user_settings_file = "#{dir}/user_settings.yml"
        stub_user_settings(user_settings_file)

        visit(new_batch_connect_session_context_url('sys/bc_paraview'))

        fill_in(bc_ele_id('bc_num_hours'), with: 4)
        fill_in(bc_ele_id('bc_account'), with: 'abc123')
        fill_in('bc_vnc_resolution_x_field', with: '500')
        fill_in('bc_vnc_resolution_y_field', with: '600')

        check('Save settings')
        fill_in('modal_input_template_new_name', with: 'test')
        sleep 1
        # find('#batch_connect_session_template_choose_name_button').click
        click_button('Save')
        sleep 1
        click_button('Save settings and close')

        sleep 3
        assert_equal(batch_connect_setting_path('sys/bc_paraview', 'test'), current_path)

        # we can find the card and all the text
        find('.card-header', text: 'test')
        find('p', text: 'Cluster: quick')
        find('p', text: 'Number of hours: 4')
        find('p', text: 'Account: abc123')
        find('p', text: 'Resolution: 500x600')

        settings = YAML.safe_load(File.read(user_settings_file)).to_h
        actual_data = settings['batch_connect_templates']['sys/bc_paraview']['test']
        expected_data = {
          'cluster' => 'quick', 'bc_num_hours' => '4',
          'bc_account' => 'abc123', 'bc_vnc_resolution' => '500x600'
        }
        assert_equal(expected_data, actual_data)

        find('a[aria-label="Edit test saved settings"]').click
        sleep 1
        assert_equal(batch_connect_edit_settings_path('sys/bc_paraview', 'test'), current_path)

        fill_in(bc_ele_id('bc_account'), with: '')
        fill_in(bc_ele_id('bc_account'), with: 'def456')
        click_button('Save settings and close')
        sleep 1

        # save and we're back to show.
        assert_equal(batch_connect_setting_path('sys/bc_paraview', 'test'), current_path)

        settings = YAML.safe_load(File.read(user_settings_file)).to_h
        actual_data = settings['batch_connect_templates']['sys/bc_paraview']['test']
        expected_data = {
          'cluster' => 'quick', 'bc_num_hours' => '4',
          'bc_account' => 'def456', 'bc_vnc_resolution' => '500x600'
        }
        assert_equal(expected_data, actual_data)

        page.accept_alert 'Are you sure?' do
          find('button[aria-label="Delete test saved settings"]').click
        end

        sleep 1
        # after deleting, now there are no settings in the file.
        assert_equal(new_batch_connect_session_context_path('sys/bc_paraview'), current_path)
        settings = YAML.safe_load(File.read(user_settings_file)).to_h
        assert_equal({ 'batch_connect_templates' => {} }, settings)
      end
    end
  end

  test 'display settings with invalid names correctly redirect' do
    visit(batch_connect_setting_path(token: 'sys/bc_paraview', id: 'invalid'))

    assert_equal(new_batch_connect_session_context_path('sys/bc_paraview'), current_path)

    # the alert div is on the page
    find('.alert', text: I18n.t('dashboard.bc_saved_settings.missing_settings'))
  end

  test 'password_fields settings are encrypted when saved' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_git("#{dir}/app")
      user_settings_file = "#{dir}/user_settings.yml"
      stub_user_settings(user_settings_file)
      BatchConnect::Session.stubs(:cache_root).returns(Pathname.new('/dev/null'))

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - some_field
          - some_password_field
        attributes:
          some_password_field:
            widget: 'password_field'
      HEREDOC

      Pathname.new("#{dir}/app/form.yml").write(form)
      visit(new_batch_connect_session_context_url('sys/app'))

      fill_in(bc_ele_id('some_field'), with: 'my data')
      fill_in(bc_ele_id('some_password_field'), with: 'mypassword')

      check('Save settings')
      fill_in('modal_input_template_new_name', with: 'test')
      sleep 1
      # find('#batch_connect_session_template_choose_name_button').click
      click_button('Save')
      sleep 1
      click_button('Save settings and close')

      sleep 3
      assert_equal(batch_connect_setting_path('sys/app', 'test'), current_path)

      settings = YAML.safe_load(File.read(user_settings_file)).to_h
      actual_data = settings['batch_connect_templates']['sys/app']['test']
      crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])
      stored_password = crypt.decrypt_and_verify(actual_data['some_password_field'])

      assert_equal('mypassword', stored_password)
      assert_equal('my data', actual_data['some_field'])
      assert_equal('owens', actual_data['cluster'])
      assert_equal(3, actual_data.size)

      File.write('delme.html', page.body)
      find('p', text: 'Some Field: my data')
      find('p', text: 'Some Password Field: **********')
    end
  end
end
