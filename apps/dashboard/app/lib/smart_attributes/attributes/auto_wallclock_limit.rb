# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    def self.build_auto_wallclock_limit(opts = {})
      Attributes::AutoWallclockLimit.new('auto_wallclock_limit', opts)
    end
  end

  module Attributes
    class AutoWallclockLimit < Attribute
      def initialize(id, opts)
        super(id, opts)
        @opts = @opts.reverse_merge(min: 1, step: 1)
      end

      def value
        (opts[:value] || '1').to_s
      end

      def widget
        'number_field'
      end

      def label(fmt: nil)
        (opts[:label] || 'Walltime Limit').to_s
      end

      def required
        true
      end

      def submit(fmt: nil)
        { script: { wall_time: (value.blank? ? 1 : value.to_i) * 3600 } }
      end
    end
  end
end
