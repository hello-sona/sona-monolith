require "json"
require "net/http"

RSpec.describe "Sona smoke", type: :feature do
  it "shows the login screen" do
    visit "/"

    expect(page).to have_selector("h1, h2, h3, h4", text: /welcome back/i)
    expect(page).to have_button("Sign in")
  end

  it "serves a CSRF token from the API" do
    uri = URI.join(Stack::BACKEND_URL, "/api/auth/csrf")

    response = Net::HTTP.get_response(uri)

    expect(response.code).to eq("200")
    expect(JSON.parse(response.body)).to include("csrfToken")
    expect(response["Set-Cookie"]).to include("_sona_session")
  end
end
