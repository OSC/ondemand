# frozen_string_literal: true

# The Controller to render widget templates without any layout furniture
class WidgetsController < ApplicationController

  def show
    widget_path = File.join('/widgets', params[:widget_path])

    unless valid_path?(widget_path)
      render plain: "400 Bad Request. Invalid widget path: #{widget_path}", status: :bad_request
      return
    end


    widget_exists = lookup_context.exists?(widget_path, [], true)
    unless widget_exists
      render plain: "404 Widget not found: #{widget_path}", status: :not_found
      return
    end

    render partial: widget_path, layout: false
  end

  private

  # Checks if the widget path contains only allowed characters
  def valid_path?(widget_path)
    widget_path.match?(/\A[a-zA-Z0-9_\-\/]+\z/)
  end
end

