class User < ActiveRecord::Base
  after_initialize :initialize_role
  
  has_many :wikis, dependent: :destroy
  has_many :collaborations, dependent: :destroy
  has_many :collaborative_wikis, through: :collaborations, source: :wiki

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

  def view?(resource)
    admin? || owns?(resource) || !resource.private || resource.collaborators.includes(self)
  end
  
  def skip_confirmation!
    self.confirmed_at = DateTime.now
  end
  
  def upgrade_account!
    self.role = "premium" unless self.role == "admin"
    save!
  end
  
  def downgrade_account!
    ActiveRecord::Base.transaction do
      self.role = "standard" unless self.role == "admin"
      save!
      Wiki.publicize_wikis! self
    end
  end
  
  private
  
  def initialize_role
    self.role ||= 'standard'
  end
end