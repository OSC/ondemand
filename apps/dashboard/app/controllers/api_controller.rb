class ApiController < ActionController::API
  include ActionController::MimeResponds

  before_action :set_user
  before_action :verify_content_type, only: [:create]

  def set_user
    @user = User.new
  end

  def verify_content_type
    #THIS IS TO AVOID THE API BEiNG USED WITH A FORM
    if request.content_type != "application/json"
      render json: { message: "Invalid request content-type" }, status: :bad_request
    end
  end

end