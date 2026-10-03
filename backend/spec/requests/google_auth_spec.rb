require "rails_helper"

RSpec.describe "Google sign-in", type: :request do
  let(:payload) do
    {
      "sub" => "google-sub-123",
      "email" => "ada@gmail.com",
      "email_verified" => true,
      "name" => "Ada Lovelace"
    }
  end

  def stub_google(result)
    allow(GoogleCredential).to receive(:verify).and_return(result)
  end

  it "creates a passwordless user and starts a session" do
    stub_google(payload)

    post "/api/auth/google", params: { credential: "fake-token" }, as: :json

    expect(response).to have_http_status(:created)
    expect(json).to include("email" => "ada@gmail.com", "display_name" => "Ada Lovelace")
    expect(GoogleCredential).to have_received(:verify).with("fake-token")

    user = User.find_by!(email: "ada@gmail.com")
    expect(user.google_sub).to eq("google-sub-123")
    expect(user.password_set?).to be(false)

    get "/api/auth/me"
    expect(json["email"]).to eq("ada@gmail.com")
  end

  it "signs in an existing Google user without creating another" do
    create(:user, email: "ada@gmail.com", display_name: "Ada",
                  password: nil, google_sub: "google-sub-123")
    stub_google(payload)

    post "/api/auth/google", params: { credential: "fake-token" }, as: :json

    expect(response).to have_http_status(:ok)
    expect(User.where(email: "ada@gmail.com").count).to eq(1)

    get "/api/auth/me"
    expect(response).to have_http_status(:ok)
  end

  it "links an existing password account and keeps its password" do
    user = create(:user, email: "ada@gmail.com", display_name: "ada")
    stub_google(payload)

    post "/api/auth/google", params: { credential: "fake-token" }, as: :json

    expect(response).to have_http_status(:ok)
    user.reload
    expect(user.google_sub).to eq("google-sub-123")
    expect(user.password_set?).to be(true)
    # "ada" was derived from the email, so the Google name replaces it.
    expect(user.display_name).to eq("Ada Lovelace")
  end

  it "leaves a display name the user chose themselves" do
    user = create(:user, email: "ada@gmail.com", display_name: "Countess")
    stub_google(payload)

    post "/api/auth/google", params: { credential: "fake-token" }, as: :json

    expect(user.reload.display_name).to eq("Countess")
  end

  it "rejects an invalid credential" do
    allow(GoogleCredential).to receive(:verify)
      .and_raise(GoogleCredential::Error, "Invalid Google credential.")

    post "/api/auth/google", params: { credential: "bad" }, as: :json

    expect(response).to have_http_status(:bad_request)
    expect(json["detail"]).to eq("Invalid Google credential.")
  end

  it "reports 503 when Google sign-in is not configured" do
    allow(Rails.configuration.x).to receive(:google_client_id).and_return("")

    post "/api/auth/google", params: { credential: "fake-token" }, as: :json

    expect(response).to have_http_status(:service_unavailable)
    expect(json["detail"]).to include("not configured")
  end
end
