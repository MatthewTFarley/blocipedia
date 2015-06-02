class SessionsController < ApplicationController
  def new
  end
    
  def create
    user = User.find_by_email(params[:email])

    unless user && user.authenticate(params[:password])
      flash.now.alert = "Email or password is invalid"
      return render "new"
    end

    if user.confirmed?
      session[:user_id] = user.id
      redirect_to wikis_path, notice: "Welcome #{user.name}!"
    else
      flash.now.alert = "Please confirm your account by checking your email for a confirmation link."
      render "new"
    end
  end
   
  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Signed out!"
  end
end
