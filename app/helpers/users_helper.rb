module UsersHelper
  def potential_collaborator_list
    users = User.where('id <> ? AND id <> [?]', current_user.id, @wiki.users.each {|user| user.id}).order(:name)
    users.collect{|user| [user.name, user.id]}
  end
end
