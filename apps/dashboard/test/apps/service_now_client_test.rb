# frozen_string_literal: true

require 'test_helper'

class ServiceNowClientTest < ActiveSupport::TestCase
  test 'should throw exception when server is not provided' do
    config = {
      server: nil,
      user:   'test',
      pass:   'test'
    }

    assert_raises(ArgumentError) { ServiceNowClient.new(config) }
  end

  test 'should throw exception when user or password are missing and not auth_token provided' do
    config = {
      server: 'http://server.com',
      user:   'test',
      pass:   nil
    }
    assert_raises(ArgumentError) { ServiceNowClient.new(config) }

    config = {
      server: 'http://server.com',
      user:   nil,
      pass:   'test'
    }
    assert_raises(ArgumentError) { ServiceNowClient.new(config) }
  end

  test 'should not throw exception auth_token is provided instead of username and password' do
    config = {
      server:     'http://server.com',
      auth_token: 'auth'
    }

    assert_not_nil(ServiceNowClient.new(config))
  end

  test 'should set the expected default values' do
    config = {
      server: 'http://server.com',
      user:   'test',
      pass:   'test'
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
      timeout:    90,
      verify_ssl: true,
      proxy:      'proxy.com:8888'
    }

    target = ServiceNowClient.new(config)
    assert_equal('payload_username', target.client.options[:user])
    assert_equal('payload_password', target.client.options[:password])
    assert_equal(90, target.client.options[:timeout])
    assert_equal(true, target.client.options[:verify_ssl])
    assert_equal('proxy.com:8888', target.client.options[:proxy])
  end
end
