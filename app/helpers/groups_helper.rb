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
    if group_member.group.private
      if group_member.group.owned_by?(current_user) or
              (group_member.group.moderated_by?(current_user) and
                      (group_member.member_type == MEMBER or group_member.member_type == PENDING))
        link_to "Remove", remove_group_member_path(group_member), :method => :delete, :confirm => "Are you sure?"
      end
    end
  end
end