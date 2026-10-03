# One chat thread owned by a user.
#
# Schema:
#   id          bigint PK
#   user_id     FK -> users, cascade delete
#   title       sidebar label; starts as "New chat", then the first message
#   created_at  set on insert
#   updated_at  bumped when a message is added or the title is renamed
#
# Indexed on (user_id, updated_at desc) for the sidebar listing.
class Conversation < ApplicationRecord
  DEFAULT_TITLE = "New chat".freeze
  TITLE_LIMIT = 72

  belongs_to :user
  has_many :messages, dependent: :destroy

  validates :title, presence: true, length: { maximum: 200 }

  scope :recent_first, -> { order(updated_at: :desc) }

  # True while the thread still carries its placeholder title.
  def default_title?
    title == DEFAULT_TITLE
  end
end
