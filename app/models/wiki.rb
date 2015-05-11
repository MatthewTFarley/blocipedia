class Wiki < ActiveRecord::Base
  belongs_to :user
  has_many :collaborations, dependent: :destroy
  has_many :users, through: :collaborations, dependent: :destroy

  
  validates :title, length: { minimum: 5 }, presence: true
  validates :body, length: { minimum: 10 }, presence: true
  validates :user, presence: true
  
  def markdown_title
    render_as_markdown title
  end

  def markdown_body
    render_as_markdown body
  end

  def self.available_wikis_for user
    return public_wikis if user.blank?
    return all if user.admin?
    
    public_wikis + where(user:user, private:true)
  end
  
  def self.public_wikis
    where(private:false)
  end
  
  def self.publicize_wikis! user
    wikis_to_publicize = where(user:user).where(private:true)
    wikis_to_publicize.each do |wiki|
      wiki.update! private: false
    end
  end
  
  private
  
  def render_as_markdown(text)
    renderer = Redcarpet::Render::HTML.new
    extensions = {fenced_code_blocks: true}
    redcarpet = Redcarpet::Markdown.new(renderer, extensions)
    (redcarpet.render text).html_safe
  end
end