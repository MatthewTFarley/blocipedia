module WikisHelper
  def private_checkbox_is_viewable?(wiki)
    !current_user.standard? && (current_user.owns?(wiki) || wiki.new_record?)
  end

  def collaborators_can_be_added?(wiki)
    !current_user.standard? && User.count > 1
  end

  def wiki_is_editable?(wiki)
    current_user && current_user.edit?(wiki)
  end
end
