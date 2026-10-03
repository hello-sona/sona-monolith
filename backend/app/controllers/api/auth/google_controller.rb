module Api
  module Auth
    class GoogleController < BaseController
      skip_before_action :require_authentication

      # Declared general-to-specific: rescue_from resolves the last match first.
      rescue_from GoogleCredential::Error, with: :render_bad_credential
      rescue_from GoogleCredential::NotConfigured, with: :render_not_configured

      def create
        result = GoogleSignIn.call(params[:credential])

        sign_in(result.user)
        render json: UserSerializer.call(result.user),
               status: result.created? ? :created : :ok
      end

      private

      def render_not_configured(error)
        render_detail(error.message, :service_unavailable)
      end

      def render_bad_credential(error)
        render_detail(error.message, :bad_request)
      end
    end
  end
end
