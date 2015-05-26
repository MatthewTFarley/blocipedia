class Collaboration < ActiveRecord::Base
  belongs_to :user
  belongs_to :wiki

  def self.add_collaborators wiki, params, user
    if user.owns?(wiki)
      return [] if params[:wiki][:collaborators].blank?
      user_ids = params[:wiki][:collaborators].reject{|element| element.blank?}
      wiki.collaborators  = User.find(user_ids) # unless user_ids.empty  end, user
    else
      wiki.collaborators
    end
  end
end