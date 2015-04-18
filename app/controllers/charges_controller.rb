class ChargesController < ApplicationController
  before_filter :authorize, :check_upgrade_authorization
  
  def new
    @stripe_btn_data = {
      key: "#{ Rails.configuration.stripe[:publishable_key] }",
      description: "Blocipedia Premium Membership - #{current_user.name}",
      amount: Amount.default
      }
  end
  
  def create
    customer = Stripe::Customer.create(
      email: current_user.email,
      card: params[:stripeToken]
      )

    charge = Stripe::Charge.create(
      customer: customer.id,
      amount: Amount.default,
      description: "Blocipedia Premium Membership - #{current_user.email}",
      currency: 'usd'
      )
    
    user = User.find(current_user.id)
    user.upgrade_account!
    
    if user.save
      flash.now[:success] = "You have successfully upgraded your account to premium!"
      redirect_to wikis_path
    else
      flash.now[:error] = "There was a problem upgrading your account. Please try again."
      render :new
    end

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path
  end
  
  class Amount
    def self.default
      15_00
    end
  end
end