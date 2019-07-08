module SmartAttributes
  class AttributeFactory
    # Build this attribute object with defined options
    # @param opts [Hash] attribute's options
    # @return [Attributes::BCAccount] the attribute object
    def self.build_bc_account(opts = {})
      Attributes::BCAccount.new("bc_account", opts)
    end
  end

  module Attributes
    class BCAccount < Attribute
      # Type of form widget used for this attribute
      # @return [String] widget type
      def widget
        "text_field"
      end

      # Form label for this attribute
      # @param fmt [String, nil] formatting of form label
      # @return [String] form label
      def label(fmt: nil)
        (opts[:label] || "Account").to_s
      end

      # Submission hash describing how to submit this attribute
      # @param fmt [String, nil] formatting of hash
      # @return [Hash] submission hash
      def submit(fmt: nil)
        { script: { accounting_id: value.blank? ? nil : value.strip } }
      end
    end
  end
end
