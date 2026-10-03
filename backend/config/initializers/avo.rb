Avo.configure do |config|
  config.root_path = "/admin"
  config.app_name = "Sona admin"

  # Avo's controllers do not inherit ApplicationController, so the session is
  # resolved here instead of reusing the controller helper.
  config.current_user_method do
    User.from_session_id(session[:user_id])
  end

  # Admin is session-backed like the API. Anyone else gets the sign-in form.
  # Resolved from the session rather than Avo's internals so this does not break
  # on an Avo upgrade.
  config.authenticate_with do
    unless User.from_session_id(session[:user_id])&.admin?
      redirect_to main_app.admin_login_path
    end
  end

  config.sign_out_path_name = :admin_logout_path
  config.timezone = "UTC"
end
