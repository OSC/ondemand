class FilesController < ApplicationController
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
    respond_to do |format|
      format.html { # show.html.erb
        raise ActionController::RoutingError.new('Not Found')
      }
      # TODO: generate files listing below! then we have it...
      # then we can add the other things till the backend is re-implemented
      format.json {
        render :json => {
            "path": "/" + params[:filepath].chomp("/")+"/",
            "files": Files.new.ls('/' + params[:filepath])
        }
      }
    end
  end
end
