class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :confirm]
  before_action :authenticate_user, only: [:edit, :update]

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
      render "new"
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:notice] = "User profile was successfully updated."
      redirect_to wikis_path
    else
      flash[:error] = "Error saving profile changes. Please try again."
      render :edit
    end
  end
  
  def confirm    
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
  
  def downgrade
    @user = current_user
    if @user.downgrade_account!
      flash.now[:success] = "Your account was successfully downgraded."
      redirect_to wikis_path
    else
      flash.now[:error] = "There was an error downgrading your account. Please try again."
      render :edit
    end
  end
  
  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
