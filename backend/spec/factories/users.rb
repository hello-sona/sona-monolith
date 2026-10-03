FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    display_name { "Test User" }
    password { AuthHelpers::DEFAULT_PASSWORD }

    trait :admin do
      admin { true }
    end

    # Google-only accounts carry no password digest.
    trait :google_only do
      password { nil }
      sequence(:google_sub) { |n| "google-sub-#{n}" }
    end
  end
end
