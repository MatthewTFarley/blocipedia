class UsersController < ApplicationController
  before_filter :authorize, only: [:edit, :update]
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    @user.confirmation_token = SecureRandom.hex(16)
    if @user.save
      flash[:notice] = "Welcome to Blocipedia #{@user.name}! Check your email for a link to confirm your account."
      UserMailer.confirmation_email(@user).deliver
      redirect_to root_url
    else
      flash[:error] = "Something went wrong. Please try again."
      render "edit"
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])

    if @user.update_attributes(user_params)
      flash[:notice] = "User profile was successfully updated."
      redirect_to root_path
    else
      flash[:error] = "Error saving profile changes. Please try again"
      render :edit
    end
  end
  
  def confirm
    @user = User.find(params[:id])
    
    if @user.confirmation_token == params[:confirmation_token]
      @user.confirmed_at = DateTime.now
      @user.save!
      flash[:notice] = "You have successfully confirmed your account!"
      session[:user_id] = @user.id
      redirect_to root_path
    else
      flash[:error] = "Incorrect confirmation token."
      redirect_to root_path
    end
  end
  
  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

end
