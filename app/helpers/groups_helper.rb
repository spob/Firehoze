module GroupsHelper
  def show_join_link(group)
    if !group.private and !group.includes_member?(current_user)
      link_to "Join", group_members_path(:id => group.id), :method => :post
    end
  end

  def show_leave_link(group)
    group_member = group.includes_member?(current_user)
    if group_member and group_member.member_type != OWNER
      link_to "Leave Group", group_member_path(group.id), :method => :delete
    end
  end

  def show_invite_link(group)
    if group.private and (group.owned_by?(current_user) or group.moderated_by(current_user))
      link_to "Invite a User", new_group_invitation_path(:id => group)
    end
  end
end