class SystemStatusController < ApplicationController
  def index
    #TODO: Actually query clusters with ood-core gem
    @clusters = %w[ownes pitzer ascend]
  end
end
