# frozen_string_literal: true

require 'test_helper'

class SettingsControllerTest < ActionDispatch::IntegrationTest
  def setup
    # lot's of setup here to get a valid csrf-token
    get root_path
    assert :success

    doc = Nokogiri::XML(@response.body)
    @token = doc.xpath("/html/head/meta[@name='csrf-token']/@content").to_s
    @headers = { 'X-CSRF-Token' => @token }
  end

  test 'should save and override profile settings when posting profile' do
    Dir.mktmpdir do |temp_data_dir|
      Configuration.stubs(:user_settings_file).returns("#{temp_data_dir}/settings.yml")
      data = { settings: {} }

      data[:settings][:profile] = 'first_profile'
      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_equal 'first_profile', TestUserSettings.new.user_settings[:profile]

      data[:settings][:profile] = 'override_profile'
      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_equal 'override_profile', TestUserSettings.new.user_settings[:profile]
    end
  end

  test 'should allow empty or nil profile settings when posting profile' do
    Dir.mktmpdir do |temp_data_dir|
      Configuration.stubs(:user_settings_file).returns("#{temp_data_dir}/settings.yml")
      data = { settings: {} }

      data[:settings][:profile] = ''
      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_equal '', TestUserSettings.new.user_settings[:profile]

      data[:settings][:profile] = nil
      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_nil TestUserSettings.new.user_settings[:profile]
    end
  end

  test 'should save announcement settings and allow multiple announcements when posting announcement' do
    Dir.mktmpdir do |temp_data_dir|
      Configuration.stubs(:user_settings_file).returns("#{temp_data_dir}/settings.yml")
      data = { settings: {} }

      value =  Time.now.localtime.strftime('%Y-%m-%d %H:%M:%S')
      data[:settings] = { announcements: { 'announcement_id' => value } }
      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_equal value, TestUserSettings.new.user_settings[:announcements][:announcement_id]

      data[:settings] = { announcements: { 'other_announcement_id' => value } }
      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_equal value, TestUserSettings.new.user_settings[:announcements][:announcement_id]
      assert_equal value, TestUserSettings.new.user_settings[:announcements][:other_announcement_id]
    end
  end

  test 'should not save user_settings when no data' do
    Dir.mktmpdir do |temp_data_dir|
      Configuration.stubs(:user_settings_file).returns("#{temp_data_dir}/settings.yml")
      data = { settings: {} }

      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_empty TestUserSettings.new.user_settings
    end
  end

  test 'should not save user_settings when parameters are outside the settings namespace' do
    Dir.mktmpdir do |temp_data_dir|
      Configuration.stubs(:user_settings_file).returns("#{temp_data_dir}/settings.yml")
      data = { profile: 'root_value' }

      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_empty TestUserSettings.new.user_settings
    end
  end

  test 'should not save user_settings when parameters are not in the allowed list' do
    Dir.mktmpdir do |temp_data_dir|
      Configuration.stubs(:user_settings_file).returns("#{temp_data_dir}/settings.yml")
      data = { settings: { not_allowed: 'root_value' } }

      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_empty TestUserSettings.new.user_settings
    end
  end

    test 'should redirect to referrer if back param is true' do
      Dir.mktmpdir do |temp_data_dir|
        Configuration.stubs(:user_settings_file).returns("#{temp_data_dir}/settings.yml")
        data = { settings: {}, back: 'true' }
        referrer_url = '/some-previous-page'

        post settings_path, params: data, headers: @headers.merge('HTTP_REFERER' => referrer_url)

        assert_response :redirect
        assert_redirected_to referrer_url
      end
    end

  test 'should save locale settings when posting a valid locale' do
    Dir.mktmpdir do |temp_data_dir|
      Configuration.stubs(:user_settings_file).returns("#{temp_data_dir}/settings.yml")
      data = { settings: { locale: 'zh-CN' } }

      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_equal 'zh-CN', TestUserSettings.new.user_settings[:locale]
    end
  end

  test 'should override previously saved locale when posting a new locale' do
    Dir.mktmpdir do |temp_data_dir|
      Configuration.stubs(:user_settings_file).returns("#{temp_data_dir}/settings.yml")
      data = { settings: { locale: 'zh-CN' } }

      post settings_path, params: data, headers: @headers
      assert_equal 'zh-CN', TestUserSettings.new.user_settings[:locale]

      data[:settings][:locale] = 'ja_JP'
      post settings_path, params: data, headers: @headers
      assert_equal 'ja_JP', TestUserSettings.new.user_settings[:locale]
    end
  end

  test 'should not save locale when posting an invalid locale' do
    Dir.mktmpdir do |temp_data_dir|
      Configuration.stubs(:user_settings_file).returns("#{temp_data_dir}/settings.yml")
      data = { settings: { locale: 'klingon' } }

      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_nil TestUserSettings.new.user_settings[:locale]
    end
  end

  test 'should not save a locale from a gem that has no dashboard translations' do
    Dir.mktmpdir do |temp_data_dir|
      Configuration.stubs(:user_settings_file).returns("#{temp_data_dir}/settings.yml")
      # 'de' is contributed by the dotiw gem and appears in I18n.available_locales
      # but has no dashboard translations, so it must be rejected.
      data = { settings: { locale: 'de' } }

      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal I18n.t('dashboard.settings_updated'), flash[:notice]
      assert_nil TestUserSettings.new.user_settings[:locale]
    end
  end

  test 'should apply the saved locale on subsequent requests' do
    Dir.mktmpdir do |temp_data_dir|
      Configuration.stubs(:user_settings_file).returns("#{temp_data_dir}/settings.yml")
      TestUserSettings.new.update_user_settings(locale: 'zh-CN')

      get root_path
      assert_response :success
      assert_equal :"zh-CN", I18n.locale
      assert_match(/<html lang="zh-CN">/, @response.body)
    end
  end

  test 'should fall back to default locale when no locale is saved' do
    Dir.mktmpdir do |temp_data_dir|
      Configuration.stubs(:user_settings_file).returns("#{temp_data_dir}/settings.yml")

      get root_path
      assert_response :success
      assert_equal ::Configuration.locale, I18n.locale
    end
  end

  test 'should render locale switcher in help dropdown when multiple locales available' do
    get root_path
    assert_response :success
    assert_match(/settings\[locale\]/, @response.body)
    assert_match(/#{Regexp.escape(I18n.t('dashboard.nav_language'))}/, @response.body)
  end

  test 'locale switcher shows only locales with dashboard translations, not gem locales' do
    get root_path
    assert_response :success
    # supported_locales should be the 5 app locale files, not the extra
    # locales contributed by gems (e.g. dotiw adds de, fr, ja, ...).
    assert_equal 5, @controller.supported_locales.size
    # Each locale link should carry settings[locale]=<code>
    locale_links = @response.body.scan(/settings\[locale\]=([a-zA-Z_\-]+)&/).flatten
    assert_equal %w[en en-CA fr-CA ja_JP zh-CN], locale_links.sort
    # Gem locales like 'de' must not appear
    assert_no_match(/settings\[locale\]=de&/, @response.body)
  end

  teardown do
    I18n.locale = I18n.default_locale
  end

  class TestUserSettings
    include UserSettingStore
  end
end
