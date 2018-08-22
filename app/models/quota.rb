class InvalidQuotaFile < StandardError; end

# This describes disk quota utilization for a given user and volume
class Quota

  begin
    BLOCK_SIZE = ::Configuration.block_size
  rescue NameError
    BLOCK_SIZE = 1024
  end

  attr_reader :type, :path, :user, :resource_type, :user_usage, :total_usage, :limit, :grace, :updated_at

  # for number_to_human_size & number_to_human
  include ActionView::Helpers::NumberHelper

  class << self

    # Get quota objects only for requested user in JSON file(s)
    def find(quota_path, user)
      user  = user && user.to_s

      quotas = []
      json = JSON.parse(quota_path.read)
      case json["version"].to_i
      when 0..1
        quotas += find_v1(user, json)
      else
        raise InvalidQuotaFile("JSON version found was: #{json["version"].to_i}")
      end
      quotas
    end

    private

    # Parse JSON object using version 1 formatting
    def find_v1(user, params)
      q = []
      time = params["timestamp"]
      params["quotas"].each do |quota|
        q += create_both_quota_types(quota.merge "updated_at" => time) if !user || user == quota["user"]
      end
      q
    end

    def create_both_quota_types(params)
      params = params.to_h.compact.symbolize_keys
      file_quota = Quota.new(
        type:   params.fetch(:type, :user).to_sym,
        path:   Pathname.new(params.fetch(:path).to_s),
        user:   params.fetch(:user).to_s,    # FIXME: Can be integer in rare cases
        resource_type: "file",
        total_usage: params.fetch(:total_file_usage).to_i,
        user_usage: params.fetch(:file_usage, params.fetch(:total_file_usage)).to_i,
        limit: params.fetch(:file_limit).to_i,
        grace: params.fetch(:file_grace, 0).to_i, # future functionality
        updated_at: Time.at(params.fetch(:updated_at).to_i),
      )
      block_quota = Quota.new(
        type:   params.fetch(:type, :user).to_sym,
        path:   Pathname.new(params.fetch(:path).to_s),
        user:   params.fetch(:user).to_s,    # FIXME: Can be integer in rare cases
        resource_type: "block",
        total_usage: params.fetch(:total_block_usage).to_i,
        user_usage: params.fetch(:block_usage, params.fetch(:total_block_usage)).to_i,
        limit: params.fetch(:block_limit).to_i,
        grace: params.fetch(:block_grace, 0).to_i, # future functionality
        updated_at: Time.at(params.fetch(:updated_at).to_i),
      )
      [file_quota, block_quota]
    end

  end

  # @param params [#to_h] list of parameters that define quota object
  # @option params [#to_sym] :type (:user) type of quota (usually "fileset")
  # @option params [#to_s] :path path to volume
  # @option params [#to_s] :user user name
  # @option params [#to_s] :resource_type "file" or "block"
  # @option params [#to_i] :user_usage number of resource units used by user
  # @option params [#to_i] :total_usage total resource units used
  # @option params [#to_i] :limit resource unit limit
  # @option params [#to_i] :grace resource unit allowed overage amount
  # @option params [#to_i] :updated_at time when quota was generated
  def initialize(params)
    params = params.to_h.compact.symbolize_keys

    @type = params.fetch(:type, :user).to_sym
    @path = Pathname.new(params.fetch(:path).to_s)
    @user = params.fetch(:user).to_s    # FIXME: Can be integer in rare cases
    @resource_type = params.fetch(:resource_type).to_s
    @user_usage = params.fetch(:user_usage).to_i
    @total_usage = params.fetch(:total_usage).to_i
    @limit = params.fetch(:limit).to_i
    @grace = params.fetch(:grace).to_i # future functionality
    @updated_at = Time.at(params.fetch(:updated_at).to_i)
  end

  # Whether quota reporting is shared for this volume amongst other users
  # @return [Boolean] is quota for this volume shared
  def shared?
    @type != :user
  end

  def sufficient?(threshold: 0.95)
    @total_usage < threshold * @limit
  end

  def insufficient?(threshold: 0.95)
    !sufficient?(threshold: threshold)
  end

  # Percent of user resource units used for this volume
  # @return [Integer] percent user usage
  def percent_user_usage
    @user_usage * 100 / @limit
  end

  # Percent of total resource units used for this volume
  # @return [Integer] percent total block usage
  def percent_total_usage
    @total_usage * 100 / @limit
  end

  def to_s
    if @resource_type == "file"
      msg = "Using #{number_to_human(@total_usage).downcase} files of quota #{number_to_human(@limit).downcase} files"
      return msg unless self.shared?
      return msg + " (#{number_to_human(@user_usage).downcase} files are yours)"
    elsif @resource_type == "block"
      msg = "Using #{number_to_human_size(@total_usage * BLOCK_SIZE)} of quota #{number_to_human_size(@limit * BLOCK_SIZE)}"
      return msg unless self.shared?
      return msg + " (#{number_to_human_size(@user_usage * BLOCK_SIZE)} are yours)"
    end
  end

end
