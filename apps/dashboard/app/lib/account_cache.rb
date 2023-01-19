# frozen_string_literal: true

# AccountCache is a simple module that caches complex operations
# that stitch together accounts and other attributes like queues
# and QoS'.
module AccountCache
  # Get all the accounts for the current user.
  #
  # @return [Array<AccountInfo>] - the account info objects
  def accounts
    Rails.cache.fetch('account_info', expires_in: 4.hours) do

      # only Slurm support in ood_core
      cluster = Configuration.job_clusters.select(&:slurm?).first
      cluster.nil? ? [] : cluster.job_adapter.accounts
    end
  end

  # Get a unique list of account names for the current user.
  #
  # @return [Array<String>] - the unique list of accounts
  def account_names
    Rails.cache.fetch('account_info', expires_in: 4.hours) do
      accounts.map(&:to_s).uniq
    end
  end

  # To be used with dynamic forms. This method stithes together data
  # about the account's availablity WRT clusters, queues & QoS'.
  #
  # @return [Array] - the dynamic form options
  def dynamic_accounts
    # raise StandardError, accounts.inspect
    Rails.cache.fetch('dynamic_account_info', expires_in: 4.hours) do
      accounts.map do |account|
        [account.name, account.name, data_for_account(account)]
      end
    end
  end

  private

  def data_for_account(account)
    data_for_clusters(account)
  end

  def data_for_clusters(account)
    Configuration.job_clusters.map do |cluster|
      cluster_name = cluster.id.to_s
      next if cluster_name == account.cluster

      ["data-option-for-cluster-#{cluster_name}", false]
    end.compact.to_h
  end
end
