class FilesController < ApplicationController

  def fs
    # FIXME: force format for accept header
    request.format = 'json' if request.headers['HTTP_ACCEPT'].split(',').include?('application/json')

    @path = normalized_path
    if @path.stat.directory?
      Files.raise_if_cant_access_directory_contents(@path)

      @layout_container_class = "container-fluid"

      respond_to do |format|
        format.html {
          @layout_container_class = "container-fluid"

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

    # FIXME: if broken symlink and the link is clicked to download the file (or view the file)
    # you are redirected to the other page
    # probably the best way to handle this is to properly handle symlinks in the view, especially
    # broken symlinks
    @layout_container_class = "container-fluid"

    respond_to do |format|
      format.html {
        @layout_container_class = "container-fluid"

        render :index
      }
      format.json {
        @files = []

        render :index
      }
    end
  end

  # put - create or update
  # FIXME: separate from touching a file (for new) vs saving content of 0 to a file
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
    # TODO: this can be merged with the update for creating a new directory or new file
    # using create
    #
    # if params["file"] => a file upload
    # else if
    # else bad!
    #
    # that way creating a new directory can do nothing, creating a new file will just touch the file
    # instead of overwriting it (or reject as "file already exists")

    # FIXME: uppy uses "null" :-P
    #
    # File.join '/a/b', '/c' => '/a/b/c'
    # Pathname.new('/a/b').join('/c') => '/c'
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

  private

  def normalized_path
    Pathname.new("/" + params[:filepath].chomp("/"))
  end

  def show_file
    #FIXME: this is not RESTFUL (you ask for JSON or HTML or any other representation, you get file contents)
    # but there is no clear solution that also enables using SAME URI INTERFACE for both directories and files
    # which is what a file system does with file system paths
    #
    # solution could be to use different URLs, one to get different representations of a single inode
    # (i.e. SHOW the file or directory)
    # and the other to get the inode children and other information (i.e. INDEX for the directory)
    #
    # files/index/(/*dirpath)
    # files/show/(/*filepath)
    #
    # the issue is "goto" where you place in the path to a file instead of a directory
    # the solution is files/index/(/*dirpath) could show the parent directory (and highlight the file)
    # or redirect the user to the parent directory (and highlight the file)
    #
    # another problem here is when we do a listing and want to generate a URL for
    # EACH file (a directory OR a file) => here we have to do control flow (if directory, link to index,
    # if file, link to file)
    #
    # but we do have control flow client side - to determine what to do with a directory or a file
    # so this would shift that to the server side (or have it serverside and client side)
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
