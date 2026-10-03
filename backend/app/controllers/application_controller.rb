class ApplicationController < ActionController::Base
  helper_method :current_user, :signed_in?

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.from_session_id(session[:user_id])
  end

  def signed_in?
    current_user.present?
  end

  # Rotates the session id first so a pre-login session cannot be fixated.
  def sign_in(user)
    reset_session
    session[:user_id] = user.id
    user.update_column(:last_login_at, Time.current)
    @current_user = user
  end

  def sign_out
    reset_session
    @current_user = nil
  end
end
