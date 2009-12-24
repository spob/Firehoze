module GroupsHelper
  def show_join_link(group)
    if !group.private and !group.includes_member?(current_user)
      link_to "Join", group_members_path(:id => group.id), :method => :post, :class => :rounded
    end
  end

  def show_leave_link(group)
    group_member = group.includes_member?(current_user)
    if group_member and group_member.member_type != OWNER
      link_to "Leave Group", group_member_path(group.id), :method => :delete, :class => :rounded
    end
  end

  def show_invite_link(group)
    if group.private and (group.owned_by?(current_user) or group.moderated_by?(current_user))
      link_to "Invite a User", new_group_invitation_path(:id => group), :class => :rounded
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
      link_to "Edit", edit_group_path(group), :class => :rounded
    end
  end

  def show_membership_text(group)
    if group.owned_by?(current_user)
      "You are the owner of this group"
    elsif group.moderated_by?(current_user)
      "You are the moderator of this group"
    elsif group.includes_member?(current_user)
      "You are a member of this group"
    elsif current_user.nil?
      "You are not logged in"
    else
      "You are a #{member_type.downcase} of this group"
    end
  end

  def logo_tag(group, options = {})
    return unless group
    size = options[:size] || :medium
    logo_url = group.logo.file? ? group.logo.url(size) : Group.default_logo_url(size)
    cdn_logo_url = Group.convert_logo_url_to_cdn(logo_url)
    image_tag cdn_logo_url, options.merge({ :alt => h(group.name), :class => 'logo' })
  end

end