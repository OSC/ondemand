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
        options: options
      }.merge(opts.without(:options).to_h)

      Attributes::AutoAccounts.new('auto_accounts', static_opts)
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
