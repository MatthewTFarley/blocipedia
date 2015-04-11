require 'faker'

# Create Users
5.times do
  user = User.new(
    name:      Faker::Name.name,
    email:     Faker::Internet.email,
    password:  "helloworld"
    )
  user.skip_confirmation!
  user.save!
end
users = User.all

# Create Wikis
users.each do |element|
  wiki = Wiki.create!(
    user:        element,
    title:       Faker::Lorem.words(2).join(" "),
    body:        Faker::Lorem.paragraph,
    created_at:  DateTime.now,
    private:     false
    )
end
Wikis = Wiki.all

# Create a standard user
standard_user = User.new(
  name:     'Standard User',
  email:    'standard_user@example.com',
  password: 'helloworld',
  )
standard_user.skip_confirmation!
standard_user.save!

# Create my own account
matt = User.new(
  name:     'Matthew T Farley',
  email:    'matthewthomasfarley@gmail.com',
  password: 'helloworld',
  role:     'admin'
  )
matt.skip_confirmation!
matt.save!

puts "Seed finished"
puts "#{User.count} users created"
puts "#{Wiki.count} wikis created"