module UsersHelper
  def signin_or_signout_link
    if current_user
      "Greetings, #{current_user.login} (not #{signout_link(current_user.login)}?) #{signout_link("Sign Out")}"
    else
      "#{link_to "Sign In", login_path} | #{link_to "Register", new_registration_path}"
    end
  end

  def signout_link(string)
    link_to "#{string}", logout_path, :method => :delete
  end

  def link_to_profile(user)
    link_to_unless_current user.handle_or_name, user_path(user)
  end

  def avatar_tag(user, options = {})
    return unless user
    size = options[:size] || :medium
    avatar_url = user.avatar.file? ? user.avatar.url(size) : User.default_avatar_url(size)
    image_tag avatar_url, options.merge({ :alt => user.full_name, :class => 'avatar' })
  end
end
