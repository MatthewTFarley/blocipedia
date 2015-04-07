class UserMailer < ApplicationMailer
  default from: 'hello@mtfarley-blocipedia.com'
  
  def confirmation_email(user)
    @user = user
    @url = confirm_url(@user, {confirmation_token: @user.confirmation_token})
    mail(to: @user.email, subject: 'Please confirm your account')
  end 
end
