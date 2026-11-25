module SmartAttributes
  class AttributeFactory
    # Build this attribute object with defined options
    # @param opts [Hash] attribute's options
    # @return [Attributes::BCVncIdle] the attribute object
    def self.build_bc_vnc_idle(opts = {})
      Attributes::BcVncIdle.new("bc_vnc_idle", opts)
    end
  end

  module Attributes
    class BcVncIdle < Attribute
      # Value of attribute
      # @return [String] attribute value
      def value
        (opts[:value] || "0").to_s
      end

      # Type of form widget used for this attribute
      # @return [String] widget type
      def widget
        "number_field"
      end

      # Form label for this attribute
      # @param fmt [String, nil] formatting of form label
      # @return [String] form label
      def label(fmt: nil)
        (opts[:label] || I18n.t('dashboard.smart_attributes.vnc_idle_label')).to_s
      end

      # Help text for this attribute
      # @param fmt [String, nil] formatting of help text
      # @return [String] help text
      def help(fmt: nil)
        (opts[:help] || I18n.t('dashboard.smart_attributes.vnc_idle_help')).to_s
      end

      # Submission hash describing how to submit this attribute
      # @param fmt [String, nil] formatting of hash
      # @return [Hash] submission hash
      def submit(fmt: nil)
        { batch_connect: { idle: value.blank? ? 0 : value.to_i } }
      end
    end
  end
end
