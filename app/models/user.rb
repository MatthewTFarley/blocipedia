class User < ActiveRecord::Base
  validate :length_of_password, on: :create
  
  has_secure_password
  validates_presence_of :name, :email
  validates_uniqueness_of :email
  
  private
  
  def length_of_password
    if password.length < 5
      errors.add :password, "Password must be 5 characters or longer."
    end
  end  
end