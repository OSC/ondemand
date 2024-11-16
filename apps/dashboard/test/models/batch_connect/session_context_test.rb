# frozen_string_literal: true

require 'test_helper'

module BatchConnect
  class SessionContextTest < ActiveSupport::TestCase
    test 'should use default values' do
      app = BatchConnect::App.new(router: nil)
      app.stubs(:form_config).returns(attributes: { num_cores: { widget: 'number_field', value: '1' } },
                                      form:       ['bc_account', 'num_cores'])
      context = app.build_session_context

      assert_equal ['', '1'], [context['bc_account'].value, context['num_cores'].value]
    end

    test 'should update cache using from_json' do
      app = BatchConnect::App.new(router: nil)
      app.stubs(:form_config).returns(attributes: { num_cores: { widget: 'number_field', value: '1' } },
                                      form:       ['bc_account', 'num_cores'])
      context = app.build_session_context

      context.from_json({ 'bc_account' => 'PZS0714', 'num_cores' => '28' }.to_json)

      assert_equal ['PZS0714', '28'], [context['bc_account'].value, context['num_cores'].value]
    end

    test 'should update cache using attributes=' do
      app = BatchConnect::App.new(router: nil)
      app.stubs(:form_config).returns(attributes: { num_cores: { widget: 'number_field', value: '1' } },
                                      form:       ['bc_account', 'num_cores'])
      context = app.build_session_context

      context.attributes = { 'bc_account' => 'PZS0714', 'num_cores' => '28' }

      assert_equal ['PZS0714', '28'], [context['bc_account'].value, context['num_cores'].value]
    end
    test 'should update cache using update_with_cache' do
      app = BatchConnect::App.new(router: nil)
      app.stubs(:form_config).returns(attributes: { num_cores: { widget: 'number_field', value: '1' } },
                                      form:       ['bc_account', 'num_cores'])
      context = app.build_session_context

      context.update_with_cache({ 'bc_account' => 'PZS0714', 'num_cores' => '28' })

      assert_equal ['PZS0714', '28'], [context['bc_account'].value, context['num_cores'].value]
    end

    test 'should not update cache if global cache setting disabled' do
      with_modified_env(OOD_BATCH_CONNECT_CACHE_ATTR_VALUES: 'FALSE') do
        app = BatchConnect::App.new(router: nil)
        app.stubs(:form_config).returns(attributes: { num_cores: { widget: 'number_field', value: '1' } },
                                        form:       ['bc_account', 'num_cores'])
        context = app.build_session_context

        context.update_with_cache({ 'bc_account' => 'PZS0714', 'num_cores' => '28' })

        assert_equal ['', '1'], [context['bc_account'].value, context['num_cores'].value]
      end
    end

    test 'should not update cache if per app cache disabled' do
      app = BatchConnect::App.new(router: nil)
      app.stubs(:form_config).returns(cacheable: false,
                                      attributes: { num_cores: { widget: 'number_field', value: '1' } }, form: ['bc_account', 'num_cores'])
      context = app.build_session_context

      context.update_with_cache({ 'bc_account' => 'PZS0714', 'num_cores' => '28' })

      assert_equal ['', '1'], [context['bc_account'].value, context['num_cores'].value]
    end

    test 'should not update single field if per attribute cache disabled' do
      app = BatchConnect::App.new(router: nil)
      app.stubs(:form_config).returns(
        attributes: { num_cores: { widget: 'number_field', value: '1',
cacheable: false } }, form: ['bc_account', 'num_cores']
      )
      context = app.build_session_context
      context.update_with_cache({ 'bc_account' => 'PZS0714', :num_cores => 28 })
      assert_equal ['PZS0714', '1'], [context['bc_account'].value, context['num_cores'].value]
    end

    test 'should not update single field if per attribute cache disabled even if global cache setting disabled but per app cache enabled' do
      with_modified_env(OOD_BATCH_CONNECT_CACHE_ATTR_VALUES: 'FALSE') do
        app = BatchConnect::App.new(router: nil)
        app.stubs(:form_config).returns(cacheable: true,
                                        attributes: { num_cores: { widget: 'number_field', value: '1', cacheable: false } }, form: ['bc_account', 'num_cores'])
        context = app.build_session_context
        context.update_with_cache({ 'bc_account' => 'PZS0714', 'num_cores' => '28' })

        assert_equal ['PZS0714', '1'], [context['bc_account'].value, context['num_cores'].value]
      end
    end

    test 'should update single field if per attribute cache enabled even if global cache setting disabled' do
      with_modified_env(OOD_BATCH_CONNECT_CACHE_ATTR_VALUES: 'FALSE') do
        app = BatchConnect::App.new(router: nil)
        app.stubs(:form_config).returns(
          attributes: { num_cores: { widget: 'number_field', value: '1',
cacheable: true } }, form: ['bc_account', 'num_cores']
        )
        context = app.build_session_context

        context.update_with_cache({ 'bc_account' => 'PZS0714', 'num_cores' => '28' })

        assert_equal ['', '28'], [context['bc_account'].value, context['num_cores'].value]
      end
    end

    test 'should update single field if per attribute cache enabled even if per app cache disabled' do
      app = BatchConnect::App.new(router: nil)
      app.stubs(:form_config).returns(cacheable: false,
                                      attributes: { num_cores: { widget: 'number_field', value: '1', cacheable: true } }, form: ['bc_account', 'num_cores'])
      context = app.build_session_context

      context.update_with_cache({ 'bc_account' => 'PZS0714', 'num_cores' => '28' })

      assert_equal ['', '28'], [context['bc_account'].value, context['num_cores'].value]
    end

    test 'should ignore bad cache keys when updating cache using update_with_cache' do
      app = BatchConnect::App.new(router: nil)
      app.stubs(:form_config).returns(attributes: { num_cores: { widget: 'number_field', value: '1' } },
                                      form:       ['bc_account', 'num_cores'])
      context = app.build_session_context

      context.update_with_cache({ 'bc_account' => 'PZS0714', 'num_cores' => '28', 'bad_key_1' => '1',
'bad_key_2' => '2' })

      assert_equal ['PZS0714', '28'], [context['bc_account'].value, context['num_cores'].value]
    end

    test 'to_openstruct throws error when using OpenStruct methods' do
      app = BatchConnect::App.new(router: nil)
      app.stubs(:form_config).returns(attributes: { table: { value: 'the_table' } }, form: ['bc_account', 'table'])
      context = app.build_session_context

      assert_raises ArgumentError do
        context.to_openstruct
      end
    end

    test 'to_openstruct accepts empty values' do
      app = BatchConnect::App.new(router: nil)
      app.stubs(:form_config).returns(attributes: { queue: { value: 'gpu' } }, form: ['bc_account', 'queue'])
      context = app.build_session_context

      assert_equal context.to_openstruct.to_h, { :bc_account => '', :queue => 'gpu' }
    end

    test 'to_openstruct accepts accepts hashes with string keys' do
      app = BatchConnect::App.new(router: nil)
      app.stubs(:form_config).returns(attributes: { queue: { value: 'gpu' } }, form: ['bc_account', 'queue'])
      context = app.build_session_context
      struct = context.to_openstruct(addons: { "new_thing": 'some_new_thing' })

      assert_equal struct.to_h, { :bc_account => '', :queue => 'gpu', :new_thing => 'some_new_thing' }
    end

    test 'to_openstruct accepts accepts hashes with symbol keys' do
      app = BatchConnect::App.new(router: nil)
      app.stubs(:form_config).returns(attributes: { queue: { value: 'gpu' } }, form: ['bc_account', 'queue'])
      context = app.build_session_context
      struct = context.to_openstruct(addons: { :new_thing => 'some_new_thing' })

      assert_equal struct.to_h, { :bc_account => '', :queue => 'gpu', :new_thing => 'some_new_thing' }
    end
  end
end
