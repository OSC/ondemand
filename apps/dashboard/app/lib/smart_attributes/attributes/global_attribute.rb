# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    # Build this attribute object with defined options
    # @param opts [Hash] attribute's options
    # @return [Attributes::GlobalAttribute] the attribute object
    def self.build_global_attribute(opts = {})
      id = opts.delete('key').to_s

      config = Configuration.global_bc_form_item(id)

      # this behaves like a normal Attribute if there's no actual configuration for it.
      config = opts if config.nil? || config.empty?
      Attributes::GlobalAttribute.new(id, config)
    end
  end

  module Attributes
    class GlobalAttribute < Attribute
    end
  end
end
