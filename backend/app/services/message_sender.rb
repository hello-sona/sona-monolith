# Writes a user turn plus the stub assistant reply, and names the thread from
# the first thing the user said.
class MessageSender
  REPLY_EXCERPT_LIMIT = 400
  ELLIPSIS = "…".freeze

  Result = Struct.new(:user_message, :assistant_message, keyword_init: true)

  def self.call(conversation, content)
    new(conversation, content).call
  end

  def initialize(conversation, content)
    @conversation = conversation
    @content = content.to_s
  end

  def call
    result = nil

    conversation.transaction do
      result = Result.new(
        user_message: conversation.messages.create!(role: :user, content: content),
        assistant_message: conversation.messages.create!(role: :assistant, content: reply)
      )

      if conversation.default_title?
        conversation.update!(title: derived_title)
      else
        conversation.touch
      end
    end

    result
  end

  private

  attr_reader :conversation, :content

  def derived_title
    truncate(content.strip.lines.first.to_s.chomp, Conversation::TITLE_LIMIT)
  end

  def reply
    "I'm Sona's local stand-in until a model is wired up. " \
      "You said: #{truncate(content.strip, REPLY_EXCERPT_LIMIT)}"
  end

  def truncate(text, limit)
    return text if text.length <= limit

    "#{text[0, limit].rstrip}#{ELLIPSIS}"
  end
end
