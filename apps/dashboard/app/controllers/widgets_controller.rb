class WidgetsController < ApplicationController

  SUPPORTED_TYPES = {
    ".jpg" => "image/jpeg",
    ".gif" => "image/gif",
    ".png" => "image/png",
    ".svg" => "image/svg+xml",
  }

  def image
    return render plain: "Widget images not configured", content_type: 'text/plain', status: :bad_request unless ::Configuration.widget_images_path

    image_file = Pathname.new(::Configuration.widget_images_path).join(params[:image_name])

    return render plain: "Image type not supported: #{image_file.extname}", content_type: 'text/plain', status: :bad_request unless supported? image_file

    if image_file.file? && image_file.readable?
      send_file image_file, :type => SUPPORTED_TYPES[image_file.extname], :disposition => 'inline'
    else
      render plain: "Image not found", content_type: 'text/plain', status: :not_found
    end
  end

  private

  def supported?(image_file)
    SUPPORTED_TYPES.has_key? image_file.extname
  end
end