class ContactMailer < ActionMailer::Base

  default :from => "noreply@adae.co"
  default :to => "ruavilaa@gmail.com"

  def new_message(contact)
    @contact = contact
    mail(:subject => "[Adae.tld] #{contact.subject}")
  end

end