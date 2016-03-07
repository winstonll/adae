class ContactMailer < ActionMailer::Base

  default :from => "mail@adae.co"
  default :to => "winston@adae.co"

  def new_message(contact)
    @contact = contact
    mail(:subject => "Adae.co #{contact.subject}")
  end

end