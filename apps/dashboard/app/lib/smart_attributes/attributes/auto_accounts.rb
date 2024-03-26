# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    extend AccountCache

    # Build this attribute object. No 'options' are used as this Attribute
    # is meant to be dynamically generated from the users' available accounts
    # from a given scheduler.
    #
    # @param opts [Hash] attribute's options
    # @return [Attributes::AutoAccounts] the attribute object
    def self.build_auto_accounts(opts = {})
      options = if Configuration.bc_simple_auto_accounts?
                  account_names
                elsif Configuration.bc_dynamic_js?
                  dynamic_accounts
                else
                  account_names
                end

      static_opts = {
        options: options,
        value:   default_value(opts, scalar_accounts(options))
      }.merge(opts.without(:options, :value).to_h)

      Attributes::AutoAccounts.new('auto_accounts', static_opts)
    end

    # dynamic accounts are in the form [acct, acct, {}]. so cast these
    # arrays to scalar strings if applicable.
    def self.scalar_accounts(account_list)
      account_list.map do |account|
        account.is_a?(Array) ? account.first : account
      end
    end

    # try to find which default account value to use given
    # all the input options and the actual users' account list.
    def self.default_value(input_options, account_list)
      Rails.logger.debug("input: #{input_options.inspect} & #{account_list.inspect}")
      input_value = input_options[:value].to_s
      exclude_list = input_options[:exclude_options].to_a
      available_accounts = account_list - exclude_list

      if account_list.include?(input_value)
        input_value
      elsif !available_accounts.empty?
        available_accounts.first
      else
        account_list.first
      end
    end
  end

  module Attributes
    class AutoAccounts < Attribute
      def widget
        'select'
      end

      def label(*)
        (opts[:label] || 'Account').to_s
      end

      # Submission hash describing how to submit this attribute
      # @param fmt [String, nil] formatting of hash
      # @return [Hash] submission hash
      def submit(*)
        { script: { accounting_id: value } }
      end
    end
  end
end
