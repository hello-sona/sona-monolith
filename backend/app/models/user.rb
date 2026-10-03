# Account that owns conversations. Login is email, not a username.
#
# Schema:
#   id              bigint PK
#   email           unique, login identifier, normalized to lowercase
#   display_name    shown in the UI; defaults to the email local-part
#   google_sub      unique Google subject; nil until Google sign-in
#   password_digest bcrypt; nil when the account is Google-only
#   admin           grants access to /admin
#   active          inactive accounts cannot sign in
#   last_login_at   stamped on each successful sign-in
class User < ApplicationRecord
  MIN_PASSWORD_LENGTH = 8

  has_many :conversations, dependent: :destroy

  # validations: false keeps password optional so Google-only accounts can
  # exist without a digest.
  has_secure_password validations: false

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :google_sub, uniqueness: true, allow_nil: true
  validates :password, length: { minimum: MIN_PASSWORD_LENGTH }, if: -> { password.present? }

  before_validation :backfill_display_name

  # Shared by ApplicationController and the Avo admin, which cannot inherit our
  # controllers and so resolves the session itself.
  def self.from_session_id(user_id)
    return nil if user_id.blank?

    find_by(id: user_id, active: true)
  end

  # Accepts a full email address or a short name. The short forms exist so the
  # seeded local account can sign in as just "admin".
  def self.find_for_sign_in(identifier)
    value = identifier.to_s.strip
    return find_by(email: value.downcase) if value.include?("@")

    find_by(email: "#{value.downcase}@example.com") ||
      where("LOWER(display_name) = ?", value.downcase).first
  end

  # Google-only accounts have no password to check.
  def password_set?
    password_digest.present?
  end

  # Guards on the digest because has_secure_password raises on a nil digest.
  def valid_password?(candidate)
    return false unless password_set? && active?

    authenticate(candidate.to_s).present?
  end

  private

  def backfill_display_name
    return if display_name.present?

    self.display_name = email.to_s.split("@").first.to_s
  end
end
