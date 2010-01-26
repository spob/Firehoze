module GroupsHelper
  def show_join_link(group, user)
    if !group.private and !group.includes_member?(user)
      link_to content_tag(:span, 'Join'), group_members_path(:id => group.id), :method => :post, :class => :minibutton
    end
  end

  def show_leave_link(group, user)
    group_member = group.includes_member?(user)
    if group_member and group_member.member_type != OWNER
      link_to content_tag(:span, "Leave Group"), group_member_path(group.id), :method => :delete, :class => :minibutton
    end
  end

  def show_invite_link(group, user)
    if group.private and (group.owned_by?(user) or group.moderated_by?(user))
      link_to content_tag(:span, "Invite a User"), new_group_invitation_path(:id => group), :class => :minibutton
    end
  end

  def show_remove_link(group_member, user)
    if group_member.group.private and group_member.can_edit?(user)
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

  def show_edit_link(group, user)
    if group.owned_by?(user)
      link_to content_tag(:span, "Edit"), edit_group_path(group), :class => :minibutton
    end
  end

  def show_membership_text(group, user)
    if group.owned_by?(user)
      "#{image_tag 'icons/key_16.png'} You are the owner of this group"
    elsif group.moderated_by?(user)
      "#{image_tag 'icons/shield_16.png'} You are the moderator of this group"
    elsif group.includes_member?(user)
      "#{image_tag 'icons/16-check.png'} You are a member of this group"
    elsif user.nil?
      "You are not logged in"
    else
      "#{image_tag 'icons/block_16.png'} You are not a member of this group"
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