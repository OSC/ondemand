# frozen_string_literal: true

require 'rclone_util'

# The controller for transfer pages /dashboard/transfers
class TransfersController < ApplicationController
  def show
    @transfer = Transfer.find(params[:id])
    if @transfer
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

    from_fs = body_params.fetch(:from_fs, RcloneUtil::LOCAL_FS_NAME)
    to_fs = body_params.fetch(:to_fs, RcloneUtil::LOCAL_FS_NAME)

    if from_fs == RcloneUtil::LOCAL_FS_NAME && to_fs == RcloneUtil::LOCAL_FS_NAME
      @transfer = PosixTransfer.build(action: body_params[:command], files: body_params[:files])
    elsif ::Configuration.remote_files_enabled?
      @transfer = RemoteTransfer.build(action: body_params[:command], files: body_params[:files], src_remote: from_fs,
                                       dest_remote: to_fs)
    else
      render json: { error_message: 'Remote file support is not enabled' }
    end

    if !@transfer.valid?
      # error
      render json: { error_message: @transfer.errors.full_messages.join('. ') }
    elsif @transfer.synchronous?
      logger.info "files: executing synchronous commmand in directory #{@transfer.from}: #{@transfer.command_str}"
      @transfer.perform

      respond_to do |format|
        format.json { render :show }
      end
    else
      logger.info "files: initiating asynchronous commmand in directory #{@transfer.from}: #{@transfer.command_str}"
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
