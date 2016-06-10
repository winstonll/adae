class ReviewPromptJob < ActiveJob::Base
  queue_as :default

  def perform(buyer, seller, listing)
    @buyer = buyer
    @seller = seller
    @listing = listing
    ContactMailer.review_prompt(@buyer, @seller, @listing).deliver_later
  end
end
