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

  def adaebot_message(user, message)
    @user = user
    @message = message
    mail(to: @user.email, subject: 'Hello! We have an update on your transaction.')
  end

  def signup_message(user)
    @user = user
    mail(to: "winston@adae.co", :subject => "Adae.co New Signup")
  end

  def system_message(user,recipient,listing)
    @user = user
    @listing = listing
    @recipient = recipient
    mail(to: @recipient.email, subject: 'Someone has replied to your Shout Out!')
  end

  def review_prompt(buyer, seller, listing)
    @buyer = buyer
    @seller = seller
    @listing = listing
    mail(to: @buyer.email, :subject => "Hello! Please Rate & Review #{@seller.full_name}.")
  end

end
