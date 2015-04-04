class UserMailer < ApplicationMailer
  default from: 'hello@blocipedia.com'
  
  def confirmation_email(user)
    @user = user
    @url = confirm_path(@user, @user.confirmation_token)
    mail(to: @user.email, subject: 'Please confirm your account')
  end 
end
