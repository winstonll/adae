class RequestSentEmailJob < ActiveJob::Base
  queue_as :default

  def perform(transaction)
    @transaction = transaction
    ContactMailer.request_sent_email_job(@transaction).deliver_later
  end
end
