class FilesController < ApplicationController
  # FIXME:
  skip_before_action :verify_authenticity_token

  # TODO: how do we support legacy ability to control access to files app through file permissions?

  def legacy_app_config
    respond_to do |format|
      format.html { # show.html.erb
        raise ActionController::RoutingError.new('Not Found')
      }
      format.json {
        render :json => {"auth":false,"username":"root","password":"2b64f2e3f9fee1942af9ff60d40aa5a719db33b8ba8dd4864bb4f11e25ca2bee00907de32a59429602336cac832c8f2eeff5177cc14c864dd116c8bf6ca5d9a9","algo":"sha512WithRSAEncryption","editor":"edward","diff":true,"zip":true,"notifications":false,"localStorage":true,"buffer":true,"dirStorage":false,"minify":false,"online":true,"cache":true,"showKeysPanel":false,"port":8000,"ip":nil,"root":"/","prefix":"/pun/dev/files","progress":true,"htmlDialogs":true,"treeroot":"/users/PZS0562/efranz","treeroottitle":"Home Directory","upload_max":10737420000,"file_editor":"/pun/sys/file-editor/edit","shell":"/pun/sys/shell/ssh/default","ssh_hosts":[],"whitelist":nil}
      }
    end
  end

  def fs
    # FIXME: force format for accept header
    request.format = 'json' if request.headers['HTTP_ACCEPT'].split(',').include?('application/json')


    @path = Pathname.new("/" + params[:filepath].chomp("/"))

    respond_to do |format|
      format.html { # show.html.erb
        if @path.directory?
          @transfers = TransferLocalJob.progress.values
          @files = Files.new.ls(@path.to_s)
          render :index
        else
          #FIXME: type, inline
          send_file @path
        end
      }
      # TODO: generate files listing below! then we have it...
      # then we can add the other things till the backend is re-implemented
      format.json {
        #FIXME:
        #the current API does a GET on the file to get the file contents AND
        #a GET on the directory to get the JSON for the directory
        if @path.directory?
          @transfers = TransferLocalJob.progress.values
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
  # an empty put wants to create or touch a file
  # Content-Length: 0
  #
  # a put with contents wants to do something else
  # Content-Type: application/x-www-form-urlencoded; charset=UTF-8
  #
  # request payload: the content of the file
  #
  # but an empty payload might be
  #
  # so their new file request actually creates a file of 0 size instead of touching a file
  #
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

  # FIXME: TransfersController
  def cp
    # TODO: validate data (no bad copy/move commands) - using file system abstraction ideally
    params = ActionController::Parameters.new(JSON.parse(request.body.read).merge(params.to_h))

    @job = TransferLocalJob.perform_later('cp', params['from'], params['names'], params['to'])
    @transfers = TransferLocalJob.progress.values

    respond_to do |format|
      format.json {
        render :body => "copy started"
      }
      format.js {
        render "transfers/index"
      }
    end
  end

  # FIXME: TransfersController
  def mv
    # TODO: validate data (no bad copy/move commands) - using file system abstraction ideally
    # TODO: if device is same for dest as for src, do move synchronously
    params = ActionController::Parameters.new(JSON.parse(request.body.read).merge(params.to_h))

    @job = TransferLocalJob.perform_later('mv', params['from'], params['names'], params['to'])
    @transfers = TransferLocalJob.progress.values

    respond_to do |format|
      format.json {
        render :body => "move started"
      }
      format.js {
        render "transfers/index"
      }
    end
  end

  def zip
    raise "not yet impl"
  end
end
