require 'rails_helper'

describe Wiki do
  describe "#add_collaborators" do
    before do
      @user1 = User.new name: "user1", email: "user1@email.com", password: "password"
      @user2 = User.new name: "user2", email: "user2@email.com", password: "password"
      @user3 = User.new name: "user3", email: "user3@email.com", password: "password"
      @user1.skip_confirmation!
      @user1.save
      @user2.skip_confirmation!
      @user2.save
      @user3.skip_confirmation!
      @user3.save

      @wiki = Wiki.create! title: "title", body: "This is the body", user: @user1
    end

    it "should add collaborators to a wiki if collaborators are passed in" do
      user_ids = [@user2.id, @user3.id]
      @wiki.add_collaborators user_ids
      expect(@wiki.collaborators.count).to eq 2
    end

    it "should not add collaborators to a wiki if no collaborators are passed in" do
      user_ids = []
      @wiki.add_collaborators user_ids
      expect(@wiki.collaborators.count).to eq 0
    end
  end
end