module Api
  module Auth
    class SessionsController < BaseController
      skip_before_action :require_authentication, only: :create

      def create
        user = User.find_for_sign_in(params[:email])

        unless user&.valid_password?(params[:password])
          return render_detail("Invalid email or password.", :unauthorized)
        end

        sign_in(user)
        render json: UserSerializer.call(user)
      end

      def destroy
        sign_out
        head :no_content
      end
    end
  end
end
