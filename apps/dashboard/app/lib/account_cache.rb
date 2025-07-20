# frozen_string_literal: true

# AccountCache is a simple module that caches complex operations
# that stitch together accounts and other attributes like queues
# and QoS'.
module AccountCache
  # Get all the accounts for the current user.
  #
  # @return [Hash<String, Array<AccountInfo>>] - the account info objects organized by cluster name
  def accounts_per_cluster
    Rails.cache.fetch('accounts_per_cluster', expires_in: 4.hours) do
      {}.tap do |hash|
        Configuration.job_clusters.each do |cluster|
          if cluster.job_adapter.respond_to?(:accounts) then
            hash[cluster.id.to_s] = cluster.job_adapter.accounts
          end
        end
      end
    rescue StandardError => e
      Rails.logger.warn("Did not get accounts from system with error #{e}")
      Rails.logger.warn(e.backtrace.join("\n"))
      {}
    end
  end

  # Get a unique list of account names for the current user.
  #
  # @return [Array<String>] - the unique list of accounts
  def account_names
    Rails.cache.fetch('account_names', expires_in: 4.hours) do
      cluster_names_per_account_name.keys
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

      cluster_names_per_account_name.map do |account_name, cluster_names|
        invalid_clusters = job_cluster_names - cluster_names
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
      qos_tuples = accounts_per_cluster.flat_map do |cluster_name, accounts|
        accounts.flat_map do |account|
          account.qos.map do |qos|
            [account.name, cluster_name, qos]
          end
        end
      end.group_by { |tuple| tuple[2] }

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

        unavailable_accounts.each do |account|
          data["data-option-for-auto-accounts-#{account}"] = false
        end

        [qos, qos, data]
      end
    end
  end

  private

  def unique_qos_names
    accounts_per_cluster.values.map { |accounts| accounts.map(&:qos) }.flatten.uniq
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
          hash[cluster.id.to_s] = cluster.job_adapter.queues
        end
      end
    end
  end

  def cluster_names_per_account_name
    Rails.cache.fetch('cluster_names_per_account_name', expires_in: 4.hours) do
      {}.tap do |hash|
        accounts_per_cluster.each do |cluster_name, accounts|
          accounts.each do |account|
            hash[account.name] ||= []
            hash[account.name] << cluster_name
          end
        end
      end
    end
  end

  def queue_account_data(queue)
    account_names.map do |account|
      ["data-option-for-auto-accounts-#{account}", false] unless account_allowed?(queue, account)
    end.compact.to_h
  end

  def account_allowed?(queue, account_name)
    return false if queue.deny_accounts.any? { |account| account == account_name }

    if queue.allow_accounts.nil?
      true
    else
      queue.allow_accounts.any? { |account| account == account_name }
    end
  end
end
