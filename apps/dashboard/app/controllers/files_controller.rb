class FilesController < ApplicationController

  def fs
    # FIXME: force format for accept header
    request.format = 'json' if request.headers['HTTP_ACCEPT'].split(',').include?('application/json')


    @path = Pathname.new("/" + params[:filepath].chomp("/"))

    respond_to do |format|
      format.html { # show.html.erb
        if @path.directory?
          @transfers = Transfer.transfers
          @files = Files.new.ls(@path.to_s)
          render :index
        elsif params[:download]
          send_file @path
        else
          send_file @path, disposition: 'inline'
        end
      }
      # TODO: generate files listing below! then we have it...
      # then we can add the other things till the backend is re-implemented
      format.json {
        #FIXME:
        #the current API does a GET on the file to get the file contents AND
        #a GET on the directory to get the JSON for the directory
        if @path.directory?
          @transfers = Transfer.transfers
          @files = Files.new.ls(@path.to_s)
          render :index
        else
          #FIXME: type, inline
          send_file @path
        end
      }
    end
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
