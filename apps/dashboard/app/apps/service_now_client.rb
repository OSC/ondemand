# frozen_string_literal: true

require 'rest_client'

# HTTP client to create a ServiceNow incident using the API
# Configuration parameters:
# - `server`: URL for the ServiceNow server (required)
# - `user`: ServiceNow API username
# - `pass`: ServiceNow API password
# - `auth_token`: ServiceNow API key
# - `auth_header`: ServiceNow API key HTTP header. Defaults to x-sn-apikey.
# - `timeout`: Connection and read timeout in seconds. Defaults to 30.
# - `verify_ssl`: Whether or not the client should validate SSL certificates. Defaults to true.
# - `proxy`: Proxy server URL. Defaults to no proxy.
#
class ServiceNowClient

  UA = 'Open OnDemand ruby ServiceNow Client'
  attr_reader :server, :auth_header, :client, :timeout, :verify_ssl

  def initialize(config)
    # FROM CONFIGURATION
    @user = config[:user]
    @pass = config[:pass]
    @auth_token = config[:auth_token]
    @auth_header = config[:auth_header] || 'x-sn-apikey'
    @timeout = config[:timeout] || 30
    @verify_ssl = config[:verify_ssl] || false
    @server = config[:server] if config[:server]

    raise ArgumentError, 'server is a required parameter for ServiceNow client' unless @server

    if !@auth_token && (!@user || !@pass)
      raise ArgumentError, 'user and pass are required if not auth_token is provided for the ServiceNow client'
    end

    headers = { 'User-Agent' => UA,
                'Cookie'     => '' }
    headers[@auth_header] = @auth_token if @auth_token

    options = {
      headers:    headers,
      timeout:    @timeout,
      verify_ssl: @verify_ssl,
    }

    if @user && @pass
      options[:user] = @user
      options[:password] = @pass
    end
    options[:proxy] = config[:proxy] if config[:proxy]

    @client = RestClient::Resource.new(@server, options)
  end

  def create(payload, attachments)
    incident = @client['/api/now/table/incident'].post(payload.to_json, content_type: :json)
    response_hash = JSON.parse(incident.body)['result'].symbolize_keys
    incident_number = response_hash[:number]
    incident_id = response_hash[:sys_id]

    Rails.logger.info response_hash
    raise StandardError, "Unable to create ticket. Server response: #{incident}" unless incident_id

    begin
      attachments.to_a.each do |request_file|
        add_attachment(incident_id, request_file)
      end
      attachments_success = true
    rescue StandardError => e
      Rails.logger.info "Could not add attachments to incident: #{incident_number}. Error=#{e}"
      attachments_success = false
    end

    create_response(incident_number, attachments.to_a.size, attachments_success)
  end

  def add_attachment(incident_id, request_file)
    params = {
      table_name:   'incident',
      table_sys_id: incident_id,
      file_name:    request_file.original_filename,
    }
    file = File.new(request_file.tempfile, 'rb')
    @client['/api/now/attachment/file'].post(file, params: params, content_type: request_file.content_type)
  end

  private

  def create_response(incident_number, attachments, attachments_success)
    OpenStruct.new({
      number:             incident_number,
      attachments:        attachments,
      attachments_success: attachments_success
    })
  end

end
