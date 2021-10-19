# frozen_string_literal: true

# bootstrap all the kuberenetes clusters if there are any
OodAppkit.clusters.select(&:kubernetes?).each do |cluster|
  require 'ood_core/job/adapters/kubernetes'
  require 'ood_core/job/adapters/kubernetes/batch'

  OodCore::Job::Adapters::Kubernetes::Batch.configure_kube!(cluster.job_config)
rescue StandardError, LoadError => e
  Rails.logger.error("could not initialize k8s cluster #{cluster.id} because of error '#{e.message}'")
end
