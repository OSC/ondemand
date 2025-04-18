# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    # Build this attribute object with defined options
    # @param opts [Hash] attribute's options
    # @return [Attributes::GlobalAttribute] the attribute object
    def self.build_global_attribute(opts = {})
      id = opts.delete('key').to_s
      sub_id = opts.delete('sub_id').to_s

      config = Configuration.global_bc_form_item(id)

      # this behaves like a normal Attribute if there's no actual configuration for it,
      # and you can override the global options if you have a 'attributes' defined.
      config = config.to_h.deep_merge(opts)

      # try to build a bc_ attribute if you can.
      if sub_id.start_with?('bc_')
        begin
          require_relative sub_id
          build_method = "build_#{sub_id}"
          return send(build_method, config) if respond_to?(build_method)
        rescue LoadError
          # just keep going if you can't load bc_doesnt_exist
        end
      end

      # can't build a bc_ attribute, so just build a generic global attribute
      Attributes::GlobalAttribute.new(id, config)
    end
  end

  module Attributes
    class GlobalAttribute < Attribute
    end
  end
end
