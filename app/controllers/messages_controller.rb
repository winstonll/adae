class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_access!
  before_action :transaction_exists?, only: [:index]

  def index
    #if @messages.length > 10
    #  @over_ten = true
    #  @messages = @messages[-10..-1]
    #end

    if @messages.last
      if @messages.last.user_id != current_user.id
        @messages.last.read = true;
      end
    end

    @message = @conversation.messages.new
  end

  def new
    @conversation = Conversation.find(params[:conversation_id])
    @message = @conversation.messages.new
  end

  def create
    @conversation = Conversation.find(params[:conversation_id])
    @message = @conversation.messages.new(message_params)

    @user = User.find_by(id: @conversation.recipient)

    if @message.save
      if @user == current_user
        @user = User.find_by(id: @conversation.sender)
      else
        @user = User.find_by(id: @conversation.recipient)
      end

      my_hash = {:body => @message.body, :time => @message.message_time,
      :conversation => @message.conversation_id, :user => @message.user_id,
      :room => "#{@conversation.id}#{@conversation.recipient_id}#{@conversation.sender_id}"}

      my_hash = JSON.generate(my_hash)

      $redis.publish "message", my_hash

      SendEmailJob.set(wait: 1.seconds).perform_later(@user, @message)

      if params[:message][:item_id]
        #redirect_to conversation_messages_path(@conversation, item_id: params[:message][:item_id])
      else
        #redirect_to conversation_messages_path(@conversation)
      end

      @messages = @conversation.messages.order(:created_at)

      respond_to do |format|
        format.js
      end
    end
  end

  private

    def validate_access!
      @conversation = Conversation.find(params[:conversation_id])

      if !user_signed_in? || (@conversation.sender_id != current_user.id && @conversation.recipient_id != current_user.id)
        redirect_to items_path
      end
    end

    def transaction_exists?
      @conversation = Conversation.find(params[:conversation_id])
      @messages = @conversation.messages.order(:created_at)

      if params[:item_id]

        @item = Item.find(params[:item_id])
        @picture = Picture.where(item_id: @item.id).first

        @transaction = Transaction.where("( (transactions.seller_id = #{@conversation.recipient_id} AND transactions.buyer_id = #{@conversation.sender_id}) \
        OR (transactions.seller_id = #{@conversation.sender_id} AND transactions.buyer_id = #{@conversation.recipient_id}) ) \
        AND (transactions.status != 'Completed' AND transactions.status != 'Denied' AND transactions.status != 'Cancelled') \
        AND (transactions.item_id = #{params[:item_id].to_i})").first
      end

      if @transaction.nil?
        @transaction = Transaction.where("( (transactions.seller_id = #{@conversation.recipient_id} AND transactions.buyer_id = #{@conversation.sender_id}) \
        OR (transactions.seller_id = #{@conversation.sender_id} AND transactions.buyer_id = #{@conversation.recipient_id}) ) \
        AND (transactions.status != 'Completed' AND transactions.status != 'Denied' AND transactions.status != 'Cancelled') ").first

        if @transaction
          @item = Item.find(@transaction.item_id)
          @picture = Picture.where(item_id: @item.id).first
        end
      end
    end

    def message_params
    params.require(:message).permit(:body, :user_id)
    end
end
