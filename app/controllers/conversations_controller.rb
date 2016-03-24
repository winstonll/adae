class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index

    @conversations = Conversation.where("(conversations.sender_id = #{current_user.id}) OR (conversations.recipient_id = #{current_user.id})")

    @transactions = []
    #Transaction.where("(transactions.seller_id = #{current_user.id} OR transactions.buyer_id = #{current_user.id}) \
    #AND (transactions.status != 'Completed' AND transactions.status != 'Denied' AND transactions.status != 'Cancelled')")

    @conversations.each do |conversation|
      if transaction = Transaction.where("((transactions.seller_id = #{conversation.sender_id} AND transactions.buyer_id = #{conversation.recipient_id})\
        OR (transactions.seller_id = #{conversation.recipient_id} AND transactions.buyer_id = #{conversation.sender_id}))\
        AND (transactions.status != 'Completed' AND transactions.status != 'Denied' AND transactions.status != 'Cancelled')").first

        @transactions << transaction
      else
        @transactions << nil 
      end
    end

  end

  def create
    if Conversation.between(params[:sender_id],params[:recipient_id]).present?
      @conversation = Conversation.between(params[:sender_id],
      params[:recipient_id]).first
    else
      @conversation = Conversation.create!(conversation_params)
    end
    redirect_to conversation_messages_path(@conversation, item_id: params[:item_id])
  end

  private

    def conversation_params
    params.permit(:sender_id, :recipient_id)
    end
end
