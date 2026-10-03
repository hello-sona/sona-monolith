module Api
  class MessagesController < BaseController
    before_action :set_conversation

    def index
      render json: @conversation.messages.chronological.map { |m| MessageSerializer.call(m) }
    end

    def create
      content = params.fetch(:message, {}).permit(:content).fetch(:content, "").to_s.strip

      if content.blank?
        return render json: { content: [ "Message cannot be empty." ] }, status: :bad_request
      end

      result = MessageSender.call(@conversation, content)

      render json: {
        user_message: MessageSerializer.call(result.user_message),
        assistant_message: MessageSerializer.call(result.assistant_message),
        conversation: ConversationSerializer.call(@conversation.reload)
      }, status: :created
    end

    private

    def set_conversation
      @conversation = current_user.conversations.find(params[:conversation_id])
    end
  end
end
