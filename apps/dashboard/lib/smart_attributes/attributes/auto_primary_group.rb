module SmartAttributes
  class AttributeFactory
    # Build this attribute object. No options are used as this Attribute
    # is meant to be dynamically generated from the users' primary group
    # @param opts [Hash] attribute's options
    # @return [Attributes::BCAccount] the attribute object
    def self.build_auto_primary_group(opts = {})
      static_opts = { 
          fixed: true,
          value: CurrentUser.primary_group
        }
      Attributes::AutoPrimaryGroup.new("auto_primary_group", static_opts) 
    end
  end

  module Attributes
    class AutoPrimaryGroup < Attribute

      # Submission hash describing how to submit this attribute
      # @param fmt [String, nil] formatting of hash
      # @return [Hash] submission hash
      def submit(fmt: nil)
        { script: { accounting_id: value } }
      end
    end
  end
end
