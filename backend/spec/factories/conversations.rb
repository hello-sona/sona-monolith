FactoryBot.define do
  factory :conversation do
    user
    title { Conversation::DEFAULT_TITLE }
  end

  factory :message do
    conversation
    role { :user }
    content { "Hello" }
  end
end
