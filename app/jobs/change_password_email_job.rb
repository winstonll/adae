class ChangePasswordEmailJob < ActiveJob::Base
  queue_as :default

  def perform(user, pass)
    @user = user
    @pass = pass
    ContactMailer.change_password(@user, @pass).deliver_later
  end
end
