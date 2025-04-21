# frozen_string_literal: true

require 'test_helper'

class ServiceNowClientTest < ActiveSupport::TestCase
  test 'should throw exception when server is not provided' do
    config = {
      server: nil
    }

    assert_raises(ArgumentError) { ServiceNowClient.new(config) }
  end

  test 'should allow missing credentials' do
    config = {
      server: 'http://server.com',
    }

    assert_not_nil(ServiceNowClient.new(config))
  end

  test 'should set the expected default values' do
    config = {
      server: 'http://server.com'
    }

    target = ServiceNowClient.new(config)
    assert_equal('x-sn-apikey', target.auth_header)
    assert_equal(30, target.timeout)
    assert_equal(false, target.verify_ssl)
  end

  test 'should set RestClient options when provided' do
    config = {
      server:     'http://server.com',
      user:       'payload_username',
      pass:       'payload_password',
      auth_token: 'payload_token',
      timeout:    90,
      verify_ssl: true,
      proxy:      'proxy.com:8888'
    }

    target = ServiceNowClient.new(config)
    assert_equal('payload_username', target.client.options[:user])
    assert_equal('payload_password', target.client.options[:password])
    assert_equal('payload_token', target.client.options[:headers]['x-sn-apikey'])
    assert_equal(90, target.client.options[:timeout])
    assert_equal(true, target.client.options[:verify_ssl])
    assert_equal('proxy.com:8888', target.client.options[:proxy])
  end

  test 'should set password and token from environment if configured' do
    config = {
      server:         'http://server.com',
      pass_env:       'SNOW_PASSWORD',
      auth_token_env: 'SNOW_TOKEN'
    }

    with_modified_env(SNOW_PASSWORD: 'password_from_env', SNOW_TOKEN: 'token_from_env') do
      target = ServiceNowClient.new(config)
      assert_equal('password_from_env', target.client.options[:password])
      assert_equal('token_from_env', target.client.options[:headers]['x-sn-apikey'])
    end

  end
end
