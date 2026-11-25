# frozen_string_literal: true

require 'test_helper'
require 'smart_attributes'

module SmartAttributes
  class SmartAttributesI18nTest < ActiveSupport::TestCase
    test 'smart attributes translate default labels and help by locale while preserving custom overrides' do
      attrs = {
        account:              Attributes::AutoAccounts.new('auto_accounts', {}),
        batch_clusters:       Attributes::AutoBatchClusters.new('auto_batch_clusters', {}),
        cores:                Attributes::AutoCores.new('auto_cores', {}),
        env_var:              Attributes::AutoEnvironmentVariable.new('auto_environment_variable', { key: 'FOO' }),
        groups:               Attributes::AutoGroups.new('auto_groups', {}),
        job_name:             Attributes::AutoJobName.new('auto_job_name', {}),
        modules_none:         Attributes::AutoModules.new('auto_modules', {}),
        modules_r:            Attributes::AutoModules.new('auto_modules', { module: 'python' }),
        qos:                  Attributes::AutoQos.new('auto_qos', {}),
        queues:               Attributes::AutoQueues.new('auto_queues', {}),
        scripts:              Attributes::AutoScripts.new('auto_scripts', {}),
        bc_account:           Attributes::BcAccount.new('bc_account', {}),
        bc_email:             Attributes::BcEmailOnStarted.new('bc_email_on_started', {}),
        bc_hours:             Attributes::BcNumHours.new('bc_num_hours', {}),
        bc_nodes:             Attributes::BcNumNodes.new('bc_num_nodes', {}),
        bc_slots:             Attributes::BcNumSlots.new('bc_num_slots', {}),
        bc_queue:             Attributes::BcQueue.new('bc_queue', {}),
        bc_vnc_idle:          Attributes::BcVncIdle.new('bc_vnc_idle', {}),
        bc_vnc_resolution:    Attributes::BcVncResolution.new('bc_vnc_resolution', {})
      }

      I18n.with_locale(:en) do
        assert_equal 'Account', attrs[:account].label
        assert_equal 'Cluster', attrs[:batch_clusters].label
        assert_equal 'Cores', attrs[:cores].label
        assert_equal 'Environment Variable: FOO', attrs[:env_var].label
        assert_equal 'Environment Variable', attrs[:env_var].original_label
        assert_equal 'Account', attrs[:groups].label
        assert_equal 'Job Name', attrs[:job_name].label
        assert_equal 'Auto modules (none given)', attrs[:modules_none].label
        assert_equal 'Python version', attrs[:modules_r].label
        assert_equal 'QoS', attrs[:qos].label
        assert_equal 'Queue', attrs[:queues].label
        assert_equal 'Partition', attrs[:queues].label(fmt: 'slurm')
        assert_equal 'Script', attrs[:scripts].label
        assert_equal 'Account', attrs[:bc_account].label
        assert_equal 'I would like to receive an email when the session starts', attrs[:bc_email].label
        assert_equal 'Number of hours', attrs[:bc_hours].label
        assert_equal 'Number of nodes', attrs[:bc_nodes].label
        assert_equal 'Number of nodes', attrs[:bc_slots].label
        assert_equal 'Number of processors', attrs[:bc_slots].label(fmt: 'lsf')
        assert_equal 'Number of CPUs on single node', attrs[:bc_slots].label(fmt: 'pbspro')
        assert_equal 'Queue', attrs[:bc_queue].label
        assert_equal 'Partition', attrs[:bc_queue].label(fmt: 'slurm')
        assert_equal 'Idle timeout', attrs[:bc_vnc_idle].label
        assert_equal 'Exit if # seconds elapse with no VNC viewer connections', attrs[:bc_vnc_idle].help
        assert_equal 'Resolution', attrs[:bc_vnc_resolution].label
        assert_equal 'Resolution is only used by native VNC connections', attrs[:bc_vnc_resolution].help
      end

      I18n.with_locale(:'fr-CA') do
        assert_equal 'Compte', attrs[:account].label
        assert_equal 'Grappe', attrs[:batch_clusters].label
        assert_equal 'Cœurs', attrs[:cores].label
        assert_equal "Variable d'environnement : FOO", attrs[:env_var].label
        assert_equal "Variable d'environnement", attrs[:env_var].original_label
        assert_equal 'Compte', attrs[:groups].label
        assert_equal 'Nom de la tâche', attrs[:job_name].label
        assert_equal 'Modules automatiques (aucun indiqué)', attrs[:modules_none].label
        assert_equal 'Version de Python', attrs[:modules_r].label
        assert_equal 'QoS', attrs[:qos].label
        assert_equal "File d'attente", attrs[:queues].label
        assert_equal 'Partition', attrs[:queues].label(fmt: 'slurm')
        assert_equal 'Script', attrs[:scripts].label
        assert_equal 'Compte', attrs[:bc_account].label
        assert_equal 'Je souhaite recevoir un courriel lorsque la session démarre', attrs[:bc_email].label
        assert_equal "Nombre d'heures", attrs[:bc_hours].label
        assert_equal 'Nombre de nœuds', attrs[:bc_nodes].label
        assert_equal 'Nombre de nœuds', attrs[:bc_slots].label
        assert_equal 'Nombre de processeurs', attrs[:bc_slots].label(fmt: 'lsf')
        assert_equal 'Nombre de processeurs sur un seul nœud', attrs[:bc_slots].label(fmt: 'pbspro')
        assert_equal "File d'attente", attrs[:bc_queue].label
        assert_equal 'Partition', attrs[:bc_queue].label(fmt: 'slurm')
        assert_equal "Délai d'inactivité", attrs[:bc_vnc_idle].label
        assert_equal "Quitter si ce nombre de secondes s'écoule sans connexion au visualiseur VNC", attrs[:bc_vnc_idle].help
        assert_equal 'Résolution', attrs[:bc_vnc_resolution].label
        assert_equal 'La résolution est uniquement utilisée par les connexions VNC natives', attrs[:bc_vnc_resolution].help
      end

      custom = Attributes::BcVncResolution.new('bc_vnc_resolution', { label: 'Custom Res', help: 'Custom Help' })
      I18n.with_locale(:'fr-CA') do
        assert_equal 'Custom Res', custom.label
        assert_equal 'Custom Help', custom.help
      end
    end
  end
end
