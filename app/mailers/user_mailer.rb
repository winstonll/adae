class UserMailer < ActionMailer::Base
  default from: "mail@adae.com"

  def signup_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to Adae!')
  end

  def forgot_password_email(user)
    @user = user
    mail(to: @user.email, subject: 'Reset your password')
  end

  def inactive_email(user)
    update_last_emailed_at(user)
    mail(to: user.email, subject: "We miss you!")
  end

  def user_submission_accepted_email(user)
    @user                 = user
    @question_name        = submit_question_data.title
    @wants_subscription   = submit_question_data.wants_subscription
    @points_for_approval  = 5
    mail(to: '#{user.email}', subject: 'Congrats, your item got approved!')
  end

  def referred_user_email(user_who_referred, user_who_signed_up)
    @registered_user     = user_who_referred
    @new_user            = user_who_signed_up
    @points_for_referral = 5
    mail(to: @registered_user.email, subject: "Congrats! You\ve gained <%= @points_for_referral %> points!")
  end

  protected
    def update_last_emailed_at(user)
      user.last_emailed_at = Time.now
      user.save
    end
end
