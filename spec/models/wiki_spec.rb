require 'rails_helper'

describe Wiki do
  describe "#viewable_wikis" do
    it "lists all public wikis and only user-owned private wikis to that user" do
      user = User.create! name: "john", email: "example@example.com", password: "helloworld", password_confirmation: "helloworld", role: "premium"
      another_user = User.create! name: 'jane', email: "jane@example.com", password: "helloworld", password_confirmation: "helloworld", role: "premium"

      private_wiki = Wiki.create! user: user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      Wiki.create! user: another_user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      public_wiki = Wiki.create! user: another_user, title: "This is a test wiki", body: "12345678912345678912345", private: false
      owned_public_wiki = Wiki.create! user: user, title: "This is a test wiki", body: "12345678912345678912345", private: false

      available_wikis = Wiki.viewable_wikis user

      expect(available_wikis).to eq [public_wiki, owned_public_wiki, private_wiki]
    end

    it "lists only public wikis for unauthenticated users" do
      user = User.create! name: 'jane', email: "jane@example.com", password: "helloworld", password_confirmation: "helloworld"
      private_wiki = Wiki.create! user: user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      public_wiki = Wiki.create! user: user, title: "This is a test wiki", body: "12345678912345678912345", private: false

      available_wikis = Wiki.viewable_wikis nil

      expect(available_wikis).to eq [public_wiki]
    end
    
    it "lists all wikis for an admin user" do
      user = User.create! name: 'john', email: "john@example.com", password: "helloworld", password_confirmation: "helloworld", role: "admin"
      another_user = User.create! name: 'jane', email: "jane@example.com", password: "helloworld", password_confirmation: "helloworld"
      private_wiki_1 = Wiki.create! user: another_user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      private_wiki_2 = Wiki.create! user: another_user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      public_wiki_1 = Wiki.create! user: another_user, title: "This is a test wiki", body: "12345678912345678912345", private: false
      public_wiki_2 = Wiki.create! user: another_user, title: "This is a test wiki", body: "12345678912345678912345", private: false

      available_wikis = Wiki.viewable_wikis user

      expect(available_wikis).to eq Wiki.all
    end
  end
  
  describe "#publicize_wikis!" do
    it "finds the private wikis of the current user and sets private field to false" do
      user = User.create! name: "matt", email: "matt@example.com", password: "matt", password_confirmation: "matt"
      private_wiki_1 = Wiki.create! user: user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      private_wiki_2 = Wiki.create! user: user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      private_wiki_3 = Wiki.create! user: user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      another_user = User.create! name: 'jane', email: "jane@example.com", password: "helloworld", password_confirmation: "helloworld"
      Wiki.create! user: another_user, title: "This is a test wiki", body: "12345678912345678912345", private: true
      
      user.downgrade_account!
      
      expect(user.wikis.all? {|wiki| !wiki.private}).to eq(true)
      expect(Wiki.where(private: true).count).to eq 1
    end
  end 
end