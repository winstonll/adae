class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index

    @transactions = Transaction.where("(transactions.seller_id = #{current_user.id} OR transactions.buyer_id = #{current_user.id}) \
    AND (transactions.status != 'Completed' AND transactions.status != 'Denied' AND transactions.status != 'Cancelled')")

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
