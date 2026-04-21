# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    # Build this attribute object with defined options
    # @param opts [Hash] attribute's options
    # @return [Attributes::BCVncResolution] the attribute object
    def self.build_bc_vnc_resolution(opts = {})
      Attributes::BcVncResolution.new('bc_vnc_resolution', opts)
    end
  end

  module Attributes
    class BcVncResolution < Attribute
      # Type of form widget used for this attribute
      # @return [String] widget type
      def widget
        'resolution_field'
      end

      # Form label for this attribute
      # @param fmt [String, nil] formatting of form label
      # @return [String] form label
      def label(fmt: nil)
        return opts[:label].to_s if opts.key?(:label)

        I18n.t('dashboard.smart_attributes.labels.bc_vnc_resolution', default: 'Resolution').to_s
      end

      def help(fmt: nil)
        return opts[:help].to_s if opts.key?(:help)

        I18n.t(
          'dashboard.smart_attributes.helps.bc_vnc_resolution',
          default: 'Resolution is only used by native VNC connections'
        ).to_s
      end

      # Submission hash describing how to submit this attribute
      # @param fmt [String, nil] formatting of hash
      # @return [Hash] submission hash
      def submit(fmt: nil)
        { batch_connect: { geometry: value.blank? ? '800x600' : value.strip } }
      end
    end
  end
end
