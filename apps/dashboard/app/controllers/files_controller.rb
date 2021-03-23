class FilesController < ApplicationController

  def fs
    # FIXME: force format for accept header
    request.format = 'json' if request.headers['HTTP_ACCEPT'].split(',').include?('application/json')

    @path = Pathname.new("/" + params[:filepath].chomp("/"))
    if @path.directory?
      show_directory
    elsif @path.file?
      show_file
    else
      # error handling
    end
  end

  def show_directory
    @layout_container_class = "container-fluid"

    @transfers = Transfer.transfers
    @files = Files.new.ls(@path.to_s)

    respond_to do |format|
      format.html { render :index }
      format.json { render :index }
    end
    # rescue exceptions
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
      send_file @path, disposition: 'inline'
    end

    # rescue exceptions
  end

  # put - create or update
  # FIXME: separate from touching a file (for new) vs saving content of 0 to a file
  def update
    # 1.find the path
    # 2. if it is a file, write the content to it
    # 3. if it doesn't exist, create the file
    #
    # format.html { # show.html.erb
    #   raise ActionController::RoutingError.new('Not Found')
    # }
    # format.json {
    respond_to do |format|
      format.text {
        path = "/" + params[:filepath]

        if params.include?("dir")
          #TODO: separate FilesController and DirectoriesController
          # and separate TransfersController (create new transfer)
          Dir.mkdir path
          render :body => "make dir: ok(#{File.basename(path)}) }"
        elsif params.include?("file")
          FileUtils.mv params["file"].tempfile, path
          render :body => "save: ok(#{File.basename(path)}) }"
        else
          # so... this is file upload instead...
          # so... we need to preserve the content type
          File.write(path, request.body.read)
          render :body => "save: ok(#{File.basename(path)}) }"
        end
       }
    end
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
    # render :body => "save: ok(#{path}) }"
    # TODO: uppy: could add url to the file
    render json: {}
  end

  def zip
    raise "not yet impl"
  end
end
