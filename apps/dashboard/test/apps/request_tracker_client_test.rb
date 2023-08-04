# frozen_string_literal: true

require 'test_helper'

class RequestTrackerClientTest < ActiveSupport::TestCase
  test 'should throw exception when server is not provided' do
    config = {
      server: nil,
      user:   'test',
      pass:   'test'
    }

    assert_raises(ArgumentError) { RequestTrackerClient.new(config) }
  end

  test 'should throw exception when username or password is not provided' do
    config = {
      server: 'http://server.com',
      user:   'test',
      pass:   nil
    }

    assert_raises(ArgumentError) { RequestTrackerClient.new(config) }
  end

  test 'should not throw exception auth_token is provided instead of username and password' do
    config = {
      server:     'http://server.com',
      auth_token: 'auth'
    }

    assert_not_nil(RequestTrackerClient.new(config))
  end

  test 'should set the expected default values' do
    config = {
      server: 'http://server.com',
      user:   'test',
      pass:   'test'
    }

    target = RequestTrackerClient.new(config)
    assert_equal(30, target.timeout)
    assert_equal(false, target.verify_ssl)
  end

  test 'compose should set username and password in payload if provided' do
    config = {
      server: 'http://server.com',
      user:   'payload_username',
      pass:   'payload_password'
    }

    target = RequestTrackerClient.new(config)
    payload = target.compose({})
    assert_equal('payload_username', payload['user'])
    assert_equal('payload_password', payload['pass'])
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

    target = RequestTrackerClient.new(config)
    assert_equal(90, target.rt_client.options[:timeout])
    assert_equal(true, target.rt_client.options[:verify_ssl])
    assert_equal('proxy.com:8888', target.rt_client.options[:proxy])
  end
end
