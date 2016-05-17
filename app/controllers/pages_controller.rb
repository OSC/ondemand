class PagesController < ApplicationController

  def index
    @editor_content = ""
    path = "/#{params[:path]}"
    path += params.has_key?(:format) ? ".#{params[:format]}" : ""
    @pathname = Pathname.new(path)
    if @pathname.file? && @pathname.readable?
      @editor_content = @pathname.read
    elsif @pathname.directory?
      # TODO make these into links and display a separate view
      @editor_content = Pathname.glob(@pathname + "*")
    else
      # TODO make an error page
      @editor_content = "Unreadable location!"
    end
  end

  def about
  end
end
