class TransferLocalJob < ApplicationJob
  queue_as :default

  def perform(transfer)
    transfer.perform
  end
end
