module UsersHelper
  def follow_link user
    if current_user
      if user.followed_by?(current_user)
        link_to "Stop Following", instructor_follow_path(user), :method => :delete
      elsif user.verified_instructor? and user != current_user
        link_to "Follow this instructor", instructor_follows_path(:id => user), :method => :post
      end
    end
  end

  def signin_or_signout_link
    if current_user
      "Greetings, #{h(current_user.login)} (not #{signout_link(h(current_user.login))}?) #{signout_link("Sign Out")}"
    else
      "#{link_to "Sign In", login_path} | #{link_to "Sign Up", new_registration_path}"
    end
  end

  def show_bio
    unless @user.bio.blank?
      if @user.rejected_bio
        "<i>" + t('user.rejected_bio') + "</i>"
      else
        @user.bio
      end
    end
  end

  def signout_link(string)
    link_to "#{string}", logout_path, :method => :delete
  end

  def avatar_tag(user, options = {})
    return unless user
    size = options[:size] || :medium
    avatar_url = user.avatar.file? ? user.avatar.url(size) : User.default_avatar_url(size)
    cdn_avatar_url = User.convert_avatar_url_to_cdn(avatar_url)
    image_tag cdn_avatar_url, options.merge({ :alt => h(user.full_name), :class => 'avatar' })
  end

  def payment_levels_for_select
    PaymentLevel.ascend_by_name.collect { |m| [m.name, m.id] }
  end

  def possessive_helper word
    word + "'" + (word.end_with?("s") ? "" : "s")
  end
end