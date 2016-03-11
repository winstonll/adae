class MessagesController < ApplicationController
  before_action do
    @conversation = Conversation.find(params[:conversation_id])
  end

  def index

    @messages = @conversation.messages

    @transaction = Transaction.where("( (transactions.seller_id = #{@conversation.recipient_id} AND transactions.buyer_id = #{@conversation.sender_id}) \
    OR (transactions.seller_id = #{@conversation.sender_id} AND transactions.buyer_id = #{@conversation.recipient_id}) ) \
    AND (transactions.status != 'Completed' AND transactions.status != 'Denied' AND transactions.status != 'Cancelled') \
    AND (transactions.item_id = #{params[:item_id].to_i})").first

    @item = Item.find(params[:item_id])
    @picture = Picture.where(item_id: @item.id).first

    if @messages.length > 10
      @over_ten = true
      @messages = @messages[-10..-1]
    end

    if @messages.last
      if @messages.last.user_id != current_user.id
        @messages.last.read = true;
      end
    end

    @message = @conversation.messages.new
  end

  def new
    @message = @conversation.messages.new
  end

  def create
    @message = @conversation.messages.new(message_params)
    @user = User.find_by(id: @conversation.recipient)
    if @message.save
      if @user == current_user
        @user = User.find_by(id: @conversation.sender)
      else
        @user = User.find_by(id: @conversation.recipient)
      end
      ContactMailer.new_message(@user, @message).deliver_now
      redirect_to conversation_messages_path(@conversation, item_id: params[:message][:item_id])
    end
  end

  private

    def message_params
    params.require(:message).permit(:body, :user_id)
    end
end
