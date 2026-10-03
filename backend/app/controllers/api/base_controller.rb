module Api
  # JSON base for the whole /api namespace.
  #
  # Errors use the shape the UI already parses: `{ "detail": "..." }` for single
  # messages and `{ "field": ["..."] }` for per-attribute validation errors.
  class BaseController < ApplicationController
    before_action :require_authentication

    # Rails ties the CSRF token to the session, so signing in or out rotates it.
    # Echoing the current token lets the UI stay in sync without a second
    # round-trip to /api/auth/csrf.
    after_action :expose_csrf_token

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::InvalidAuthenticityToken, with: :render_invalid_csrf
    rescue_from ActionController::ParameterMissing, with: :render_parameter_missing
    rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid

    private

    def require_authentication
      return if signed_in?

      render_detail("Authentication credentials were not provided.", :unauthorized)
    end

    def expose_csrf_token
      response.headers["X-CSRF-Token"] = form_authenticity_token
    end

    def render_detail(message, status)
      render json: { detail: message }, status: status
    end

    def render_not_found
      render_detail("Not found.", :not_found)
    end

    def render_invalid_csrf
      render_detail("CSRF verification failed.", :forbidden)
    end

    def render_parameter_missing(error)
      render json: { error.param => [ "is required" ] }, status: :bad_request
    end

    def render_record_invalid(error)
      render_errors(error.record)
    end

    def render_errors(record)
      render json: record.errors.to_hash(true), status: :bad_request
    end
  end
end
