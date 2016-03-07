class ContactsController < ApplicationController

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)
    
    if @contact.valid?
      ContactMailer.new_message(@contact).deliver
      redirect_to(root_path, :notice => "Message was successfully sent.")
    else
      flash.now.alert = "Please fill all fields."
      render :new
    end
  end

  private
  	def contact_params
      params.require(:contact).permit(:name, :email, :subject, :content)
    end

end