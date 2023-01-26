# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    # Build this attribute object. No options are used as this Attribute
    # is meant to be dynamically generated from the users' unix groups
    # @param opts [Hash] attribute's options
    # @return [Attributes::AutoGroups] the attribute object
    def self.build_auto_groups(opts = {})
      options = begin
        CurrentUser.group_names.grep(/#{Configuration.auto_groups_filter}/)
      rescue RegexpError => e
        Rails.logger.warn("auto_groups_filter does not compile, throwing this error: #{e}")
        []
      end

      static_opts = {
        options: options
      }.merge(opts.without(:options).to_h)

      Attributes::AutoGroups.new('auto_groups', static_opts)
    end
  end

  module Attributes
    class AutoGroups < Attribute
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
