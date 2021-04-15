class TransferLocalJob < ApplicationJob
  queue_as :default

  def perform(transfer)
    if transfer
      transfer.perform
    else
      raise "TransferLocalJobError: transfer not found"
    end
  end
end
