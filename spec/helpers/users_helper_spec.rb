require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the UsersHelper. For example:
#
# describe UsersHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe UsersHelper, :type => :helper do
  it "collects user name and user id of potential collaborators" do
    current_user = User.create! name: "matt", email: "matt@example.com", password: "matt", password_confirmation: "matt"
    user2 = User.create! name: "john", email: "john@example.com", password: "john", password_confirmation: "john"

    helper.class.send(:define_method, :current_user, -> {current_user})

    collaborator_list = helper.collaborator_select_list

    expect(collaborator_list).to eq([[user2.name, user2.id]])
  end
end
