class FileEditorController < ApplicationController
  def index
    path = params[:path] || "/"
    path = "/" + path unless path.start_with?("/")

    @pathname = Pathname.new(path)

    if ! WhitelistPolicy.new(Rails.application.config.x.whitelist_paths).permitted?(@pathname)
      @path_forbidden = true
      render status: 403
    elsif @pathname.file? && @pathname.readable?
      fileinfo = %x[ file -b --mime-type #{@pathname.to_s.shellescape} ]
      if fileinfo =~ /text\/|\/(x-empty|(.*\+)?xml)/ || params.has_key?(:force)
        @editor_content = ""
        @file_api_url = OodAppkit.files.api(path: @pathname).to_s
      else
        @invalid_file_type = fileinfo
        render status: 404
      end
    elsif @pathname.directory?
      @directory_content = Dir.glob(@pathname + "*").sort
      @file_edit_url = Pathname.new(ENV['RAILS_RELATIVE_URL_ROOT'] || '/').join('edit')
    else
      @not_found = true
      render status: 404
    end
  end

  def about
  end
end
