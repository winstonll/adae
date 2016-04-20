module Api::V1
  class MessagesController < BaseController

    before_action :authenticate_user_token!, only: [:index]
    before_action :validate_access!

    #curl -X GET --header "ApiToken: 1234" --header "Authorization: zKhekYC-Mnwm1fbpU-KL" -d 'messages[conversation_id]= 2'  http://localhost:3000/api/v1/messages
    def index
      @messages = @conversation.messages

      render 'api/v1/conversations/index', :formats => [:json], :handlers => [:jbuilder], status: 201
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

      def validate_access!
        if params[:messages][:conversation_id]
          @conversation = Conversation.find(params[:messages][:conversation_id])

          if !user_signed_in? || (@conversation.sender_id != current_user.id && @conversation.recipient_id != current_user.id)
            render json: {
              error: "You do not have access to this conversation",
              status: 400
            }, status: 400
          end
        else
          render json: {
            error: "Conversation does not exist",
            status: 400
          }, status: 400
        end
      end

      def message_params
        params.require(:messages).permit(:body, :conversation_id, :user_id, :read)
      end

  end
end
