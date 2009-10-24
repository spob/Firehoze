module GroupsHelper
  def show_join_link(group)
    if current_user
      if !group.private and !group.includes_member?(current_user)
        link_to "Join", group_members_path(:id => group.id), :method => :post
      end
    end
  end
end
