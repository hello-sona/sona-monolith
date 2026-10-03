# One turn in a conversation.
#
# Schema:
#   id               bigint PK
#   conversation_id  FK -> conversations, cascade delete
#   role             user | assistant | system
#   content          message body
#   created_at       set on insert; thread order
#
# `system` is reserved for a later model. The stub writer only creates user and
# assistant rows. Indexed on (conversation_id, created_at).
class Message < ApplicationRecord
  CONTENT_LIMIT = 20_000

  belongs_to :conversation

  enum :role, { user: "user", assistant: "assistant", system: "system" }, validate: true

  validates :content, presence: true, length: { maximum: CONTENT_LIMIT }

  scope :chronological, -> { order(:created_at) }
end
