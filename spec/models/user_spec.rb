require "rails_helper"

describe User do
    
  before do 
    @user = User.new name: "matt", email: "matt@example.com", password: "matt", password_confirmation: "matt"
    @user.skip_confirmation!
    @user.save!
  end

  it "should not be saved if email is a duplicate" do   
    expect(User.count).to eq 1
    
    another_user = User.new name: "matt", email: "matt@example.com", password: "matt", password_confirmation: "matt"
    another_user.skip_confirmation!
    expect{another_user.save!}.to raise_error(ActiveRecord::RecordInvalid)
    
    expect(User.count).to eq 1
  end
  
  it "should have role set to standard by default" do
    expect(@user.role).to eq "standard"
  end
  
  it "should have confirmed_at set when skip_confirmation! is run" do
    expect(@user.confirmed_at).not_to eq nil
  end
  
  describe "#upgrade_account!" do
    it "should change the user's role to 'premium'" do
      @user.upgrade_account!
      expect(@user.role).to eq 'premium'
    end
  end
    
  describe "#downgrade_account!" do
    it "should change the user's role to 'standard'" do
      @user.upgrade_account!
      expect(@user.role).to eq 'premium'
    end
  end
end