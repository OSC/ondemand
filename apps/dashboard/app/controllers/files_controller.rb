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

  # POST
  def upload
    # careful:
    #
    #     File.join '/a/b', '/c' => '/a/b/c'
    #     Pathname.new('/a/b').join('/c') => '/c'
    #
    # handle case where uppy.js sets relativePath to "null"
    if params["relativePath"] && params["relativePath"] != "null"
      path = Pathname.new(File.join(params["parent"], params["relativePath"]))
    else
      path = Pathname.new(File.join(params["parent"], params["name"]))
    end

    path.mkpath unless path.parent.directory?

    FileUtils.mv params["file"].tempfile, path.to_s

    render json: {}
  rescue Errno::EACCES => e
    render json: { error_message: e.message }, status: :forbidden
  rescue => e
    render json: { error_message: e.message }, status: :internal_server_error
  end

  def zip
    raise "not yet impl"
  end

  def edit
    path = params[:path] || "/"
    path = "/" + path unless path.start_with?("/")

    status = 200

    @pathname = Pathname.new(path)

    if @pathname.file? && @pathname.readable?
      fileinfo = %x[ file -b --mime-type #{@pathname.to_s.shellescape} ]
      if fileinfo =~ /text\/|\/(x-empty|(.*\+)?xml)/ || params.has_key?(:force)
        @editor_content = ""
        @file_api_url = OodAppkit.files.api(path: @pathname).to_s
      else
        @invalid_file_type = fileinfo
        status = 404
      end
    elsif @pathname.directory?
      # just render error message
    else
      @not_found = true
      status = 404
    end

    render :edit, status: status, layout: 'editor'
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
