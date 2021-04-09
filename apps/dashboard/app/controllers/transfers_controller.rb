class TransfersController < ApplicationController

  def show
    @transfer = Transfer.find(params[:id])
    if(@transfer)
      respond_to do |format|
        format.html
        format.json
      end
    else
      respond_to do |format|
        format.html
        format.json { render json: {}, status: 404 }
      end
    end
  end

  def create
    body_params = JSON.parse(request.body.read).symbolize_keys
    @transfer = Transfer.build(action: body_params[:command], files: body_params[:files])
    if ! @transfer.valid?
      # error
      render json: { error_message: @transfer.errors.full_messages.join('. ') }
    elsif @transfer.synchronous?
      @transfer.perform

      respond_to do |format|
        format.json { render :show }
      end
    else
      @transfer.perform_later

      respond_to do |format|
        format.json { render :show }
      end
    end
  end

  def destroy
    TransferLocalJob.cancel(params[:id])
  rescue StandardError => e
    render json: { error: e.message }, status: 500
  end
end
