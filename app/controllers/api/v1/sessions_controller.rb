class Api::V1::SessionsController < Api::V1::BaseController

  acts_as_token_authentication_handler_for User, fallback_to_devise: false

  def create

    success, user = User.valid_login?(params[:email], params[:password])
    if success
      render json: user.as_json(only: [:email, :authentication_token]), status: :created
    else
      head :unauthorized
    end
  end

  def destroy
    current_user.reset_authentication_token!
    head :ok
  end

  private

  def current_user
    authenticate_with_http_token do |token, options|
      User.find_by(authentication_token: token)
    end
  end

end
