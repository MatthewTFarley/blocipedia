module UsersHelper
  def potential_collaborator_list
    users = User.order(:name)
    user_names = users.map do |user|
      next if user.name == current_user.name
      user.name
    end
    user_names.insert(0, user_names.delete(nil))
  end
end
