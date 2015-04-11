class User < ActiveRecord::Base
  after_initialize :initialize_role
  
  has_many :wikis, dependent: :destroy
  
  has_secure_password
  validates_presence_of :name, :email
  validates_uniqueness_of :email
  
  def standard?
    role == 'standard'
  end
  
  def premium?
    role == 'premium'
  end
  
  def admin?
    role == 'admin'
  end
  
  def role?
    self.role
  end
  
  def create?
    standard?
  end
  
  def edit?
    standard?
  end
  
  def owns?(resource)
    id == resource.user_id
  end
  
  def destroy?(resource)
    admin? || owns?(resource)
  end
  
  private
  
  def initialize_role
    self.role ||= 'standard'
  end
end