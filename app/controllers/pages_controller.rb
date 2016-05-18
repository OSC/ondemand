class PagesController < ApplicationController

  def index
    path = "/#{params[:path]}"
    path += params.has_key?(:format) ? ".#{params[:format]}" : ""
    pathname = Pathname.new(path)
    if pathname.file? && pathname.readable?
      @editor_content = pathname.read
      @file_api_url = OodApp.files.api(path: pathname)
    elsif pathname.directory?
      # TODO make these into links and display a separate view
      @directory_content = Dir.glob(pathname + "*")
      @file_edit_url = Pathname.new(ENV['RAILS_RELATIVE_URL_ROOT']).join('edit')
    else
      # TODO make an error page
      @editor_content = pathname
    end
  end

  def about
  end
end
