class FilesController < ApplicationController

  def fs
    request.format = 'json' if request.headers['HTTP_ACCEPT'].split(',').include?('application/json')

    @path = normalized_path
    if @path.stat.directory?
      Files.raise_if_cant_access_directory_contents(@path)

      respond_to do |format|
        format.html {
          render :index
        }
        format.json {
          @files = Files.new.ls(@path.to_s)
          render :index
        }
      end
    else
      show_file
    end
  rescue => e
    @files = []
    flash.now[:alert] = "#{e.message}"

    respond_to do |format|
      format.html {
        render :index
      }
      format.json {
        @files = []

        render :index
      }
    end
  end

  # PUT - create or update
  def update
    path = normalized_path

    if params.include?("dir")
      Dir.mkdir path
    elsif params.include?("file")
      FileUtils.mv params["file"].tempfile, path
    elsif params.include?("touch")
      FileUtils.touch path
    else
      File.write(path, request.body.read)
    end

    render json: {}
  rescue => e
    render json: { error_message: e.message }
  end

  private

  def normalized_path
    Pathname.new("/" + params[:filepath].chomp("/"))
  end

  def show_file
    if params[:download]
      send_file @path
    else
      begin
        type = Files.mime_type_by_extension(@path).presence || Files.mime_type(@path)

        send_file @path, disposition: 'inline', type: type
      rescue => e
        Rails.logger.warn("failed to determine mime type for file: #{@path} due to error #{e.message}")
        send_file @path, disposition: 'inline'
      end
    end
  end
end
