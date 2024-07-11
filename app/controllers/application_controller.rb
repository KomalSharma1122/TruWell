class ApplicationController < ActionController::API
  # skip_before_action :verify_authenticity_token
  include JwtToken

  def authenticate_user 
    if request.headers["HTTP_AUTH_TOKEN"].present?  
      @user = User.find_by(token: request.headers["HTTP_AUTH_TOKEN"])
      if @user.present?
        return true
      else 
        render json: {status: 440, message: "Session timed out"}
      end
    else 
      render json: {status: 400, message: "missing header"}
    end 
  end 

  def current_user
    @user
  end 

end


