require 'open-uri'

# This describes file or project balances for a given user.
class Balance
  extend UriReader

  class InvalidBalanceFile < StandardError; end

  attr_reader :user, :project, :value, :project_type, :unit, :updated_at

  class << self

    # Get balance objects only for requested user in JSON file(s)
    #
    # KeyError and JSON::ParserErrors shall be non-fatal errors
    def find(balance_path, user)
      raw = read_uri(balance_path)

      raise InvalidBalanceFile.new("No content returned when attempting to read balance file") if raw.nil? || raw.empty?

      # Attempt to parse raw JSON into an object
      json = JSON.parse(raw)
      raise InvalidBalanceFile.new("Balance file expected to be a JSON object with balances array section") unless json.is_a?(Hash) && json["balances"].respond_to?(:each)

      #FIXME: any validation of the structure here? otherwise we don't need the complexity of the code below
      # until we have more than one balance version schema, which we do not
      # so assume version is 1
      config = json["config"] || {}
      build_balances(json["balances"], json["timestamp"], config, user)
    rescue StandardError => e
      Rails.logger.error("Error #{e.class} when reading and parsing balance file #{balance_path} for user #{user}: #{e.message}")
      []
    end

    private

    # Parse JSON object using version 1 formatting
    def build_balances(balance_hashes, updated_at, config, user)
      balances = []
      balance_hashes.each do |balance|
        balance = balance.to_h.compact.symbolize_keys
        config = config.to_h.compact.symbolize_keys
        next unless user == balance[:user]
        balances << Balance.new(
          user: balance.fetch(:user).to_s,
          project: balance.fetch(:project, nil).to_s,
          value: balance.fetch(:value).to_i,
          project_type: config.fetch(:project_type, nil).to_s,
          unit: config[:unit].to_s,
          updated_at: Time.at(updated_at.to_i),
        )
      end
      balances
    end
  end

  # @param params [#to_h] list of parameters that define balance object
  # @option params [#to_s] :user user name
  # @option params [#to_s] :project project name
  # @option params [#to_i] :value balance value
  # @option params [#to_s] :project_type project type
  # @option params [#to_s] :unit value unit
  # @option params [#to_i] :updated_at time when balance was generated
  def initialize(params)
    params = params.to_h.compact.symbolize_keys

    @user = params.fetch(:user).to_s
    @project = params.fetch(:project, nil).to_s
    @value = params.fetch(:value).to_i
    @project_type = params.fetch(:project_type, nil).to_s
    @unit = params.fetch(:unit).to_s
    @updated_at = Time.at(params.fetch(:updated_at).to_i)
  end

  def balance_object
    @project.presence || @user
  end

  # Unit + balance text
  def units_balance
    return "#{@unit} balance" if @unit.present?
    'Balance'
  end

  # Plural units
  def balanace_units
    return @unit.pluralize if @unit.present?
    'resources'
  end

  def sufficient?(threshold: 0)
    @value.to_f > threshold.to_f
  end

  def insufficient?(threshold: 0)
    !sufficient?(threshold: threshold)
  end

  def to_s
    I18n.translate('dashboard.balance_message', unit: @unit, units_balance: units_balance, value: @value)
  end
end
