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
      queues_per_cluster.map do |cluster, cluster_queues|
        other_clusters = queues_per_cluster.reject do |c, _queues|
          c == cluster
        end.map do |c, _queues|
          c.to_s
        end

        cluster_data = other_clusters.map do |other_cluster|
          [
            ["data-option-for-cluster-#{other_cluster}", false],
            ["data-option-for-auto-batch-clusters-#{other_cluster}", false]
          ]
        end.flatten(1).to_h

        cluster_queues.map do |queue|
          unless blocked_queue?(queue)
            data = cluster_data.merge(queue_account_data(queue))
            [queue.name, queue.name, data]
          end
        end.compact
      end.flatten(1).sort_by do |tuple|
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
      qos_tuples = accounts.map do |account|
        account.qos.map do |qos|
          [account.name, account.cluster, qos]
        end
      end.flatten(1).group_by { |tuple| tuple[2] }

      clusters = Configuration.job_clusters.map { |c| c.id.to_s }

      unique_qos_names.map do |qos|
        data = {}
        account_tuples = qos_tuples[qos]

        available_clusters = account_tuples.map { |tuple| tuple[1] }.uniq
        unavailable_clusters = clusters.reject { |c| available_clusters.include?(c) }

        unavailable_clusters.each do |cluster|
          data["data-option-for-cluster-#{cluster}"] = false
        end

        available_accounts = account_tuples.map { |tuple| tuple[0] }.uniq
        unavailable_accounts = account_names.reject { |c| available_accounts.include?(c) }
        account_data = disabled_account_data(unavailable_accounts)

        [qos, qos, data.merge(account_data)]
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

  def queues_per_cluster
    Rails.cache.fetch('queues_per_cluster', expires_in: 24.hours) do
      {}.tap do |hash|
        Configuration.job_clusters.each do |cluster|
          hash[cluster.id] = cluster.job_adapter.queues
        end
      end
    end
  end

  def queue_account_data(queue)
    unavailable_accounts = account_names.reject do |account| 
      account_allowed?(queue, account)
    end
    disabled_account_data(unavailable_accounts)
  end

  def account_allowed?(queue, account_name)
    return false if queue.deny_accounts.any? { |account| account == account_name }

    if queue.allow_accounts.nil?
      true
    else
      queue.allow_accounts.any? { |account| account == account_name }
    end
  end

  def disabled_account_data(disabled_accounts)
    counter = 0
    disabled_accounts.map do |account|
      counter += 1
      # check if account contains anything other than digits and lowercase letters
      if !!(account =~ /\A[a-z0-9]+\z/)
        [["data-option-for-auto-accounts-#{account}", false]] 
      else
        acct_alias = "account#{counter}"
        [
          ["data-alias-#{acct_alias}", account],
          ["data-option-for-auto-accounts-#{acct_alias}", false]
        ]
      end
    end.flatten(1).compact.to_h
  end
end
