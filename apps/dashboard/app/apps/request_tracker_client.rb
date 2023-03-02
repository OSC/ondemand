# frozen_string_literal: true

require 'rest_client'

# HTTP client to create a request tracker ticket using the API
# Configuration parameters:
# - `server`: URL for the Request Tracker server (required)
# - `user`: RT API username
# - `pass`: RT API password
# - `auth_token`: RT API [auth token](https://github.com/bestpractical/rt-authen-token), preferred instead of username and password.
# - `timeout`: Connection and read timeout in seconds. Defaults to 30.
# - `verify_ssl`: Whether or not the client should validate SSL certificates. Defaults to true.
# - `proxy`: Proxy server URL. Defaults to no proxy.
#
class RequestTrackerClient
  # THIS CLIENT IS BASED ON https://github.com/uidzip/rt-client

  UA = 'Open OnDemand ruby RT Client'
  attr_reader :server, :rt_client, :resource, :timeout, :verify_ssl

  def initialize(config)
    # FROM CONFIGURATION
    @user = config[:user]
    @pass = config[:pass]
    @auth_token = config[:auth_token]
    @timeout = config[:timeout] || 30
    @verify_ssl = config[:verify_ssl] || false
    if config[:server]
      @server = config[:server]
      @server += '/' if @server !~ %r{/$}
      @resource = "#{@server}REST/1.0/"
    end

    raise ArgumentError, 'server is a required option for RT client' unless @server

    if !@auth_token && (!@user || !@pass)
      raise ArgumentError, 'user and pass are required if not auth_token is provided for RT client'
    end

    if !@auth_token && !@user && !@pass
      raise ArgumentError, 'auth_token or user and pass are required options for RT client'
    end

    headers = { 'User-Agent' => UA,
                'Cookie'     => '' }
    headers['Authorization'] = "Token #{@auth_token}" if @auth_token

    options = {
      headers:    headers,
      timeout:    @timeout,
      verify_ssl: @verify_ssl
    }
    options[:proxy] = config[:proxy] if config[:proxy]

    @rt_client = RestClient::Resource.new(@resource, options)
  end

  def create(field_hash)
    field_hash[:id] = 'ticket/new'
    payload = compose(field_hash)
    resp = @rt_client['ticket/new/edit'].post payload
    new_id = resp.match(/Ticket\s*(\d+)/)
    if new_id.instance_of?(MatchData)
      new_id[1]
    else
      raise StandardError, "Unable to create ticket. Server response: #{resp}"
    end
  end

  def compose(fields)
    payload = { :multipart => true }

    if fields.key? :Attachment
      filenames = fields[:Attachment].split(',')
      attachment_num = 1
      filenames.each do |f|
        payload["attachment_#{attachment_num}"] = File.new(f)
        attachment_num += 1
      end
      fields[:Attachment] = filenames.map { |f| File.basename(f) }.join(',')
    end

    if fields.key? :Attachments
      attachments = fields[:Attachments]
      attachment_num = 1
      attachments.each do |request_file|
        payload["attachment_#{attachment_num}"] = File.new(request_file.tempfile)
        attachment_num += 1
      end
      fields[:Attachment] = attachments.map(&:original_filename).join(',')
      fields.delete :Attachments
    end

    if fields.key? :Text
      # insert a space on continuation lines.
      fields[:Text].gsub!(/\n/, "\n ")
    end

    field_array = fields.map { |k, v| "#{k}: #{v}" }
    content = field_array.join("\n")
    payload['content'] = content
    unless @auth_token
      payload['user'] = @user
      payload['pass'] = @pass
    end

    payload
  end
end
