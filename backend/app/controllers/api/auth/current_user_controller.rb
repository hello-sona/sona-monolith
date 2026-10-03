module Api
  module Auth
    # GET /api/auth/me
    class CurrentUserController < BaseController
      def show
        render json: UserSerializer.call(current_user)
      end
    end
  end
end
