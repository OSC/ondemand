# frozen_string_literal: true

# This attribute provides a quick shortcut to hide vnc resolution
# Like bc_vnc_resolution, this is only used with ENABLE_NATIVE_VNC=true
module SmartAttributes
  class AttributeFactory
    # Build this attribute object with defined options
    # @param opts [Hash] attribute's options
    # @return [Attributes::BCVncResolution] the attribute object
    def self.build_bc_hide_resolution(opts = {})
      static_opts = {
        html_options: {
          data:{
            'hide-bc-vnc-resolution-when-un-checked' => true
          }.merge(opts.dig(:html_options, :data).to_h)
        }.merge(opts.dig(:html_options).to_h.without(:data))
      }.merge(opts.without(:html_options).to_h)
      Attributes::BcHideResolution.new('bc_hide_resolution', static_opts)
    end
  end

  module Attributes
    class BcHideResolution < Attribute
      # Type of form widget used for this attribute
      # @return [String] widget type
      def widget
        'check_box'
      end

      # Form label for this attribute
      # @param fmt [String, nil] formatting of form label
      # @return [String] form label
      def label(fmt: nil)
        (opts[:label] || 'Use native VNC client').to_s
      end
    end
  end
end