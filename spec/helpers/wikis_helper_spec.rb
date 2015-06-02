require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the WikisHelper. For example:
#
# describe WikisHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end

RSpec.describe WikisHelper, :type => :helper do
  before do
    @standard_user = User.new name: "matt", email: "matt@example.com", password: "matt", password_confirmation: "matt", role: "standard"
    @standard_user.skip_confirmation!
    @standard_user.save!


    @premium_user = User.new name: "john", email: "john@example.com", password: "john", password_confirmation: "john", role: "premium"
    @premium_user.skip_confirmation!
    @premium_user.save!

    @public_wiki = Wiki.create! user: @standard_user, title: "This is a test wiki", body: "12345678912345678912345", private: false

    @private_wiki = Wiki.create! user: @premium_user, title: "This is a test wiki", body: "12345678912345678912345", private: true
    
    @new_wiki = Wiki.new
  end

  describe "private_checkbox_is_available?" do
    it "should return 'true' if a user has permission to see the private checkbox" do
      current_user = @standard_user
      helper.class.send(:define_method, :current_user, -> {current_user})

      expect(helper.private_checkbox_is_available?(@public_wiki)).to eq(false) # false becasue user is standard
      expect(helper.private_checkbox_is_available?(@new_wiki)).to eq(false)

      current_user = @premium_user
      helper.class.send(:define_method, :current_user, -> {current_user})

      expect(helper.private_checkbox_is_available?(@private_wiki)).to eq(true) # true because user is premium
      expect(helper.private_checkbox_is_available?(@new_wiki)).to eq(true)
    end
  end

  describe "collaborators_can_be_added?" do
    it "should return 'true if a user has permission to add collaborators to a given wiki" do
      current_user = @standard_user
      helper.class.send(:define_method, :current_user, -> {current_user})

      expect(helper.collaborators_can_be_added?(@private_wiki)).to eq(false)  # false because user is standard

      current_user = @premium_user
      helper.class.send(:define_method, :current_user, -> {current_user})

      expect(helper.collaborators_can_be_added?(@public_wiki)).to eq(true) # true because user is premium
      expect(helper.collaborators_can_be_added?(@private_wiki)).to eq(true) # true because wiki is new & user is premium

      @standard_user.destroy!

      expect(helper.collaborators_can_be_added?(@private_wiki)).to eq(false) # false because Users.all < 1
    end
  end

  describe "wiki_is_editable?" do
    it "should return 'true' if a user is signed in and has edit permission" do
      current_user = @standard_user
      helper.class.send(:define_method, :current_user, -> {current_user})

      expect(helper.wiki_is_editable?(@public_wiki)).to eq(true)    # true because current user owns wiki
      expect(helper.wiki_is_editable?(@private_wiki)).to eq(false)  # false becasue current user does not own wiki

      current_user = nil
      helper.class.send(:define_method, :current_user, -> {current_user})

      expect(helper.wiki_is_editable?(@private_wiki)).to eq(nil)  # nil becasue user is not signed in
    end
  end
end
