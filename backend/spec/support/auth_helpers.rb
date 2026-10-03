module AuthHelpers
  DEFAULT_PASSWORD = "correct-horse-battery".freeze

  # Signs in through the real endpoint so specs exercise the session cookie the
  # UI actually relies on.
  def sign_in_as(user, password: DEFAULT_PASSWORD)
    post "/api/auth/login", params: { email: user.email, password: password }, as: :json
    raise "sign in failed: #{response.status} #{response.body}" unless response.successful?

    user
  end

  def json
    JSON.parse(response.body)
  end
end
