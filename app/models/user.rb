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
    standard? || premium? || admin?
  end
  
  def owns?(wiki)
    id == wiki.user_id
  end

  def confirmed?
    return false if self.confirmed_at.blank?
    true
  end

  def collaborator?(wiki)
    collaborative_wikis.include?(wiki)
  end
  
  def edit?(wiki)
    owns?(wiki) || collaborator?(wiki) || admin?
  end
  
  def destroy?(wiki)
    admin? || owns?(wiki)
  end

  def view?(wiki)
    admin? || owns?(wiki) || !wiki.private || collaborator?(wiki)
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
      self.publicize_wikis!
    end
  end

  def privately_owned_wikis
    self.wikis.where(private: true)
  end

  def viewable_wikis
    wikis = if self.admin?
      Wiki.all
    else
      wikis = Wiki.public_wikis + self.privately_owned_wikis + self.collaborative_wikis
      wikis.uniq
    end
    wikis.sort_by{ |wiki| wiki.title.capitalize }
  end

  def publicize_wikis!
    wikis_to_publicize = self.wikis.where(private:true)
    wikis_to_publicize.each do |wiki|
      wiki.collaborations.each { |collaboration| collaboration.destroy! }
      wiki.update! private: false
    end
  end
  
  private
  
  def initialize_role
    self.role ||= 'standard'
  end
end