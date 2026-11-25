# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    # Build this attribute object. No options are used as this Attribute
    # is meant to be dynamically generated
    # @param opts [Hash] attribute's options
    # @return [Attributes::AutoNumNodes] the attribute object
    def self.build_auto_num_nodes(opts = {})
      Attributes::AutoNumNodes.new('auto_num_nodes', opts)
    end
  end

  module Attributes
    # Version of bc_num_nodes whose min and max are set by other auto_ fields
    class AutoNumNodes < BcNumNodes
    end
  end
end
