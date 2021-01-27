class TransfersController < ApplicationController
  # before_action only: [:show, :destroy] do
  #   request.format = :json
  # end

  # TODO: mv create here
  # then expand the interface for multiple strategies
  # 2 controllers, 1 model?
  #
  def index
    @transfers = Transfer.transfers

    #FIXME: refactor
    # determine whether or not we need to reload the table view
    # if a transfer is completed AND to parent dir == current_directory
    @table_needs_reloaded = @transfers.any? {|t|
      # FIXME: better handled by a Transfer model

      if t.status.completed? && t.completed_at && t.completed_at >= params['current_directory_updated_at'].to_i
        if t.action == "rm"
          Pathname.new(t.from).cleanpath == Pathname.new(params['current_directory']).cleanpath
        else
          Pathname.new(t.to).cleanpath == Pathname.new(params['current_directory']).cleanpath
        end
      end
    }

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
