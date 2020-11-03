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
    @path = Pathname.new("/" + params[:filepath].chomp("/"))

    respond_to do |format|
      format.html { # show.html.erb
        if @path.directory?
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
          render :json => {
              "path": @path.to_s,
              "files": Files.new.ls(@path.to_s)
          }
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

  # FIXME: TransfersController
  def cp
    params = ActionController::Parameters.new(JSON.parse(request.body.read).merge(params.to_h))
    normalize_transfer_params(params).select { |transfer|
      if transfer.include?(:from) && transfer.include?(:to)
        transfer
      else
        raise "args needed from and to" unless transfer.include?(:from) && transfer.include?(:to)
      end
    }.each { |transfer|
      FileUtils.cp transfer[:from], transfer[:to]
    }

    render :body => "copy: ok('') }"
  end

  # FIXME: TransfersController
  def mv
    #
    # parse json body :-P
    # content type sending is its problem
    #
    params = ActionController::Parameters.new(JSON.parse(request.body.read).merge(params.to_h))
    normalize_transfer_params(params).select { |transfer|
      if transfer.include?(:from) && transfer.include?(:to)
        transfer
      else
        raise "args needed from and to" unless transfer.include?(:from) && transfer.include?(:to)
      end
    }.each { |transfer|
      FileUtils.mv transfer[:from], transfer[:to]
    }

    render :body => "move: ok('') }"
  end

  def zip
    raise "not yet impl"
  end

  def normalize_transfer_params(params)
    if params.include?('names')
      params['names'].map do |name|
        { from: File.join(params['from'], name), to: File.join(params['to'], name)  }
      end
    else
      [{ from: params['from'], to: params['to']  }]
    end
  end
end
