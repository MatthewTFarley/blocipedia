require 'rails_helper'

describe Wiki do
  it "lists public and private wikis for a normal user" do
    user = User.create! name: "john", email: "example@example.com", password: "helloworld", password_confirmation: "helloworld"
    
    private_wiki = Wiki.create! user: user, title: "This is a test wiki", body: "12345678912345678912345", private: true
    another_user = User.create! name: 'jane', email: "jane@example.com", password: "helloworld", password_confirmation: "helloworld"
    Wiki.create! user: another_user, title: "This is a test wiki", body: "12345678912345678912345", private: true
    public_wiki = Wiki.create! user: another_user, title: "This is a test wiki", body: "12345678912345678912345", private: false

    available_wikis = Wiki.available_wikis_for user
    
    expect(available_wikis).to eq [private_wiki, public_wiki]
  end
  
  it "lists only public wikis for unauthenticated users" do
    user = User.create! name: 'jane', email: "jane@example.com", password: "helloworld", password_confirmation: "helloworld"
    private_wiki = Wiki.create! user: user, title: "This is a test wiki", body: "12345678912345678912345", private: true
    public_wiki = Wiki.create! user: user, title: "This is a test wiki", body: "12345678912345678912345", private: false
    
    available_wikis = Wiki.available_wikis_for nil
    
    expect(available_wikis).to eq [public_wiki]
  end
    
end