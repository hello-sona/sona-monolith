require "rails_helper"

RSpec.describe "Authentication", type: :request do
  let(:password) { AuthHelpers::DEFAULT_PASSWORD }

  describe "POST /api/auth/register" do
    it "creates the user and starts a session" do
      post "/api/auth/register",
           params: { email: "new@example.com", password: password, display_name: "New" },
           as: :json

      expect(response).to have_http_status(:created)
      expect(json).to include("email" => "new@example.com", "display_name" => "New")

      get "/api/auth/me"
      expect(response).to have_http_status(:ok)
      expect(json["email"]).to eq("new@example.com")
    end

    it "normalizes the email and derives a display name from it" do
      post "/api/auth/register",
           params: { email: "  MixEd@Example.COM ", password: password },
           as: :json

      expect(response).to have_http_status(:created)
      expect(json).to include("email" => "mixed@example.com", "display_name" => "mixed")
    end

    it "rejects a duplicate email" do
      create(:user, email: "taken@example.com")

      post "/api/auth/register",
           params: { email: "taken@example.com", password: password },
           as: :json

      expect(response).to have_http_status(:bad_request)
      expect(json["email"]).to be_present
    end

    it "rejects a password under the minimum length" do
      post "/api/auth/register",
           params: { email: "short@example.com", password: "sh0rt" },
           as: :json

      expect(response).to have_http_status(:bad_request)
      expect(json["password"]).to be_present
    end
  end

  describe "POST /api/auth/login" do
    let!(:user) { create(:user, email: "ada@example.com", display_name: "Ada") }

    it "rejects a wrong password" do
      post "/api/auth/login",
           params: { email: user.email, password: "wrong-password" },
           as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(json["detail"]).to eq("Invalid email or password.")
    end

    it "signs in, exposes the session, and signs out again" do
      post "/api/auth/login", params: { email: user.email, password: password }, as: :json
      expect(response).to have_http_status(:ok)
      expect(json["email"]).to eq(user.email)

      get "/api/auth/me"
      expect(response).to have_http_status(:ok)

      delete "/api/auth/logout"
      expect(response).to have_http_status(:no_content)

      get "/api/auth/me"
      expect(response).to have_http_status(:unauthorized)
    end

    it "stamps last_login_at" do
      expect { sign_in_as(user) }.to change { user.reload.last_login_at }.from(nil)
    end

    it "refuses an inactive account" do
      user.update!(active: false)

      post "/api/auth/login", params: { email: user.email, password: password }, as: :json

      expect(response).to have_http_status(:unauthorized)
    end

    it "lets the seeded admin sign in with a short name" do
      create(:user, :admin, email: "admin@example.com", display_name: "admin")

      post "/api/auth/login", params: { email: "admin", password: password }, as: :json

      expect(response).to have_http_status(:ok)
      expect(json).to include("email" => "admin@example.com", "display_name" => "admin")
    end

    it "matches a display name case-insensitively" do
      post "/api/auth/login", params: { email: "ADA", password: password }, as: :json

      expect(response).to have_http_status(:ok)
      expect(json["email"]).to eq("ada@example.com")
    end
  end

  describe "GET /api/auth/me" do
    it "requires authentication" do
      get "/api/auth/me"

      expect(response).to have_http_status(:unauthorized)
      expect(json["detail"]).to be_present
    end
  end

  describe "GET /api/auth/csrf" do
    it "returns a token and sets the session cookie" do
      get "/api/auth/csrf"

      expect(response).to have_http_status(:ok)
      expect(json["csrfToken"]).to be_present
      expect(response.headers["Set-Cookie"]).to include("_sona_session")
    end
  end
end
