require "rails_helper"

RSpec.describe "Conversations", type: :request do
  let(:user) { create(:user, email: "ada@example.com", display_name: "Ada") }
  let(:other_user) { create(:user, email: "grace@example.com", display_name: "Grace") }

  before { sign_in_as(user) }

  it "requires authentication" do
    delete "/api/auth/logout"

    get "/api/conversations"

    expect(response).to have_http_status(:unauthorized)
  end

  it "scopes create, list, rename, and delete to the owner" do
    post "/api/conversations", params: { title: "Planning" }, as: :json
    expect(response).to have_http_status(:created)
    conversation_id = json["id"]

    get "/api/conversations"
    expect(response).to have_http_status(:ok)
    expect(json.map { |c| c["title"] }).to eq([ "Planning" ])

    create(:conversation, user: other_user, title: "Someone else")

    get "/api/conversations"
    expect(json.map { |c| c["title"] }).to eq([ "Planning" ])

    get "/api/conversations/#{conversation_id}"
    expect(response).to have_http_status(:ok)

    patch "/api/conversations/#{conversation_id}", params: { title: "Renamed" }, as: :json
    expect(response).to have_http_status(:ok)
    expect(json["title"]).to eq("Renamed")

    delete "/api/conversations/#{conversation_id}"
    expect(response).to have_http_status(:no_content)
    expect(Conversation.exists?(conversation_id)).to be(false)
  end

  it "creates a conversation with the default title when none is given" do
    post "/api/conversations", params: {}, as: :json

    expect(response).to have_http_status(:created)
    expect(json["title"]).to eq(Conversation::DEFAULT_TITLE)
  end

  it "lists the most recently updated conversation first" do
    older = create(:conversation, user: user, title: "Older", updated_at: 2.days.ago)
    newer = create(:conversation, user: user, title: "Newer", updated_at: 1.hour.ago)

    get "/api/conversations"

    expect(json.map { |c| c["id"] }).to eq([ newer.id, older.id ])
  end

  it "hides another user's conversation behind a 404" do
    conversation = create(:conversation, user: other_user, title: "Private")

    get "/api/conversations/#{conversation.id}"

    expect(response).to have_http_status(:not_found)
  end

  it "will not let another user's conversation be deleted" do
    conversation = create(:conversation, user: other_user)

    delete "/api/conversations/#{conversation.id}"

    expect(response).to have_http_status(:not_found)
    expect(Conversation.exists?(conversation.id)).to be(true)
  end
end
