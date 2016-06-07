module Api::V2
  class ConversationsController < BaseController

    before_action :authenticate_user_token!, only: [:index]

    # curl -X GET --header "ApiToken: 1234" --header "Authorization: zKhekYC-Mnwm1fbpU-KL"  http://localhost:3000/api/v1/conversations
    def index
      @conversations = Conversation.where("(conversations.sender_id = #{current_user.id}) OR (conversations.recipient_id = #{current_user.id})")
      @users = []

      @conversations.each do |conversation|
        if conversation.sender_id == current_user.id
          @users << User.find(conversation.recipient_id)
        else
          @users << User.find(conversation.sender_id)
        end
      end

      render 'api/v1/conversations/index', :formats => [:json], :handlers => [:jbuilder], status: 201

      #render json: @conversations, status: :ok
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
