require "rails_helper"

# Forgery protection is off for the rest of the suite, so it is switched on here
# to cover the token handshake the UI performs.
RSpec.describe "CSRF protection", type: :request do
  around do |example|
    original = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    example.run
    ActionController::Base.allow_forgery_protection = original
  end

  let!(:user) { create(:user) }
  let(:credentials) { { email: user.email, password: AuthHelpers::DEFAULT_PASSWORD } }

  it "rejects an unsafe request with no token" do
    post "/api/auth/login", params: credentials, as: :json

    expect(response).to have_http_status(:forbidden)
    expect(json["detail"]).to eq("CSRF verification failed.")
  end

  it "accepts a request carrying the token from /api/auth/csrf" do
    get "/api/auth/csrf"

    post "/api/auth/login", params: credentials, as: :json,
         headers: { "X-CSRF-Token" => json["csrfToken"] }

    expect(response).to have_http_status(:ok)
  end

  it "echoes a token that stays usable after the session rotates on sign-in" do
    get "/api/auth/csrf"

    post "/api/auth/login", params: credentials, as: :json,
         headers: { "X-CSRF-Token" => json["csrfToken"] }
    expect(response).to have_http_status(:ok)

    # Signing in reset the session, and with it the old token. The response
    # header carries the replacement.
    rotated = response.headers["X-CSRF-Token"]
    expect(rotated).to be_present

    post "/api/conversations", params: {}, as: :json,
         headers: { "X-CSRF-Token" => rotated }

    expect(response).to have_http_status(:created)
  end
end
