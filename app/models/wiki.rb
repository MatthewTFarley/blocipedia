class Wiki < ActiveRecord::Base
  belongs_to :user
  
  validates :title, length: { minimum: 5 }, presence: true
  validates :body, length: { minimum: 20 }, presence: true
  validates :user, presence: true
  
  def markdown_title
    render_as_markdown title
  end

  def markdown_body
    render_as_markdown body
  end
  
  private
  
  def render_as_markdown(text)
    renderer = Redcarpet::Render::HTML.new
    extensions = {fenced_code_blocks: true}
    redcarpet = Redcarpet::Markdown.new(renderer, extensions)
    (redcarpet.render text).html_safe
  end
  
end
