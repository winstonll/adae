class SendEmailJob < ActiveJob::Base
  queue_as :default

  def perform(user, message)
    @user = user
    @message = message
    ContactMailer.new_message(@user, @message).deliver_later
  end

  def review(buyer, seller, listing)
  	@buyer = buyer
    @seller = seller
    @listing = listing
    ContactMailer.review_prompt(@buyer, @seller, @listing).deliver_later
  end
end
