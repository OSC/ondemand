# frozen_string_literal: true

# The controller for all the files pages /dashboard/files
class FilesController < ApplicationController
  include ActionController::Live
  include ActionView::Helpers::NumberHelper

  before_action :strip_sendfile_headers, only: [:fs, :directory_frame]

  def fs
    request.format = 'json' if request.headers['HTTP_ACCEPT'].split(',').include?('application/json')
    parse_path(fs_params[:filepath], fs_params[:fs])
    validate_path!

    if @path.directory?
      @path.raise_if_cant_access_directory_contents

      request.format = 'zip' if download?

      respond_to do |format|
        format.html do
          render :index
        end

        format.json do
          response.headers['Cache-Control'] = 'no-store'
          if fs_params[:can_download]
            # check to see if this directory can be downloaded as a zip
            can_download, error_message = if ::Configuration.download_enabled?
                                            @path.can_download_as_zip?
                                          else
                                            [false, t('dashboard.files_download_not_enabled')]
                                          end

            render json: { can_download: can_download, error_message: error_message }
          else
            @files = @path.ls
            render :index
          end
        end

        # FIXME: below is a large block that should be moved to a model
        # if moved to a model the exceptions can be handled there and
        # then this code will be simpler to read
        # and we can avoid rescuing in a block so we can reintroduce
        # the block braces which is the Rails convention with the respond_to formats.
        format.zip do
          can_download, error_message = if ::Configuration.download_enabled?
                                          @path.can_download_as_zip?
                                        else
                                          raise(StandardError, t('dashboard.files_download_not_enabled'))
                                        end

          if can_download
            zipname = "#{@path.basename}.zip"
            response.set_header 'Last-Modified', Time.now.httpdate
            response.sending_file = true
            response.cache_control[:public] ||= false

            zip_headers = ZipKit::OutputEnumerator.new.streaming_http_headers
            response.headers.merge!(zip_headers)

            send_stream(filename: zipname, disposition: 'attachment', type: :zip) do |stream|
              ZipKit::Streamer.open(stream) do |zip|
                @path.files_to_zip.each do |file|
                  next unless File.readable?(file.realpath)

                  if File.file?(file.realpath)
                    zip.write_deflated_file(file.relative_path.to_s) do |zip_file|
                      IO.copy_stream(file.realpath, zip_file)
                    end
                  else
                    zip.add_empty_directory(dirname: file.relative_path.to_s)
                  end
                rescue StandardError => e
                  logger.warn("error writing file #{file.path} to zip: #{e.message}")
                end
              end
            end
          else
            logger.warn "unable to download directory #{@path}: #{error_message}"
            response.set_header 'X-OOD-Failure-Reason', error_message
            head :internal_server_error
          end
        rescue StandardError => e
          # Third party API requests (from outside of OnDemand) will see this error
          # message if there's an error while downloading a directory.
          #
          # The client side code in the Files App performs checks before downloading
          # a directory with the ?can_download query parameter but other implementations
          # that don't perform this check will see HTTP 500 returned and the error
          # error message will be in the "X-OOD-Failure-Reason" header.
          #
          Rails.logger.warn "exception raised when attempting to download directory #{@path}: #{e.message}"
          response.set_header 'X-OOD-Failure-Reason', e.message
          head :internal_server_error
        end
      end
    else
      show_file
    end
  rescue StandardError => e
    rescue_action(e)
  end

  # GET - directory for turbo-frame
  def directory_frame
    parse_path(directory_frame_params[:path], 'fs')
    validate_path!
    @path.raise_if_cant_access_directory_contents
    @files = @path.ls

    render( partial: 'files/turbo_frames/directory',
            locals: { 
              path: @path,
              files: @files
            }
    )
  rescue StandardError => e
    rescue_action(e)
  end

  # PUT - create or update
  def update
    filepath = update_params[:filepath]
    fs = update_params[:fs]
    parse_path(filepath, fs)
    validate_path!

    dir = update_params[:dir] if update_params.include?(:dir)
    file = update_params[:file] if update_params.include?(:file)
    touch = update_params[:touch] if update_params.include?(:touch)

    if dir
      @path.mkdir
    elsif file
      @path.mv_from(file.tempfile)
    elsif touch
      @path.touch
    else
      content = request.body.read

      # forcing utf-8 because File.write seems to require it. request bodies are
      # in ASCII-8BIT and need to be re encoded otherwise errors are thrown.
      # see test cases for plain text, utf-8 text, images and binary files
      content.force_encoding('UTF-8')

      @path.write(content)
    end

    render json: {}
  rescue StandardError => e
    render json: { error_message: e.message }
  end

  # POST
  def upload
    file = upload_params[:file]
    fs = upload_params[:fs]
    @relative_path = upload_params[:relativePath]
    @parent = upload_params[:parent]
    @name = upload_params[:name]

    upload_path = uppy_upload_path

    parse_path(upload_path, fs)
    validate_path!

    # Need to remove the tempfile from list of Rack tempfiles to prevent it
    # being cleaned up once request completes since Rclone uses the files.
    request.env[Rack::RACK_TEMPFILES].reject! { |f| f.path == file.tempfile.path } unless posix_file?

    @transfer = @path.handle_upload(file.tempfile)


    if @transfer.kind_of?(Transfer)
      render 'transfers/show'
    else
      render json: {}
    end
  rescue AllowlistPolicy::Forbidden => e
    render json: { error_message: e.message }, status: :forbidden
  rescue Errno::EACCES => e
    render json: { error_message: e.message }, status: :forbidden
  rescue StandardError => e
    render json: { error_message: e.message }, status: :internal_server_error
  end

  def edit
    filepath = edit_params[:filepath]
    fs = edit_params[:fs]
    parse_path(filepath, fs)
    validate_path!

    if !@path.editable?
      redirect_back(fallback_location: root_path, alert: "#{@path} is not an editable file")
    elsif @path.size > ::Configuration.file_editor_max_size
      redirect_back(fallback_location: root_path, alert: "#{@path} exceeds editor limit of #{number_to_human_size(::Configuration.file_editor_max_size)}. Please download the file to edit or view it locally.")
    else
      @content = @path.read
      render :edit, status: status, layout: 'editor'
    end
  rescue StandardError => e
    redirect_back(fallback_location: root_path, alert: e.message)
  end

  private

  def rescue_action(exception)
    @files = []
    flash.now[:alert] = exception.message.to_s

    logger.error(exception.message)

    respond_to do |format|

      format.html do
        render :index
      end
      format.json do
        @files = []

        render :index
      end
    end
  end

  # set these headers to nil so that we (Rails) will read files
  # off of disk instead of nginx.
  def strip_sendfile_headers
    request.headers['HTTP_X_SENDFILE_TYPE'] = nil
    request.headers['HTTP_X_ACCEL_MAPPING'] = nil
  end

  def normalized_path(path)
    Pathname.new("/#{path.to_s.chomp('/').delete_prefix('/')}")
  end

  def parse_path(path, filesystem)
    normal_path = normalized_path(path)
    if filesystem == 'fs'
      @path = PosixFile.new(normal_path)
      @filesystem = 'fs'
    elsif ::Configuration.remote_files_enabled? && filesystem != 'fs'
      @path = RemoteFile.new(normal_path, filesystem)
      @filesystem = filesystem
    else
      @path = PosixFile.new(normal_path)
      @filesystem = filesystem
      raise StandardError, I18n.t('dashboard.files_remote_disabled')
    end
  end

  def validate_path!
    if posix_file?
      AllowlistPolicy.default.validate!(@path)
    elsif @path.remote_type.nil?
      raise StandardError, "Remote #{@path.remote} does not exist"
    elsif ::Configuration.allowlist_paths.present? && (@path.remote_type == 'local' || @path.remote_type == 'alias')
      # local and alias remotes would allow bypassing the AllowListPolicy
      # TODO: Attempt to evaluate the path of them and validate?
      raise StandardError, "Remotes of type #{@path.remote_type} are not allowed due to ALLOWLIST_PATH"
    end
  end

  def posix_file?
    @path.is_a?(PosixFile)
  end

  def download?
    fs_params[:download]
  end

  def uppy_upload_path
    # careful:
    #
    #     File.join '/a/b', '/c' => '/a/b/c'
    #     Pathname.new('/a/b').join('/c') => '/c'
    #
    # handle case where uppy.js sets relativePath to "null"
    if @relative_path && @relative_path != 'null'
      Pathname.new(File.join(@parent, @relative_path))
    else
      Pathname.new(File.join(@parent, @name))
    end
  end

  def show_file
    raise(StandardError, t('dashboard.files_download_not_enabled')) unless ::Configuration.download_enabled?

    if posix_file?
      send_posix_file
    else
      send_remote_file
    end
  end

  def send_posix_file
    type = Files.mime_type_by_extension(@path).presence || PosixFile.new(@path).mime_type

    response.set_header 'Content-Length', @path.stat.size

    # svgs aren't safe to view until we update our CSP
    if download? || type.to_s == 'image/svg+xml'
      type = 'text/plain; charset=utf-8' if type.to_s == 'image/svg+xml'
      send_file @path, type: type
    else
      send_file @path, disposition: 'inline', type: Files.mime_type_for_preview(type)
    end
  rescue StandardError => e
    logger.warn("failed to determine mime type for file: #{@path} due to error #{e.message}")

    if download?
      send_file @path
    else
      send_file @path, disposition: 'inline'
    end
  end

  def send_remote_file
    type = begin
      Files.mime_type_by_extension(@path).presence || @path.mime_type
    rescue StandardError => e
      logger.warn("failed to determine mime type for file: #{@path} due to error #{e}")
    end

    # svgs aren't safe to view until we update our CSP
    download = download? || type.to_s == 'image/svg+xml'
    type = 'text/plain; charset=utf-8' if type.to_s == 'image/svg+xml'

    response.set_header('X-Accel-Buffering', 'no')
    response.sending_file = true
    response.set_header('Last-Modified', Time.now.httpdate)

    if download
      response.set_header('Content-Type', type) if type.present?
      response.set_header('Content-Disposition', 'attachment')
    else
      response.set_header('Content-Type', Files.mime_type_for_preview(type)) if type.present?
      response.set_header('Content-Disposition', 'inline')
    end
    begin
      @path.read do |chunk|
        response.stream.write(chunk)
      end
      # Need to rescue exception when user cancels download
    rescue ActionController::Live::ClientDisconnected => e
    end
  ensure
    response.stream.close
  end

  def fs_params
    params.permit(:format, :filepath, :fs, :download,  :can_download)
  end

  def update_params
    params.permit(:format, :filepath, :fs, :dir, :file, :touch)
  end

  def upload_params
    params.permit(:format, :relativePath, :parent, :name, :fs, :file)
  end

  def edit_params
    params.permit(:format, :path, :fs, :filepath)
  end

  def directory_frame_params
    params.permit(:format, :path)
  end
end
