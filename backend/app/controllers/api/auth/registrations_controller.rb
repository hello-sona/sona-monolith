module Api
  module Auth
    class RegistrationsController < BaseController
      skip_before_action :require_authentication

      def create
        user = User.new(registration_params)

        if user.save
          sign_in(user)
          render json: UserSerializer.call(user), status: :created
        else
          render_errors(user)
        end
      end

      private

      def registration_params
        params.permit(:email, :password, :display_name)
      end
    end
  end
end
