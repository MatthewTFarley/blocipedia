module UsersHelper
  def potential_collaborator_list
    ineligible_users = @wiki.collaborators.map {|collaborator| collaborator.id}
    ineligible_users << current_user.id
    eligible_users = User.where('id not in (?)', ineligible_users).order(:name)
    eligible_users.collect{|user| [user.name, user.id]}
  end
end
