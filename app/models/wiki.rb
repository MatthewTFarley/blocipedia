class Wiki < ActiveRecord::Base
  extend FriendlyId
  after_initialize :initialize_privacy_level
  
  friendly_id :title, use: :slugged

  belongs_to :user
  has_many :collaborations, dependent: :destroy
  has_many :collaborators, through: :collaborations, source: :user
  
  validates :title, presence: true
  validates :body, length: { minimum: 10 }, presence: true
  validates :user, presence: true
  
  def markdown_title
    render_as_markdown title
  end

  def markdown_body
    render_as_markdown body
  end

  def self.public_wikis
    wikis = where(private:false)
    wikis.sort_by{|wiki| wiki.title.capitalize}
  end

  def add_collaborators user_ids
    return [] if user_ids.blank?
    sanitized_user_ids = user_ids.reject{|element| element.blank?}
    self.collaborators = User.find(sanitized_user_ids)
  end
  
  private

  def initialize_privacy_level
    self.private ||= false
  end
  
  def render_as_markdown(text)
    renderer = Redcarpet::Render::HTML.new
    extensions = {fenced_code_blocks: true}
    redcarpet = Redcarpet::Markdown.new(renderer, extensions)
    (redcarpet.render text).html_safe
  end
end