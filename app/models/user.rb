class User < ActiveRecord::Base
  has_secure_password
  validates_presence_of :name, :email, :password, :password_confirmation
  validates_uniqueness_of :name, :email

end
