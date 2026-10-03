module Api
  module Auth
    # Seeds the session cookie and hands the UI a token for the X-CSRF-Token
    # header it sends on every unsafe request.
    class CsrfController < BaseController
      skip_before_action :require_authentication

      def show
        render json: { csrfToken: form_authenticity_token }
      end
    end
  end
end
