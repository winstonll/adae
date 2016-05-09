module Api::V1
  class MessagesController < BaseController

    before_action :authenticate_user_token!, only: [:index]
    before_action :validate_access!

    #curl -X GET --header "ApiToken: 1234" --header "Authorization: zKhekYC-Mnwm1fbpU-KL" -d 'messages[conversation_id]= 2'  http://localhost:3000/api/v1/messages
    def index
      @messages = @conversation.messages

      render json: @messages, status: :ok
    end

    def show

    end

    def create
      if params[:messages][:body]
        @message = Message.new(body: params[:messages][:body],
        conversation_id: params[:messages][:conversation_id], user_id: current_user.id)

        if @message.save

          my_hash = {:body => @message.body, :time => @message.message_time,
          :conversation => @message.conversation_id, :user => @message.user_id,
          :room => "#{@conversation.id}#{@conversation.recipient_id}#{@conversation.sender_id}",
          :mobile_time => @message.created_at}

          my_hash = JSON.generate(my_hash)

          $redis.publish "message", my_hash

          SendEmailJob.set(wait: 1.seconds).perform_later(@user, @message)

          #ContactMailer.new_message(@user, @message).deliver_now

          render :nothing => true, status: :ok
        else
          render json: @message.errors, status: 422
        end
      else
        render :json => { :errors => "message is empty".as_json }, status: 422
      end
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
