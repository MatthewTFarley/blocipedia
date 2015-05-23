module UsersHelper
  def collaborator_select_list
    eligible_users = User.where('id <> ?', current_user.id).order(:name)
    eligible_users.collect{|user| [user.name, user.id]}
  end

  def collaborator_list
    collaborators = @wiki.collaborations.map { |collaboration| collaboration.user.name }
  end 
end
