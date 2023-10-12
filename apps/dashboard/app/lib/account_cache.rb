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
    rescue StandardError => e
      Rails.logger.warn("Did not get accounts from system with error #{e}")
      Rails.logger.warn(e.backtrace.join("\n"))
      []
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
      job_cluster_names = Configuration.job_clusters
                                       .map(&:id)
                                       .map(&:to_s)

      accounts.group_by(&:name).map do |account_name, grouped_accounts|
        valid_clusters = grouped_accounts.map(&:cluster)
        invalid_clusters = job_cluster_names - valid_clusters

        data = invalid_clusters.map do |invalid_cluster|
          ["data-option-for-cluster-#{invalid_cluster}", false]
        end.compact.to_h

        [account_name, account_name, data]
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
      end.sort_by do |tuple|
        tuple[0]
      end
    rescue StandardError => e
      Rails.logger.warn("Did not get queues from system with error #{e}")
      Rails.logger.warn(e.backtrace.join("\n"))
      []
    end
  end

  def dynamic_qos
    Rails.cache.fetch('dynamic_qos', expires_in: 4.hours) do
      accounts.map do |account|
        account.qos.map do |qos|
          [account.name, account.cluster, qos]
        end
      end.flatten(1).map do |tuple|
        other_accounts = account_names.reject { |acct| acct == tuple[0] }
        other_clusters = Configuration.job_clusters.reject { |c| c.id.to_s == tuple[1] }

        data = {}.tap do |hash|
          other_clusters.each do |cluster|
            hash["data-option-for-cluster-#{cluster.id}"] = false
          end

          other_accounts.each do |account|
            hash["data-option-for-auto-accounts-#{account}"] = false
          end
        end

        [
          tuple[2], tuple[2], data
        ]
      end
    end
  end

  private

  def unique_qos_names
    [].tap do |arr|
      accounts.each do |acct|
        arr << acct.qos
      end
    end.flatten.uniq
  end

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
    Rails.cache.fetch('queues_per_cluster', expires_in: 24.hours) do
      {}.tap do |hash|
        Configuration.job_clusters.each do |cluster|
          hash[cluster.id] = cluster.job_adapter.queues
        end
      end
    end
  end
end
