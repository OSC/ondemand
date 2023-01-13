# frozen_string_literal: true

# Job class for local file transfers.
class TransferLocalJob < ApplicationJob
  queue_as :default

  def perform(transfer)
    if transfer
      transfer.perform
    else
      raise StandardError, 'TransferLocalJobError: transfer not found'
    end
  end
end
