class PagesController < ApplicationController

  def index
    @editor_content = ""
    @path = params[:path]
    @path += params.has_key?(:format) ? ".#{params[:format]}" : ""

    @editor_content = @path
  end

  def about
  end
end
