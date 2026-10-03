module Api
  class ConversationsController < BaseController
    before_action :set_conversation, only: [ :show, :update, :destroy ]

    def index
      render json: conversations.recent_first.map { |c| ConversationSerializer.call(c) }
    end

    def show
      render json: ConversationSerializer.call(@conversation)
    end

    def create
      conversation = conversations.new(conversation_params)

      if conversation.save
        render json: ConversationSerializer.call(conversation), status: :created
      else
        render_errors(conversation)
      end
    end

    def update
      if @conversation.update(conversation_params)
        render json: ConversationSerializer.call(@conversation)
      else
        render_errors(@conversation)
      end
    end

    def destroy
      @conversation.destroy!
      head :no_content
    end

    private

    # Scoping every lookup to the owner turns someone else's thread into a 404.
    def conversations
      current_user.conversations
    end

    def set_conversation
      @conversation = conversations.find(params[:id])
    end

    # Creating a thread takes an empty body, so the wrapper key may be absent.
    def conversation_params
      params.fetch(:conversation, {}).permit(:title)
    end
  end
end
