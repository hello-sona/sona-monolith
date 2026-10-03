module ConversationSerializer
  def self.call(conversation)
    {
      id: conversation.id,
      title: conversation.title,
      created_at: conversation.created_at,
      updated_at: conversation.updated_at
    }
  end
end
