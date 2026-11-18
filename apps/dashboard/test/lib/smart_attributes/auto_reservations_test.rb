# frozen_string_literal: true

require 'test_helper'
require 'smart_attributes'

module SmartAttributes
  class AutoReservationsTest < ActiveSupport::TestCase
    def setup
      Rails.cache.clear
      CurrentUser.stubs(:name).returns('me')
      CurrentUser.stubs(:group_names).returns(['me', 'staff'])
      SmartAttributes::AttributeFactory.stubs(:accounts).returns(accounts)
      Configuration.stubs(:job_clusters).returns([
                                                   cluster(:owens, owens_reservations),
                                                   cluster(:oakley, [reservation('workshop', 'oakley', allow_users: ['me'])])
                                                 ])
    end

    def cluster(id, reservations)
      stub(id: id, job_adapter: stub(reservations: reservations))
    end

    def reservation(name, cluster, **opts)
      OodCore::Job::ReservationInfo.new(name: name, cluster: cluster, **opts)
    end

    def accounts
      [
        OodCore::Job::AccountInfo.new(name: 'pzs1124', cluster: 'owens'),
        OodCore::Job::AccountInfo.new(name: 'pzs1118', cluster: 'owens'),
        OodCore::Job::AccountInfo.new(name: 'pzs1117', cluster: 'owens'),
        OodCore::Job::AccountInfo.new(name: 'pzs1124', cluster: 'oakley')
      ]
    end

    def owens_reservations
      [
        reservation('workshop', 'owens', allow_accounts: ['pzs1124', 'pzs1118']),
        reservation('me_only', 'owens', allow_users: ['me']),
        reservation('someone_else', 'owens', allow_users: ['alice', 'bob']),
        reservation('everyone_but_me', 'owens', deny_users: ['me', 'alice']),
        reservation('my_group', 'owens', allow_groups: ['staff']),
        reservation('other_group', 'owens', allow_groups: ['sysp']),
        reservation('other_accounts', 'owens', allow_accounts: ['pas9999']),
        reservation('not_pzs1124', 'owens', deny_accounts: ['pzs1124'])
      ]
    end

    def build(opts = {})
      SmartAttributes::AttributeFactory.build('auto_reservations', opts)
    end

    def option_data(choices, name, cluster)
      other_cluster = cluster == 'owens' ? 'oakley' : 'owens'
      choices.find do |choice|
        choice.first == name && choice.last["data-option-for-cluster-#{other_cluster}"] == false
      end.last
    end

    test 'only shows reservations the user can use' do
      names = build.select_choices.map(&:first)

      assert_equal(['None', 'me_only', 'my_group', 'not_pzs1124', 'workshop', 'workshop'], names)
    end

    test 'defaults to no reservation' do
      attribute = build

      assert_equal('select', attribute.widget)
      assert_equal('Reservation', attribute.label)
      assert_equal(['None', ''], attribute.select_choices.first)
      assert_equal('', attribute.value)
      assert_equal({ script: {} }, attribute.submit)
    end

    test 'submits the reservation_id' do
      attribute = build(value: 'workshop')

      assert_equal({ script: { reservation_id: 'workshop' } }, attribute.submit)
    end

    test 'reservations are hidden on other clusters' do
      choices = build.select_choices
      owens = option_data(choices, 'workshop', 'owens')
      oakley = option_data(choices, 'workshop', 'oakley')

      assert_not(owens.key?('data-option-for-cluster-owens'))
      assert_equal(false, owens['data-option-for-auto-batch-clusters-oakley'])
      assert_not(oakley.key?('data-option-for-cluster-oakley'))
      assert_equal(false, oakley['data-option-for-auto-batch-clusters-owens'])
    end

    test 'reservations are hidden for accounts they do not allow' do
      choices = build.select_choices

      workshop = option_data(choices, 'workshop', 'owens')
      assert_not(workshop.key?('data-option-for-auto-accounts-pzs1124'))
      assert_not(workshop.key?('data-option-for-auto-accounts-pzs1118'))
      assert_equal(false, workshop['data-option-for-auto-accounts-pzs1117'])

      not_pzs1124 = option_data(choices, 'not_pzs1124', 'owens')
      assert_equal(false, not_pzs1124['data-option-for-auto-accounts-pzs1124'])
      assert_not(not_pzs1124.key?('data-option-for-auto-accounts-pzs1118'))

      me_only = option_data(choices, 'me_only', 'owens')
      assert(me_only.keys.none? { |key| key.start_with?('data-option-for-auto-accounts') })
    end

    test 'shows reservations limited to accounts when the accounts are unknown' do
      SmartAttributes::AttributeFactory.stubs(:accounts).returns([])

      assert_includes(build.select_choices.map(&:first), 'other_accounts')
    end

    test 'only shows None when reservations cannot be read' do
      broken = stub(id: :owens)
      broken.stubs(:job_adapter).raises(StandardError, 'scontrol: error')
      Configuration.stubs(:job_clusters).returns([broken])

      assert_equal([['None', '']], build.select_choices)
    end
  end
end
