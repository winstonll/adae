class ContactMailer < ActionMailer::Base

  default :from => "mail@adae.co"

  def contact_message(contact)
    @contact = contact
    mail(to: "winston@adae.co", :subject => "Adae.co #{contact.subject}")
  end

  def new_message(user, message)
    @user = user
    @message = message
    @other = User.find_by(id: @message.user_id)
    mail(to: @user.email, subject: 'You have a new message in your inbox!')
  end

  def cash_out(user, location)
  	@user = user
  	@location = location
  	mail(to: "winston@adae.co", :subject => "Adae Cash out Request for #{@user}")
  end

end