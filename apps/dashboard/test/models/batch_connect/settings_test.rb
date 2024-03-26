# frozen_string_literal: true

require 'test_helper'

module BatchConnect
  class SettingsTest < ActionView::TestCase

    test 'can set values' do
      target = BatchConnect::Settings.new('app/token', 'settings name', { name: 'value' })

      assert_equal('app/token', target.token)
      assert_equal('settings name', target.name)
      assert_equal({ name: 'value' }, target.values)
    end

    test 'app returns BatchConnect::App based on token' do
      target = BatchConnect::Settings.new('sys/token', 'settings name', { name: 'value' })

      assert_instance_of(BatchConnect::App, target.app)
      assert_equal('sys/token', target.app.token)
    end

    test 'outdated? returns true when settings keys do not match app attribute ids' do
      app_token = 'sys/token'
      setting_values = { bc_account: 'engineering', bc_cluster: 'test', bc_hours: 4 }
      target = BatchConnect::Settings.new(app_token, 'settings name', setting_values)
      create_app(app_token, ['bc_account', 'bc_cluster'])
      assert_equal(true, target.outdated?)

      setting_values = { bc_account: 'engineering' }
      target = BatchConnect::Settings.new(app_token, 'settings name', setting_values)
      create_app(app_token, ['bc_account', 'bc_cluster'])
      assert_equal(true, target.outdated?)
    end

    test 'outdated? returns false when settings keys match app attribute ids' do
      app_token = 'sys/token'
      setting_values = { bc_account: 'engineering', bc_cluster: 'test' }
      target = BatchConnect::Settings.new(app_token, 'settings name', setting_values)
      create_app(app_token, ['bc_account', 'bc_cluster'])

      assert_equal(false, target.outdated?)
    end

    private

    def create_app(token, attributes)
      router = Router.router_from_token(token)
      app = BatchConnect::App.new(router: router)
      app.stubs(:attributes).returns(attributes.map { |id| SmartAttributes::AttributeFactory.build(id, {}) })
      BatchConnect::App.stubs(:from_token).with(app.token).returns(app)
    end
  end
end
