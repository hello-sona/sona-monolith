module Admin
  # Avo ships no sign-in form of its own, so this is the way into /admin.
  class SessionsController < ApplicationController
    layout "admin"

    def new
      return redirect_to Avo.configuration.root_path if current_user&.admin?

      @email = ""
    end

    def create
      user = User.find_for_sign_in(params[:email])

      if user&.valid_password?(params[:password]) && user.admin?
        sign_in(user)
        redirect_to Avo.configuration.root_path
      else
        @email = params[:email].to_s
        flash.now[:alert] = "Those credentials do not match an admin account."
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      sign_out
      redirect_to admin_login_path
    end
  end
end
