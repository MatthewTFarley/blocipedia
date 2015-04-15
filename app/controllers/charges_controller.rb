class ChargesController < ApplicationController
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

    # Where the real magic happens
    charge = Stripe::Charge.create(
      customer: customer.id,
      amount: Amount.default,
      description: "Blocipedia Premium Membership - #{current_user.email}",
      currency: 'usd'
      )

    flash[:success] = "You have successfully upgraded your account to premium status!"
    redirect_to wikis_path

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