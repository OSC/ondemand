# frozen_string_literal: true

module SmartAttributes
  class AttributeFactory
    extend AccountCache

    # Build this attribute object. No 'options' are used as this Attribute
    # is meant to be dynamically generated from the Slurm reservations
    # the user is allowed to use.
    #
    # @param opts [Hash] attribute's options
    # @return [Attributes::AutoReservations] the attribute object
    def self.build_auto_reservations(opts = {})
      static_opts = {
        options: [['None', '']] + dynamic_reservations
      }.merge(opts.without(:options).to_h)

      Attributes::AutoReservations.new('auto_reservations', static_opts)
    end
  end

  module Attributes
    class AutoReservations < Attribute
      def widget
        'select'
      end

      def label(*)
        (opts[:label] || 'Reservation').to_s
      end

      # Submission hash describing how to submit this attribute.
      # An empty value submits the job without a reservation.
      # @param fmt [String, nil] formatting of hash
      # @return [Hash] submission hash
      def submit(*)
        return { script: {} } if value.blank?

        { script: { reservation_id: value } }
      end
    end
  end
end
