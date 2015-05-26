require "rails_helper"

describe User do
    
  before do 
    @lonely_user = User.new name: "lonely", email: "lonely@lonely.com", password: "lonely", password_confirmation: "lonely"
    @lonely_user.skip_confirmation!
    @lonely_user.save!

    @user = User.new name: "matt", email: "matt@example.com", password: "matt", password_confirmation: "matt"
    @user.skip_confirmation!
    @user.save!

    @premium_user = User.new name: 'john', email: "john@example.com", password: "helloworld", password_confirmation: "helloworld", role: "premium"
    @premium_user.skip_confirmation!
    @premium_user.save!

    @admin_user = User.new name: 'jane', email: "jane@example.com", password: "helloworld", password_confirmation: "helloworld", role: "admin"
    @admin_user.skip_confirmation!
    @admin_user.save!

    @public_wiki = Wiki.create! user: @premium_user, title: "This is a test wiki", body: "12345678912345678912345", private: false

    @private_wiki = Wiki.create! user: @premium_user, title: "This is a test wiki", body: "12345678912345678912345", private: true
  end

  it "should not be saved if email is a duplicate" do   
    expect(User.count).to eq 4
    
    another_user = User.new name: "matt", email: "matt@example.com", password: "matt", password_confirmation: "matt"
    another_user.skip_confirmation!
    expect{another_user.save!}.to raise_error(ActiveRecord::RecordInvalid)
    expect(another_user.errors).to be_added :email, :taken
    
    expect(User.count).to eq 4
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
      owned_public_wiki = Wiki.create! user: @premium_user, title: "This is a test wiki", body: "12345678912345678912345", private: false

      available_wikis = @premium_user.viewable_wikis

      expect(available_wikis).to eq [@public_wiki, owned_public_wiki, @private_wiki]
    end
    
    it "lists all wikis for an admin user" do
      private_wiki_1 = Wiki.create! user: @premium_user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      private_wiki_2 = Wiki.create! user: @premium_user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      public_wiki_1 = Wiki.create! user: @premium_user, title: "This is a test wiki", body: "12345678912345678912345", private: false
      public_wiki_2 = Wiki.create! user: @premium_user, title: "This is a test wiki", body: "12345678912345678912345", private: false

      available_wikis = @admin_user.viewable_wikis

      expect(available_wikis).to eq Wiki.all
    end
  end

  describe "#publicize_wikis!" do
    it "finds the private wikis of the current user and sets private field to false" do
      # private_wiki_1 = Wiki.create! user: @user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      private_wiki_2 = Wiki.create! user: @premium_user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      private_wiki_3 = Wiki.create! user: @premium_user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      private_wiki_4 = Wiki.create! user: @admin_user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      
      @premium_user.downgrade_account!
      
      expect(@premium_user.wikis.all? {|wiki| wiki.private}).to eq(false)
      expect(Wiki.where(private: false).count).to eq 4
      expect(Wiki.where(private: true).count).to eq 1
    end
  end

  describe "#standard?" do
    it "should return 'true' if user.role is 'standard'" do
      expect(@user.standard?).to eq(true)
    end

    it "should return 'false' if user.role is not 'standard'" do
      expect(@premium_user.standard?).to eq(false)
      expect(@admin_user.standard?).to eq(false)
    end
  end

  describe "#premium?" do
    it "should return 'true' if user.role is 'premium'" do
      expect(@premium_user.premium?).to eq(true)
    end

    it "should return 'false' if user.role is not 'premium'" do
      expect(@user.premium?).to eq(false)
      expect(@admin_user.premium?).to eq(false)
    end
  end

  describe "#admin?" do
    it "should return 'true' if user.role is 'admin'" do
      expect(@admin_user.admin?).to eq(true)
    end

    it "should return 'false' if user.role is not 'admin'" do
      expect(@user.admin?).to eq(false)
      expect(@premium_user.admin?).to eq(false)
    end
  end

  describe "#create?" do
    it "should return 'true' if user.role? is 'standard', 'premium', or 'admin'" do
      expect(@user.create?).to eq(true)
      expect(@premium_user.create?).to eq(true)
      expect(@admin_user.create?).to eq(true)
    end
  end

  describe "#collaborator?" do
    it "should return 'true' if a user is a collaborator on a given wiki" do
      @private_wiki.collaborators = [@user]
      expect(@user.collaborator?(@private_wiki)).to eq(true)
    end
  end

  describe "#owns" do
    it "should return 'true' if the user owns a given wiki" do
      expect(@premium_user.owns?(@private_wiki)).to eq(true)
      expect(@lonely_user.owns?(@private_wiki)).to eq(false)
    end
  end

  describe "#edit?" do
    it "should return 'true' if a user has permission to edit a given wiki" do
      @private_wiki.collaborators = [@user]
      expect(@user.edit?(@private_wiki)).to eq(true)
      expect(@premium_user.edit?(@private_wiki)).to eq(true)
      expect(@admin_user.edit?(@private_wiki)).to eq(true)
      expect(@lonely_user.edit?(@private_wiki)).to eq(false)
    end
  end

  describe "#destroy?" do
    it "should return 'true' if the user has permission to destroy a given wiki" do
      expect(@premium_user.destroy?(@private_wiki)).to eq(true)
      expect(@admin_user.destroy?(@private)).to eq(true)
      expect(@lonely_user.destroy?(@private_wiki)).to eq(false)
    end
  end

  describe "#view?" do
    it "should return 'true' if a user has permission to view a given wiki" do
      @private_wiki.collaborators = [@user]
      expect(@premium_user.view?(@private_wiki)).to eq(true)
      expect(@admin_user.view?(@private_wiki)).to eq(true)
      expect(@user.view?(@private_wiki)).to eq(true)
      expect(@lonely_user.view?(@private_wiki)).to eq(false)
      expect(@lonely_user.view?(@public_wiki)).to eq(true)
    end
  end
end