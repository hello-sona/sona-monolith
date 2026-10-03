require "rails_helper"

RSpec.describe "Messages", type: :request do
  let(:user) { create(:user) }
  let(:conversation) { create(:conversation, user: user) }

  before { sign_in_as(user) }

  describe "POST /api/conversations/:id/messages" do
    it "rejects blank content" do
      post "/api/conversations/#{conversation.id}/messages",
           params: { content: "   " }, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(json["content"]).to eq([ "Message cannot be empty." ])
    end

    it "rejects content over the length limit" do
      post "/api/conversations/#{conversation.id}/messages",
           params: { content: "a" * (Message::CONTENT_LIMIT + 1) }, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(json["content"]).to be_present
    end

    it "creates the user turn, a stub reply, and titles the thread" do
      post "/api/conversations/#{conversation.id}/messages",
           params: { content: "How do sessions work?" }, as: :json

      expect(response).to have_http_status(:created)
      expect(json["user_message"]).to include(
        "role" => "user", "content" => "How do sessions work?"
      )
      expect(json["assistant_message"]["role"]).to eq("assistant")
      expect(json["assistant_message"]["content"]).to include("How do sessions work?")
      expect(json["conversation"]["title"]).to eq("How do sessions work?")
    end

    it "keeps the first message's title on later turns" do
      post "/api/conversations/#{conversation.id}/messages",
           params: { content: "First question" }, as: :json
      post "/api/conversations/#{conversation.id}/messages",
           params: { content: "Follow up" }, as: :json

      expect(conversation.reload.title).to eq("First question")
      expect(conversation.messages.count).to eq(4)
      expect(conversation.messages.user.count).to eq(2)
    end

    it "truncates a long first line when deriving the title" do
      content = "x" * 200

      post "/api/conversations/#{conversation.id}/messages",
           params: { content: content }, as: :json

      title = json["conversation"]["title"]
      expect(title.length).to eq(Conversation::TITLE_LIMIT + 1)
      expect(title).to end_with("…")
    end

    it "derives the title from the first line only" do
      post "/api/conversations/#{conversation.id}/messages",
           params: { content: "Subject line\nmore detail here" }, as: :json

      expect(json["conversation"]["title"]).to eq("Subject line")
    end

    it "will not post into another user's conversation" do
      other_conversation = create(:conversation, user: create(:user))

      post "/api/conversations/#{other_conversation.id}/messages",
           params: { content: "Hello" }, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/conversations/:id/messages" do
    it "returns the thread in chronological order" do
      post "/api/conversations/#{conversation.id}/messages",
           params: { content: "How do sessions work?" }, as: :json

      get "/api/conversations/#{conversation.id}/messages"

      expect(response).to have_http_status(:ok)
      expect(json.map { |m| m["role"] }).to eq([ "user", "assistant" ])
    end
  end
end
