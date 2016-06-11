module Api::V1
  class ConversationsController < BaseController

    before_action :authenticate_user_token!, only: [:index]

    # curl -X GET --header "ApiToken: 1234" --header "Authorization: zKhekYC-Mnwm1fbpU-KL"  http://localhost:3000/api/v1/conversations
    def index
      @conversations = Conversation.where("(conversations.sender_id = #{current_user.id}) OR (conversations.recipient_id = #{current_user.id})")

      render json: @conversations, status: :ok
    end

    def show

    end

    def create

    end

    def destroy

    end

    def update

    end

    private

      def conversation_params
        params.require(:conversations).permit(:sender_id, :recipient_id)
      end

  end
end
