class TransfersController < ApplicationController
  # before_action only: [:show, :destroy] do
  #   request.format = :json
  # end

  # TODO: mv create here
  # then expand the interface for multiple strategies
  # 2 controllers, 1 model?
  #
  def index
    @transfers = TransferLocalJob.progress.values

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @transfer = TransferLocalJob.progress[params[:id]]
    if(@transfer)
      render json: @transfer
    else
      render json: {}, status: 404
    end
  end

  def destroy
    TransferLocalJob.cancel(params[:id])
  rescue StandardError => e
    render json: { error: e.message }, status: 500
  end
end
