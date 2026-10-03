module MessageSerializer
  def self.call(message)
    {
      id: message.id,
      role: message.role,
      content: message.content,
      created_at: message.created_at
    }
  end
end
