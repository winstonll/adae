class ContactsController < ApplicationController

  def new
    @contact = Contact.new
  end

  def create
    if !verify_recaptcha
      redirect_to :back
      flash[:warning] = "Please verify that you are not a bot"
      return
    end
    
    @contact = Contact.new(contact_params)
    if @contact.valid?
      ContactMailer.contact_message(@contact).deliver_now
      flash[:notice] = "Message was successfully sent."
      redirect_to root_path
    else
      flash[:warning] = "Please fill all fields correctly."
      render :new
    end
  end

  private
  	def contact_params
      params.require(:contact).permit(:name, :email, :subject, :content)
    end

end