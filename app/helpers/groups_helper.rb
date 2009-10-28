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
    if group.private and (group.owned_by?(current_user) or group.moderated_by?(current_user))
      link_to "Invite a User", new_group_invitation_path(:id => group)
    end
  end

  def show_remove_link(group_member)
    if group_member.group.private and group_member.can_edit?(current_user)
      link_to "Remove", remove_group_member_path(group_member), :method => :delete, :confirm => "Are you sure?"
    end
  end

  def show_promote_demote_link(group_member)
    if group_member.group.owned_by?(current_user)
      if group_member.member_type == MEMBER
      link_to "Promote to Moderator", promote_group_member_path(group_member), :method => :post
      elsif group_member.member_type == MODERATOR
      link_to "Demote", demote_group_member_path(group_member), :method => :post
      end
    end
  end

  def show_edit_link(group)
    if group.owned_by?(current_user)
      link_to "Edit", edit_group_path(group)
    end
  end
end