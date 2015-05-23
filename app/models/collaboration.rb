class Collaboration < ActiveRecord::Base
  belongs_to :user
  belongs_to :wiki

  def self.remove_collaborators wiki
    collaborators_to_remove = where(wiki_id: wiki)
    collaborators_to_remove.each do |collaboration|
      collaboration.destroy!
    end
  end

  def self.remove_single_collaborator wiki, user
    collaborator_to_remove = where(wiki: wiki, user: user)
    collaborator_to_remove.destroy!
  end

  def self.add_collaborators wiki, params
    return [] if params[:wiki][:collaborators].blank?
    user_ids = params[:wiki][:collaborators].reject{|element| element.blank?}
    wiki.collaborators  = User.find(user_ids) # unless user_ids.empty?
  end
end
