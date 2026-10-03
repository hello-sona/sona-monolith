# Turns a verified Google payload into a User, linking accounts that already
# exist under the same email address.
class GoogleSignIn
  Result = Struct.new(:user, :created, keyword_init: true) do
    alias_method :created?, :created
  end

  def self.call(credential)
    new(GoogleCredential.verify(credential)).call
  end

  def initialize(payload)
    @payload = payload
  end

  def call
    existing_by_sub = User.find_by(google_sub: google_sub)
    return Result.new(user: existing_by_sub, created: false) if existing_by_sub

    existing_by_email = User.find_by(email: email)
    return Result.new(user: link(existing_by_email), created: false) if existing_by_email

    Result.new(user: create_user, created: true)
  end

  private

  attr_reader :payload

  def email
    @email ||= payload["email"].to_s.strip.downcase
  end

  def google_sub
    @google_sub ||= payload["sub"].to_s
  end

  def name
    @name ||= (payload["name"].presence || payload["given_name"]).to_s.strip
  end

  def link(user)
    user.google_sub = google_sub
    # Only overwrite a display name the user never personalised.
    user.display_name = name if name.present? && generated_display_name?(user)
    user.save!
    user
  end

  def generated_display_name?(user)
    user.display_name.blank? || user.display_name == user.email.split("@").first
  end

  def create_user
    User.create!(email: email, display_name: name, google_sub: google_sub)
  end
end
