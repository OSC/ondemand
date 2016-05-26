class PagesController < ApplicationController

  def index
    path = params[:path] || "/"
    path = "/" + path unless path.start_with?("/")

    @pathname = Pathname.new(path)
    if @pathname.file? && @pathname.readable?
      fileinfo = %x[ file -i #{@pathname} ]
      if fileinfo.include?("text/plain") || fileinfo.include?("application/x-empty")
        @editor_content = ""
        @file_api_url = OodApp.files.api(path: @pathname)
      else
        @invalid_file_type = fileinfo
        render status: 404
      end
    elsif @pathname.directory?
      @directory_content = Dir.glob(@pathname + "*").sort
      @file_edit_url = Pathname.new(ENV['RAILS_RELATIVE_URL_ROOT']).join('edit')
    else
      @not_found = true
      render status: 404
    end

  end

  def about
  end
end
