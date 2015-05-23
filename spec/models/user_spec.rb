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
    expect(another_user.errors).to be_added :email, :taken
    
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
      @user.update! role: "premium"
      @user.downgrade_account!
      expect(@user.role).to eq 'standard'
    end
  end

  describe "#viewable_wikis" do
    it "lists all public wikis and only user-owned private wikis" do
      user = User.create! name: "john", email: "example@example.com", password: "helloworld", password_confirmation: "helloworld", role: "premium"
      another_user = User.create! name: 'jane', email: "jane@example.com", password: "helloworld", password_confirmation: "helloworld", role: "premium"

      private_wiki = Wiki.create! user: user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      Wiki.create! user: another_user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      public_wiki = Wiki.create! user: another_user, title: "This is a test wiki", body: "12345678912345678912345", private: false
      owned_public_wiki = Wiki.create! user: user, title: "This is a test wiki", body: "12345678912345678912345", private: false

      available_wikis = user.viewable_wikis

      expect(available_wikis).to eq [public_wiki, owned_public_wiki, private_wiki]
    end
    
    it "lists all wikis for an admin user" do
      user = User.create! name: 'john', email: "john@example.com", password: "helloworld", password_confirmation: "helloworld", role: "admin"
      another_user = User.create! name: 'jane', email: "jane@example.com", password: "helloworld", password_confirmation: "helloworld"
      private_wiki_1 = Wiki.create! user: another_user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      private_wiki_2 = Wiki.create! user: another_user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      public_wiki_1 = Wiki.create! user: another_user, title: "This is a test wiki", body: "12345678912345678912345", private: false
      public_wiki_2 = Wiki.create! user: another_user, title: "This is a test wiki", body: "12345678912345678912345", private: false

      available_wikis = user.viewable_wikis

      expect(available_wikis).to eq Wiki.all
    end
  end

  describe "#publicize_wikis!" do
    it "finds the private wikis of the current user and sets private field to false" do
      private_wiki_1 = Wiki.create! user: @user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      private_wiki_2 = Wiki.create! user: @user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      private_wiki_3 = Wiki.create! user: @user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      another_user = User.create! name: 'jane', email: "jane@example.com", password: "helloworld", password_confirmation: "helloworld"
      Wiki.create! user: another_user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      
      @user.downgrade_account!
      
      expect(@user.wikis.all? {|wiki| !wiki.private}).to eq(true)
      expect(Wiki.where(private: true).count).to eq 1
    end
  end 
end