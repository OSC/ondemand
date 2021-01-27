class FilesController < ApplicationController
  # FIXME:
  skip_before_action :verify_authenticity_token

  # TODO: how do we support legacy ability to control access to files app through file permissions?

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

    transfer = Transfer.new(action: 'cp', from: params['from'], names: params['names'], to: params['to'])
    transfer.save
    TransferLocalJob.perform_later(transfer)

    @transfers = Transfer.transfers

    respond_to do |format|
      format.json {
        render :body => "copy started"
      }
      format.js {
        render "transfers/index"
      }
    end
  end

  def mv
    # TODO: validate data (no bad copy/move commands) - using file system abstraction ideally
    # TODO: if device is same for dest as for src, do move synchronously
    params = ActionController::Parameters.new(JSON.parse(request.body.read).merge(params.to_h))

    transfer = Transfer.new(action: 'mv', from: params['from'], names: params['names'], to: params['to'])
    if transfer.synchronous?
      # FIXME: we want to do TransferLocalJob.perform_now, and bypass/ignore progress reporting
      # would need to handle the error here too
      # this is where using the ActiveModel approach is preferable
      #
      transfer.perform

      respond_to do |format|
        format.json {
          render :body => "move completed"
        }
        format.js {
          render :body => "reloadTable();"
        }
      end
    else
      transfer.save
      TransferLocalJob.perform_later(transfer)
      @transfers = Transfer.transfers

      respond_to do |format|
        format.json {
          render :body => "move started"
        }
        format.js {
          render "transfers/index"
        }
      end
    end
  end

  # FIXME: TransfersController
  def rm
    # TODO: validate data (no bad copy/move commands) - using file system abstraction ideally
    # TODO: if device is same for dest as for src, do move synchronously
    params = ActionController::Parameters.new(JSON.parse(request.body.read).merge(params.to_h))

    transfer = Transfer.new(action: 'rm', from: params['from'], names: params['names'])
    transfer.save
    TransferLocalJob.perform_later(transfer)

    @transfers = Transfer.transfers

    respond_to do |format|
      format.json {
        render :body => "rm started"
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
