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
end
