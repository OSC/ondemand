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
    Rails.cache.fetch('account_names', expires_in: 4.hours) do
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

  # To be used with dynamic forms. This method stithes together data
  # about the queue's availablity WRT clusters.
  #
  # @return [Array] - the dynamic form options
  def queues
    Rails.cache.fetch('queues', expires_in: 4.hours) do
      unique_queue_names.map do |queue_name|
        data = {}
        queues_per_cluster.each do |cluster, cluster_queues|
          cluster_queue_names = cluster_queues.map(&:to_s)
          queue_info = cluster_queues.find { |q| q.name == queue_name }

          # if the queue doesn't exist on the cluster OR you're not allowed to use the queue
          if !cluster_queue_names.include?(queue_name) || blocked_queue?(queue_info)
            data["data-option-for-cluster-#{cluster}"] = false
          end
        end

        [queue_name, queue_name, data]
      end
    end
  end

  private

  # do you have _any_ account that can submit to this queue?
  def blocked_queue?(queue)
    allow_accounts = queue.allow_accounts

    if allow_accounts.nil?
      false
    else
      allow_accounts.intersection(account_names).empty?
    end
  end

  def unique_queue_names
    [].tap do |queues|
      queues_per_cluster.map do |_, cluster_queues|
        queues << cluster_queues.map(&:to_s)
      end
    end.flatten.uniq
  end

  def queues_per_cluster
    {}.tap do |hash|
      Configuration.job_clusters.each do |cluster|
        hash[cluster.id] = cluster.job_adapter.queues
      end
    end
  end

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
