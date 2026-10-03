# Verifies a Google Identity Services ID token and returns its payload.
class GoogleCredential
  class Error < StandardError; end

  # Raised when GOOGLE_CLIENT_ID is unset, which the API reports as 503 rather
  # than blaming the caller's token.
  class NotConfigured < Error; end

  class << self
    def verify(token)
      client_id = Rails.configuration.x.google_client_id
      raise NotConfigured, "Google sign-in is not configured." if client_id.blank?

      payload = decode(token, client_id)

      raise Error, "Google email is not verified." unless payload["email_verified"]
      raise Error, "Invalid Google credential." if payload["email"].blank?
      raise Error, "Invalid Google credential." if payload["sub"].blank?

      payload
    end

    private

    # verify_oidc already checks the signature, audience, expiry, and issuer.
    def decode(token, client_id)
      Google::Auth::IDTokens.verify_oidc(token.to_s, aud: client_id)
    rescue Google::Auth::IDTokens::VerificationError, JWT::DecodeError
      raise Error, "Invalid Google credential."
    end
  end
end
