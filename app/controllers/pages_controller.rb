class PagesController < ApplicationController

  def index

    path = params[:path] || "/"
    path = "/" + path unless path.start_with?("/")

    # path = "/#{params[:path]}"
    # path += params.has_key?(:format) ? ".#{params[:format]}" : ""
    pathname = Pathname.new(path)
    if pathname.file? && pathname.readable?
      @editor_content = ""
      @file_api_url = OodApp.files.api(path: pathname)
    elsif pathname.directory?
      @directory_content = Dir.glob(pathname + "*").sort
      @file_edit_url = Pathname.new(ENV['RAILS_RELATIVE_URL_ROOT']).join('edit')
    else
      @directory_content = Dir.glob(ENV['HOME'] + "*").sort
      @file_edit_url = Pathname.new(ENV['RAILS_RELATIVE_URL_ROOT']).join('edit')
    end

  end

  def about
  end
end
